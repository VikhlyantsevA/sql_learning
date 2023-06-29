-- 1. Users activity
-- There is a table messages with fieled created_at. We want to check daily activity of exact user during month.
-- If there was no activity (no message was sent to anyone), value set to 0, else - to 1.
-- Note: updates are not counted.

-- Let's find most active user
SET @most_active_user = (
	SELECT 
		from_user_id
	FROM messages
	GROUP BY from_user_id
	ORDER BY COUNT(1) DESC, from_user_id DESC
	LIMIT 1
);

SELECT @most_active_user;

-- List created at column for this most active user in descending order and choose month to show activity for.
SET @most_active_month = (
	SELECT 
		DATE_FORMAT(created_at, '%Y-%m') month_created_at
	FROM messages 
	WHERE from_user_id = @most_active_user
	GROUP BY month_created_at
	ORDER BY COUNT(1) DESC, month_created_at DESC
	LIMIT 1
);

SELECT @most_active_month;

SET @start_date = (SELECT STR_TO_DATE(CONCAT(@most_active_month, '-01'), '%Y-%m-%d'));
SET @end_date = (SELECT STR_TO_DATE(CONCAT(@most_active_month, '-01'), '%Y-%m-%d') + INTERVAL 1 MONTH);

SELECT @start_date;
SELECT @end_date;

-- Create procedure that makes table calendar with all days in range between @start_date and @end_date
DROP PROCEDURE IF EXISTS get_dates;

DELIMITER //

CREATE PROCEDURE get_dates(start_date DATE, end_date DATE)
BEGIN
	DECLARE curr_date DATE DEFAULT start_date;
	DROP TEMPORARY TABLE IF EXISTS calendar;
	CREATE TEMPORARY TABLE IF NOT EXISTS calendar(
		date_ DATE NOT NULL UNIQUE
	);
	WHILE curr_date < end_date DO
		INSERT INTO calendar (date_) VALUES (curr_date);
		SET curr_date = DATE_ADD(curr_date, INTERVAL 1 DAY);
	END WHILE;
END//

DELIMITER ;

-- Let's call procedure and create calendar table between @start_date and @end_date 
CALL get_dates(@start_date, @end_date);

SELECT * FROM calendar;

-- Let's note actions from messages table in calendar dates. 
SELECT 
	date_, 
	NOT ISNULL(created_at) action_done 
FROM calendar c
LEFT JOIN (
	SELECT created_at FROM messages
	WHERE from_user_id = @most_active_user AND created_at BETWEEN @start_date AND @end_date
) m
ON c.date_ = DATE(m.created_at)
ORDER BY date_;


-- 2. Friendship offer list.
-- Let's offer top-3 friendship with most often appeared friends of the user friends.  
-- Create users' friends view
DROP VIEW IF EXISTS users_friends;

CREATE VIEW users_friends 
AS 
SELECT user_id, friend_id FROM (
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
WHERE request_type_id = (SELECT id FROM request_types WHERE name = 'accepted');

SELECT * FROM users_friends WHERE user_id = 19;


-- Create procedure with cursor to get friends of the user friends, count frequency of their appearance and sort by this one. 
DROP PROCEDURE IF EXISTS find_friends_of_user_friends;

DELIMITER //

CREATE PROCEDURE find_friends_of_user_friends(IN desired_user BIGINT UNSIGNED)
BEGIN
	DECLARE friend_id_var BIGINT UNSIGNED;
	DECLARE is_end INT DEFAULT 0;
	DECLARE cursor_ CURSOR FOR SELECT friend_id FROM users_friends WHERE user_id = desired_user;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET is_end = 1;
	DROP TEMPORARY TABLE IF EXISTS friends_of_user_friends;
	CREATE TEMPORARY TABLE IF NOT EXISTS friends_of_user_friends(
		friend_id BIGINT UNSIGNED NOT NULL,
		friend_of_friend_id BIGINT UNSIGNED NOT NULL
	);


	OPEN cursor_;

	CYCLE: LOOP
		FETCH cursor_ INTO friend_id_var;
		IF is_end THEN LEAVE CYCLE;
		END IF;
		INSERT INTO friends_of_user_friends 
			SELECT user_id, friend_id FROM users_friends 
			WHERE user_id = friend_id_var;
	END LOOP CYCLE;
	
	CLOSE cursor_;

	SELECT friend_of_friend_id FROM friends_of_user_friends
	WHERE friend_of_friend_id NOT IN (SELECT friend_id FROM users_friends WHERE user_id = desired_user) 
		AND friend_of_friend_id != desired_user
	GROUP BY friend_of_friend_id
	ORDER BY COUNT(1) DESC, RAND()
	LIMIT 3;	
END//

DELIMITER ;

SET @test_user_id = 19;
-- Call procedure
CALL find_friends_of_user_friends(@test_user_id);

-- Let's find friends of user (with @test_user_id) friends in other way (without procedure)
SELECT user_id AS friend_id, friend_id AS friend_of_friend_id FROM users_friends 
WHERE user_id IN (SELECT friend_id FROM users_friends uf WHERE user_id = @test_user_id)
	AND friend_id NOT IN (SELECT friend_id FROM users_friends uf WHERE user_id = @test_user_id)
	AND friend_id != @test_user_id
ORDER BY friend_of_friend_id;

-- Add one of the few friend connections (with from_user_id = 7)
INSERT INTO friend_requests(from_user_id, to_user_id, request_type_id) VALUES
	(7, 98, 1),
	(7, 170, 1);
	
-- Call procedure
CALL find_friends_of_user_friends(@test_user_id);
-- As we can see, user with from_user_id = 7 is on top of the friendship offer list.

-- Let's cancel records that were added above
DELETE FROM friend_requests
	WHERE from_user_id = 7 AND to_user_id IN (98, 170);