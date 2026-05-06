-- ============================================================
-- ArtConnect Pro - Sample Data Insertion Script
-- Step 3.1: Populate database with realistic sample data
--
-- PROMPT USED FOR LLM (Claude):
-- "Generate SQL INSERT statements to populate the ArtConnect
--  database with realistic sample data. Include:
--  - 6 disciplines (Painting, Sculpture, Photography, etc.)
--  - 4 galleries across different cities
--  - 6 artists with varied disciplines and cities
--  - 10 artworks distributed among artists, with varied statuses
--  - 3 exhibitions with multiple artworks each
--  - 4 workshops with different levels and instructors
--  - 8 community members (mix of free and premium)
--  - 10 bookings for various workshops and members
--  - 8 reviews from members on artworks
--  Cover interesting cases: artists exhibiting in multiple
--  exhibitions, members booking multiple workshops,
--  cross-participations between artworks and exhibitions."
-- ============================================================

USE artconnect;

-- ============================================================
-- 1. DISCIPLINES
-- ============================================================
INSERT INTO disciplines (name) VALUES
    ('Painting'),
    ('Sculpture'),
    ('Photography'),
    ('Digital Art'),
    ('Watercolor'),
    ('Ceramics');

-- ============================================================
-- 2. GALLERIES
-- ============================================================
INSERT INTO galleries (name, address, owner_name, opening_hours, contact_phone, rating, website) VALUES
    ('Galerie Lumière', '12 Rue des Arts, Paris 75004', 'Sophie Martin', 'Tue-Sun 10:00-19:00', '+33 1 42 00 11 22', 4.7, 'https://galerie-lumiere.fr'),
    ('The Canvas House',  '89 Baker Street, London W1U 6AG', 'James Harper', 'Mon-Sat 09:00-18:00', '+44 20 7946 0011', 4.3, 'https://canvashouse.co.uk'),
    ('Espacio Vivo',      'Calle Mayor 55, Madrid 28013', 'Elena Ruiz', 'Tue-Sun 11:00-20:00', '+34 91 555 0033', 4.5, 'https://espaciovivo.es'),
    ('Studio Nord',       'Bredgade 21, Copenhagen 1260', 'Lars Andersen', 'Wed-Sun 12:00-18:00', '+45 33 12 34 56', 4.1, 'https://studionord.dk');

-- ============================================================
-- 3. ARTISTS
-- ============================================================
INSERT INTO artists (name, bio, birth_year, contact_email, phone, city, website, social_media, is_active) VALUES
    ('Amélie Fontaine',  'French painter known for her vivid Impressionist landscapes and urban scenes.', 1985, 'amelie.fontaine@art.com', '+33 6 11 22 33 44', 'Paris',      'https://ameliefontaine.com',    '@ameliefontaine',  TRUE),
    ('Marco Bellini',    'Italian sculptor working with marble and bronze. Exhibited across Europe.',       1978, 'marco.bellini@art.com',  '+39 02 1234 5678',  'Milan',      'https://marcobellini.it',       '@marcobellini',    TRUE),
    ('Yuki Tanaka',      'Japanese-born photographer capturing the intersection of nature and urbanism.',   1990, 'yuki.tanaka@art.com',    '+81 3-1234-5678',   'Tokyo',      'https://yukitanaka.photo',      '@yukitanaka',      TRUE),
    ('Sofia Reyes',      'Contemporary ceramic artist and digital illustrator based in Madrid.',            1993, 'sofia.reyes@art.com',    '+34 91 222 3344',   'Madrid',     'https://sofiareyes.es',         '@sofiareyes_art',  TRUE),
    ('Thomas Breuer',    'German watercolor artist specializing in botanical and architectural subjects.',   1971, 'thomas.breuer@art.com',  '+49 30 9876 5432',  'Berlin',     'https://thomasbreuer.de',       '@thomasbreuer',    TRUE),
    ('Clara Dubois',     'Belgian painter and sculptor with works in public institutions and galleries.',   1982, 'clara.dubois@art.com',   '+32 2 555 6677',    'Brussels',   'https://claradubois.be',        '@claradubois',     TRUE);

-- ============================================================
-- 4. ARTIST-DISCIPLINES (multiple disciplines per artist)
-- ============================================================
-- Amélie: Painting, Watercolor
INSERT INTO artist_disciplines VALUES (1, 1), (1, 5);
-- Marco: Sculpture
INSERT INTO artist_disciplines VALUES (2, 2);
-- Yuki: Photography, Digital Art
INSERT INTO artist_disciplines VALUES (3, 3), (3, 4);
-- Sofia: Ceramics, Digital Art
INSERT INTO artist_disciplines VALUES (4, 6), (4, 4);
-- Thomas: Watercolor, Painting
INSERT INTO artist_disciplines VALUES (5, 5), (5, 1);
-- Clara: Painting, Sculpture
INSERT INTO artist_disciplines VALUES (6, 1), (6, 2);

