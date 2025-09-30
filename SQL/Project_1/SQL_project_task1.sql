CREATE DATABASE users_adverts;
DROP TABLE users_adverts.users;
SELECT * FROM users_adverts.users;

/* 1. Напишите запрос SQL, выводящий одним числом количество уникальных пользователей
	в этой таблице в период с 2023-11-07 по 2023-11-15. */
SELECT COUNT(DISTINCT user_id) AS unique_users
FROM users_adverts.users
WHERE date BETWEEN '2023-11-07' AND '2023-11-15';

/* 2. Определите пользователя, который за весь период посмотрел наибольшее
	количество объявлений. */
SELECT user_id
FROM users_adverts.users
GROUP BY user_id
ORDER BY SUM(view_adverts) DESC
LIMIT 1;
    
/* 3. Определите день с наибольшим средним количеством просмотренных рекламных
	объявлений на пользователя, но учитывайте только дни с более чем 500
    уникальными пользователями. */
SELECT date
FROM users_adverts.users
GROUP BY date
HAVING COUNT(DISTINCT user_id) > 500
ORDER BY AVG(view_adverts) DESC
LIMIT 1;

/* 4. Напишите запрос возвращающий LT (продолжительность присутствия пользователя на сайте)
	по каждому пользователю. Отсортировать LT по убыванию. */
SELECT user_id, COUNT(DISTINCT date) AS LT
FROM users_adverts.users
GROUP BY user_id
ORDER BY LT DESC;

/* 5. Для каждого пользователя подсчитайте среднее количество просмотренной рекламы за день,
	а затем выясните, у кого самый высокий средний показатель среди тех, кто был активен
    как минимум в 5 разных дней. */
SELECT user_id, AVG(view_adverts) AS avg_viewed_ads
FROM users_adverts.users
GROUP BY user_id
HAVING COUNT(DISTINCT date) >= 5
ORDER BY avg_viewed_ads DESC;