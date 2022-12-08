BEGIN;

CREATE TABLE day04_input (
    pair_id SERIAL PRIMARY KEY,
    section_1 text,
    section_2 text
);

COPY day04_input(section_1, section_2) FROM '/inputs/04.txt' WITH (FORMAT csv, DELIMITER ',');

WITH ranges AS (
    SELECT 
        (SELECT array(SELECT generate_series(
            substring(section_1, 1, POSITION('-' IN section_1) - 1)::int,
            substring(section_1, POSITION('-' IN section_1) + 1)::int
        ))) AS range_1,
        (SELECT array(SELECT generate_series(
            substring(section_2, 1, POSITION('-' IN section_2) - 1)::int,
            substring(section_2, POSITION('-' IN section_2) + 1)::int
        ))) AS range_2
    FROM day04_input
),
part_1 AS (
    SELECT COUNT(*) FROM ranges
    WHERE range_1 <@ range_2 OR range_2 <@ range_1
),
part_2 AS (
    SELECT COUNT(*) FROM ranges
    WHERE range_1 && range_2
)

SELECT 
    (SELECT * FROM part_1) AS part_1,
    (SELECT * FROM part_2) AS part_2;

ROLLBACK;