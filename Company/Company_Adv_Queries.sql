-- Contents: With, With Recursive, Partition by

USE daeshik_sql;

-- WITH: CTE (Common Table Expressions) to make a temporary table just for one query
-- format: WITH cte_name AS ( SELECT ~ ) SELECT * FROM cte_name
SELECT emp_id FROM employee
WHERE branch_id = 2;
WITH branch_2 AS 
	(SELECT emp_id FROM employee e
	WHERE e.branch_id = 2)
SELECT * FROM branch_2; -- same as above

-- After With clause, temporary table name (col1, col2, ...)
WITH avg_salary (avg_sal) AS
	(SELECT ROUND(AVG(salary), 2) FROM employee)
SELECT * FROM employee e, avg_salary av
WHERE e.salary > av.avg_sal; -- same as above

-- Finding employees whose total sales are more than the average sales of all employees
SELECT ww.emp_id, SUM(total_sales) AS total_sales_emp FROM works_with ww
GROUP BY ww.emp_id; -- total sales per employee
SELECT ROUND(AVG(ts.total_sales_emp), 2) AS avg_sales FROM
	(SELECT ww.emp_id, SUM(total_sales) AS total_sales_emp FROM works_with ww
	GROUP BY ww.emp_id) ts; -- average sales of all employees
SELECT * FROM
	(SELECT ww.emp_id, SUM(total_sales) AS total_sales_emp FROM works_with ww
	GROUP BY ww.emp_id) ts -- total sales per employee
JOIN
	(SELECT ROUND(AVG(ts.total_sales_emp), 2) AS avg_sales FROM
		(SELECT ww.emp_id, SUM(total_sales) AS total_sales_emp FROM works_with ww
		GROUP BY ww.emp_id) ts
    ) av -- average sales of all employees
ON ts.total_sales_emp > av.avg_sales;

-- Same as above with With clause
WITH 
	total_sales (emp_id, total_sales_per_emp) AS 
		(SELECT ww.emp_id, SUM(total_sales) AS total_sales_emp FROM works_with ww
		GROUP BY ww.emp_id),
    avg_sales (avg_sales_all) AS
		(SELECT ROUND(AVG(total_sales_per_emp), 2) FROM total_sales)
SELECT * FROM total_sales ts
JOIN avg_sales av
ON ts.total_sales_per_emp > av.avg_sales_all;

-- Recursive/Hierarchical Queries
-- Arranging the hierarchical levels of the employee
WITH RECURSIVE employee_hier AS 
	(-- Anchor Query: assigning 1 to the ceo
	SELECT e.emp_id, e.first_name, e.last_name, e.super_id, 1 AS level FROM employee e
	WHERE super_id IS NULL
	UNION
    -- Recursive Query: finding the number of levels by inclementing levels and joining itself
	SELECT e.emp_id, e.first_name, e.last_name, e.super_id, eh.level + 1 FROM employee e
	JOIN employee_hier eh
	ON e.super_id = eh.emp_id
	WHERE e.super_id IS NOT NULL)
SELECT * FROM employee_hier
ORDER BY level;

-- Partition By
-- Finding the percent of total sales for each employee
SELECT emp_id, client_id, total_sales,
SUM(total_sales) OVER (PARTITION BY emp_id) AS emp_totalsales,
total_sales/SUM(total_sales) OVER (PARTITION BY emp_id) * 100 as pct_totalsales
FROM works_with
ORDER BY emp_id, total_sales DESC;


