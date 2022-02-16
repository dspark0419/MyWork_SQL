-- In MySQL, a trigger is a stored program invoked automatically in response to an event 
-- such as insert, update, or delete that occurs in the associated table.

USE daeshik_sql;

DROP TABLE IF EXISTS trigger_test;

CREATE TABLE trigger_test (
message VARCHAR(100)
);

DROP TRIGGER IF EXISTS my_trigger_emp;

DELIMITER $$
CREATE TRIGGER my_trigger_emp BEFORE INSERT ON employee -- BEFORE/AFTER, INSERT/UPDATE/DELETE
	FOR EACH ROW
    BEGIN
		INSERT INTO trigger_test VALUES ('added new employee');
	END $$
DELIMITER ;

INSERT INTO employee VALUES (DEFAULT, 'Oscar', 'Martinez', '1968-02-19', 'M', 69000, 106, 3);

SELECT * FROM trigger_test;

DROP TRIGGER IF EXISTS my_trigger_last;

DELIMITER $$
CREATE TRIGGER my_trigger_last BEFORE INSERT ON employee
	FOR EACH ROW
    BEGIN
		INSERT INTO trigger_test VALUES (NEW.last_name);
	END $$
DELIMITER ;

INSERT INTO employee VALUES (DEFAULT, 'Kevin', 'Malone', '1978-02-19', 'M', 69000, 107, 3);

SELECT * FROM trigger_test;

DROP TRIGGER IF EXISTS my_trigger_sex;

DELIMITER $$
CREATE TRIGGER my_trigger_sex BEFORE INSERT ON employee
	FOR EACH ROW
    BEGIN
		IF NEW.sex = 'M' THEN
			INSERT INTO trigger_test VALUES ('added male employee');
		ELSEIF NEW.sex = 'F' THEN
			INSERT INTO trigger_test VALUES ('added female employee');
		else
			INSERT INTO trigger_test VALUES ('added other employee');
		END IF;
	END $$
DELIMITER ; 

INSERT INTO employee VALUES (DEFAULT, 'Pam', 'Beasly', '1988-02-19', 'F', 69000, 109, 3);

SELECT * FROM trigger_test;
