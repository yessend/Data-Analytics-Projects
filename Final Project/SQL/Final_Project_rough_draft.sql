USE final_project;

# Узнаем максимальный возраст: 88 лет
SELECT MAX(age) FROM customers;

WITH age_groups AS (
	SELECT *,
		CASE
			WHEN age < 10 THEN '[0; 10)'
            WHEN age < 20 THEN '[10; 20)'
            WHEN age < 30 THEN '[20; 30)'
            WHEN age < 40 THEN '[30; 40)'
            WHEN age < 50 THEN '[40; 50)'
            WHEN age < 60 THEN '[50; 60)'
            WHEN age < 70 THEN '[60; 70)'
            WHEN age < 80 THEN '[70; 80)'
            WHEN age < 90 THEN '[80; 90)'
            WHEN age IS NULL THEN 'no age group'
            ELSE 'invalid'
        END AS age_group
	FROM customers ),
checks AS (
	# Общая сумма за каджый чек клиентов по кварталам
	SELECT CONCAT(YEAR(date_new), '-Q', QUARTER(date_new)) AS year_quarter,
		id_check, id_client, SUM(sum_payment) AS total_check
	FROM transactions
	GROUP BY year_quarter, id_check, id_client )
SELECT
	age_group, 
    year_quarter,
    SUM(SUM(total_check)) OVER(PARTITION BY age_group) AS total_sales_whole_period,
    SUM(COUNT(id_check)) OVER(PARTITION BY age_group) AS total_operations_whole_period,
    AVG(total_check) AS avg_check,
    COUNT(id_check) / COUNT(DISTINCT ch.id_client) AS avg_operations_per_client,
    100 * SUM(total_check) / SUM(SUM(total_check)) OVER() AS sales_percent,
    100 * COUNT(id_check) / SUM(COUNT(id_check)) OVER() AS operations_percent
FROM checks ch
JOIN age_groups ag
	ON ch.id_client = ag.id_client
GROUP BY age_group, year_quarter
ORDER BY age_group ASC, year_quarter ASC;