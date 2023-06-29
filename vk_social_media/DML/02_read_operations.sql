USE vk_messenger;

-- 1. Basic operators (DISTINCT, GROUP BY ORDER BY, aggregation and other built-in finctions)
--     Find unique first_names of users
SELECT DISTINCT first_name FROM users
ORDER BY first_name;

--     Calculate average age for every users group according to gender
SELECT gender, ROUND(AVG(TIMESTAMPDIFF(YEAR, birthday, CURRENT_TIMESTAMP)), 2) avg_age FROM users
WHERE gender IS NOT NULL
GROUP BY gender;

--     Calculate number of birthdays for every weekday for current year.
--     Notice: get statistics exactly for current year, but not for birthday year.
SELECT day_of_week, COUNT(day_of_week) birthdays_num FROM (
	SELECT DAYOFWEEK(CONCAT(YEAR(NOW()), '-', DATE_FORMAT(birthday,'%m-%d'))) AS day_of_week FROM users
) AS t1
GROUP BY day_of_week
ORDER BY day_of_week;

-- 2. Nested queries, UNION, GROUP BY, HAVING, variables
--     Get info (first_name, last_name, city and country) about users with user_id between 1 and 14
SELECT 
	user_id,
	(SELECT first_name FROM users WHERE profiles.user_id = users.id) first_name,
	(SELECT last_name FROM users WHERE profiles.user_id = users.id) last_name,
	(SELECT city FROM cities WHERE id = profiles.city_id) city,
	(SELECT country FROM countries WHERE id = (
		SELECT country_id FROM cities WHERE id = profiles.city_id
		)
	) country
FROM profiles
WHERE user_id BETWEEN 1 AND 14;

--     Get info (user_id, full_name, photo_id and file_path) of user with email = 'rmattiolia@livejournal.com'.
--     Get info for media type 'image' only with extension *.jpg
SELECT 
	user_id,
	(SELECT CONCAT_WS(' ', first_name, last_name) FROM users WHERE id = media.user_id) AS full_name,
	id AS photo_id,
	file_path
FROM media 
WHERE (user_id = (SELECT id FROM users WHERE email = 'rmattiolia@livejournal.com')) 
	AND media_type_id = (SELECT id FROM media_types WHERE name = 'image')
	AND file_path LIKE '%.jpg';

--     Get number of files of every media type
SELECT 
	media_type_id,
	(SELECT name FROM media_types WHERE id = media.media_type_id) media_type,
	COUNT(1) AS num 
FROM media 
GROUP BY media_type_id;

--     Count content of every extension type
SELECT 
	SUBSTRING_INDEX(file_path, '.', -1) AS extension, 
	COUNT(1) AS num
FROM media
GROUP BY extension;

--     Count content of every extension type for users with user_id <= 6.
--     Sort by increasing user_id and descending number of files with an extension
SELECT 
	user_id,
	SUBSTRING_INDEX(file_path, '.', -1) AS extension, 
	COUNT(1) AS num
FROM media
GROUP BY user_id, extension
HAVING user_id <= 6
ORDER BY user_id, num DESC;


-- Fid friends of user with user_id = 9
-- Version 1 (getting only friend_id)
SET @request_user_id = 1;
SELECT 
	IF(from_user_id = @request_user_id, to_user_id, from_user_id) friend_id
FROM friend_requests
WHERE (from_user_id = @request_user_id OR to_user_id = @request_user_id) 
	AND (request_type_id = (SELECT id FROM request_types WHERE name = 'accepted'));

-- Version 2 (getting only friend_id)
SET @request_user_id = 1;
SELECT to_user_id AS friend_id FROM friend_requests
WHERE (from_user_id = @request_user_id) 
	AND (request_type_id = (SELECT id FROM request_types WHERE name = 'accepted'))
UNION
SELECT from_user_id AS friend_id FROM friend_requests
WHERE (to_user_id = @request_user_id) 
	AND (request_type_id = (SELECT id FROM request_types WHERE name = 'accepted'));
	
