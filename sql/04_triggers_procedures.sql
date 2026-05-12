-- ============================================================
-- ArtConnect Pro - Triggers & Stored Programs
-- Step 3.3: Triggers, Stored Procedures, and Functions
-- ============================================================

USE artconnect;

-- Change delimiter for multi-statement objects
DELIMITER $$

-- ============================================================
-- TRIGGERS (minimum 3 required)
-- ============================================================

-- TRIGGER 1: trg_check_exhibition_dates
-- Purpose: Ensure that a new or updated exhibition always has
--          end_date >= start_date (date consistency).
DROP TRIGGER IF EXISTS trg_check_exhibition_dates$$
CREATE TRIGGER trg_check_exhibition_dates
BEFORE INSERT ON exhibitions
FOR EACH ROW
BEGIN
    IF NEW.end_date < NEW.start_date THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Exhibition end_date cannot be before start_date.';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_check_exhibition_dates_update$$
CREATE TRIGGER trg_check_exhibition_dates_update
BEFORE UPDATE ON exhibitions
FOR EACH ROW
BEGIN
    IF NEW.end_date < NEW.start_date THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Exhibition end_date cannot be before start_date.';
    END IF;
END$$

-- TRIGGER 2: trg_check_workshop_capacity
-- Purpose: Prevent a new booking if the workshop is already full
--          (seat capacity check).
DROP TRIGGER IF EXISTS trg_check_workshop_capacity$$
CREATE TRIGGER trg_check_workshop_capacity
BEFORE INSERT ON bookings
FOR EACH ROW
BEGIN
    DECLARE current_bookings INT;
    DECLARE max_cap INT;

    SELECT COUNT(*) INTO current_bookings
    FROM bookings
    WHERE workshop_id = NEW.workshop_id
      AND payment_status != 'CANCELLED';

    SELECT max_participants INTO max_cap
    FROM workshops
    WHERE workshop_id = NEW.workshop_id;

    IF current_bookings >= max_cap THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Workshop is fully booked. No seats available.';
    END IF;
END$$

-- TRIGGER 3: trg_audit_booking_cancellation
-- Purpose: Audit log — record whenever a booking is cancelled
--          (event modification tracking).
CREATE TABLE IF NOT EXISTS booking_audit_log (
    log_id       INT AUTO_INCREMENT PRIMARY KEY,
    booking_id   INT,
    workshop_id  INT,
    member_id    INT,
    old_status   VARCHAR(20),
    new_status   VARCHAR(20),
    changed_at   DATETIME DEFAULT CURRENT_TIMESTAMP
)$$

DROP TRIGGER IF EXISTS trg_audit_booking_cancellation$$
CREATE TRIGGER trg_audit_booking_cancellation
AFTER UPDATE ON bookings
FOR EACH ROW
BEGIN
    IF OLD.payment_status != NEW.payment_status THEN
        INSERT INTO booking_audit_log
            (booking_id, workshop_id, member_id, old_status, new_status, changed_at)
        VALUES
            (OLD.booking_id, OLD.workshop_id, OLD.member_id,
             OLD.payment_status, NEW.payment_status, NOW());
    END IF;
END$$

-- TRIGGER 4: trg_validate_review_rating
-- Purpose: Ensure review rating stays within the range [1, 5].
DROP TRIGGER IF EXISTS trg_validate_review_rating$$
CREATE TRIGGER trg_validate_review_rating
BEFORE INSERT ON reviews
FOR EACH ROW
BEGIN
    IF NEW.rating < 1 OR NEW.rating > 5 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Review rating must be between 1 and 5.';
    END IF;
END$$

-- TRIGGER 5: trg_auto_update_artwork_status
-- Purpose: Automatically mark an artwork as EXHIBITED when it
--          is added to an exhibition.
DROP TRIGGER IF EXISTS trg_auto_update_artwork_status$$
CREATE TRIGGER trg_auto_update_artwork_status
AFTER INSERT ON exhibition_artworks
FOR EACH ROW
BEGIN
    UPDATE artworks
    SET status = 'EXHIBITED'
    WHERE artwork_id = NEW.artwork_id
      AND status = 'FOR_SALE';
