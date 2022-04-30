-- Contents: Correlated/Nested queries, In/Any/All/Exists, Like, Union, Joins, On Delete

USE daeshik_sql;

INSERT INTO employee VALUES (DEFAULT, 'Jane', 'White', '1968-05-19', 'F', 79000, 103, 3);
SELECT LAST_INSERT_ID ();

INSERT INTO branch VALUES (4, 'Buffalo', LAST_INSERT_ID (), '2002-08-01');

SELECT last_name, COUNT(emp_id) FROM employee
WHERE sex = 'F' AND birth_date >= '1970-01-01'
GROUP BY last_name;

-- Correlated subqueries
-- Find the employees in each branch who earn more than the average salary in that branch
SELECT * FROM employee e1
WHERE e1.salary > (SELECT AVG(salary) FROM employee e2 
					WHERE e2.branch_id = e1.branch_id);
                    
-- Find the employees who do not have clients
SELECT e.emp_id, e.last_name FROM employee e
WHERE NOT EXISTS (SELECT * FROM works_with ww 
					WHERE ww.emp_id = e.emp_id);
-- same as above
SELECT e.emp_id, e.last_name, ww.client_id FROM employee e
LEFT JOIN works_with ww
ON e.emp_id = ww.emp_id
WHERE ww.client_id IS NULL;

-- Nested Queries
-- Find all clients who are handled by the branch that Michael Scott manages 
-- assuming that his ID is known
SELECT client.client_name FROM client
WHERE client.branch_id IN (
	SELECT branch.branch_id FROM branch
	WHERE branch.mgr_id = 102
);

-- Find names of all employees who have sold over 50,000 to a single client
SELECT e.last_name, e.salary, e.branch_id FROM employee e
WHERE e.emp_id IN (
	SELECT ww.emp_id FROM works_with ww
	WHERE ww.total_sales < 50000
)
ORDER BY e.salary DESC;

-- Give 10% bonus to all employees with clients based on the max salary in each branch
UPDATE employee e
SET salary = salary + (SELECT MAX(salary) * 0.1 FROM company_data cd
						WHERE cd.branch_id = e.branch_id)
WHERE e.emp_id IN (SELECT emp_id FROM works_with);

-- ANY/ ALL/ EXISTS
SELECT last_name, salary, super_id FROM employee e
WHERE emp_id = ANY(
	SELECT emp_id FROM works_with
	WHERE total_sales < 50000
)
ORDER BY e.salary DESC; -- same as above

SELECT * FROM employee
WHERE birth_date LIKE '____-02%'; -- 4 _s for year

-- Divide the employees into 3 grougs row, med, high salaries
SELECT emp_id, last_name, salary, 'row' AS type FROM employee
WHERE salary < 70000
UNION
SELECT emp_id, last_name, salary, 'med' AS type FROM employee
WHERE salary BETWEEN 70000 AND 150000
UNION
SELECT emp_id, last_name, salary, 'high' AS type FROM employee
WHERE salary > 150000
ORDER BY emp_id;

-- JOINs: inner, left, right, full outer, self, multiple, cross joins
SELECT employee.emp_id, employee.last_name, branch.branch_name FROM employee
JOIN branch ON employee.emp_id = branch.mgr_id; -- inner join: common values
SELECT e.emp_id, e.last_name, b.branch_name FROM employee e
JOIN branch b ON e.emp_id = b.mgr_id; -- same as above using alias
SELECT e.emp_id, e.last_name, b.branch_name FROM employee e, branch b
WHERE e.emp_id = b.mgr_id; -- Implicit Join: same as above
-- can join two tables from different databases using prefixes

SELECT employee.emp_id, employee.last_name, branch.branch_name FROM employee
LEFT JOIN branch ON employee.emp_id = branch.mgr_id; -- left join

SELECT employee.emp_id, employee.last_name, branch.branch_name FROM employee
RIGHT JOIN branch ON employee.emp_id = branch.mgr_id; -- right join

-- Full Outer Join
-- COALESCE is to merge two id columns into one column
-- IFNULL is to assign the second value for NULL
SELECT COALESCE(e.emp_id, ww.emp_id) AS emp_id, e.last_name,
	IFNULL(ww.client_id, 'none') as client_id,
	IFNULL(ww.total_sales, 0) AS total_sales FROM employee e
LEFT JOIN works_with ww ON e.emp_id = ww.emp_id
UNION ALL
SELECT COALESCE(e.emp_id, ww.emp_id), e.last_name, ww.client_id, ww.total_sales FROM employee e
RIGHT JOIN works_with ww ON e.emp_id = ww.emp_id
WHERE e.emp_id IS NULL;

-- Self Join: Joins a table with itself,
-- -- especially when the table has a FOREIGN KEY which references its own PRIMARY KEY. 
SELECT emp.emp_id, emp.last_name, emp.super_id, sup.last_name AS supervisor 
FROM employee emp
LEFT JOIN employee sup
ON emp.super_id = sup.emp_id;

-- Join multiple tables and save it to a table
DROP TABLE IF EXISTS company_data;
CREATE TABLE company_data AS
	SELECT 
		e.emp_id, e.last_name, e.salary, e.branch_id, sup.last_name AS supervisor,
		b.branch_name, c.client_name, ww.total_sales
	FROM employee e
	LEFT JOIN employee sup ON e.super_id = sup.emp_id
	JOIN branch b ON e.branch_id = b.branch_id
	LEFT JOIN works_with ww ON e.emp_id = ww.emp_id
	LEFT JOIN client c on ww.client_id = c.client_id
	ORDER BY e.emp_id;

-- Cross Join
SELECT * FROM branch b
CROSS JOIN client c -- no condition needed
ORDER BY b.branch_name;

-- ON DELETE: SET NULL OR CASCADE
/*
DELETE FROM employee
WHERE emp_id = 102;

SELECT * FROM employee; -- no 102, but set null applied to super_id
SELECT * FROM branch; -- set null

DELETE FROM branch
WHERE branch_id = 2;

SELECT * FROM branch_supplier; -- cascade: branch_id is crucial as primary key in branch_supplier
*/


