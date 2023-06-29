USE vk_messenger;

-- 1. Create function to get user popularity rate and use it to sort friends of the user in descending order.
-- Formula to popularity_rate = (total incoming friendship requests)/(total outcoming friendship requests)
DROP FUNCTION IF EXISTS find_user_popularity;

DELIMITER //

CREATE FUNCTION find_user_popularity(desired_user_id BIGINT UNSIGNED)
RETURNS FLOAT READS SQL DATA
BEGIN
	DECLARE cnt_to_user INT;
	DECLARE cnt_from_user INT;

	-- Count total incoming friendship requests
    -- 	SET cnt_to_user = (SELECT COUNT(*) FROM friend_requests WHERE to_user_id = desired_user_id);
    SELECT COUNT(*) INTO cnt_to_user FROM friend_requests WHERE to_user_id = desired_user_id;
	-- Count total outcoming friendship requests
	SELECT COUNT(*) INTO cnt_from_user FROM friend_requests WHERE from_user_id = desired_user_id;

	IF cnt_from_user = 0
	THEN
		RETURN cnt_to_user;
	ELSE
		RETURN cnt_to_user / cnt_from_user;
	END IF;
END//

DELIMITER ;

-- Call function and round result to third sign after delimiter
SELECT TRUNCATE(find_user_popularity(1), 3);

-- Show friends of user with user_id = @test_user_id and sort them according to the popularity_rate
SET @test_user_id = 19;

SELECT DISTINCT
    u.id,
    TRUNCATE(find_user_popularity(u.id), 3) AS popularity_rate
FROM friend_requests fr
JOIN users u
ON fr.from_user_id = u.id OR fr.to_user_id = u.id
WHERE (fr.from_user_id = @test_user_id OR fr.to_user_id = @test_user_id)
  AND fr.request_type_id = 1
  AND u.id != @test_user_id
ORDER BY popularity_rate DESC;


-- 2. Create greeting function with timezone  
/*
 * Let's create function hello(), that returns greeting which depends on current day time. 
 * Function returns: 
 * 	'Good night' from 0 am to 6 am.
 * 	'Good morning' from 6 am to 12 am, 
 * 	'Good afternoon' from 12 am to 6 pm, 
 * 	'Good evening' from 6 pm 0 am, 
*/
DROP FUNCTION IF EXISTS hello;
DELIMITER //

CREATE FUNCTION hello(name VARCHAR(50))
RETURNS VARCHAR(50) DETERMINISTIC
BEGIN
	DECLARE hour_ TINYINT;
	SET hour_ = HOUR(CONVERT_TZ(NOW(), 'SYSTEM', 'Asia/Bangkok'));
	CASE
		WHEN hour_ BETWEEN 0 AND 5 THEN
			RETURN CONCAT('Good night, ', name);
		WHEN hour_ BETWEEN 6 AND 11 THEN
			RETURN CONCAT('Good morning, ', name);
		WHEN hour_ BETWEEN 12 AND 17 THEN
			RETURN CONCAT('Good afternoon, ', name);
		WHEN hour_ BETWEEN 18 AND 23 THEN
			RETURN CONCAT('Good evening, ', name);
	END CASE;
END//

DELIMITER ;

-- Run function with greeting
SELECT hello('Aleksander') AS greeting;
-- Check current time in local timezone
SELECT CONVERT_TZ(NOW(),'SYSTEM','Asia/Bangkok') AS current_time_tz;