-- ============================================================
-- 5. ARTWORKS
-- ============================================================
INSERT INTO artworks (title, creation_year, type, medium, dimensions, description, price, status, artist_id) VALUES
    ('Lumière du Soir',        2022, 'Painting',     'Oil on canvas',         '80x60 cm',  'A golden-hour Parisian street scene.',            2800.00, 'FOR_SALE',  1),
    ('Reflets du Canal',       2023, 'Painting',     'Watercolor on paper',   '50x40 cm',  'Reflections on a quiet canal at dusk.',            950.00, 'FOR_SALE',  1),
    ('Forma Eterna',           2021, 'Sculpture',    'Carrara marble',        '40x20x20cm','Abstract human form carved in white marble.',     12000.00, 'EXHIBITED', 2),
    ('Equilibrio',             2020, 'Sculpture',    'Bronze',                '60x30x30cm','A balancing act between two opposing forces.',     8500.00, 'FOR_SALE',  2),
    ('Urban Silence',          2023, 'Photography',  'Fine art print',        '90x60 cm',  'Deserted Tokyo alley at 5am.',                    1200.00, 'FOR_SALE',  3),
    ('Bloom Series #3',        2022, 'Photography',  'C-print',               '70x50 cm',  'Cherry blossom macro detail.',                    1100.00, 'SOLD',      3),
    ('Terra Cotta Dream',      2023, 'Ceramics',     'Stoneware glaze',       '30x15 cm',  'Hand-thrown vessel with textured earth-tone glaze.', 450.00, 'FOR_SALE', 4),
    ('Pixel Garden',           2024, 'Digital Art',  'Archival giclee print', '100x80 cm', 'Generative art combining nature and code.',         750.00, 'FOR_SALE',  4),
    ('Botanical Study IV',     2022, 'Watercolor',   'Watercolor on paper',   '42x29.7 cm','Detailed botanical illustration of wild orchids.',  680.00, 'SOLD',      5),
    ('Dualité',                2021, 'Painting',     'Acrylic on canvas',     '120x90 cm', 'Juxtaposition of light and shadow, figure and void.', 3200.00, 'EXHIBITED', 6);

-- ============================================================
-- 6. ARTWORK TAGS
-- ============================================================
INSERT INTO artwork_tags (artwork_id, tag) VALUES
    (1, 'Paris'), (1, 'Impressionism'), (1, 'Urban'),
    (2, 'Canal'), (2, 'Watercolor'), (2, 'Dusk'),
    (3, 'Abstract'), (3, 'Marble'), (3, 'Human form'),
    (4, 'Bronze'), (4, 'Balance'), (4, 'Contemporary'),
    (5, 'Tokyo'), (5, 'Street'), (5, 'Minimalism'),
    (6, 'Nature'), (6, 'Macro'), (6, 'Spring'),
    (7, 'Ceramics'), (7, 'Earth'), (7, 'Handmade'),
    (8, 'Digital'), (8, 'Generative'), (8, 'Nature'),
    (9, 'Botanical'), (9, 'Illustration'),
    (10, 'Duality'), (10, 'Light'), (10, 'Abstract');

-- ============================================================
-- 7. EXHIBITIONS
-- ============================================================
INSERT INTO exhibitions (title, start_date, end_date, description, curator_name, theme, gallery_id) VALUES
    ('Lumières Croisées',   '2024-03-01', '2024-05-31', 'An exploration of light across painting and sculpture.', 'Marie Leclerc',  'Light & Shadow',    1),
    ('Urban Visions',       '2024-06-15', '2024-08-30', 'Photography and digital art in the contemporary city.', 'Peter Holms',    'Urbanism',          2),
    ('Tierra y Forma',      '2024-09-01', '2024-11-30', 'Ceramics and mixed media celebrating natural materials.','Carmen Vidal',  'Earth & Matter',    3);

-- ============================================================
-- 8. EXHIBITION-ARTWORKS (cross-participations)
-- ============================================================
-- Lumières Croisées: Paintings + Sculptures
INSERT INTO exhibition_artworks VALUES (1, 1), (1, 2), (1, 3), (1, 10);
-- Urban Visions: Photography + Digital
INSERT INTO exhibition_artworks VALUES (2, 5), (2, 6), (2, 8);
-- Tierra y Forma: Ceramics + Sculpture
INSERT INTO exhibition_artworks VALUES (3, 4), (3, 7), (3, 9);

-- ============================================================
-- 9. WORKSHOPS
-- ============================================================
INSERT INTO workshops (title, workshop_date, duration_minutes, max_participants, price, instructor_id, location, description, level) VALUES
    ('Introduction to Watercolor',        '2024-04-10 10:00:00', 180, 12, 45.00, 5,  'Studio Nord, Copenhagen',     'Learn the basics of watercolor painting with Thomas Breuer.',          'beginner'),
    ('Bronze Sculpture Fundamentals',     '2024-05-15 14:00:00', 240, 8,  95.00, 2,  'Galerie Lumière, Paris',      'Hands-on introduction to bronze casting with Marco Bellini.',          'intermediate'),
    ('Urban Photography Walk',            '2024-06-20 09:00:00', 150, 15, 35.00, 3,  'London City Centre',          'Street photography master class with Yuki Tanaka.',                    'beginner'),
    ('Advanced Digital Illustration',     '2024-07-05 10:00:00', 300, 10, 120.00, 4, 'Espacio Vivo, Madrid',        'Deep dive into generative and digital art techniques with Sofia Reyes.','advanced');

