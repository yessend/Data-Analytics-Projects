# Create the database
CREATE DATABASE us_household_income;

# Select the database
USE us_household_income;

# Import the tables using the wizard

# Alter the name of the tables to be more convenient
ALTER TABLE ushouseholdincome
RENAME TO us_household_income;

ALTER TABLE ushouseholdincome_statistics
RENAME TO us_household_income_statistics;

# Check the tables
SELECT *
FROM us_household_income;

SELECT *
FROM us_household_income_statistics;

# Create the duplicates of the tables to work on them
ALTER TABLE us_household_income
RENAME TO us_household_income_original;

CREATE TABLE IF NOT EXISTS us_household_income LIKE us_household_income_original;
INSERT INTO us_household_income
SELECT * FROM us_household_income_original;

SELECT *
FROM us_household_income;

ALTER TABLE us_household_income_statistics
RENAME TO us_household_income_statistics_original;

CREATE TABLE IF NOT EXISTS us_household_income_statistics LIKE us_household_income_statistics_original;
INSERT INTO us_household_income_statistics
SELECT * FROM us_household_income_statistics_original;

SELECT *
FROM us_household_income_statistics;

# Delete duplicates from the us_household_income table
DELETE FROM us_household_income
WHERE row_id IN (
	WITH duplicate_del AS (
		SELECT row_id, id, ROW_NUMBER() OVER(PARTITION BY id ORDER BY row_id ASC) AS row_num
		FROM us_household_income )
	SELECT row_id
	FROM duplicate_del
	WHERE row_num > 1 );

# Checked missing values in the columns using COUNT function for each column separately in both tables

# Fill missing values in the place field of the us_household_income table in both tables
UPDATE us_household_income us1
JOIN us_household_income us2
ON us1.county = us2.county AND us1.city = us2.city AND
us1.place IS NULL AND us2.place IS NOT NULL
SET us1.place = us2.place;

# The query below shows that there are no duplicates in the us_household_income_statistics table
SELECT * FROM (
SELECT id, ROW_NUMBER() OVER(PARTITION BY id ORDER BY id ASC) AS row_num
FROM us_household_income_statistics) duplicates
WHERE row_num > 1;

# Correct the states name in the us_household_income table
UPDATE us_household_income
SET state_name = 'Georgia'
WHERE state_name = 'georia';

UPDATE us_household_income
SET state_name = 'Alabama'
WHERE state_name = 'alabama';

# Check types
SELECT DISTINCT type
FROM us_household_income
ORDER BY 1;

# Update incorrect type name
UPDATE us_household_income 
SET type = 'Borough'
WHERE type = 'Boroughs';

# Check water: there are some rows having zero water area (no blanks and no NULLs).
SELECT DISTINCT AWater
FROM us_household_income
WHERE AWater = 0 OR AWater = '' OR AWater IS NULL;

# Check land: there are some rows that have zero land area (no blanks and no NULLs). 
SELECT DISTINCT ALand
FROM us_household_income
WHERE ALand = 0 OR ALand = '' OR ALand IS NULL;

/* Shows that there are no rows having both land or water zero, blank, or NULL (good thing).
Thus, we don't need to clean land and water fields. */
SELECT *
FROM us_household_income
WHERE ( AWater = 0 OR AWater = '' OR AWater IS NULL ) AND
( ALand = 0 OR ALand = '' OR ALand IS NULL );