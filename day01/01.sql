BEGIN;
CREATE TABLE day01 (
    id SERIAL NOT NULL PRIMARY KEY,
    calories INT NULL
);

COPY day01(calories) FROM '/inputs/01.txt' WITH (FORMAT csv);

WITH elf_with_group AS (
    SELECT
        -- Every empty row increases the elf id
        id - row_number() OVER (ORDER BY id) AS elf_id,
        calories
    FROM day01
    WHERE calories IS NOT NULL
), sum_of_calories AS (
    SELECT SUM (calories) AS calories_sum
    FROM elf_with_group
    GROUP BY elf_id
    ORDER BY calories_sum DESC
)

SELECT
    (SELECT calories_sum FROM sum_of_calories LIMIT 1) AS part_one,
    (SELECT SUM(t.calories_sum) FROM (SELECT calories_sum FROM sum_of_calories LIMIT 3) t) AS part_two;
;

ROLLBACK;
