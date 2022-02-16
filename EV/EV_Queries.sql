-- Import a table:
-- Move a mouse on a table in 'Tables', click right, choose 'Table Data Import Wizard' and 
-- then follow the directions. Must choose 'Create new table' with a table name
-- For safety, change column types into 'text'.

USE daeshik_sql;

SET SQL_SAFE_UPDATES = 0;

SELECT * FROM electric_cars;

-- Replace blank cells with NULL
UPDATE electric_cars SET fastcharge_speed = NULL
WHERE fastcharge_speed = '';
UPDATE electric_cars SET price_euro = NULL
WHERE price_euro = '';
UPDATE electric_cars SET price_uk = NULL
WHERE price_uk = '';

-- Change type for columns
ALTER TABLE electric_cars MODIFY COLUMN fastcharge_speed INT;
ALTER TABLE electric_cars MODIFY COLUMN price_euro INT;
ALTER TABLE electric_cars MODIFY COLUMN price_uk INT;

-- Choose the first word for the company from each name
-- SUBSTRING_INDEX(string, delimiter, number)
-- For a positive number, return all to the left of the delimiter
-- For a negative number, return all to the right of the delimiter
-- SUBSTRING_INDEX(SUBSTRING_INDEX(name, ' ', 2), ' ', -1) for the second word
ALTER TABLE electric_cars DROP COLUMN company;
SELECT *, SUBSTRING_INDEX(name, ' ', 1) AS company
FROM electric_cars;

-- Add a column 'company' obtained from the table to the table
ALTER TABLE electric_cars ADD COLUMN company VARCHAR(20);

UPDATE electric_cars ec
JOIN 
	(SELECT name, SUBSTRING_INDEX(name, ' ', 1) AS company FROM electric_cars) comp
ON ec.name = comp.name
SET ec.company = comp.company;

-- Find the number of cars for each company
SELECT company, COUNT(*) AS count FROM electric_cars
GROUP BY company
ORDER BY count DESC;

-- Rank the efficiency per company
SELECT name, efficiency, price_euro,
RANK() OVER (PARTITION BY company ORDER BY efficiency DESC, price_euro) AS rnk
FROM electric_cars;



