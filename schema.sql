-- =====================================================================
-- Assignment 4: SQL -- schema.sql
-- Small Monsters schema (MySQL 8)
--
-- Starts from the schema built in class (species, types, species/type
-- link, actual monsters) and expands it with:
--   * COLLECTOR                    -- people who own monsters
--   * SMALL_MONSTER_ACTUAL.owner_id -- now a real foreign key to COLLECTOR
--   * REGION                       -- places monsters can be found
--   * REGION_SPECIES_LINK          -- probability of finding each species
--                                     in each region (many-to-many)
--
-- Run order: schema.sql -> data.sql -> queries.sql
-- =====================================================================

-- CREATE DATABASE IF NOT EXISTS small_monsters;
-- USE small_monsters;

-- Drop everything first so the script can be re-run cleanly.
-- (Children before parents so foreign keys don't block the drops.)
DROP VIEW  IF EXISTS ancestry;
DROP TABLE IF EXISTS region_species_link;
DROP TABLE IF EXISTS small_monster_actual;
DROP TABLE IF EXISTS collector;
DROP TABLE IF EXISTS region;
DROP TABLE IF EXISTS small_monster_species_type_link;
DROP TABLE IF EXISTS small_monster_type;
DROP TABLE IF EXISTS small_monster_species;


-- ---------------------------------------------------------------------
-- Existing schema from class
-- ---------------------------------------------------------------------

CREATE TABLE small_monster_species (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    evolves_from_id INT NULL,               -- NULL = base form (does not evolve from anything)
    species_name    VARCHAR(64) NOT NULL,
    base_health     INT,
    base_energy     INT,
    base_size       DOUBLE,
    base_weight     DOUBLE,
    base_strength   INT,
    base_speed      INT,
    base_defense    INT,
    health_growth   INT,
    energy_growth   INT,
    size_growth     DOUBLE,
    weight_growth   DOUBLE,
    strength_growth INT,
    speed_growth    INT,
    defense_growth  INT,
    CONSTRAINT fk_species_evolves_from
        FOREIGN KEY (evolves_from_id) REFERENCES small_monster_species (id)
);

CREATE VIEW ancestry AS SELECT
    descendant.id           AS id,
    descendant.species_name AS name,
    ancestor.id             AS ancestor_id,
    ancestor.species_name   AS ancestor_name
FROM
    small_monster_species AS descendant
        LEFT JOIN
    small_monster_species AS ancestor
        ON (ancestor.id = descendant.evolves_from_id)
;

CREATE TABLE small_monster_type (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    type_name       VARCHAR(64) NOT NULL
);

CREATE TABLE small_monster_species_type_link (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    species_id      INT NOT NULL,
    type_id         INT NOT NULL,
    CONSTRAINT fk_stl_species FOREIGN KEY (species_id) REFERENCES small_monster_species (id),
    CONSTRAINT fk_stl_type    FOREIGN KEY (type_id)    REFERENCES small_monster_type (id)
);


-- ---------------------------------------------------------------------
-- NEW: REGION
-- A named area, and the base level of the small monsters found there.
-- ---------------------------------------------------------------------

CREATE TABLE region (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    region_name     VARCHAR(64) NOT NULL UNIQUE,
    base_level      INT NOT NULL DEFAULT 1,
    CONSTRAINT chk_region_base_level CHECK (base_level >= 1)
);


-- ---------------------------------------------------------------------
-- NEW: COLLECTOR
-- A person who catches and owns small monsters.
-- ---------------------------------------------------------------------

CREATE TABLE collector (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    collector_name  VARCHAR(64) NOT NULL UNIQUE,
    collector_level INT NOT NULL DEFAULT 1,
    experience      INT NOT NULL DEFAULT 0,
    money           INT NOT NULL DEFAULT 0,
    badges          INT NOT NULL DEFAULT 0,
    battles_won     INT NOT NULL DEFAULT 0,
    battles_lost    INT NOT NULL DEFAULT 0,
    home_region_id  INT NULL,               -- where the collector started out
    CONSTRAINT fk_collector_home_region
        FOREIGN KEY (home_region_id) REFERENCES region (id)
);


-- ---------------------------------------------------------------------
-- Existing table from class: SMALL_MONSTER_ACTUAL
-- (created exactly as in class, including the later actual_name column)
-- ---------------------------------------------------------------------

CREATE TABLE small_monster_actual (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    owner_id        INT,
    species_id      INT,
    level           INTEGER,
    experience      INTEGER,
    current_health  INTEGER,
    max_health      INTEGER,
    current_energy  INTEGER,
    max_energy      INTEGER,
    actual_size     DOUBLE,
    actual_weight   DOUBLE,
    actual_strength DOUBLE,
    actual_speed    DOUBLE
);

ALTER TABLE small_monster_actual ADD COLUMN actual_name VARCHAR(64);

-- NEW: modify SMALL_MONSTER_ACTUAL so monsters can be owned by collectors.
-- owner_id becomes a foreign key into COLLECTOR. It stays nullable, so a
-- NULL owner means a wild (uncaught) monster. If a collector is deleted,
-- their monsters are released back into the wild rather than deleted.
ALTER TABLE small_monster_actual
    MODIFY COLUMN owner_id INT NULL,
    ADD CONSTRAINT fk_actual_owner
        FOREIGN KEY (owner_id) REFERENCES collector (id)
        ON DELETE SET NULL,
    ADD CONSTRAINT fk_actual_species
        FOREIGN KEY (species_id) REFERENCES small_monster_species (id);


-- ---------------------------------------------------------------------
-- NEW: REGION_SPECIES_LINK
-- Linking table (many-to-many) between REGION and SMALL_MONSTER_SPECIES.
-- probability = chance (0.0 to 1.0) that a given encounter in the
-- region is that species. A species/region pair appears at most once.
-- ---------------------------------------------------------------------

CREATE TABLE region_species_link (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    region_id       INT NOT NULL,
    species_id      INT NOT NULL,
    probability     DOUBLE NOT NULL,
    CONSTRAINT fk_rsl_region  FOREIGN KEY (region_id)  REFERENCES region (id) ON DELETE CASCADE,
    CONSTRAINT fk_rsl_species FOREIGN KEY (species_id) REFERENCES small_monster_species (id) ON DELETE CASCADE,
    CONSTRAINT uq_rsl_region_species UNIQUE (region_id, species_id),
    CONSTRAINT chk_rsl_probability CHECK (probability >= 0.0 AND probability <= 1.0)
);