END$$

-- ============================================================
-- STORED PROCEDURES (minimum 3 required)
-- ============================================================

-- PROCEDURE 1: sp_create_workshop_with_artist
-- Purpose: Create a workshop and automatically verify/register
--          the instructor as an active artist (common operation).
DROP PROCEDURE IF EXISTS sp_create_workshop_with_artist$$
CREATE PROCEDURE sp_create_workshop_with_artist(
    IN p_title           VARCHAR(200),
    IN p_date            DATETIME,
    IN p_duration        INT,
    IN p_max_participants INT,
    IN p_price           DECIMAL(8,2),
    IN p_artist_id       INT,
    IN p_location        VARCHAR(255),
    IN p_description     TEXT,
    IN p_level           VARCHAR(20)
)
BEGIN
    DECLARE artist_exists INT;

    -- Verify the artist exists and is active
    SELECT COUNT(*) INTO artist_exists
    FROM artists
    WHERE artist_id = p_artist_id AND is_active = TRUE;

    IF artist_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Instructor does not exist or is not active.';
    END IF;

    -- Insert the workshop
    INSERT INTO workshops
        (title, workshop_date, duration_minutes, max_participants,
         price, instructor_id, location, description, level)
    VALUES
        (p_title, p_date, p_duration, p_max_participants,
         p_price, p_artist_id, p_location, p_description, p_level);

    SELECT LAST_INSERT_ID() AS new_workshop_id;
END$$

-- PROCEDURE 2: sp_register_member_for_workshop
-- Purpose: Register a member for a workshop in a single call,
--          with built-in existence checks.
DROP PROCEDURE IF EXISTS sp_register_member_for_workshop$$
CREATE PROCEDURE sp_register_member_for_workshop(
    IN p_member_id   INT,
    IN p_workshop_id INT
)
BEGIN
    DECLARE member_ok  INT;
    DECLARE workshop_ok INT;

    SELECT COUNT(*) INTO member_ok FROM community_members WHERE member_id = p_member_id;
    SELECT COUNT(*) INTO workshop_ok FROM workshops WHERE workshop_id = p_workshop_id;

    IF member_ok = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Member not found.';
    END IF;

    IF workshop_ok = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Workshop not found.';
    END IF;

    -- The capacity trigger will fire automatically
    INSERT INTO bookings (workshop_id, member_id, payment_status)
    VALUES (p_workshop_id, p_member_id, 'PENDING');

    SELECT 'Booking created successfully.' AS message;
END$$

-- PROCEDURE 3: sp_get_artist_statistics
-- Purpose: Return aggregated statistics for a given artist
--          (number of artworks, exhibitions, workshops, avg price).
DROP PROCEDURE IF EXISTS sp_get_artist_statistics$$
CREATE PROCEDURE sp_get_artist_statistics(IN p_artist_id INT)
BEGIN
    SELECT
        a.name                          AS artist_name,
        COUNT(DISTINCT aw.artwork_id)   AS total_artworks,
        SUM(CASE WHEN aw.status='FOR_SALE' THEN 1 ELSE 0 END) AS artworks_for_sale,
        SUM(CASE WHEN aw.status='SOLD'     THEN 1 ELSE 0 END) AS artworks_sold,
        SUM(CASE WHEN aw.status='EXHIBITED' THEN 1 ELSE 0 END) AS artworks_exhibited,
        AVG(aw.price)                   AS avg_artwork_price,
        COUNT(DISTINCT ea.exhibition_id) AS exhibitions_participated,
        COUNT(DISTINCT w.workshop_id)   AS workshops_taught
    FROM artists a
    LEFT JOIN artworks aw         ON aw.artist_id      = a.artist_id
    LEFT JOIN exhibition_artworks ea ON ea.artwork_id  = aw.artwork_id
    LEFT JOIN workshops w         ON w.instructor_id   = a.artist_id
    WHERE a.artist_id = p_artist_id
    GROUP BY a.artist_id, a.name;
