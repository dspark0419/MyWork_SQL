-- Contents:
-- Basic table queries, Update, Case When, Order by, Where/Between/IN/Having, Like/RegExp,
-- Union, Aggregations, Group by, Trigger, Deleting duplicate rows,
-- View, Copying or Truncating a table, String Functions, Date/Time

-- How to load the sample database into MySQL Server
-- Download and unzip the classicmodels database from the MySQL sample database section.
-- On MySQL Client, input mysql -u root -p and password.
-- Use the source command to load data into the MySQL Server: source C:\file location
-- List all databases in the current server using show databases;

-- Query order of execution:
-- From, On, Join, Where, Group by, Having, Window Functions, 
-- Select, Distinct, Union, Order by, Limit/Offset

-- Remember: Everything in SQL is a table.

#CREATE DATABASE basic_sql;

USE daeshik_sql;

DROP TABLE IF EXISTS student;

-- alternatively left click on "Tables", choose "Create Table" and 
-- then fill out the desirded cells.
-- While applying the table created, copy the script and paste it to a file.

CREATE TABLE student (
	student_id INT AUTO_INCREMENT PRIMARY KEY, -- use DEFAULT when inserting
    last_name VARCHAR(20) NOT NULL,
    first_name VARCHAR(20),
    sex CHAR(1) CHECK (sex IN ('F', 'M')), -- use CHAR for a fixed length
    major INT, #major VARCHAR(20) DEFAULT 'undecided'
    gpa DECIMAL(3, 2)
);

-- ALTER TABLE
ALTER TABLE student ADD COLUMN num_courses INT;
ALTER TABLE student DROP COLUMN last_name;
ALTER TABLE student RENAME COLUMN first_name TO name;
ALTER TABLE student MODIFY COLUMN major varchar(20);

DESCRIBE student;
SHOW COLUMNS FROM student; -- almost same as above

INSERT INTO student VALUES
	(DEFAULT, 'Jack', 'M', 'Biology', 2.4, 24), -- 1 not needed for auto_increment
	(DEFAULT, 'Kate', 'F', 'Math', 3.26, 32), 
    (DEFAULT, 'Clair', 'F', NULL, 4, 8), #(3, 'Clair', 4); -- for default
	(DEFAULT, 'Mike', 'M', 'Chemistry', 3.65, 15),
    (DEFAULT, 'Jack', 'M', 'Math', 3.1, 18);

-- deleting rows
#DELETE FROM student WHERE student_id = 5; -- deleting one row
#DELETE FROM student LIMIT 2; -- delete the first two rows

UPDATE student
SET name = 'Paul', gpa = 3.15
WHERE student_id = 5;

-- change Math by Mathematics
/*SELECT student_id FROM student WHERE major = 'Math';
UPDATE student 
SET major = 'Mathematics'
WHERE student_id IN (2, 5);
*/

-- Update two or more 
SET SQL_SAFE_UPDATES = 0; -- "Safe Updates" in Edit-Preferences-SQL Editor is off

UPDATE student 
SET major = 'Mathematics'
WHERE major = 'Math'; -- same as above

-- Case When
UPDATE student
SET num_courses = CASE
	WHEN student_id = 1 THEN num_courses + 8
	WHEN student_id = 2 THEN num_courses + 5
	ELSE num_courses + 0
END WHERE student_id IN (1, 2, 3, 4);

SELECT name, gpa, CASE 
	WHEN gpa < 2.5 THEN 'poor'
	WHEN gpa BETWEEN 2.5 AND 3.5 THEN 'good'
	ELSE 'great'
END AS gpa_status
FROM student
WHERE gpa IS NOT NULL
ORDER BY gpa;

INSERT INTO student VALUES (DEFAULT, 'Dee', 'F', 'Biology', 3.15, 16);
SELECT LAST_INSERT_ID (); -- with AUTO_INCREMENT

-- ORDER BY/ LIMIT
SELECT 	* FROM student
ORDER BY name, student_id DESC -- default is asc
LIMIT 3;
SELECT 	name, major FROM student
ORDER BY gpa
LIMIT 1, 2; -- skip the first and display the next 2
SELECT *, gpa + num_courses AS total FROM student
WHERE major IS NOT NULL
ORDER BY total DESC
LIMIT 5;

-- WHERE/ BETWEEN/ IN/ Having
-- AND = &&, OR = ||
SELECT * FROM student
WHERE student_id != 3; -- != not equal
SELECT * FROM student
WHERE NOT (student_id = 3); -- same as above
SELECT * FROM student
WHERE gpa BETWEEN 3.5 AND 4; -- inclusive
SELECT * FROM student
WHERE gpa NOT BETWEEN 3.5 AND 4;
SELECT * FROM student
WHERE name IN ('Jack', 'Clair', 'Paul', 'Jean');
SELECT major, AVG(gpa) FROM student
GROUP BY major
HAVING AVG(gpa) > (SELECT AVG(gpa) FROM student);

