USE us_household_income;

# See what states have the biggest land and mass
SELECT state_name, SUM(ALand) AS total_land, SUM(AWater) AS total_water
FROM us_household_income
GROUP BY state_name
ORDER BY 2 DESC
LIMIT 10;

SELECT state_name, SUM(ALand) AS total_land, SUM(AWater) AS total_water
FROM us_household_income
GROUP BY state_name
ORDER BY 3 DESC
LIMIT 10;

/* Join the tables, it seems that unless at least one numeric field in the second table is zero,
others won't be zero, meaning we can filter out based just on one field. */
SELECT *
FROM us_household_income us1
JOIN us_household_income_statistics us2
	ON us1.id = us2.id
WHERE us2.mean != 0;

# See the mean and median salaries by states
SELECT us1.state_name, AVG(mean), AVG(median)
FROM us_household_income us1
JOIN us_household_income_statistics us2
	ON us1.id = us2.id
WHERE us2.mean != 0
GROUP BY us1.state_name
ORDER BY 2 ASC
LIMIT 10;

SELECT us1.state_name, AVG(mean), AVG(median)
FROM us_household_income us1
JOIN us_household_income_statistics us2
	ON us1.id = us2.id
WHERE us2.mean != 0
GROUP BY us1.state_name
ORDER BY 2 DESC
LIMIT 10;

# Check incomes by type
SELECT type, COUNT(type), AVG(mean), AVG(median)
FROM us_household_income us1
JOIN us_household_income_statistics us2
	ON us1.id = us2.id
WHERE us2.mean != 0
GROUP BY type
ORDER BY 3 DESC;

/* There are some types that only have up to 5 entries that we might want to exclude.
   It might explain why 'Municipality' type, for example, has such a huge mean as it is not
   skewed by many data points. */
SELECT type, COUNT(*), AVG(mean), AVG(median)
FROM us_household_income us1
JOIN us_household_income_statistics us2
	ON us1.id = us2.id
WHERE us2.mean != 0
GROUP BY type
ORDER BY 3 DESC;

SELECT type, COUNT(*), AVG(mean), AVG(median)
FROM us_household_income us1
JOIN us_household_income_statistics us2
	ON us1.id = us2.id
WHERE us2.mean != 0
GROUP BY type
HAVING COUNT(*) > 100
ORDER BY 3 DESC;

# Check rows having type 'Municipality' and 'Community'.
SELECT *
FROM us_household_income us1
JOIN us_household_income_statistics us2
	ON us1.id = us2.id
WHERE type = 'Municipality';

# Many low earning households (on average) appear to be communities and from Puerto-Rico
SELECT *
FROM us_household_income us1
JOIN us_household_income_statistics us2
	ON us1.id = us2.id
WHERE type = 'Community';

# Check salaries across cities. A lot of high earning cities are in North-East
SELECT us1.state_name, city, ROUND(AVG(Mean), 1), ROUND(AVG(Median), 1)
FROM us_household_income us1
JOIN us_household_income_statistics us2
	ON us1.id = us2.id
GROUP BY us1.state_name, city
ORDER BY 3 DESC;