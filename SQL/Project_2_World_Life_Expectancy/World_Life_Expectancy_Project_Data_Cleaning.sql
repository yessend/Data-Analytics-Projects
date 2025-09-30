# World Life Expectancy dataset Data Cleaning
USE world_life_expectancy;

ALTER TABLE world_life_expectancy
RENAME TO world_life_expectancy_staging;
# Renamed the table to the raw table that we won't use.

CREATE TABLE IF NOT EXISTS world_life_expectancy
LIKE world_life_expectancy_staging;
/* Created the buffering table so that we can manipulate and clean the data without
being scared that we might accidentally delete the data. */

INSERT INTO world_life_expectancy
SELECT * FROM world_life_expectancy_staging;
# Copied the raw data into the buffering table that we will use

SELECT *
FROM world_life_expectancy;

SELECT country, year, COUNT(*) AS row_num
FROM world_life_expectancy
GROUP BY country, year
HAVING row_num > 1;
# Saw how many duplicates we have

DELETE FROM world_life_expectancy
WHERE row_id IN (
	SELECT row_id
	FROM (
		SELECT country, year, row_id,
		ROW_NUMBER() OVER(PARTITION BY country, year ORDER BY row_id ASC) AS row_num
		FROM world_life_expectancy ) temp
	WHERE row_num > 1 );
# Deleted duplicates based on the row_id that is the second duplicate in the order by row_id's.
    
SELECT *
FROM world_life_expectancy
WHERE status = '' OR status IS NULL;
# Checked countries that have no status or have NULL values there to clean data in that column.

SELECT DISTINCT(status)
FROM world_life_expectancy
WHERE status <> '';
# Checked how many different status values we have to populate missing values in that column.

SELECT DISTINCT(country)
FROM world_life_expectancy
WHERE status = 'Developing';
# Checked countries that have 'Developing' status to populate missing values in that column for those countries.

UPDATE world_life_expectancy
SET status = 'Developing'
WHERE country IN (
	SELECT DISTINCT(country)
	FROM world_life_expectancy
	WHERE status = 'Developing'
);
/* Tried to populate status field for Developing countries, but this query failed. 
We cannot update some field value in the rows of the table that is being used in the FROM clause in 
the subquery. To be able to do so, we need to use subquery in the subquery or update using the JOIN statement (self join). */

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
ON t1.country = t2.country
SET t1.status = 'Developing'
WHERE t1.status = ''
AND t2.status = 'Developing';
/* Populated status field for Developing countries. Here we succeeded. We only need one match in the self join
to update the necessary field in the row (then we will have that updated value in all other rows that satisfy the joining
condition). */

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
ON t1.country = t2.country
SET t1.status = 'Developed'
WHERE t1.status = ''
AND t2.status = 'Developed';
# Populated status field for Developed countries.

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
ON t1.country = t2.country
	AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
ON t2.country = t3.country
	AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND( ( t2.`Life expectancy` + t3.`Life expectancy` ) / 2, 1 )
WHERE t1.`Life expectancy` = '' OR t1.`Life expectancy` IS NULL;
/* Used the same technique to populate the `Life expectancy` field with the average of the `Life expectancy` field
from the previous and the next years. Might be a faulty approach, need to make sure that the `Life expectancy` field HAS
non-zero non-null values in the previous and next years. */