-- LIKE/ REGEXP
-- LIKE - Wildcards: % = any # characters, _ = one character
-- REGEXP - '^k': first character must be k, 'k$': last character must be k
-- REGEXP - 'k|t' containing k or t
-- REGEXP - '[gim]e' containing ge or ie or me, similarly, 'k[yei]', '[a-h]e'='[abc~h]e'
SELECT * FROM student
WHERE name LIKE '%k%'; -- all names containing k
SELECT * FROM student
WHERE major NOT LIKE '%y';
SELECT * FROM student
WHERE name REGEXP 'k'; -- same as above, 
SELECT * FROM student
WHERE name LIKE '___e' or major REGEXP '[gr]y'; -- 3 _s for 3 characters

SELECT * FROM student
WHERE major IS NOT NULL;
SELECT * FROM student
WHERE NOT(major IS NULL); -- same as above

-- Unions: must display the same # of columns from each, possibly similar types
SELECT *, 'decided' AS status FROM student
WHERE major IS NOT NULL
UNION
SELECT *, 'undecided' AS status FROM student
WHERE major IS NULL;

-- AGGREGATEs/ GROUP BY
SELECT DISTINCT major, name FROM student
WHERE major IS NOT NULL; -- distinc values for two columns combined
SELECT major, COUNT(major) AS count FROM student
GROUP BY major;
SELECT COUNT(DISTINCT major) FROM student
WHERE major IS NOT NULL;
SELECT COUNT(major) FROM student
WHERE major LIKE '%y%';
SELECT major, ROUND(AVG(gpa), 2) AS dept_gpa FROM student
GROUP BY major;
SELECT name, gpa FROM student
WHERE sex = 'M' AND gpa > (SELECT AVG(gpa) FROM student)
GROUP BY name;
SELECT 3456 % 4 != 0; -- % modulo

-- Trigger: Run automatically when a specific table is changed
-- DELIMITER //
-- CREATE TRIGGER trigger_name 
-- BEFORE/AFTER  INSERT/UPDATE/DELETE  ON table_name FOR EACH ROW
-- BEGIN trigger_body END //
-- DELIMITER ;

DELIMITER //
CREATE TRIGGER major_null BEFORE INSERT ON student
FOR EACH ROW
	BEGIN
		IF NEW.major IS NULL 
			THEN SET NEW.major = 'undecided';
		END IF; 
	END //
DELIMITER ;

INSERT INTO student VALUES (DEFAULT, 'Steve', 'M', NULL, 3.5, 18);
SELECT * FROM student;

-- Another way to check inputs on the sex column
DELIMITER //
CREATE TRIGGER sex_status BEFORE INSERT ON student 
FOR EACH ROW
	BEGIN
		IF NEW.sex NOT IN ('F', 'M') 
			THEN SIGNAL SQLSTATE '12345'
				SET MESSAGE_TEXT = 'Please input your sex, either F or M.';
		END IF;
	END //
DELIMITER ;

#INSERT INTO student VALUES (DEFAULT, 'Mike', 'T', NULL, NULL, 5);
INSERT INTO student VALUES (DEFAULT, 'Mike', 'M', NULL, NULL, 5);

-- Delete the duplicate rows
SELECT name, COUNT(name) FROM student
GROUP BY name
HAVING COUNT(name) > 1;
DELETE t1 FROM student t1
JOIN student t2
WHERE t1.gpa IS NULL AND t1.major = 'undecided' AND t1.name = t2.name;
SELECT * FROM student;

-- Table: View/ Copying/ Truncating/ Inserting/ Showing
-- Views: Virtual tables
-- -- This is nothing but the query statement that is stored in the data dictionary
DROP VIEW IF EXISTS student_v1;
CREATE VIEW student_v1 AS
SELECT * FROM student;
SELECT * from student_v1;
DROP VIEW IF EXISTS student_v2;
RENAME TABLE student_v1 to student_v2;

-- Copying a table
DROP TABLE IF EXISTS student_archived;
CREATE TABLE student_archived AS
SELECT * FROM student; -- PRIMARY KEY AND AUTO_INCLEMENT needed to reset
TRUNCATE TABLE student_archived; -- deleting all rows
INSERT INTO student_archived
SELECT * FROM student
WHERE gpa >= 3.5 and num_courses >= 15;

