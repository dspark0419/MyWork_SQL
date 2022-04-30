-- In MySQL, a trigger is a stored program invoked automatically in response to an event 
-- such as insert, update, or delete that occurs in the associated table.
-- DELIMITER //
-- CREATE TRIGGER trigger_name 
-- BEFORE/AFTER  INSERT/UPDATE/DELETE  ON table_name FOR EACH ROW
-- BEGIN trigger_body END //
-- DELIMITER ;

USE daeshik_sql;

DROP TABLE IF EXISTS trigger_message;
CREATE TABLE trigger_message (
message VARCHAR(100)
);

DROP TRIGGER IF EXISTS employee_new;
DELIMITER //
CREATE TRIGGER employee_new 
BEFORE INSERT ON employee -- BEFORE/AFTER, INSERT/UPDATE/DELETE
	FOR EACH ROW
    BEGIN
		INSERT INTO trigger_message VALUES (CONCAT(NEW.last_name, ' added'));
	END //
DELIMITER ;

INSERT INTO employee VALUES (DEFAULT, 'Oscar', 'Martinez', '1968-02-19', 'M', 69000, 106, 3);
SELECT * FROM trigger_message;

DROP TRIGGER IF EXISTS employee_sex;
DELIMITER //
CREATE TRIGGER employee_sex 
BEFORE INSERT ON employee
	FOR EACH ROW
    BEGIN
		IF NEW.sex = 'M' THEN
			INSERT INTO trigger_message VALUES ('male employee added');
		ELSEIF NEW.sex = 'F' THEN
			INSERT INTO trigger_message VALUES ('female employee added');
		else
			INSERT INTO trigger_message VALUES ('other employee added');
		END IF;
	END //
DELIMITER ;

INSERT INTO employee VALUES (DEFAULT, 'Pam', 'Beasly', '1988-02-19', 'F', 65000, 107, 3);
SELECT * FROM trigger_message;

DROP TRIGGER IF EXISTS birth_null;
DELIMITER //
CREATE TRIGGER birth_null
AFTER INSERT ON employee
	FOR EACH ROW
    BEGIN
		IF NEW.birth_date IS NULL
			THEN INSERT INTO trigger_message 
				VALUES (CONCAT('Hi ', NEW.first_name, ', please update your date of birth.'));
		END IF;
	END //
DELIMITER ;

INSERT INTO employee VALUES (DEFAULT, 'Kevin', 'Malone', NULL, 'M', 59000, 109, 3);
SELECT * FROM trigger_message;






