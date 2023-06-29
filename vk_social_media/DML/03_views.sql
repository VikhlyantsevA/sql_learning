USE vk_messenger;

DROP VIEW IF EXISTS users_activity;

CREATE VIEW users_activity 
AS 
SELECT 
	id user_id,
	COALESCE(vk_alias, vk_id) vk_id,
	email, 
	phone_num,
	CONCAT(first_name, ' ', last_name) full_name,
	CASE(gender)
		WHEN 'M' THEN 'male'
		WHEN 'F' THEN 'female'
		ELSE 'undefined'
	END gender,
	TIMESTAMPDIFF(YEAR, birthday, NOW()) age,
	is_active,
	created_at signed_up_at,
	posts_liked,
	friend_requests
FROM users u
LEFT JOIN(
	SELECT user_id, COUNT(like_type) posts_liked FROM posts_likes
	WHERE like_type != 0
	GROUP BY user_id
) pl
ON u.id = pl.user_id
LEFT JOIN (
	SELECT from_user_id, COUNT(to_user_id) friend_requests FROM friend_requests
	GROUP BY from_user_id
) fr
ON u.id = fr.from_user_id;
