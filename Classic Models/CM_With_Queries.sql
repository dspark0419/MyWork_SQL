USE classicmodels;

-- Find dates when there are 3 or more orders
SELECT orderDate, COUNT(orderDate) AS num_orders FROM orders
GROUP BY orderDate
HAVING num_orders >= 3;

-- Find dates when there are orders in 5 or more consecutive days
WITH
	distinctDates AS (SELECT DISTINCT(orderDate) FROM orders),
    -- number the rows by orderDate
    dates_rn AS 
		(SELECT *,
			ROW_NUMBER() OVER (ORDER BY orderDate) AS row_num FROM distinctDates),
	-- difference between orderDate and row number
    dates_diff AS 
		(SELECT *,
			DATE_SUB(orderDate, INTERVAL row_num DAY) AS diff FROM dates_rn),
	-- count the records for each difference
    dates_count AS 
		(SELECT *, COUNT(*) OVER (PARTITION BY diff) AS num_consec_days FROM dates_diff) 
SELECT * FROM dates_count
WHERE num_consec_days >= 5;

-- Fetch the records when payments >= 50,000 were consecutively made for 3 or more times
WITH pmt_status AS
	(SELECT *,
		-- creating a column if amount is >= 10,000
		CASE WHEN amount >= 50000
				AND LEAD(amount) OVER (ORDER BY paymentDate, amount) >= 50000
				AND LEAD(amount, 2) OVER (ORDER BY paymentDate, amount) >= 50000
			THEN 'yes' -- Among any 3 consecutive records, checking the first
			WHEN amount >= 50000
				AND LAG(amount) OVER (ORDER BY paymentDate, amount) >= 50000
				AND LEAD(amount) OVER (ORDER BY paymentDate, amount) >= 50000
			THEN 'yes' -- Among any 3 consecutive records, checking the middle
			WHEN amount >= 50000
				AND LAG(amount) OVER (ORDER BY paymentDate, amount) >= 50000
				AND LAG(amount, 2) OVER (ORDER BY paymentDate, amount) >= 50000
			THEN 'yes' -- Among any 3 consecutive records, checking the last
			ELSE 'no'
		END amount_status
	FROM payments)
SELECT * FROM pmt_status
WHERE amount_status = 'yes';

-- Fetch all employees with the duplicate last names
WITH emp_rn AS 
	-- number the rows of each last name
	(SELECT employeeNumber, lastName, firstName,
		ROW_NUMBER() OVER (PARTITION BY lastName) AS row_num FROM employees)
SELECT employeeNumber, lastName, firstName FROM employees e
WHERE e.lastName IN 
	(SELECT lastName FROM emp_rn WHERE row_num = 2)
ORDER BY e.lastName;

-- Fetch the customer name who paid the 10th most
WITH 
	-- create a row for the total payment of each customer
    totalPayments AS
		(SELECT customerNumber, SUM(amount) AS total_pmt FROM payments
		GROUP BY customerNumber),
	-- join the above table with the table customers
    customersPayments AS
		(SELECT c.customerNumber, c.customerName, tp.total_pmt 
			FROM customers c
		RIGHT JOIN totalPayments tp
		ON c.customerNumber = tp.customerNumber)
SELECT * FROM customersPayments
ORDER BY total_pmt DESC
LIMIT 9, 1;

-- Display the customers who either paid most or least in each country
WITH -- same as above
	totalPayments AS
		(SELECT customerNumber, SUM(amount) AS total_pmt FROM payments
		GROUP BY customerNumber),
	customersPayments AS
		(SELECT c.*, tp.total_pmt FROM customers c
		RIGHT JOIN totalPayments tp
		ON c.customerNumber = tp.customerNumber),
	-- select the names of the highest and lowest payments for each county
	customersHL AS
		(SELECT *, 
			MAX(total_pmt) OVER w AS highest_pmt,
			MIN(total_pmt) OVER w AS lowest_pmt
		FROM customersPayments
		WINDOW w AS (PARTITION BY country ORDER BY country
			RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING))
