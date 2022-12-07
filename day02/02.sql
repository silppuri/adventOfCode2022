BEGIN;
CREATE TABLE day02_input (
    opponent varchar(1),
    me varchar(1)
);

COPY day02_input(opponent, me) FROM '/inputs/02.txt' WITH (FORMAT csv, DELIMITER ' ');

CREATE TABLE day02 (
    id SERIAL PRIMARY KEY,
    opponent_value int,
    my_value int
);

/*
Opponent
A -> Rock       1
B -> Paper      2
C -> Scissors   3

Me
value, map, score
X -> Rock       1
Y -> Paper      2
Z -> Scissors   3
*/
INSERT INTO day02(opponent_value, my_value)
SELECT 
    (CASE
        WHEN opponent = 'A' THEN 1
        WHEN opponent = 'B' THEN 2
        WHEN opponent = 'C' THEN 3
    END) AS opponent_value,
    (CASE
        WHEN me = 'X' THEN 1
        WHEN me = 'Y' THEN 2
        WHEN me = 'Z' THEN 3
    END) AS my_value
FROM
    day02_input;

-- Part one
WITH i_win_rows AS (
    SELECT *, 'win' AS state FROM day02
    WHERE my_value - 1 = opponent_value OR (my_value=1 AND opponent_value=3)
),
draw AS (
    SELECT *, 'draw' AS state FROM day02
    WHERE my_value = opponent_value
),
i_loose_rows AS (
    SELECT *, 'loss' AS state FROM day02
    WHERE (
        my_value + 1 = opponent_value OR (opponent_value=1 AND my_value=3)
    )
)
SELECT SUM(score) FROM (
    SELECT id, 6 + my_value AS score FROM i_win_rows
    UNION
    SELECT id, 3 + my_value AS score FROM draw
    UNION
    SELECT id, 0 + my_value AS score FROM i_loose_rows
) games;


-- Part Two
-- X -> Loss        1
-- Y -> Drwaw       2
-- Z -> Win         3
WITH i_choose_to_win AS (
    SELECT id,
        opponent_value % 3 + 1 AS play_value,
        'win' AS state
    FROM day02
    WHERE my_value = 3
),
i_choose_draw AS (
    SELECT id,
        opponent_value AS play_value,
        'draw' AS state
    FROM day02
    WHERE my_value = 2
),
i_choose_to_loose AS (
    SELECT id,
        (opponent_value + 1) % 3 + 1 AS play_value,
        'loss' AS state
    FROM day02
    WHERE my_value = 1
)
SELECT SUM(score) FROM (
    SELECT id, 6 + play_value AS score FROM i_choose_to_win
    UNION
    SELECT id, 3 + play_value AS score FROM i_choose_draw
    UNION
    SELECT id, 0 + play_value AS score FROM i_choose_to_loose
) games;


ROLLBACK;