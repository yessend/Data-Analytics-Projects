USE final_project;

SELECT * FROM customers;
SELECT * FROM transactions;

# Таблица customers имеет NULLs только в gender и age, что нормально.
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN id_client IS NULL THEN 1 ELSE 0 END) AS nulls_id_client,
    SUM(CASE WHEN total_amount IS NULL THEN 1 ELSE 0 END) AS nulls_total_amount,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS nulls_gender,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS nulls_age,
    SUM(CASE WHEN count_city IS NULL THEN 1 ELSE 0 END) AS nulls_count_city,
    SUM(CASE WHEN response_communcation IS NULL THEN 1 ELSE 0 END) AS nulls_response_communcation,
    SUM(CASE WHEN communication_3month IS NULL THEN 1 ELSE 0 END) AS nulls_communication_3month,
    SUM(CASE WHEN tenure IS NULL THEN 1 ELSE 0 END) AS nulls_tenure
FROM customers;

# Таблица transactions не имеет NULL значений.
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN date_new IS NULL THEN 1 ELSE 0 END) AS nulls_date_new,
    SUM(CASE WHEN id_check IS NULL THEN 1 ELSE 0 END) AS nulls_id_check,
    SUM(CASE WHEN id_client IS NULL THEN 1 ELSE 0 END) AS nulls_id_client,
    SUM(CASE WHEN count_products IS NULL THEN 1 ELSE 0 END) AS nulls_count_products,
    SUM(CASE WHEN sum_payment IS NULL THEN 1 ELSE 0 END) AS nulls_sum_payment
FROM transactions;

/* Задание 1: */
# Узнать сколько месяцев в общем в которых происходили транзакции.
SELECT DISTINCT date_new
FROM transactions;

SELECT COUNT(DISTINCT date_new) AS month_year_count
FROM transactions;
/* Выходит что транзакционная таблица уже показывает информацию по месяцам
   в формате ГОД-МЕСЯЦ-01. Общее количество месяцев - 13. */

# Вытаскиваем необходимые метрики только для активных пользователей на протяжении всего периода
WITH checks AS (
	# Общая сумма за каджый чек клиентов по датам
	SELECT date_new, id_check, id_client, SUM(sum_payment) AS total_check
    FROM transactions
    GROUP BY date_new, id_check, id_client ),
total_sales_month AS (
	# Общая сумма продаж для каждого клиента по месяцам
    SELECT id_client, date_new, SUM(sum_payment) AS total_sales
    FROM transactions
    GROUP BY id_client, date_new )
SELECT 
	ch.id_client,
	AVG(ch.total_check) AS avg_check,
    AVG(tsm.total_sales) AS avg_sales_month,
    COUNT(DISTINCT ch.id_check) AS operations_count
FROM checks ch
JOIN total_sales_month tsm
	ON ch.id_client = tsm.id_client
WHERE (ch.date_new >= '2015-06-01' AND ch.date_new <= '2016-06-01') AND ch.id_client IN (
	SELECT id_client
	FROM transactions
	GROUP BY id_client
	HAVING COUNT(DISTINCT date_new) = 13 )
GROUP BY ch.id_client
ORDER BY ch.id_client ASC;

/* Задание 2: */
/* Здесь интерпертация среднего "количества" за месяц в разрезе месяцев берется как количество за месяц
   так как данные дат предоставлены в месячном формате. Также были добавлены дополнительные средние показатели. */
WITH checks AS (
	# Общая сумма за каджый чек клиентов по датам
	SELECT date_new, id_check, id_client, SUM(sum_payment) AS total_check
    FROM transactions
    GROUP BY date_new, id_check, id_client )
SELECT 
	date_new, 
    AVG(total_check) AS avg_check,
    COUNT(id_check) AS operations_amount,
    COUNT(DISTINCT ch.id_client) AS puchasing_clients,
    SUM(total_check) / COUNT(DISTINCT ch.id_client) AS avg_check_per_client,
    COUNT(id_check) / COUNT(DISTINCT ch.id_client) AS avg_operations_per_client,
    ROUND(100 * COUNT(id_check) / SUM(COUNT(id_check)) OVER(), 3) AS percent_of_total_operations,
    ROUND(100 * SUM(total_check) / SUM(SUM(total_check)) OVER(), 3) AS percent_of_total_sales,
    CONCAT(
		ROUND(100 * COUNT(CASE WHEN gender = 'M' THEN 1 END) / COUNT(id_check), 1), '/',
		ROUND(100 * COUNT(CASE WHEN gender = 'F' THEN 1 END) / COUNT(id_check), 1), '/',
		ROUND(100 * COUNT(CASE WHEN gender IS NULL THEN 1 END) / COUNT(id_check), 1)
    ) AS M_F_NA_operations_percentages,
    CONCAT(
		ROUND(100 * SUM(CASE WHEN gender = 'M' THEN total_check ELSE 0 END) / SUM(total_check), 1), '/',
		ROUND(100 * SUM(CASE WHEN gender = 'F' THEN total_check ELSE 0 END) / SUM(total_check), 1), '/',
		ROUND(100 * SUM(CASE WHEN gender IS NULL THEN total_check ELSE 0 END) / SUM(total_check), 1)
    ) AS M_F_NA_sales_percentages
FROM checks ch
JOIN customers cus
	ON ch.id_client = cus.id_client
WHERE (date_new >= '2015-06-01' AND date_new <= '2016-06-01')
GROUP BY date_new
ORDER BY date_new ASC;

/* Задание 3: */
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
    COUNT(id_check) AS operations_amount,
    COUNT(DISTINCT ch.id_client) AS puchasing_clients,
    # Средний чек как средний показатель
    AVG(total_check) AS avg_check,
    # Среднее количество операций на клиента был также взят как средний показатель
    COUNT(id_check) / COUNT(DISTINCT ch.id_client) AS avg_operations_per_client,
    # Здесь процентаж продаж в кварталах относительно всех продаж определенной возрастной группы
    100 * SUM(total_check) / SUM(SUM(total_check)) OVER(PARTITION BY age_group) AS sales_percent,
    # Здесь процентаж операций в кварталах относительно всех операций определенной возрастной группы
    100 * COUNT(id_check) / SUM(COUNT(id_check)) OVER(PARTITION BY age_group) AS operations_percent
FROM checks ch
JOIN age_groups ag
	ON ch.id_client = ag.id_client
GROUP BY age_group, year_quarter
ORDER BY age_group ASC, year_quarter ASC;