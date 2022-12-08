BEGIN;
CREATE TABLE day03_input (
    bag_items text
);

CREATE TABLE day03_bag_items(
    id int,
    part int,
    item char
);

COPY day03_input(bag_items) FROM '/inputs/03.txt' WITH (FORMAT csv, DELIMITER ' ');

-- Part I
-- Insert first half of bag item id, part and item chars
INSERT INTO day03_bag_items SELECT
    ROW_NUMBER() OVER () AS id,
    1,
    unnest(regexp_split_to_array(substring(bag_items, 0, octet_length(bag_items)/2 + 1), ''))
FROM   day03_input;

-- Insert second half of bag item id, part and item chars
INSERT INTO day03_bag_items SELECT
    ROW_NUMBER() OVER () AS id,
    2,
    unnest(regexp_split_to_array(substring(bag_items, octet_length(bag_items)/2 + 1, octet_length(bag_items)), ''))
FROM   day03_input;


WITH priorities AS (
    SELECT generate_series(1,26) AS priority, chr(generate_series(97,122)) AS item
    UNION
    SELECT generate_series(27,52) AS priority, chr(generate_series(65, 90)) AS item
), duplicate_items AS (
    SELECT DISTINCT b1.id, b1.item FROM day03_bag_items b1
        JOIN day03_bag_items b2 ON b2.id = b1.id AND b2.part = 2 AND b1.part = 1
    WHERE b2.item = b1.item
)

SELECT SUM(priorities.priority) FROM duplicate_items
    JOIN priorities ON priorities.item = duplicate_items.item;

-- Part 2
CREATE TABLE bag_groups (
    item_id SERIAL PRIMARY KEY,
    group_id int,
    bag_id int,
    item char
);

INSERT INTO bag_groups(group_id, bag_id, item)
SELECT
    group_id,
    ROW_NUMBER() OVER () AS bag_id,
    unnest(regexp_split_to_array(bag_items, '')) AS item
FROM
    (SELECT ROW_NUMBER() OVER () AS group_id, unnest(items) AS bag_items FROM
        (SELECT
            ROW_NUMBER() OVER () AS group_id,
            CASE WHEN COUNT(bag_items) OVER w = 3
            THEN array_agg(bag_items) OVER w END AS items
        FROM day03_input
        WINDOW w AS (ROWS BETWEEN 0 FOLLOWING AND 2 FOLLOWING)
        ) combinations
    WHERE (combinations.group_id - 1) % 3 = 0 AND items IS NOT NULL) bags;

WITH priorities AS (
    SELECT generate_series(1,26) AS priority, chr(generate_series(97,122)) AS item
    UNION
    SELECT generate_series(27,52) AS priority, chr(generate_series(65, 90)) AS item
), duplicate_items AS (
    SELECT DISTINCT ON (b1.item, b1.group_id) b1.item FROM bag_groups b1
        JOIN bag_groups b2 ON b2.group_id = b1.group_id
        JOIN bag_groups b3 ON b3.group_id = b2.group_id
    WHERE b1.item = b2.item AND b1.item = b3.item AND b2.item = b3.item AND b1.bag_id != b2.bag_id AND b2.bag_id != b3.bag_id AND b1.bag_id != b3.bag_id
)
SELECT SUM(priorities.priority) FROM duplicate_items
    JOIN priorities ON priorities.item = duplicate_items.item;

ROLLBACK;