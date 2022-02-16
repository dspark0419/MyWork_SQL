-- Contents:
-- Basic table queries, Update, Case When, Order by, Where/Between/IN/Having, Like/RegExp,
-- Union, Aggregations, Group by, 
-- Trigger, Window Functions, View, Copying or Truncating a table, Concatenate, Date/Time

-- How to load the sample database into MySQL Server
-- Download and unzip the classicmodels database from the MySQL sample database section.
-- On MySQL Client, input mysql -u root -p and password.
-- Use the source command to load data into the MySQL Server: source C:\file location
-- List all databases in the current server using show databases;

-- Query order of execution: From, On, Join, Where, Group by, Having, Select, Distinct, 
-- Order by, Limit, Offset, 

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
    sex VARCHAR(1),
    major INT, #major VARCHAR(20) DEFAULT 'undecided'
    gpa DECIMAL(3, 2)
);

-- ALTER TABLE
ALTER TABLE student ADD COLUMN num_courses INT;
ALTER TABLE student DROP COLUMN last_name;
ALTER TABLE student RENAME COLUMN first_name TO name;
ALTER TABLE student MODIFY COLUMN major varchar(20);

DESCRIBE student;

INSERT INTO student VALUES
	(DEFAULT, 'Jack', 'M', 'Biology', 3.5, 24), -- 1 not needed for auto_increment
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

SELECT name, gpa, CASE -- put , before Case
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
SELECT * FROM student
WHERE student_id != 3; -- != not equal
SELECT * FROM student
WHERE NOT (student_id = 3); -- same as above
SELECT * FROM student
WHERE gpa BETWEEN 3.5 AND 4; -- inclusive
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
WHERE name REGEXP 'k'; -- same as above, 
SELECT * FROM student
WHERE name LIKE '___e' or major REGEXP '[gr]y'; -- 3 _s for 3 characters

SELECT * FROM student
WHERE major IS NOT NULL;
SELECT * FROM student
WHERE NOT(major IS NULL); -- same as above

-- Unions: must display the same # of columns from each, possibly similar types
SELECT *, 'decided' as status FROM student
WHERE major IS NOT NULL
UNION
SELECT *, 'undecided' as status FROM student
WHERE major IS NULL;

### AGGREGATEs/ GROUP BY
SELECT DISTINCT(major) FROM student
WHERE major IS NOT NULL;
SELECT major, COUNT(major) AS count FROM student
GROUP BY major;
SELECT COUNT(DISTINCT major) FROM student
WHERE major IS NOT NULL;
SELECT major, AVG(gpa) as dept_gpa FROM student
GROUP BY major;
SELECT name, gpa FROM student
WHERE sex = 'M' AND gpa > (SELECT AVG(gpa) FROM student)
GROUP BY name;

-- Trigger
DELIMITER //
CREATE TRIGGER major_null BEFORE INSERT ON student
FOR EACH ROW
	BEGIN
		IF new.major IS NULL THEN SET new.major = 'undecided';
		END IF; 
	END //
DELIMITER ;

INSERT INTO student VALUES (DEFAULT, 'Steve', 'M', NULL, 3.5, 18);

-- Views
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

TRUNCATE TABLE student_archived; -- deleting all rows and columns
INSERT INTO student_archived
SELECT * FROM student
WHERE gpa >= 3.5 and num_courses >= 15;

-- Show Tables/ Views/ Procedures/ Functions
SHOW TABLES;
SHOW FULL TABLES;
SHOW FULL TABLES WHERE table_type = 'VIEW';
SHOW PROCEDURE STATUS WHERE DB = 'daeshik_sql';
SHOW FUNCTION STATUS WHERE DB = 'daeshik_sql';

-- Concatenate
SELECT 'dae' 'shik' AS my_first_name;
SELECT CONCAT('Daeshik', ' Park') AS my_name; -- same as above

SELECT *, CONCAT(name, ' ', sex) as 'name_sex' FROM student; -- combine two columns

-- Date/ Time
SELECT NOW();
SELECT CURRENT_TIMESTAMP(); -- same as above
SELECT DATEDIFF('2022-02-01', '1968-12-02') AS days; -- number of days between two dates
SELECT DATEDIFF((SELECT NOW()), '1968-12-02') AS days; -- same as above