-- ============================================================
-- 10. COMMUNITY MEMBERS
-- ============================================================
INSERT INTO community_members (name, email, birth_year, phone, city, membership_type) VALUES
    ('Alice Moreau',    'alice.moreau@email.com',     1995, '+33 6 10 20 30 40', 'Paris',      'premium'),
    ('Ben Carter',      'ben.carter@email.com',       1988, '+44 7700 900100',   'London',     'free'),
    ('Carla Gomez',     'carla.gomez@email.com',      2000, '+34 600 123 456',   'Madrid',     'premium'),
    ('David Schmidt',   'david.schmidt@email.com',    1975, '+49 151 1234 5678', 'Berlin',     'free'),
    ('Emilie Bernard',  'emilie.bernard@email.com',   1992, '+33 6 55 44 33 22', 'Lyon',       'premium'),
    ('Finn Olsen',      'finn.olsen@email.com',       1985, '+45 20 12 34 56',   'Copenhagen', 'free'),
    ('Grace Lee',       'grace.lee@email.com',        1998, '+44 7800 000999',   'London',     'premium'),
    ('Hugo Petit',      'hugo.petit@email.com',       1970, '+33 6 77 88 99 00', 'Marseille',  'free');

-- ============================================================
-- 11. MEMBER-DISCIPLINES
-- ============================================================
INSERT INTO member_disciplines VALUES (1,1),(1,5); -- Alice: Painting, Watercolor
INSERT INTO member_disciplines VALUES (2,3);       -- Ben: Photography
INSERT INTO member_disciplines VALUES (3,6),(3,4); -- Carla: Ceramics, Digital Art
INSERT INTO member_disciplines VALUES (4,1),(4,2); -- David: Painting, Sculpture
INSERT INTO member_disciplines VALUES (5,1);       -- Emilie: Painting
INSERT INTO member_disciplines VALUES (6,5);       -- Finn: Watercolor
INSERT INTO member_disciplines VALUES (7,3),(7,4); -- Grace: Photography, Digital Art
INSERT INTO member_disciplines VALUES (8,2);       -- Hugo: Sculpture

-- ============================================================
-- 12. BOOKINGS (members registering for multiple workshops)
-- ============================================================
INSERT INTO bookings (workshop_id, member_id, booking_date, payment_status) VALUES
    (1, 1, '2024-03-15 10:30:00', 'PAID'),      -- Alice → Watercolor
    (1, 6, '2024-03-16 14:00:00', 'PAID'),      -- Finn → Watercolor
    (1, 5, '2024-03-20 09:15:00', 'PENDING'),   -- Emilie → Watercolor
    (2, 4, '2024-04-01 11:00:00', 'PAID'),      -- David → Bronze Sculpture
    (2, 8, '2024-04-02 12:00:00', 'PAID'),      -- Hugo → Bronze Sculpture
    (3, 2, '2024-05-10 08:00:00', 'PAID'),      -- Ben → Photography Walk
    (3, 7, '2024-05-11 09:00:00', 'PENDING'),   -- Grace → Photography Walk
    (4, 3, '2024-06-01 10:00:00', 'PAID'),      -- Carla → Digital Illustration
    (4, 7, '2024-06-02 11:00:00', 'PAID'),      -- Grace → Digital Illustration (cross-participation)
    (1, 4, '2024-03-18 16:00:00', 'CANCELLED'); -- David → Watercolor (cancelled)

-- ============================================================
-- 13. REVIEWS
-- ============================================================
INSERT INTO reviews (member_id, artwork_id, rating, comment, review_date) VALUES
    (1, 1,  5, 'Absolutely stunning Impressionist work. The light is magical.',          '2024-04-05'),
    (1, 2,  4, 'Delicate watercolor technique, very peaceful.',                          '2024-04-06'),
    (2, 5,  5, 'Urban Silence speaks to me — minimal yet so powerful.',                 '2024-07-01'),
    (3, 7,  5, 'Beautiful craftsmanship. The glaze texture is incredible.',             '2024-10-05'),
    (3, 8,  4, 'Pixel Garden is innovative — love the generative approach.',             '2024-10-06'),
    (4, 3,  5, 'Forma Eterna is the best marble sculpture I have seen in years.',       '2024-04-20'),
    (5, 10, 4, 'Dualité is thought-provoking. Clara Dubois is a true master.',          '2024-05-01'),
    (7, 8,  5, 'Mind-blowing digital art. Sofia Reyes is ahead of her time.',           '2024-07-10');
