-- Let's create extra table e_wallet to exercise on transactions
DROP TABLE IF EXISTS e_wallet;
CREATE TABLE IF NOT EXISTS e_wallet(
	user_id SERIAL PRIMARY KEY,
	balance DECIMAL(9,2) NOT NULL,
	balance_type ENUM('debit', 'credit') NOT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT mt_user_id FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Put some data into table
INSERT INTO e_wallet (user_id, balance, balance_type) VALUES 
	(77, 182635, 'credit'),
	(131, 6712, 'credit'),
	(148, 1300, 'debit'),
	(29, 67091, 'credit'),
	(104, 91206, 'debit'),
	(184, 167905, 'credit'),
	(188, 152135, 'credit'),
	(38, 146164, 'credit'),
	(196, 3605, 'debit'),
	(156, 89723, 'debit');


-- Create procedure with transaction. Metioned amount of money will be charged from user with from_user_id and put to user with to_user_id.
-- Balance must be positive only. If money not enough to be charged, transaction is canceled and rollback made.
DROP PROCEDURE IF EXISTS `money_transfer_trans`;

DELIMITER //

CREATE PROCEDURE `money_transfer_trans`(
	from_user_id BIGINT UNSIGNED,
	money DECIMAL(9,2),
	to_user_id BIGINT UNSIGNED,
	OUT info_message VARCHAR(200)
)
BEGIN
	DECLARE code VARCHAR(100);
	DECLARE error_message VARCHAR(100);
	DECLARE `_rollback` BOOL DEFAULT 0;
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
	BEGIN
		SET `_rollback` = 1;
		GET stacked DIAGNOSTICS CONDITION 1
			code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT;
		SET info_message = CONCAT(code, ': ', error_message);
	END;
	SET @balance_type = (SELECT balance_type FROM e_wallet WHERE user_id=from_user_id);
    
	START TRANSACTION;

	UPDATE e_wallet SET balance = balance - money WHERE user_id=from_user_id;
	IF @balance_type = 'debit' AND (SELECT balance FROM e_wallet WHERE user_id=from_user_id) < 0 THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Transaction is canceled. Negative balance is not acceptable for debit balance type';
	END IF;
	UPDATE e_wallet SET balance = balance + money WHERE user_id=to_user_id;
		
	IF `_rollback` THEN 
		ROLLBACK;
    ELSE
    	SET info_message = 'Charged successfully';
   		COMMIT;
    END IF;
   
END//

DELIMITER ;

-- Check balance of test users with from_user_id=148 (debit balance type) and to_user_id=196
SELECT * FROM e_wallet WHERE user_id IN (148, 196);
-- Let's charge 1000 from user with debit balance type
CALL money_transfer_trans(148, 1000, 196, @info_message);
-- Check balance now. It's changed
SELECT * FROM e_wallet WHERE user_id IN (148, 196);
SELECT @info_message;


-- Let's charge 2000 from user with debit balance type
CALL money_transfer_trans(148, 2000, 196, @info_message);
-- Balance remained same.
SELECT * FROM e_wallet WHERE user_id IN (148, 196);
SELECT @info_message;

-- Let's charge 7000 from user with credit balance type
CALL money_transfer_trans(131, 7000, 196, @info_message);
-- Balance became negative.
SELECT * FROM e_wallet WHERE user_id IN (131, 196);
SELECT @info_message;