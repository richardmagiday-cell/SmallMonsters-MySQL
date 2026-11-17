-- =====================================================================
-- Assignment 4: SQL -- data.sql
-- Sample data for the Small Monsters schema. Run after schema.sql.
--
-- IDs are given explicitly so the relationships below are easy to read.
-- =====================================================================


-- ---------------------------------------------------------------------
-- Species (ElectricScooter / ElectricBicycle are the ones from class)
-- ---------------------------------------------------------------------
INSERT INTO small_monster_species (
    id, evolves_from_id, species_name,
    base_health, base_energy, base_size, base_weight,
    base_strength, base_speed, base_defense,
    health_growth, energy_growth, size_growth, weight_growth,
    strength_growth, speed_growth, defense_growth
) VALUES
    ( 1, NULL, 'ElectricScooter',  50, 200, 1.0, 18.0, 20, 10, 50,  5, 10, 0.05, 0.05, 1, 2, 2),
    ( 2,    1, 'ElectricBicycle', 100, 400, 1.0, 40.0, 40, 30, 50, 15, 20, 0.05, 0.05, 2, 4, 4),
    ( 3, NULL, 'Pebblit',          70,  80, 0.4, 25.0, 30,  8, 60,  8,  5, 0.02, 0.80, 3, 1, 5),
    ( 4,    3, 'Bouldron',        160, 120, 1.8, 210.0, 70, 12, 95, 18,  8, 0.04, 2.50, 6, 1, 8),
    ( 5, NULL, 'Sproutling',       45, 120, 0.3,  4.0, 15, 20, 25,  6, 12, 0.03, 0.20, 2, 2, 2),
    ( 6,    5, 'Thornwyrm',        95, 220, 2.2, 60.0, 45, 35, 40, 12, 18, 0.06, 1.10, 4, 3, 3),
    ( 7, NULL, 'Puddlepup',        60, 150, 0.5,  9.0, 22, 28, 30,  7, 11, 0.02, 0.30, 2, 3, 2),
    ( 8, NULL, 'Emberfox',         55, 170, 0.6, 11.0, 35, 40, 20,  6, 14, 0.02, 0.35, 4, 4, 1),
    ( 9, NULL, 'Glimmerbat',       40, 190, 0.4,  3.0, 18, 55, 15,  5, 16, 0.01, 0.10, 2, 5, 1);


-- ---------------------------------------------------------------------
-- Types and species/type links
-- ---------------------------------------------------------------------
INSERT INTO small_monster_type (id, type_name) VALUES
    (1, 'ElectricVehicle'),
    (2, 'Rock'),
    (3, 'Plant'),
    (4, 'Water'),
    (5, 'Fire'),
    (6, 'Shadow');

INSERT INTO small_monster_species_type_link (species_id, type_id) VALUES
    (1, 1),
    (2, 1),
    (3, 2),
    (4, 2),
    (5, 3),
    (6, 3),
    (6, 6),     -- Thornwyrm is Plant + Shadow
    (7, 4),
    (8, 5),
    (9, 6);


-- ---------------------------------------------------------------------
-- Regions
-- ---------------------------------------------------------------------
INSERT INTO region (id, region_name, base_level) VALUES
    (1, 'Voltage Valley',   3),
    (2, 'Mossy Hollow',     5),
    (3, 'Tidepool Coast',   8),
    (4, 'Cinder Peaks',    15),
    (5, 'Gloomwood',       20),
    (6, 'Empty Barrens',   25);   -- no monsters live here (edge case)


-- ---------------------------------------------------------------------
-- Probability of each species in each region.
-- Within a region the probabilities add up to 1.0.
-- Emberfox in Tidepool Coast has probability 0.0 (listed but currently
-- never found) to show the queries ignore zero-chance entries.
-- ---------------------------------------------------------------------
INSERT INTO region_species_link (region_id, species_id, probability) VALUES
    -- Voltage Valley
    (1, 1, 0.50),   -- ElectricScooter
    (1, 2, 0.10),   -- ElectricBicycle
    (1, 3, 0.25),   -- Pebblit
    (1, 7, 0.15),   -- Puddlepup
    -- Mossy Hollow
    (2, 5, 0.55),   -- Sproutling
    (2, 6, 0.05),   -- Thornwyrm
    (2, 3, 0.20),   -- Pebblit
    (2, 7, 0.20),   -- Puddlepup
    -- Tidepool Coast
    (3, 7, 0.70),   -- Puddlepup
    (3, 3, 0.30),   -- Pebblit
    (3, 8, 0.00),   -- Emberfox (zero chance)
    -- Cinder Peaks
    (4, 8, 0.45),   -- Emberfox
    (4, 3, 0.35),   -- Pebblit
    (4, 4, 0.15),   -- Bouldron
    (4, 2, 0.05),   -- ElectricBicycle
    -- Gloomwood
    (5, 9, 0.60),   -- Glimmerbat
    (5, 6, 0.40);   -- Thornwyrm


-- ---------------------------------------------------------------------
-- Collectors
-- ---------------------------------------------------------------------
INSERT INTO collector (
    id, collector_name, collector_level, experience, money,
    badges, battles_won, battles_lost, home_region_id
) VALUES
    (1, 'Rin',    12, 4800, 2350, 3, 41, 9, 1),
    (2, 'Marcus', 20, 9900, 7100, 5, 88, 20, 4),
    (3, 'Priya',   7, 1500,  640, 1, 12, 6, 3),
    (4, 'Ned',     1,    0,  100, 0,  0, 0, 2);   -- brand new, owns nothing (edge case)


-- ---------------------------------------------------------------------
-- Actual monsters. owner_id points at COLLECTOR; NULL = wild monster.
-- ---------------------------------------------------------------------
INSERT INTO small_monster_actual (
    id, owner_id, species_id, actual_name, level, experience,
    current_health, max_health, current_energy, max_energy,
    actual_size, actual_weight, actual_strength, actual_speed
) VALUES
    -- Rin: ElectricBicycle, two Pebblits, Sproutling
    ( 1,    1, 2, 'Zippy',     5,  500, 100, 100, 500, 500, 1.2,  50.0, 50, 46),
    ( 2,    1, 3, 'Rocky',     8,  900,  95, 126, 110, 115, 0.5,  30.6, 51, 15),
    ( 3,    1, 3, 'Gravel',    4,  300,  80,  94,  90,  95, 0.5,  27.4, 39, 11),
    ( 4,    1, 5, 'Sprig',     6,  610,  70,  81, 190, 192, 0.5,   5.2, 27, 32),
    -- Marcus: Bouldron, Emberfox, Thornwyrm
    ( 5,    2, 4, 'Tectonic', 22, 7400, 500, 538, 290, 296, 2.7, 265.0, 202, 34),
    ( 6,    2, 8, 'Cinder',   18, 5200, 150, 157, 410, 422, 1.0,  17.3, 107, 112),
    ( 7,    2, 6, 'Briar',    19, 5600, 300, 323, 560, 562, 3.3,  80.9, 121, 92),
    -- Priya: Puddlepup, Glimmerbat
    ( 8,    3, 7, 'Splash',    9, 1100, 110, 123, 245, 249, 0.7,  11.7, 40, 55),
    ( 9,    3, 9, 'Nyx',       3,  180,  50,  50, 222, 222, 0.4,   3.2, 22, 65),
    -- Wild monster: nobody owns it
    (10, NULL, 1, NULL,         3,    0,  60,  60, 220, 220, 1.1,  18.1, 22, 14);
