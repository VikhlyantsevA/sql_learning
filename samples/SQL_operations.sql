-- Database structures creation
{CREATE | DROP} DATABASE [IF NOT EXISTS | IF EXISTS] <database_name>;
CREATE [TEMPORARY] TABLE IF NOT EXISTS <tbl_name> (
	<column_1_description>,
	...
	<column_n_description>
);
DROP [TEMPORARY] TABLE IF EXISTS <tbl_name>;

-- Tables modification
ALTER TABLE <table_name> {DROP | ADD} INDEX <index_name>(<column_name>);
ALTER TABLE <table_name> {DROP | ADD} INDEX <column_name>; -- generates index name automatically

ALTER TABLE <table_name> ADD CONSTRAINT <constraint_name> CHECK(REGEXP_LIKE(email, '^[a-zA-Z0-9]+@[a-zA-Z\\.\\-0-9]+\\.[a-zA-Z]+$'));
ALTER TABLE <table_name> ADD CONSTRAINT <constraint_name> FOREIGN KEY (<child_table_col>) REFERENCES <parent_table_name>(<parent_table_col>);
ALTER TABLE <table_name> DROP CONSTRAINT <constraint_name>;

ALTER TABLE <table_name> ADD COLUMN <column_name> <column_description>;
ALTER TABLE <table_name> DROP COLUMN <column_name>;

ALTER TABLE <table_name> MODIFY COLUMN <column_name> <new_column_description>;
ALTER TABLE <table_name> RENAME COLUMN <old_column_name> TO <new_column_name>;


-- Table description
DESCRIBE <table_name>;
SHOW CREATE TABLE <table_name>;

-- Variables
SET FOREIGN_KEY_CHECKS = [1 | 0]; -- Set if foreign key constraint will be checked or not correspondingly during truncate/delete/update operations


-- CRUD
-- 	Create
INSERT [IGNORE] [INTO] <table_name>[(<column_1_name>,...,<column_n_name>)] VALUES
(<row_1_value_1>,...,<row_1_value_n>),
...
(<row_m_value_1>,...,<row_m_value_n>); -- if no columns mentioned, all of them will be used to insert

INSERT [IGNORE] [INTO] <table_name>[(<column_1_name>,...,<column_n_name>)] 
<select_query>;

INSERT [IGNORE] [INTO] <table_name>
SET
	<column_1_name> = <value_1>,
	...
	<column_n_name> = <value_n>;


-- 	Read
-- 	Window functions
SELECT 
	{SUM | AVG | MAX | MIN | COUNT}(<agg_column_name>) OVER([PARTITION BY <part_column_name>]),
	{ROW_NUMBER | RANK | DENSE_RANK}() OVER([PARTITION BY <part_column_name>] [ORDER BY <ord_column_name> {ASC | DESC}]),
	{LEAD | LAG}(<to_get_value_column_name>) OVER([PARTITION BY <part_column_name>] [ORDER BY <ord_column_name> {ASC | DESC}])-- get next or previous value in choosen column with partitioning and ordering according to over-clause
FROM <table_name>
[ORDER BY <column_name_1> {ASC | DESC},...,<column_name_n> {ASC | DESC}]
[LIMIT <number_of_rows>];


-- 	Update
UPDATE <table_name>
SET
	<column_1_name> = <value_1>,
	...
	<column_n_name> = <value_n>
WHERE <condition_>;


-- 	Delete
TRUNCATE TABLE <table_name>;

DELETE FROM <table_name>
WHERE <condition_>;