-- Version 3 (getting fields friend_id, full_name, gender)
SELECT 
	friend_id,
	(SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE users.id = t1.friend_id) full_name,
	(SELECT 
		CASE gender 
			WHEN 'M' THEN 'male'
			WHEN 'F' THEN 'female'
			ELSE 'undefined'
		END
	FROM users WHERE users.id = t1.friend_id) AS gender,
	(SELECT TIMESTAMPDIFF(YEAR, birthday, CURRENT_TIMESTAMP) FROM users WHERE users.id = t1.friend_id) AS age
FROM (
	SELECT	
		from_user_id AS user_id, 
		to_user_id AS friend_id, 
		request_type_id 
	FROM friend_requests
	UNION
	SELECT	
		to_user_id AS user_id, 
		from_user_id AS friend_id,
		request_type_id 
	FROM friend_requests
) t1
WHERE user_id = 1
	AND (request_type_id = (SELECT id FROM request_types WHERE name = 'accepted'));
	

-- Show all messages of user with user_id = 1. Firstly show messages which were sent to user, then - ones sent by him.
-- Order both groups by field created_at as descending.
SET @request_user_id = 1;
SELECT from_user_id, to_user_id, message_txt, is_delivered, created_at FROM messages
WHERE (from_user_id = @request_user_id OR to_user_id = @request_user_id) AND is_delivered = 1
ORDER BY to_user_id = @request_user_id DESC, created_at DESC;


-- 3. Joins, subqueries, window functions
--     Get info (full_name, gender, age, country, city, vk_id, phone_num, email, passport).
--     Vk_alias is preffered than vk_id if exists.
SELECT
	CONCAT(u.first_name, ' ', u.last_name) AS full_name,
	CASE u.gender
		WHEN 'F' THEN 'female'
		WHEN 'M' THEN 'male'
		ELSE 'undefined'
	END AS gender,
	TIMESTAMPDIFF(YEAR, u.birthday, NOW()) AS age,
	c2.country,
	c1.city,
	COALESCE(u.vk_alias, u.vk_id) AS vk_id, 
	u.phone_num,
	u.email, 
	p.passport
FROM users u 
LEFT JOIN profiles p
ON u.id = p.user_id
LEFT JOIN cities c1
ON p.city_id = c1.id
LEFT JOIN countries c2 
ON c1.country_id = c2.id;

--     Few users are given.
--     Find user(-s) of the social media who chatted with each of the users most of all (sent him messages).
--     If more than one of users have same number of messages, than  show full sorted in descending order by user_id list.
SELECT
	reciever,
	most_active_user,
	messages_sent
FROM (
	SELECT 
		to_user_id AS reciever,
		from_user_id AS most_active_user,
		messages_sent,
		MAX(messages_sent) OVER(PARTITION BY to_user_id) max_messages_sent
	FROM (
		SELECT 
			to_user_id,
			from_user_id, 
			COUNT(1) AS messages_sent
		FROM messages
		WHERE to_user_id IN (120, 145, 157)
		GROUP BY to_user_id, from_user_id
	) AS t1
) AS t2
WHERE messages_sent = max_messages_sent
ORDER BY reciever DESC, most_active_user DESC;

--     Count total number of likes, for posts of users who younger than 18.
SELECT COUNT(1) AS teenager_post_likes FROM posts p 
JOIN users u
ON u.id = p.creator_id
JOIN posts_likes pl 
ON p.id = pl.post_id 
WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 18 AND like_type = 1;


--     Get number of likes left by males and females
SELECT
	CASE gender
		WHEN 'F' THEN 'female'
		WHEN 'M' THEN 'male'
	END gender,
	COUNT(1) likes 
FROM users u 
JOIN posts_likes pl 
ON u.id = pl.user_id 
WHERE like_type = 1 AND gender IS NOT NULL
GROUP BY gender;
