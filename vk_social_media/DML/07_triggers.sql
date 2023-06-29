USE vk_messenger;

-- Let's suppose that first_name and last_name are optional fields
-- Change table structure to be that
ALTER TABLE users MODIFY COLUMN first_name VARCHAR(128);
ALTER TABLE users MODIFY COLUMN last_name VARCHAR(128);

DESCRIBE users;

-- Let's create trigger that's not allow appearance of NULL both in last_name and first_name
DROP TRIGGER IF EXISTS check_insert_name;
DROP TRIGGER IF EXISTS check_update_name;

DELIMITER //

CREATE TRIGGER check_insert_name BEFORE INSERT ON users
FOR EACH ROW 
BEGIN
	IF NEW.first_name IS NULL AND NEW.last_name IS NULL THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = "Both first and last names can't be NULL";
	END IF;
END//

CREATE TRIGGER check_update_name BEFORE UPDATE ON users
FOR EACH ROW 
BEGIN
	IF NEW.first_name IS NULL AND NEW.last_name IS NULL THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = "Both first and last names can't be NULL";
	END IF;
END//

DELIMITER ;

-- Find last user
SET @start_id_num = (SELECT MAX(id) FROM users);
SELECT @start_id_num;

-- Let's check how trigger works
INSERT INTO users (vk_alias, email, password_hash, phone_num, first_name, last_name, birthday) VALUES 
	('rdives2', 'rdives2@360.cn', '5a80246d2deb64ea57e05c3a42c4113c', '+86-844-463-0937', 'Roxi', 'Dives', '2007-09-26 09:08:35'),
	(null, 'redlyn3@prlog.org', '5b6f589abd73662bd92b7b43fe35f00d', '+86-775-737-4338', 'Janean', null, '2007-10-30 11:41:10'),
	('jsimonitto4', 'jsimonitto4@1688.com', '603ea8349c2aec0326a63fec5f529bdb', '+351-321-764-9249', null, 'Simonitto', '2001-07-27 13:36:23'),
	(null, 'kscriviner0@issuu.com', '4c3bde5e12597a22ab0baa503ee455c6', '+351-406-535-2985', null, null, '1999-12-21 10:27:21'),
	(null, 'lbackler1@blinklist.com', '37770e93d7d317653723bf88e620273f', '+1-118-893-9156', null, null, '2005-02-23 05:39:08');

-- As we can see values were not added
SET @current_id_num = (SELECT MAX(id) FROM users);
SELECT @current_id_num != @start_id_num AS data_added;

-- Let's try update data
INSERT INTO users (vk_alias, email, password_hash, phone_num, first_name, last_name, birthday) VALUES 
	('rdives2', 'rdives2@360.cn', '5a80246d2deb64ea57e05c3a42c4113c', '+86-844-463-0937', 'Roxi', 'Dives', '2007-09-26 09:08:35');

-- Set last name of user with email='rdives2@360.cn' to NULL
UPDATE users 
SET
	last_name = NULL
WHERE email = 'rdives2@360.cn';

-- Done.
SELECT email, first_name, last_name FROM users WHERE email = 'rdives2@360.cn';

-- Set first name of user with email='rdives2@360.cn' to NULL
UPDATE users 
SET
	first_name = NULL
WHERE email = 'rdives2@360.cn';
-- Trigger worked

-- Let's revert table modifications
DELETE FROM users WHERE id > @start_id_num;
ALTER TABLE users MODIFY COLUMN first_name VARCHAR(128) NOT NULL;
ALTER TABLE users MODIFY COLUMN last_name VARCHAR(128) NOT NULL;
DESCRIBE users;