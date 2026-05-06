-- ============================================================
-- ArtConnect Pro - Database Creation Script
-- Step 3.1: Create and populate the database
-- ============================================================

DROP DATABASE IF EXISTS artconnect;
CREATE DATABASE artconnect
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE artconnect;

-- ============================================================
-- TABLE: disciplines
-- ============================================================
CREATE TABLE disciplines (
    discipline_id INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL UNIQUE
);

-- ============================================================
-- TABLE: galleries
-- ============================================================
CREATE TABLE galleries (
    gallery_id    INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(150) NOT NULL,
    address       VARCHAR(255),
    owner_name    VARCHAR(150),
    opening_hours VARCHAR(100),
    contact_phone VARCHAR(30),
    rating        DECIMAL(3,1) DEFAULT 0.0,
    website       VARCHAR(255)
);

-- ============================================================
-- TABLE: artists
-- ============================================================
CREATE TABLE artists (
    artist_id      INT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(150) NOT NULL,
    bio            TEXT,
    birth_year     INT,
    contact_email  VARCHAR(150) UNIQUE,
    phone          VARCHAR(30),
    city           VARCHAR(100),
    website        VARCHAR(255),
    social_media   VARCHAR(255),
    is_active      BOOLEAN DEFAULT TRUE
);

-- ============================================================
-- TABLE: artist_disciplines  (M:N)
-- ============================================================
CREATE TABLE artist_disciplines (
    artist_id     INT NOT NULL,
    discipline_id INT NOT NULL,
    PRIMARY KEY (artist_id, discipline_id),
    FOREIGN KEY (artist_id)     REFERENCES artists(artist_id)     ON DELETE CASCADE,
    FOREIGN KEY (discipline_id) REFERENCES disciplines(discipline_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE: artworks
-- ============================================================
CREATE TABLE artworks (
    artwork_id     INT AUTO_INCREMENT PRIMARY KEY,
    title          VARCHAR(200) NOT NULL,
    creation_year  INT,
    type           VARCHAR(100),
    medium         VARCHAR(150),
    dimensions     VARCHAR(100),
    description    TEXT,
    price          DECIMAL(10,2) DEFAULT 0.00,
    status         ENUM('FOR_SALE','SOLD','EXHIBITED') DEFAULT 'FOR_SALE',
    artist_id      INT NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE: artwork_tags
-- ============================================================
CREATE TABLE artwork_tags (
    tag_id     INT AUTO_INCREMENT PRIMARY KEY,
    artwork_id INT NOT NULL,
    tag        VARCHAR(100) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE: exhibitions
-- ============================================================
CREATE TABLE exhibitions (
    exhibition_id INT AUTO_INCREMENT PRIMARY KEY,
    title         VARCHAR(200) NOT NULL,
    start_date    DATE NOT NULL,
    end_date      DATE NOT NULL,
    description   TEXT,
    curator_name  VARCHAR(150),
    theme         VARCHAR(150),
    gallery_id    INT NOT NULL,
    FOREIGN KEY (gallery_id) REFERENCES galleries(gallery_id) ON DELETE CASCADE,
    CONSTRAINT chk_exhibition_dates CHECK (end_date >= start_date)
);

-- ============================================================
-- TABLE: exhibition_artworks  (M:N)
-- ============================================================
CREATE TABLE exhibition_artworks (
    exhibition_id INT NOT NULL,
    artwork_id    INT NOT NULL,
    PRIMARY KEY (exhibition_id, artwork_id),
    FOREIGN KEY (exhibition_id) REFERENCES exhibitions(exhibition_id) ON DELETE CASCADE,
    FOREIGN KEY (artwork_id)    REFERENCES artworks(artwork_id)    ON DELETE CASCADE
);

-- ============================================================
-- TABLE: workshops
-- ============================================================
CREATE TABLE workshops (
    workshop_id      INT AUTO_INCREMENT PRIMARY KEY,
    title            VARCHAR(200) NOT NULL,
    workshop_date    DATETIME NOT NULL,
    duration_minutes INT DEFAULT 60,
    max_participants INT DEFAULT 10,
    price            DECIMAL(8,2) DEFAULT 0.00,
    instructor_id    INT NOT NULL,
    location         VARCHAR(255),
    description      TEXT,
    level            ENUM('beginner','intermediate','advanced') DEFAULT 'beginner',
    FOREIGN KEY (instructor_id) REFERENCES artists(artist_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE: community_members
-- ============================================================
CREATE TABLE community_members (
    member_id        INT AUTO_INCREMENT PRIMARY KEY,
    name             VARCHAR(150) NOT NULL,
    email            VARCHAR(150) NOT NULL UNIQUE,
    birth_year       INT,
    phone            VARCHAR(30),
    city             VARCHAR(100),
    membership_type  ENUM('free','premium') DEFAULT 'free'
);

-- ============================================================
-- TABLE: member_disciplines  (M:N)
-- ============================================================
CREATE TABLE member_disciplines (
    member_id     INT NOT NULL,
    discipline_id INT NOT NULL,
    PRIMARY KEY (member_id, discipline_id),
    FOREIGN KEY (member_id)     REFERENCES community_members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (discipline_id) REFERENCES disciplines(discipline_id)   ON DELETE CASCADE
);

-- ============================================================
-- TABLE: bookings
-- ============================================================
CREATE TABLE bookings (
    booking_id      INT AUTO_INCREMENT PRIMARY KEY,
    workshop_id     INT NOT NULL,
    member_id       INT NOT NULL,
    booking_date    DATETIME DEFAULT CURRENT_TIMESTAMP,
    payment_status  ENUM('PENDING','PAID','CANCELLED') DEFAULT 'PENDING',
    UNIQUE KEY uq_booking (workshop_id, member_id),
    FOREIGN KEY (workshop_id) REFERENCES workshops(workshop_id)        ON DELETE CASCADE,
    FOREIGN KEY (member_id)   REFERENCES community_members(member_id)  ON DELETE CASCADE
);

-- ============================================================
-- TABLE: reviews
-- ============================================================
CREATE TABLE reviews (
    review_id    INT AUTO_INCREMENT PRIMARY KEY,
    member_id    INT NOT NULL,
    artwork_id   INT NOT NULL,
    rating       INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment      TEXT,
    review_date  DATE DEFAULT (CURRENT_DATE),
    UNIQUE KEY uq_review (member_id, artwork_id),
    FOREIGN KEY (member_id)  REFERENCES community_members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)         ON DELETE CASCADE
);