END$$

-- PROCEDURE 4: sp_cancel_booking
-- Purpose: Cancel a specific booking and update payment status.
DROP PROCEDURE IF EXISTS sp_cancel_booking$$
CREATE PROCEDURE sp_cancel_booking(IN p_booking_id INT)
BEGIN
    DECLARE booking_exists INT;

    SELECT COUNT(*) INTO booking_exists FROM bookings WHERE booking_id = p_booking_id;

    IF booking_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Booking not found.';
    END IF;

    UPDATE bookings SET payment_status = 'CANCELLED' WHERE booking_id = p_booking_id;
    SELECT 'Booking cancelled successfully.' AS message;
END$$

-- ============================================================
-- FUNCTIONS (minimum 3 required)
-- ============================================================

-- FUNCTION 1: fn_count_workshop_participants
-- Purpose: Return the number of confirmed (non-cancelled)
--          participants for a given workshop.
DROP FUNCTION IF EXISTS fn_count_workshop_participants$$
CREATE FUNCTION fn_count_workshop_participants(p_workshop_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE participant_count INT;

    SELECT COUNT(*) INTO participant_count
    FROM bookings
    WHERE workshop_id = p_workshop_id
      AND payment_status != 'CANCELLED';

    RETURN participant_count;
END$$

-- FUNCTION 2: fn_get_artist_avg_rating
-- Purpose: Return the average rating of all artworks by an artist.
DROP FUNCTION IF EXISTS fn_get_artist_avg_rating$$
CREATE FUNCTION fn_get_artist_avg_rating(p_artist_id INT)
RETURNS DECIMAL(3,2)
READS SQL DATA
BEGIN
    DECLARE avg_rating DECIMAL(3,2);

    SELECT ROUND(AVG(r.rating), 2) INTO avg_rating
    FROM reviews r
    JOIN artworks aw ON aw.artwork_id = r.artwork_id
    WHERE aw.artist_id = p_artist_id;

    RETURN COALESCE(avg_rating, 0.00);
END$$

-- FUNCTION 3: fn_is_workshop_available
-- Purpose: Return TRUE (1) if a workshop still has available
--          seats, FALSE (0) if it is fully booked.
DROP FUNCTION IF EXISTS fn_is_workshop_available$$
CREATE FUNCTION fn_is_workshop_available(p_workshop_id INT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE max_cap  INT;
    DECLARE cur_count INT;

    SELECT max_participants INTO max_cap
    FROM workshops WHERE workshop_id = p_workshop_id;

    SET cur_count = fn_count_workshop_participants(p_workshop_id);

    RETURN cur_count < max_cap;
END$$

-- FUNCTION 4: fn_member_total_spending
-- Purpose: Return the total amount a member has spent on
--          paid workshops.
DROP FUNCTION IF EXISTS fn_member_total_spending$$
CREATE FUNCTION fn_member_total_spending(p_member_id INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10,2);

    SELECT COALESCE(SUM(w.price), 0.00) INTO total
    FROM bookings b
    JOIN workshops w ON w.workshop_id = b.workshop_id
    WHERE b.member_id = p_member_id
      AND b.payment_status = 'PAID';

    RETURN total;
END$$

DELIMITER ;

-- ============================================================
-- Quick usage test (read-only, safe to run anytime)
-- ============================================================
SELECT fn_count_workshop_participants(1) AS participants_ws1;
SELECT fn_is_workshop_available(1)       AS ws1_available;
SELECT fn_get_artist_avg_rating(1)       AS avg_rating_amelie;
SELECT fn_member_total_spending(1)       AS alice_spending;

CALL sp_get_artist_statistics(1);
