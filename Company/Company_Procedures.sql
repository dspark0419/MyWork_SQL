-- A procedure is a subroutine (like a subprogram) in a regular scripting language,
-- stored in a database: no, in, out, in-out parameters
-- A procedure without parameters does not take any input or casts an output indirectly.
-- An IN parameter needs input such as an attribute. When defining an IN parameter in a procedure,
-- the calling program has to pass an argument to the stored procedure.
-- An OUT parameter is used to pass a parameter as output or display like the select operator,
-- but implicitly (through a set value). 
-- An IN-OUT parameter is a combination of IN and OUT parameters.

USE daeshik_sql;

-- stored procedure without parameter
DROP PROCEDURE IF EXISTS high_salary;

DELIMITER //
CREATE PROCEDURE high_salary ()
BEGIN
	SELECT last_name, salary FROM employee
	WHERE salary > 150000;
END //
DELIMITER ;

CALL high_salary();

-- stored procedure using IN
DROP PROCEDURE IF EXISTS top_salary;

DELIMITER //
CREATE PROCEDURE top_salary (IN num INT)
BEGIN
	SELECT last_name, salary FROM employee
	ORDER BY salary DESC LIMIT num;
END //
DELIMITER ;

CALL top_salary(3);

DROP PROCEDURE IF EXISTS update_salary;

DELIMITER //
CREATE PROCEDURE update_salary (IN temp_name VARCHAR(20), IN new_salary DECIMAL)
BEGIN
UPDATE employee 
SET salary = new_salary WHERE last_name = temp_name;
END //
DELIMITER ;

SET SQL_SAFE_UPDATES = 0;
CALL update_salary ('SCOTT', 85000);

-- stored procedure using OUT
DROP PROCEDURE IF EXISTS num_f_emp;

DELIMITER //
CREATE PROCEDURE num_f_emp (OUT female_emp INT)
BEGIN
	SELECT COUNT(emp_id) into female_emp FROM employee
	WHERE sex = 'F';
END //
DELIMITER ;

CALL num_f_emp(@F_emp);
SELECT @F_emp AS num_f_emp;


-- stored procedure using IN-OUT
DROP PROCEDURE IF EXISTS num_emp;

DELIMITER //
CREATE PROCEDURE num_emp (INOUT mf_emp INT, IN emp_sex VARCHAR(1))
BEGIN
SELECT COUNT(sex) INTO mf_emp FROM employee
WHERE sex = emp_sex;
END //
DELIMITER ;

CALL num_emp(@F_emp, 'F');
SELECT @F_emp;
CALL num_emp(@M_emp, 'M');
SELECT @M_emp;




