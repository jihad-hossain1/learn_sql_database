# SQL Database Learning Guide - Part 3: Intermediate SQL

## Table of Contents
1. [Aggregate Functions](#aggregate-functions)
2. [GROUP BY and HAVING](#group-by-and-having)
3. [Joins](#joins)
4. [Subqueries](#subqueries)
5. [String Functions](#string-functions)
6. [Date Functions](#date-functions)
7. [Practice Exercises](#practice-exercises)

---

## Aggregate Functions

### Basic Aggregate Functions
```sql
-- Count records
SELECT COUNT(*) FROM employees;
SELECT COUNT(salary) FROM employees; -- Excludes NULL values
SELECT COUNT(DISTINCT department) FROM employees;

-- Sum values
SELECT SUM(salary) FROM employees;
SELECT SUM(salary) FROM employees WHERE department = 'IT';

-- Average
SELECT AVG(salary) FROM employees;
SELECT ROUND(AVG(salary), 2) FROM employees;

-- Min and Max
SELECT MIN(salary), MAX(salary) FROM employees;
SELECT MIN(hire_date), MAX(hire_date) FROM employees;

-- Multiple aggregates
SELECT 
    COUNT(*) AS total_employees,
    AVG(salary) AS avg_salary,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    SUM(salary) AS total_payroll
FROM employees;
```

---

## GROUP BY and HAVING

### GROUP BY Clause
```sql
-- Group by single column
SELECT department, COUNT(*) AS employee_count
FROM employees
GROUP BY department;

-- Group by with multiple aggregates
SELECT department, 
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary
FROM employees
GROUP BY department;

-- Group by multiple columns
SELECT department, YEAR(hire_date) AS hire_year, COUNT(*) AS count
FROM employees
GROUP BY department, YEAR(hire_date)
ORDER BY department, hire_year;

-- Group by with calculated fields
SELECT 
    CASE 
        WHEN salary < 60000 THEN 'Low'
        WHEN salary < 80000 THEN 'Medium'
        ELSE 'High'
    END AS salary_range,
    COUNT(*) AS employee_count
FROM employees
GROUP BY 
    CASE 
        WHEN salary < 60000 THEN 'Low'
        WHEN salary < 80000 THEN 'Medium'
        ELSE 'High'
    END;
```

### HAVING Clause
```sql
-- Filter groups with HAVING
SELECT department, AVG(salary) AS avg_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 70000;

-- Multiple conditions in HAVING
SELECT department, COUNT(*) AS employee_count, AVG(salary) AS avg_salary
FROM employees
GROUP BY department
HAVING COUNT(*) > 2 AND AVG(salary) > 65000;

-- HAVING with WHERE
SELECT department, AVG(salary) AS avg_salary
FROM employees
WHERE hire_date >= '2023-01-01'
GROUP BY department
HAVING AVG(salary) > 70000;
```

---

## Joins

### Sample Tables for Join Examples
```sql
-- Departments table
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    location VARCHAR(50)
);

INSERT INTO departments VALUES
(1, 'IT', 'New York'),
(2, 'HR', 'Chicago'),
(3, 'Finance', 'Boston'),
(4, 'Marketing', 'Los Angeles');

-- Projects table
CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INT,
    budget DECIMAL(10,2)
);

INSERT INTO projects VALUES
(1, 'Website Redesign', 1, 50000),
(2, 'HR System', 2, 30000),
(3, 'Budget Analysis', 3, 25000);
```

### Inner Join
```sql
-- Basic inner join
SELECT e.first_name, e.last_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

-- Inner join with additional conditions
SELECT e.first_name, e.last_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 70000;

-- Multiple table joins
SELECT e.first_name, e.last_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;
```

### Left Join (Left Outer Join)
```sql
-- Show all employees, even those without departments
SELECT e.first_name, e.last_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- Find employees without departments
SELECT e.first_name, e.last_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;
```

### Right Join (Right Outer Join)
```sql
-- Show all departments, even those without employees
SELECT e.first_name, e.last_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- Find departments without employees
SELECT d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;
```

### Full Outer Join
```sql
-- Show all employees and all departments
SELECT e.first_name, e.last_name, d.dept_name
FROM employees e
FULL OUTER JOIN departments d ON e.dept_id = d.dept_id;

-- MySQL doesn't support FULL OUTER JOIN, use UNION
SELECT e.first_name, e.last_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
UNION
SELECT e.first_name, e.last_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;
```

### Self Join
```sql
-- Find employees and their managers (assuming manager_id column)
SELECT 
    e.first_name AS employee_name,
    m.first_name AS manager_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;
```

### Cross Join
```sql
-- Cartesian product (use with caution)
SELECT e.first_name, d.dept_name
FROM employees e
CROSS JOIN departments d;
```

---

## Subqueries

### Subqueries in WHERE Clause
```sql
-- Find employees with above-average salary
SELECT * FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Find employees in the IT department
SELECT * FROM employees
WHERE dept_id = (SELECT dept_id FROM departments WHERE dept_name = 'IT');

-- Multiple value subqueries with IN
SELECT * FROM employees
WHERE dept_id IN (
    SELECT dept_id FROM departments 
    WHERE location IN ('New York', 'Chicago')
);

-- EXISTS subquery
SELECT * FROM employees e
WHERE EXISTS (
    SELECT 1 FROM projects p 
    WHERE p.dept_id = e.dept_id
);

-- NOT EXISTS subquery
SELECT * FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM projects p 
    WHERE p.dept_id = e.dept_id
);
```

### Subqueries in FROM Clause
```sql
-- Use subquery as a table
SELECT dept_avg.dept_name, dept_avg.avg_salary
FROM (
    SELECT d.dept_name, AVG(e.salary) as avg_salary
    FROM employees e
    JOIN departments d ON e.dept_id = d.dept_id
    GROUP BY d.dept_name
) dept_avg
WHERE dept_avg.avg_salary > 70000;
```

### Subqueries in SELECT Clause
```sql
-- Scalar subqueries in SELECT
SELECT 
    first_name, 
    last_name, 
    salary,
    (SELECT AVG(salary) FROM employees) AS company_avg,
    salary - (SELECT AVG(salary) FROM employees) AS diff_from_avg
FROM employees;
```

### Correlated Subqueries
```sql
-- Find employees earning more than their department average
SELECT e1.first_name, e1.last_name, e1.salary, e1.dept_id
FROM employees e1
WHERE e1.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.dept_id = e1.dept_id
);

-- Find the highest paid employee in each department
SELECT e1.first_name, e1.last_name, e1.salary, e1.dept_id
FROM employees e1
WHERE e1.salary = (
    SELECT MAX(e2.salary)
    FROM employees e2
    WHERE e2.dept_id = e1.dept_id
);
```

---

## String Functions

### Common String Functions
```sql
-- Concatenation
SELECT CONCAT(first_name, ' ', last_name) as full_name FROM employees;
SELECT CONCAT(first_name, ' (', department, ')') as name_dept FROM employees;

-- Length
SELECT first_name, LENGTH(first_name) as name_length FROM employees;
SELECT first_name, CHAR_LENGTH(first_name) as char_count FROM employees;

-- Substring
SELECT SUBSTRING(first_name, 1, 3) as first_three FROM employees;
SELECT LEFT(first_name, 2) as first_two FROM employees;
SELECT RIGHT(last_name, 3) as last_three FROM employees;

-- Case conversion
SELECT UPPER(first_name), LOWER(last_name) FROM employees;
SELECT INITCAP(CONCAT(first_name, ' ', last_name)) as proper_name FROM employees;

-- Trim functions
SELECT TRIM('  John  ') as trimmed; -- Removes leading/trailing spaces
SELECT LTRIM('  John') as left_trimmed;
SELECT RTRIM('John  ') as right_trimmed;

-- Replace
SELECT REPLACE(department, 'IT', 'Information Technology') FROM employees;

-- Position/Find
SELECT LOCATE('o', first_name) as position_of_o FROM employees;
SELECT INSTR(first_name, 'oh') as position_of_oh FROM employees;

-- Padding
SELECT LPAD(emp_id, 5, '0') as padded_id FROM employees;
SELECT RPAD(first_name, 10, '.') as padded_name FROM employees;
```

### Advanced String Operations
```sql
-- String comparison
SELECT * FROM employees WHERE first_name LIKE 'J%';
SELECT * FROM employees WHERE last_name REGEXP '^[A-M]';

-- Extract parts of strings
SELECT 
    email,
    SUBSTRING_INDEX(email, '@', 1) as username,
    SUBSTRING_INDEX(email, '@', -1) as domain
FROM employees;

-- Format strings
SELECT FORMAT(salary, 2) as formatted_salary FROM employees;
SELECT CONCAT('$', FORMAT(salary, 0)) as currency_salary FROM employees;
```

---

## Date Functions

### Current Date and Time
```sql
-- Current date and time functions
SELECT NOW() as current_datetime;
SELECT CURDATE() as current_date;
SELECT CURTIME() as current_time;
SELECT UNIX_TIMESTAMP() as unix_timestamp;
```

### Date Formatting
```sql
-- Format dates
SELECT DATE_FORMAT(hire_date, '%Y-%m-%d') as formatted_date FROM employees;
SELECT DATE_FORMAT(hire_date, '%M %d, %Y') as readable_date FROM employees;
SELECT DATE_FORMAT(NOW(), '%W, %M %e, %Y at %h:%i %p') as full_format;

-- Extract date parts
SELECT 
    hire_date,
    YEAR(hire_date) as hire_year,
    MONTH(hire_date) as hire_month,
    DAY(hire_date) as hire_day,
    DAYNAME(hire_date) as day_name,
    MONTHNAME(hire_date) as month_name
FROM employees;
```

### Date Arithmetic
```sql
-- Add/subtract time intervals
SELECT 
    hire_date,
    DATE_ADD(hire_date, INTERVAL 1 YEAR) as anniversary,
    DATE_ADD(hire_date, INTERVAL 6 MONTH) as six_months_later,
    DATE_SUB(hire_date, INTERVAL 30 DAY) as thirty_days_before
FROM employees;

-- Calculate differences
SELECT 
    hire_date,
    DATEDIFF(NOW(), hire_date) as days_employed,
    TIMESTAMPDIFF(MONTH, hire_date, NOW()) as months_employed,
    TIMESTAMPDIFF(YEAR, hire_date, NOW()) as years_employed
FROM employees;

-- Age calculations
SELECT 
    first_name,
    birth_date,
    TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) as age
FROM employees;
```

### Date Comparisons
```sql
-- Find employees hired in specific periods
SELECT * FROM employees WHERE YEAR(hire_date) = 2023;
SELECT * FROM employees WHERE MONTH(hire_date) = 1;
SELECT * FROM employees WHERE hire_date >= '2023-01-01' AND hire_date < '2024-01-01';

-- Find employees hired in last 30 days
SELECT * FROM employees 
WHERE hire_date >= DATE_SUB(NOW(), INTERVAL 30 DAY);

-- Find employees with upcoming anniversaries
SELECT first_name, last_name, hire_date
FROM employees
WHERE DATE_FORMAT(hire_date, '%m-%d') = DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 30 DAY), '%m-%d');
```

---

## Practice Exercises

### Exercise 1: Aggregate Functions and Grouping
```sql
-- Using the employees table, answer these questions:

-- 1. How many employees are in each department?
SELECT department, COUNT(*) as employee_count
FROM employees
GROUP BY department;

-- 2. What's the average salary by department?
SELECT department, ROUND(AVG(salary), 2) as avg_salary
FROM employees
GROUP BY department;

-- 3. Which departments have more than 2 employees?
SELECT department, COUNT(*) as employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 2;

-- 4. What's the total payroll by department for departments with average salary > 70000?
SELECT department, SUM(salary) as total_payroll
FROM employees
GROUP BY department
HAVING AVG(salary) > 70000;
```

### Exercise 2: Joins Practice
```sql
-- Create sample data for practice
CREATE TABLE employee_projects (
    emp_id INT,
    project_id INT,
    hours_worked INT,
    PRIMARY KEY (emp_id, project_id)
);

-- Practice queries:

-- 1. List all employees with their department names
SELECT e.first_name, e.last_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- 2. Find employees working on projects
SELECT e.first_name, e.last_name, p.project_name
FROM employees e
JOIN employee_projects ep ON e.emp_id = ep.emp_id
JOIN projects p ON ep.project_id = p.project_id;

-- 3. Find departments without any projects
SELECT d.dept_name
FROM departments d
LEFT JOIN projects p ON d.dept_id = p.dept_id
WHERE p.project_id IS NULL;
```

### Exercise 3: Subqueries Challenge
```sql
-- 1. Find employees earning more than the company average
SELECT first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- 2. Find the second highest salary
SELECT MAX(salary) as second_highest
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);

-- 3. Find employees in departments with the highest average salary
SELECT e.first_name, e.last_name, e.department
FROM employees e
WHERE e.department = (
    SELECT department
    FROM employees
    GROUP BY department
    ORDER BY AVG(salary) DESC
    LIMIT 1
);
```

---

## Performance Tips

1. **Use indexes on columns used in WHERE, JOIN, and ORDER BY clauses**
2. **Avoid SELECT * in production queries**
3. **Use EXISTS instead of IN for subqueries when possible**
4. **Use LIMIT to restrict result sets**
5. **Consider using JOINs instead of subqueries for better performance**

---

## Next Steps
Continue with [Part 4: Advanced SQL](04_Advanced_SQL.md) to learn about window functions, CTEs, stored procedures, and more advanced topics.