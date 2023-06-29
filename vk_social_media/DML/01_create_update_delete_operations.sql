USE vk_messenger;

-- 1. Messages ()
-- 	Let's add messages from future
INSERT IGNORE INTO messages (from_user_id, to_user_id, message_txt, is_delivered, created_at) VALUES 
	(77, 180, 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst.', false, '2031-09-23 14:47:57'),
	(183, 42, 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae, Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', true, '2024-12-05 14:38:59'),
	(74, 197, 'Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo.', true, '2027-11-19 13:22:38'),
	(95, 168, 'Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.', true, '2026-11-22 13:21:26'),
	(106, 75, 'Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus.', false, '2027-08-01 04:58:53'),
	(149, 123, 'Duis bibendum.', true, '2027-01-23 12:21:43'),
	(53, 122, 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', false, '2031-04-12 06:04:18'),
	(113, 13, 'Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.', false, '2030-09-02 03:16:37'),
	(75, 153, 'Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', false, '2024-06-17 19:47:57'),
	(44, 128, 'Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.', true, '2029-12-02 18:40:52');

-- 	Check number of messages from future
SELECT COUNT(1) messeges_from_future FROM messages
WHERE created_at > NOW();

-- 	Delete all messages from future 
DELETE FROM messages
WHERE created_at > NOW();


-- 2. Users
-- 	Check last id in users table and save it to local variable
SET @previous_last_id = (SELECT MAX(id) max_id FROM users);
SELECT @previous_last_id;

-- 	Let's add more users
INSERT IGNORE INTO users (vk_alias, email, password_hash, phone_num, first_name, last_name, gender, birthday) VALUES 
	('kbalshaw0', 'kbalshaw0@webs.com', '835df882bbcceb4e243d41f0e2b89200', '+355-295-559-3103', 'Kerr', 'Balshaw', 'M', '2014-10-10 07:17:54'),
	(null, 'cplumridge1@constantcontact.com', '670fcf3002566685ee53f71041816f85', '+962-341-757-5200', 'Constantine', 'Plumridge', 'F', '2010-11-28 08:12:28'),
	(null, 'cciobotaro2@acquirethisname.com', 'c512c8cf8bf63f629dd5bd029dec32cb', '+1-305-691-1411', 'Clarence', 'Ciobotaro', 'F', '2015-02-07 17:58:45'),
	('eoloshkin3', 'eoloshkin3@digg.com', '94c1ef5e082152ae41d63bbfdfd35996', '+977-908-549-0637', 'Eal', 'Oloshkin', 'M', '2012-04-05 14:57:25'),
	('mgoodram4', 'mgoodram4@tamu.edu', '052eec883ee08160e39f8efd79a590ae', '+86-867-922-9172', 'Mayer', 'Goodram', 'M', '2012-05-10 10:42:29'),
	(null, 'sgreatrakes5@dedecms.com', '2e9c10f7194e7edd10546231ea173a11', '+353-163-745-5765', 'Stanislaw', 'Greatrakes', 'M', '2011-02-04 16:53:41'),
	('hthonason6', 'hthonason6@latimes.com', 'e14821878fca26990e607d2008263eb6', '+237-192-843-9676', 'Hadlee', 'Thonason', 'M', '2015-10-01 18:01:25'),
	('arangell7', 'arangell7@ox.ac.uk', '3a6ccfb9973fdd376b9b5ac3d12bc3a3', '+7-208-989-4288', 'Abner', 'Rangell', 'M', '2012-10-29 01:16:15'),
	(null, 'bbritch8@symantec.com', 'ec418aa96f2b059be4977f77178bc0e5', '+86-559-878-2142', 'Broderick', 'Britch', 'M', '2015-04-30 03:36:03'),
	('tgartrell9', 'tgartrell9@reference.com', 'ed9383b8cb8a0d84d20d682287269b35', '+380-743-323-1532', 'Thaxter', 'Gartrell', 'F', '2011-07-19 05:12:10');

-- 	Check number of new records
SELECT COUNT(1) new_records FROM users
WHERE id > @previous_last_id;

DESCRIBE users;

-- 	Let's check how much younger than 14 users in new records
SELECT COUNT(1) teenagers FROM users
WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 14 AND id > @previous_last_id;

-- 	Let's check their account status (is_active)
SELECT id, is_active FROM users
WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 14 AND id > @previous_last_id;

-- 	Let's switch off users from new records who is younger than 14  
UPDATE users
SET
	is_active = 0
WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 14;

-- 	Let's delete all new records
DELETE FROM users
WHERE id > @previous_last_id;