-- ============================================================
-- ArtConnect Pro - Transaction Test Script
-- Step 3.4: Complex transactional scenario
-- ============================================================

USE artconnect;

-- ============================================================
-- SCENARIO 1: Register a member for multiple workshops atomically
-- Use case: A premium member signs up for a package deal (3 workshops).
-- If any registration fails (workshop full, member not found, etc.),
-- ALL registrations are rolled back to keep data consistent.
-- ============================================================

START TRANSACTION;

-- Register member Alice (member_id=1) for workshop 2 and 4
-- (she is already in workshop 1)
INSERT INTO bookings (workshop_id, member_id, payment_status)
VALUES (2, 1, 'PAID');

INSERT INTO bookings (workshop_id, member_id, payment_status)
VALUES (4, 1, 'PAID');

-- Verify no capacity issues (should show 0 violations)
SELECT
    w.workshop_id,
    w.title,
    w.max_participants,
    fn_count_workshop_participants(w.workshop_id) AS current_participants,
    CASE
        WHEN fn_count_workshop_participants(w.workshop_id) > w.max_participants
        THEN 'OVER CAPACITY !'
        ELSE 'OK'
    END AS capacity_status
FROM workshops w
WHERE w.workshop_id IN (2, 4);

COMMIT;

SELECT 'Transaction 1 committed: Alice registered for 2 new workshops.' AS result;

-- ============================================================
-- SCENARIO 2: Create a new exhibition with multiple artworks
-- Use case: A gallery creates a new exhibition and immediately
-- assigns 3 artworks. If any INSERT fails, everything rolls back.
-- ============================================================

START TRANSACTION;

INSERT INTO exhibitions (title, start_date, end_date, description, curator_name, theme, gallery_id)
VALUES ('Nouvelles Voix', '2025-01-10', '2025-03-20',
        'Emerging artists from across Europe.', 'Jean Moreau', 'Emergence', 1);

-- Store the new exhibition id
SET @new_exhibition_id = LAST_INSERT_ID();

-- Assign 3 artworks to the new exhibition
INSERT INTO exhibition_artworks (exhibition_id, artwork_id) VALUES (@new_exhibition_id, 2);
INSERT INTO exhibition_artworks (exhibition_id, artwork_id) VALUES (@new_exhibition_id, 5);
INSERT INTO exhibition_artworks (exhibition_id, artwork_id) VALUES (@new_exhibition_id, 8);

-- Verify the exhibition was created properly
SELECT e.title, e.start_date, e.end_date, COUNT(ea.artwork_id) AS artworks_count
FROM exhibitions e
JOIN exhibition_artworks ea ON ea.exhibition_id = e.exhibition_id
WHERE e.exhibition_id = @new_exhibition_id
GROUP BY e.exhibition_id, e.title, e.start_date, e.end_date;

COMMIT;

SELECT 'Transaction 2 committed: New exhibition created with 3 artworks.' AS result;

-- ============================================================
-- SCENARIO 3: ROLLBACK demonstration
-- Use case: Attempt to register a member for a workshop that
-- doesn't exist — the entire transaction is rolled back.
-- ============================================================

START TRANSACTION;

-- This booking is valid
INSERT INTO bookings (workshop_id, member_id, payment_status)
VALUES (3, 5, 'PENDING');

-- Simulate a failure: try to insert a booking for a non-existent workshop
-- (workshop_id = 9999 does not exist → FK violation)
-- Uncomment the line below to test the ROLLBACK:
-- INSERT INTO bookings (workshop_id, member_id, payment_status) VALUES (9999, 5, 'PENDING');

-- Since we leave it commented, we ROLLBACK manually to demonstrate the concept:
ROLLBACK;

SELECT 'Transaction 3 rolled back: No bookings were saved.' AS result;

-- ============================================================
-- SCENARIO 4: Batch payment confirmation
-- Use case: Confirm all PENDING bookings for a specific workshop
-- as a single atomic operation (e.g., after payment gateway confirms).
-- ============================================================

START TRANSACTION;

UPDATE bookings
SET payment_status = 'PAID'
WHERE workshop_id = 1
  AND payment_status = 'PENDING';

-- Verify
SELECT b.booking_id, m.name AS member_name, b.payment_status
FROM bookings b
JOIN community_members m ON m.member_id = b.member_id
WHERE b.workshop_id = 1;

COMMIT;

SELECT 'Transaction 4 committed: All pending bookings for workshop 1 confirmed.' AS result;
