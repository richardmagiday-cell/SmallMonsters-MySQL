-- =====================================================================
-- Assignment 4: SQL -- queries.sql
-- Run after schema.sql and data.sql.
--
-- Each query takes its "given" value from a user variable set just
-- above it. Change the variable to try a different collector / region.
-- =====================================================================


-- ---------------------------------------------------------------------
-- Query 1: all actual small monsters owned by a given collector.
-- ---------------------------------------------------------------------
SET @collector_name = 'Rin';

SELECT
    c.collector_name,
    a.id            AS monster_id,
    a.actual_name   AS monster_name,
    s.species_name,
    a.level,
    a.experience,
    a.current_health,
    a.max_health,
    a.current_energy,
    a.max_energy
FROM
    collector AS c
        JOIN
    small_monster_actual AS a
        ON (a.owner_id = c.id)
        JOIN
    small_monster_species AS s
        ON (s.id = a.species_id)
WHERE
    c.collector_name = @collector_name
ORDER BY
    a.level DESC, a.actual_name
;
-- Expected for 'Rin': Rocky, Sprig, Zippy, Gravel (4 rows).
-- 'Ned' owns nothing, so he returns 0 rows.


-- ---------------------------------------------------------------------
-- Query 2: all small monster species that can be found in a given
--          region, and the probability of finding each one.
-- Zero-probability entries are excluded because they can't be found.
-- ---------------------------------------------------------------------
SET @region_name = 'Tidepool Coast';

SELECT
    r.region_name,
    s.species_name,
    l.probability,
    CONCAT(ROUND(l.probability * 100, 1), '%') AS chance
FROM
    region AS r
        JOIN
    region_species_link AS l
        ON (l.region_id = r.id)
        JOIN
    small_monster_species AS s
        ON (s.id = l.species_id)
WHERE
    r.region_name = @region_name
    AND l.probability > 0
ORDER BY
    l.probability DESC, s.species_name
;
-- Expected for 'Tidepool Coast': Puddlepup 70%, Pebblit 30%.
-- (Emberfox is linked at 0.0 and is correctly left out.)


-- ---------------------------------------------------------------------
-- Query 3: the regions in which a given collector could find small
--          monsters of the same species they already own.
--
-- Walk collector -> owned monsters -> their species -> regions where
-- that species can be found (probability > 0). A collector who owns
-- two of the same species, or several species found in the same
-- region, would otherwise produce duplicate region rows, so we GROUP
-- BY region and list which of the collector's species live there.
-- DISTINCT inside GROUP_CONCAT handles owning duplicates of a species.
-- ---------------------------------------------------------------------
SET @collector_name = 'Rin';

SELECT
    r.region_name,
    r.base_level,
    GROUP_CONCAT(DISTINCT s.species_name ORDER BY s.species_name SEPARATOR ', ')
                                     AS owned_species_found_here,
    COUNT(DISTINCT s.id)             AS matching_species_count
FROM
    collector AS c
        JOIN
    small_monster_actual AS a
        ON (a.owner_id = c.id)
        JOIN
    small_monster_species AS s
        ON (s.id = a.species_id)
        JOIN
    region_species_link AS l
        ON (l.species_id = s.id)
        JOIN
    region AS r
        ON (r.id = l.region_id)
WHERE
    c.collector_name = @collector_name
    AND l.probability > 0
GROUP BY
    r.id, r.region_name, r.base_level
ORDER BY
    matching_species_count DESC, r.region_name
;
-- Expected for 'Rin' (owns ElectricBicycle, Pebblit x2, Sproutling):
--   Cinder Peaks    -> ElectricBicycle, Pebblit   (2)
--   Mossy Hollow    -> Pebblit, Sproutling        (2)
--   Voltage Valley  -> ElectricBicycle, Pebblit   (2)
--   Tidepool Coast  -> Pebblit                    (1)
-- Gloomwood and Empty Barrens are correctly absent.
-- Try 'Priya' (Puddlepup, Glimmerbat): Gloomwood, Mossy Hollow,
--   Tidepool Coast, Voltage Valley. Try 'Ned': 0 rows.


-- ---------------------------------------------------------------------
-- Query 3 (detail view): same question, one row per region + species,
-- showing the probability of finding that species there.
-- ---------------------------------------------------------------------
SELECT DISTINCT
    r.region_name,
    s.species_name,
    l.probability
FROM
    collector AS c
        JOIN
    small_monster_actual AS a
        ON (a.owner_id = c.id)
        JOIN
    small_monster_species AS s
        ON (s.id = a.species_id)
        JOIN
    region_species_link AS l
        ON (l.species_id = s.id)
        JOIN
    region AS r
        ON (r.id = l.region_id)
WHERE
    c.collector_name = @collector_name
    AND l.probability > 0
ORDER BY
    r.region_name, l.probability DESC
;
