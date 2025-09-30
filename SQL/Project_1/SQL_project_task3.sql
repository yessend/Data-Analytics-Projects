/* 1. Выведите сколько пользователей добавили книгу 'Coraline',
	сколько пользователей прослушало больше 10%. */
SELECT COUNT(DISTINCT ac.user_id) AS users_added_Coraline,
COUNT(DISTINCT users_listened.user_id) AS users_listened_more_than_10_percent_of_Coraline
FROM audio_cards ac
JOIN audiobooks ab ON ac.audiobook_uuid = ab.uuid
LEFT JOIN (	
	SELECT l.user_id, l.audiobook_uuid
	FROM listenings l
	JOIN audiobooks ab
	ON l.audiobook_uuid = ab.uuid
	AND ab.title = 'Coraline'
	GROUP BY l.user_id, audiobook_uuid, ab.duration
	HAVING ROUND(SUM(l.position_to - l.position_from)*1.0/ab.duration, 4) > 0.1000	) AS users_listened
ON ac.user_id = users_listened.user_id AND ac.audiobook_uuid = users_listened.audiobook_uuid
WHERE ab.title = 'Coraline';

/* 2. По каждой операционной системе и названию книги выведите
	количество пользователей, сумму прослушивания в часах, не учитывая
	тестовые прослушивания. */
SELECT a.title, l.os_name,
COUNT( DISTINCT l.user_id ) AS num_of_users,
ROUND(SUM(l.position_to - l.position_from) / 3600.0, 3) AS listened_hours
FROM audiobooks a
JOIN listenings l
ON a.uuid = l.audiobook_uuid AND l.is_test != 1
GROUP BY l.os_name, a.title
ORDER BY a.title, l.os_name;

/* 3. Найдите книгу, которую слушает больше всего людей. */
SELECT title
FROM audiobooks
WHERE uuid IN (
	SELECT audiobook_uuid
	FROM audio_cards
	GROUP BY audiobook_uuid
	ORDER BY COUNT( user_id ) DESC
	LIMIT 1	);

/* 4. Найдите книгу, которую чаще всего дослушивают до конца. */
SELECT ab.title, COUNT(*) AS completed_count
FROM listenings l
JOIN audiobooks ab ON l.audiobook_uuid = ab.uuid
WHERE l.position_to = ab.duration
GROUP BY ab.title
ORDER BY completed_count DESC
LIMIT 1;

/* 4. Версия 2 */
SELECT title
FROM audiobooks
WHERE uuid IN (
	SELECT audiobook_uuid
	FROM audio_cards
	GROUP BY audiobook_uuid
	ORDER BY SUM( CASE WHEN state = 'finished' THEN 1.0 ELSE 0.0 END ) / COUNT(DISTINCT user_id) DESC
	LIMIT 1	);