SELECT * FROM customersHL hl
WHERE hl.total_pmt = hl.highest_pmt OR hl.total_pmt = hl.lowest_pmt;

-- Fetch the customers who made payments in 3 or more times within 12 months
WITH pmt_rn_period AS
	(SELECT *,
		ROW_NUMBER() OVER w AS row_num,
		MIN(paymentDate) OVER w AS start_date,
		MAX(paymentDate) OVER w AS end_date            
	FROM payments
	WINDOW w AS (PARTITION BY customerNumber ORDER BY paymentDate
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING))
SELECT DISTINCT(customerNumber), MAX(row_num), start_date, end_date FROM pmt_rn_period
WHERE DATE_SUB(end_date, INTERVAL 1 YEAR) <= start_date and row_num >= 3
GROUP BY customerNumber;

-- Find the top 2 customer numbers with the maximum payments on a monthly basis
-- Consider only the max payment per customer each month
-- Prefer the customer number with the least value in case of same payments
WITH 
-- extract year and month from date
pmt_y_m AS
	(SELECT *, 
		EXTRACT(YEAR FROM paymentDate) AS year, 
		EXTRACT(MONTH FROM paymentDate) AS month
	FROM payments),
-- find the max payment per customer over year and month
max_pmt_y_m AS
	(SELECT *, 
		MAX(amount) OVER (PARTITION BY year, month, customerNumber) AS max_pmt_cust
	FROM pmt_y_m),
-- rank the max payments over year and month
max_pmt_rk AS
	(SELECT *,
    RANK() OVER (PARTITION BY year, month ORDER BY max_pmt_cust DESC) AS rk
    FROM max_pmt_y_m
    WHERE amount = max_pmt_cust)
SELECT * FROM max_pmt_rk
WHERE rk IN (1, 2); -- choose the first two highest max payments over year and month

-- Find the customers who paid more than the average of all customers
WITH 
totalPayments AS
	(SELECT customerNumber, ROUND(SUM(amount), 2) AS total_pmt
	FROM payments
	GROUP BY customerNumber),
customersOverAvg AS
	(SELECT * FROM totalPayments
	WHERE total_pmt > (SELECT AVG(total_pmt) FROM totalPayments))
SELECT coa.customerNumber, c.customerName, coa.total_pmt
FROM customersOverAvg coa
LEFT JOIN customers c
ON coa.customerNumber = c.customerNumber;

-- Find the salespersons in each office who sold most or least 
WITH 
totalPayments AS
	(SELECT customerNumber, ROUND(SUM(amount), 2) AS total_pmt
	FROM payments
	GROUP BY customerNumber),
salesRep AS
	(SELECT c.customerNumber, tp.total_pmt, c.salesRepEmployeeNumber 
	FROM totalPayments tp
	RIGHT JOIN customers c
	ON tp.customerNumber = c.customerNumber
	WHERE c.salesRepEmployeeNumber IS NOT NULL),
totalSales AS
	(SELECT salesRepEmployeeNumber, SUM(total_pmt) AS total_sales FROM salesRep
	GROUP BY salesRepEmployeeNumber),
salesRepOffice AS
	(SELECT ts.*, e.lastName, e.firstName, e.officeCode FROM totalSales ts
	LEFT JOIN employees e
	ON ts.salesRepEmployeeNumber = e.EmployeeNumber),
salesRepRank AS
	(SELECT *,
	MAX(total_sales) OVER w AS max_sales,
    MIN(total_sales) OVER w AS min_sales
    FROM salesRepOffice
    WINDOW w AS (PARTITION BY officeCode ORDER BY total_sales DESC))
SELECT * FROM salesRepRank
WHERE (total_sales = max_sales OR total_sales = min_sales)
	AND officeCode = 1;

