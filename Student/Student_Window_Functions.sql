-- Windows Functions: 
-- Aggregations/ Partition/ Order/ Lead/ Lag/ Row Number/ Rank/ Dense Rank/ First Value/
-- Last Value/ Nth Value/ Frame clause/ Window clause/ Ntile/ Cume_Dist/ Percent_Rank

USE daeshik_sql;

SELECT name, major, gpa, AVG(gpa) OVER (PARTITION BY major) as dept_gpa 
FROM student
WHERE major IS NOT NULL; -- average over each major

-- LEAD() is used to get value from row that succeeds the current row
-- LAG() is used to get value from row that precedes the current row
SELECT *,
	LEAD(name, 2) OVER (ORDER BY name) -- showing the second name from the current name
FROM student;

INSERT INTO student VALUES 
	(DEFAULT, 'Paul', NULL, NULL, 2.9, NULL),
	(DEFAULT, 'Steve', NULL, NULL, NULL, NULL);
SELECT student_id, name, gpa, ROW_NUMBER() OVER (PARTITION BY name ORDER BY gpa DESC) as row_num
FROM student; -- number the rows for each name, so 1 means a new name

-- Rank/ Dense_Rank
-- If there are two values at the second, RANK skips the next available ranking value
-- DENSE_RANK still uses the next chronological ranking value
SELECT name, major, gpa, RANK() OVER (ORDER BY gpa DESC) AS gpa_rank FROM student
WHERE gpa IS NOT NULL; -- rank over gpa
SELECT name, major, gpa, DENSE_RANK() OVER (ORDER BY gpa DESC) AS gpa_rank FROM student
WHERE gpa IS NOT NULL;

-- Frame clause/ Last_Value/ Nth_Value
-- In Frame clause, default is range between unbounded preceding and current row
-- UNBOUNDED PRECEDING indicates that the window starts at the first row of the partition
-- UNBOUNDED FOLLOWING indicates that the window ends at the last row of the partition
-- Finding the names of the highest and lowest gpa for each major
SELECT name, major, gpa,
	FIRST_VALUE(name) OVER (PARTITION BY major ORDER BY gpa DESC) AS highest_gpa,
	LAST_VALUE(name) OVER (PARTITION BY major ORDER BY gpa DESC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS lowest_gpa
FROM student;

-- Same as above using Window clause when there are repeated conditions
SELECT name, major, gpa,
	FIRST_VALUE(name) OVER w AS highest_gpa,
	LAST_VALUE(name) OVER w AS lowest_gpa,
    NTH_VALUE(name, 2) OVER w AS 2nd_gpa
FROM student
WINDOW w AS (PARTITION BY major ORDER BY gpa DESC
    RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING);

-- NTile: Distribute the rows in an ordered partition into a specified number of groups
SELECT *, NTILE(3) OVER (ORDER BY gpa DESC) AS gpa_buckets
FROM student
WHERE gpa IS NOT NULL;
SELECT name, gpa, 
	CASE WHEN zz.gpa_buckets = 1 THEN 'great'
		WHEN zz.gpa_buckets = 2 THEN 'decent'
		ELSE 'poor'
END AS gpa_status FROM 
	(SELECT *, NTILE(3) OVER (ORDER BY gpa DESC) AS gpa_buckets
	FROM student
	WHERE gpa IS NOT NULL) zz;

-- CUME_DIST (cumulative distribution): Calculate the cumulative distribution of a value 
-- within a partition or result set
SELECT *,
	CONCAT(ROUND(CUME_DIST() OVER (ORDER BY gpa) * 100, 2), '%') AS cumul_dist_percent
FROM student;
-- Finding the gpa within 60%
SELECT name, cumul_dist_percent
FROM
	(SELECT *,
		CONCAT(ROUND(CUME_DIST() OVER (ORDER BY gpa) * 100, 2), '%') AS cumul_dist_percent
	FROM student) zz
WHERE zz.cumul_dist_percent <= 60;

-- Percent_Rank: Calculate the percentile rank of a row within a partition or result set
SELECT *,
	PERCENT_RANK() OVER (ORDER BY gpa) AS percent_rk
FROM student;

