-- Contents: Inserting a table to an existing table, running totals

USE classicmodels;

DROP TABLE IF EXISTS employee_customer;
CREATE TABLE employee_customer (
emp_id INT,
last_name VARCHAR(30),
first_name VARCHAR(30),
customer_id INT,
customer_name VARCHAR(50)
);
INSERT INTO employee_customer VALUES (123, 'Abc', 'Cde', 999, 'GoogleA');

-- Insert a table to an exsiting table
INSERT INTO employee_customer
SELECT e.employeeNumber, e.lastName, e.firstName, c.customerNumber, c.customerName
FROM employees e
JOIN customers c
ON e.employeeNumber = c.salesRepEmployeeNumber
-- only employeeNumbers not in employee_customer
WHERE NOT EXISTS (SELECT * FROM employee_customer ec 
					WHERE e.employeeNumber = ec.emp_id);

SELECT * FROM employee_customer ORDER BY emp_id;

-- Find the running total amounts over all products
WITH prod_total AS
	(SELECT o.productCode, p.productName, o.quantityOrdered, o.priceEach,
	SUM(o.quantityOrdered * o.priceEach) AS totalAmount
	FROM orderdetails o
	JOIN products p
	ON o.productCode = p.productCode
	GROUP BY o.productCode)
SELECT productCode, productName, totalAmount,
SUM(totalAmount) OVER (ORDER BY productCode) AS runningTotal
FROM prod_total;

-- Find the running total amounts of each product line
WITH prod_total AS
	(SELECT o.productCode, p.productName, p.productLine, o.quantityOrdered, o.priceEach,
	SUM(o.quantityOrdered * o.priceEach) AS totalAmount
	FROM orderdetails o
	JOIN products p
	ON o.productCode = p.productCode
    GROUP BY o.productCode, p.productLine)
SELECT productCode, productName, productLine, totalAmount,
SUM(totalAmount) OVER (PARTITION BY productLine ORDER BY productCode) AS runningTotal
FROM prod_total;

-- Find the intervals for each customer between two orders
WITH 
cust_orders AS
	(SELECT o.customerNumber, c.customerName, o.orderDate,
    LEAD(o.orderDate) OVER (PARTITION BY c.customerName ORDER BY o.orderDate) AS nextOrder,
	LAG(o.orderDate) OVER (PARTITION BY c.customerName ORDER BY o.orderDate) AS previousOrder
	FROM orders o
	JOIN customers c
	ON o.customerNumber = c.customerNumber)
SELECT *,
IFNULL(DATEDIFF(nextOrder, orderDate), 0) AS nextOrderInt,
IFNULL(DATEDIFF(orderDate, previousOrder), 0) AS previousOrderInt
FROM cust_orders;