-- Show Tables/ Views/ Procedures/ Functions
SHOW TABLES;
SHOW FULL TABLES;
SHOW FULL TABLES WHERE table_type = 'VIEW';
SHOW PROCEDURE STATUS WHERE DB = 'daeshik_sql';
SHOW FUNCTION STATUS WHERE DB = 'daeshik_sql';

-- String Functions: Concatenate/ Substring/ Replace/ Reverse/ Length/ Substring_Index
SELECT 'dae' 'shik' AS my_first_name;
SELECT CONCAT('Daeshik', ' ', 'Park') AS my_name; -- same as above
SELECT *, CONCAT(name, '_', sex) as 'name_sex' FROM student; -- combine two columns
-- combine two or more columns with the same separator
SELECT *, CONCAT_WS(' - ', name, sex, major) FROM student;
SELECT UPPER('park');
SELECT LOWER('Park');

-- Use " " for a string if it has a single quote.
SELECT SUBSTRING("Hello! I'm a student.", 8, 7); -- from 8th to 14th inclucing spaces
SELECT SUBSTRING("Hello! I'm a student.", 2); -- from the 2nd to end
SELECT SUBSTRING("Hello! I'm a student.", -7); -- last 7 characters

SELECT CONCAT(SUBSTRING("Hello! I'm a student.", 8, 3), '...');
SELECT REPLACE("Hello! I'm a student.", 'student', 'professor'); -- case sensitive
SELECT INSERT('ABC CDEF', 1, 3, 'PARK');
SELECT POSITION("student" IN "Hello! I'm a student.");
SELECT REVERSE("Hello! I'm a student.");
SELECT CHAR_LENGTH("Hello! I'm a student.");
SELECT LENGTH("Hello! I'm a student."); -- same as above
SELECT UPPER("Hello! I'm a student.");
SELECT LOWER("Hello! I'm a student.");

-- SUBSTRING_INDEX(string, delimiter, number)
-- For a positive number, return all to the left of the delimiter
-- For a negative number, return all to the right of the delimiter
-- SUBSTRING_INDEX(SUBSTRING_INDEX(name, ' ', 2), ' ', -1) for the second word
SELECT SUBSTRING_INDEX("Hello! I'm a student.", ' ', 2);
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX("Hello! I'm a student.", ' ', 2), ' ', -1);

-- Date/ Time/ TimeStamp/ Cast
-- Date: 'yyyy-mm-dd', Time: 'hh:mm:ss', DateTime: 'yyyy-mm-dd hh:mm:ss'
SELECT CAST('1968-12-02' AS DATE); -- cast a date string to a date for sure
SELECT NOW(), CURDATE(), CURTIME();
SELECT CURRENT_TIMESTAMP(); -- same as above
SELECT HOUR('1968-12-02 23:45:05'), MONTH('1968-12-02 23:45:05'), YEAR('1968-12-02 23:45:05'),
	DAYNAME('1968-12-02 23:45:05'), MONTHNAME('1968-12-02 23:45:05'),
	DAYOFWEEK('1968-12-02 23:45:05'), DAYOFYEAR('1968-12-02 23:45:05');
SELECT DATE_FORMAT('1968-12-02 23:45:05', '%W %M %D %Y');
SELECT DATE_FORMAT('1968-12-02 23:45:05', '%a %m/%d/%y');

SELECT DATEDIFF('2022-02-01', '1968-12-02') AS days; -- number of days between two dates
SELECT DATEDIFF((SELECT NOW()), '1968-12-02') AS days;
SELECT DATE_ADD((SELECT CURDATE()), INTERVAL 12 MONTH);
SELECT DATE_SUB((SELECT CURDATE()), INTERVAL 100 DAY);
SELECT NOW(), NOW() + INTERVAL 11 MONTH - INTERVAL 25 DAY;

SELECT LAST_DAY(NOW()); -- last day of the month
SELECT LAST_DAY(NOW()) + INTERVAL 1 MONTH;
SELECT LAST_DAY(NOW()) - INTERVAL 2 MONTH;
SELECT LAST_DAY(NOW()) + INTERVAL 1 DAY - INTERVAL 1 MONTH; -- first day of the month

-- TimeStamp: take less space than DateTime
DROP TABLE IF EXISTS comments;
CREATE TABLE comments (
	content VARCHAR(100),
    changed_at TIMESTAMP DEFAULT NOW() ON UPDATE CURRENT_TIMESTAMP
    );
INSERT INTO comments (content) VALUES ('LOL, what a funny article!');
INSERT INTO comments (content) VALUES ('I found this offensive');
INSERT INTO comments (content) VALUES ('agidgidfjf');
UPDATE comments SET content = 'Not worth a penny' WHERE content = 'agidgidfjf';
SELECT * FROM comments;





