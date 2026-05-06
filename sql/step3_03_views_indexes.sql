-- ============================================================
-- ArtConnect Pro - Views & Indexes
-- Step 3.2: Views, indexes, and access rights
-- ============================================================

USE artconnect;

-- ============================================================
-- VIEWS
-- ============================================================

-- VIEW 1: v_artist_portfolio
-- Objective: Simplify access to artist + their artworks info.
--            Hides internal IDs; used by the UI service layer.
CREATE OR REPLACE VIEW v_artist_portfolio AS
SELECT
    a.name              AS artist_name,
    a.city,
    a.contact_email,
    aw.title            AS artwork_title,
    aw.type             AS artwork_type,
    aw.creation_year,
    aw.price,
    aw.status
FROM artists a
JOIN artworks aw ON aw.artist_id = a.artist_id
WHERE a.is_active = TRUE;

-- VIEW 2: v_exhibition_catalog
-- Objective: Query simplification — join of exhibitions, galleries,
--            and artworks in a single flat view for reporting.
CREATE OR REPLACE VIEW v_exhibition_catalog AS
SELECT
    e.title             AS exhibition_title,
    e.start_date,
    e.end_date,
    e.theme,
    e.curator_name,
    g.name              AS gallery_name,
    g.address           AS gallery_address,
    aw.title            AS artwork_title,
    ar.name             AS artist_name
FROM exhibitions e
JOIN galleries g          ON g.gallery_id    = e.gallery_id
JOIN exhibition_artworks ea ON ea.exhibition_id = e.exhibition_id
JOIN artworks aw          ON aw.artwork_id    = ea.artwork_id
JOIN artists ar           ON ar.artist_id     = aw.artist_id;

-- VIEW 3: v_workshop_bookings
-- Objective: Security layer — expose booking info without
--            revealing member birth year or phone number.
CREATE OR REPLACE VIEW v_workshop_bookings AS
SELECT
    w.title             AS workshop_title,
    w.workshop_date,
    w.level,
    w.max_participants,
    COUNT(b.booking_id) AS confirmed_bookings,
    (w.max_participants - COUNT(b.booking_id)) AS seats_available,
    ar.name             AS instructor_name
FROM workshops w
JOIN artists ar    ON ar.artist_id   = w.instructor_id
LEFT JOIN bookings b ON b.workshop_id = w.workshop_id
                     AND b.payment_status != 'CANCELLED'
GROUP BY w.workshop_id, w.title, w.workshop_date, w.level,
         w.max_participants, ar.name;

-- VIEW 4: v_artwork_ratings
-- Objective: Aggregated view for rankings and recommendation;
--            hides individual reviewer identity.
CREATE OR REPLACE VIEW v_artwork_ratings AS
SELECT
    aw.title            AS artwork_title,
    ar.name             AS artist_name,
    aw.type,
    aw.status,
    AVG(r.rating)       AS avg_rating,
    COUNT(r.review_id)  AS review_count
FROM artworks aw
JOIN artists ar         ON ar.artist_id  = aw.artist_id
LEFT JOIN reviews r     ON r.artwork_id  = aw.artwork_id
GROUP BY aw.artwork_id, aw.title, ar.name, aw.type, aw.status;

-- VIEW 5: v_member_activity
-- Objective: Summary of member engagement (workshops + reviews).
--            Useful for identifying premium candidate members.
CREATE OR REPLACE VIEW v_member_activity AS
SELECT
    m.member_id,
    m.name              AS member_name,
    m.membership_type,
    m.city,
    COUNT(DISTINCT b.booking_id)  AS total_bookings,
    COUNT(DISTINCT r.review_id)   AS total_reviews
FROM community_members m
LEFT JOIN bookings b ON b.member_id = m.member_id
                     AND b.payment_status = 'PAID'
LEFT JOIN reviews r  ON r.member_id  = m.member_id
GROUP BY m.member_id, m.name, m.membership_type, m.city;

-- ============================================================
-- INDEXES
-- ============================================================

-- INDEX 1: Frequent filter on artist city
-- Rationale: The UI allows filtering artists by city;
--            without an index, this requires a full table scan.
CREATE INDEX idx_artists_city ON artists(city);

-- INDEX 2: Artwork status (FOR_SALE, SOLD, EXHIBITED)
-- Rationale: The "Discover" tab queries artworks by status
--            constantly. This greatly speeds up those lookups.
CREATE INDEX idx_artworks_status ON artworks(status);

-- INDEX 3: Artwork artist FK
-- Rationale: JOINs between artworks and artists are the most
--            common query pattern. Indexing the FK is essential.
CREATE INDEX idx_artworks_artist_id ON artworks(artist_id);

-- INDEX 4: Workshop date ordering
-- Rationale: Workshops are always displayed sorted by date.
--            An index on workshop_date avoids a filesort.
CREATE INDEX idx_workshops_date ON workshops(workshop_date);

-- INDEX 5: Booking payment status filter
-- Rationale: Seat capacity calculations filter on payment_status.
--            This composite index covers both the filter and JOIN.
CREATE INDEX idx_bookings_status ON bookings(workshop_id, payment_status);

-- INDEX 6: Reviews by artwork for fast aggregation
-- Rationale: v_artwork_ratings and manual rating queries group
--            by artwork_id. The index avoids full scans on reviews.
CREATE INDEX idx_reviews_artwork ON reviews(artwork_id);
