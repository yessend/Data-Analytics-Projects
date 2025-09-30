# World Life Expectancy dataset Exploratory Data Analysis (EDA)
USE world_life_expectancy;

SELECT *
FROM world_life_expectancy;

SELECT country, MAX(`Life expectancy`) AS max_life_expectancy,
	MIN(`Life expectancy`) AS min_life_expectancy,
    ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) AS life_expectancy_increase
FROM world_life_expectancy
GROUP BY country
HAVING  MAX(`Life expectancy`) != 0
AND MIN(`Life expectancy`) != 0
ORDER BY life_expectancy_increase DESC;
/* It seems that the biggest increase in life expectancy over the last 15 years has been observed mostly in countries of the third world (as well as developing world) as they had a life expectancy significantly lower in the past compared to countries from the developed world. Otherwise, countries that already had a quite high life expectancy increased it only by couple of years. */

SELECT year, ROUND(AVG(`Life expectancy`),1) AS avg_life_expectancy
FROM world_life_expectancy
WHERE `Life expectancy` != 0
GROUP BY year
ORDER BY avg_life_expectancy DESC;
-- As a world, there has been about 5 years increase in life expectancy

SELECT country, ROUND(AVG(`Life expectancy`), 1) AS avg_life_expectancy,
ROUND(AVG(GDP), 1) AS avg_gdp
FROM world_life_expectancy
GROUP BY country
HAVING avg_life_expectancy != 0 AND avg_gdp != 0 
ORDER BY avg_gdp DESC, avg_life_expectancy DESC;
-- It seems that the life expectancy might be positively correlated with the GDP of the country

WITH gdp_percentiles AS (
	SELECT gdp,
	100 * PERCENT_RANK() OVER(ORDER BY GDP ASC) AS percentiles
	FROM world_life_expectancy
) SELECT gdp
FROM gdp_percentiles
WHERE percentiles >= 50
ORDER BY percentiles
LIMIT 1;
# Here we find the median GDP across all countries and accross all years to use in the next query.

SELECT 
SUM( CASE WHEN GDP > 1173 THEN 1 ELSE 0 END ) AS high_gdp_rows,
ROUND( AVG( CASE WHEN GDP > 1173 THEN `Life expectancy` ELSE NULL END ), 2 ) AS high_gdp_avg_life_expectancy,
SUM( CASE WHEN GDP <= 1173 THEN 1 ELSE 0 END ) AS low_gdp_rows,
ROUND( AVG( CASE WHEN GDP <= 1173 THEN `Life expectancy` ELSE NULL END ), 2 ) AS low_gdp_avg_life_expectancy
FROM world_life_expectancy;
/* This observation further confirms that there might be a positive correlation between the gdp and life expectancy. */

SELECT status, 
COUNT(DISTINCT country ) AS number_of_countries,
ROUND( AVG( `Life expectancy` ), 2 ) AS avg_life_expectancy
FROM world_life_expectancy
GROUP BY status;
/* It might seem that the life expectancy is higher for developed countries, however we need to keep in mind that there are a lot more developing countries, than developed countries, meaning there might be developing countries with high life expectancy, however due to the the huge number of developing countries the overall average is brought down by developing countries with lower life expectancy. */

SELECT country, ROUND( AVG(`Life expectancy`), 2 ) avg_life_expectancy,
ROUND( AVG(BMI), 2 ) avg_bmi
FROM world_life_expectancy
GROUP BY country
HAVING avg_life_expectancy > 0 AND avg_bmi > 0
ORDER BY avg_bmi DESC, avg_life_expectancy DESC;
/* The data shows that countries with high average BMI actually have high average life expectancy over the last 15 years and vice versa. There might be positive correlation between these two variables. While one might expect that people with high BMI might suffer from health complications, the data seems rather suggest that low BMI might indicator of poor nutrition in a country. */

SELECT country, year, `Life expectancy`, `Adult mortality`,
SUM(`Adult mortality`) OVER(PARTITION BY country ORDER BY year ASC) AS rolling_total
FROM world_life_expectancy
WHERE country LIKE '%stan%';
/* Here we observe total adult mortality over the past 15 years for each country and also see if there is some association with life expectancy. */