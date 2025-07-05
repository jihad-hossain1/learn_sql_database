# SQL Database Learning Guide - Part 2: Basic Operations (CRUD)

## Table of Contents
1. [CREATE - Creating Tables and Inserting Data](#create---creating-tables-and-inserting-data)
2. [READ - Querying Data](#read---querying-data)
3. [UPDATE - Modifying Data](#update---modifying-data)
4. [DELETE - Removing Data](#delete---removing-data)
5. [Basic Query Techniques](#basic-query-techniques)
6. [Practice Exercises](#practice-exercises)

---

## CREATE - Creating Tables and Inserting Data

### Creating Tables
```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE
);
```

### Inserting Data
```sql
-- Insert single record
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('John', 'Doe', 'IT', 75000.00, '2023-01-15');

-- Insert multiple records
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES 
    ('Jane', 'Smith', 'HR', 65000.00, '2023-02-01'),
    ('Mike', 'Johnson', 'Finance', 70000.00, '2023-01-20'),
    ('Sarah', 'Wilson', 'IT', 80000.00, '2023-03-10');

-- Insert with default values
INSERT INTO employees (first_name, last_name, department)
VALUES ('Bob', 'Brown', 'Marketing');

-- Insert from another table
INSERT INTO employees_backup
SELECT * FROM employees WHERE department = 'IT';
```

---

## READ - Querying Data

### Basic SELECT Statements
```sql
-- Select all columns
SELECT * FROM employees;

-- Select specific columns
SELECT first_name, last_name, salary FROM employees;

-- Select with alias
SELECT first_name AS 'First Name', last_name AS 'Last Name' FROM employees;

-- Select distinct values
SELECT DISTINCT department FROM employees;
```

### WHERE Clause - Filtering Data
```sql
-- Basic conditions
SELECT * FROM employees WHERE department = 'IT';
SELECT * FROM employees WHERE salary > 70000;
SELECT * FROM employees WHERE hire_date >= '2023-02-01';

-- Multiple conditions
SELECT * FROM employees 
WHERE department = 'IT' AND salary > 70000;

SELECT * FROM employees 
WHERE department = 'IT' OR department = 'HR';

-- IN operator
SELECT * FROM employees 
WHERE department IN ('IT', 'HR', 'Finance');

-- BETWEEN operator
SELECT * FROM employees 
WHERE salary BETWEEN 60000 AND 80000;

-- LIKE operator for pattern matching
SELECT * FROM employees WHERE first_name LIKE 'J%';
SELECT * FROM employees WHERE last_name LIKE '%son';
SELECT * FROM employees WHERE first_name LIKE '_ohn';

-- NULL checks
SELECT * FROM employees WHERE salary IS NULL;
SELECT * FROM employees WHERE salary IS NOT NULL;
```

### Sorting and Limiting
```sql
-- Order by salary (ascending)
SELECT * FROM employees ORDER BY salary;

-- Order by salary (descending)
SELECT * FROM employees ORDER BY salary DESC;

-- Multiple column sorting
SELECT * FROM employees ORDER BY department, salary DESC;

-- Limit results
SELECT * FROM employees ORDER BY salary DESC LIMIT 5;

-- Offset and limit (pagination)
SELECT * FROM employees ORDER BY emp_id LIMIT 10 OFFSET 20;

-- Alternative pagination syntax (MySQL)
SELECT * FROM employees ORDER BY emp_id LIMIT 20, 10;
```

---

## UPDATE - Modifying Data

### Basic UPDATE Operations
```sql
-- Update single record
UPDATE employees 
SET salary = 85000.00 
WHERE emp_id = 1;

-- Update multiple columns
UPDATE employees 
SET salary = 90000.00, department = 'Senior IT'
WHERE emp_id = 1;

-- Update multiple records
UPDATE employees 
SET salary = salary * 1.1 
WHERE department = 'IT';

-- Update with conditions
UPDATE employees 
SET department = 'Engineering' 
WHERE department = 'IT' AND hire_date < '2023-02-01';

-- Update using calculations
UPDATE employees 
SET salary = CASE 
    WHEN department = 'IT' THEN salary * 1.15
    WHEN department = 'HR' THEN salary * 1.10
    ELSE salary * 1.05
END;
```

### Safe UPDATE Practices
```sql
-- Always use WHERE clause to avoid updating all records
-- BAD: UPDATE employees SET salary = 50000;
-- GOOD: UPDATE employees SET salary = 50000 WHERE emp_id = 1;

-- Test with SELECT first
SELECT * FROM employees WHERE department = 'IT';
-- Then update
UPDATE employees SET salary = salary * 1.1 WHERE department = 'IT';
```

---

## DELETE - Removing Data

### Basic DELETE Operations
```sql
-- Delete specific record
DELETE FROM employees WHERE emp_id = 5;

-- Delete with conditions
DELETE FROM employees WHERE department = 'Temp';

-- Delete with multiple conditions
DELETE FROM employees 
WHERE department = 'IT' AND salary < 60000;

-- Delete using subquery
DELETE FROM employees 
WHERE emp_id IN (
    SELECT emp_id FROM (
        SELECT emp_id FROM employees WHERE hire_date < '2020-01-01'
    ) AS temp
);
```

### Safe DELETE Practices
```sql
-- Always use WHERE clause
-- DANGEROUS: DELETE FROM employees; -- This deletes ALL records!

-- Test with SELECT first
SELECT * FROM employees WHERE department = 'Temp';
-- Then delete
DELETE FROM employees WHERE department = 'Temp';

-- Use LIMIT for safety
DELETE FROM employees WHERE department = 'Temp' LIMIT 1;
```

### TRUNCATE vs DELETE
```sql
-- DELETE removes rows one by one (slower, can be rolled back)
DELETE FROM employees;

-- TRUNCATE removes all rows at once (faster, cannot be rolled back)
TRUNCATE TABLE employees;
```

---

## Basic Query Techniques

### Calculated Fields
```sql
-- Mathematical operations
SELECT first_name, last_name, salary, salary * 12 AS annual_salary
FROM employees;

-- String concatenation
SELECT CONCAT(first_name, ' ', last_name) AS full_name, salary
FROM employees;

-- Conditional logic
SELECT first_name, last_name, salary,
    CASE 
        WHEN salary > 80000 THEN 'High'
        WHEN salary > 60000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_grade
FROM employees;
```

### Basic Functions
```sql
-- String functions
SELECT UPPER(first_name), LOWER(last_name), LENGTH(first_name)
FROM employees;

-- Date functions
SELECT first_name, hire_date, 
    YEAR(hire_date) AS hire_year,
    DATEDIFF(CURDATE(), hire_date) AS days_employed
FROM employees;

-- Numeric functions
SELECT ROUND(salary/12, 2) AS monthly_salary,
    ABS(salary - 70000) AS salary_difference
FROM employees;
```

### Handling NULL Values
```sql
-- Check for NULL
SELECT * FROM employees WHERE salary IS NULL;

-- Replace NULL with default value
SELECT first_name, IFNULL(salary, 0) AS salary
FROM employees;

-- COALESCE (works with multiple values)
SELECT first_name, COALESCE(salary, 0) AS salary
FROM employees;
```

---

## Practice Exercises

### Exercise 1: Basic CRUD Operations
```sql
-- Create a students table
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    age INT,
    major VARCHAR(50),
    gpa DECIMAL(3,2)
);

-- Insert sample data
INSERT INTO students (first_name, last_name, email, age, major, gpa)
VALUES 
    ('Alice', 'Johnson', 'alice@email.com', 20, 'Computer Science', 3.8),
    ('Bob', 'Smith', 'bob@email.com', 22, 'Mathematics', 3.5),
    ('Carol', 'Davis', 'carol@email.com', 21, 'Physics', 3.9),
    ('David', 'Wilson', 'david@email.com', 23, 'Computer Science', 3.2);
```

### Exercise 2: Query Challenges
```sql
-- 1. Find all Computer Science students
SELECT * FROM students WHERE major = 'Computer Science';

-- 2. Find students with GPA above 3.5
SELECT * FROM students WHERE gpa > 3.5;

-- 3. Find students aged between 20 and 22
SELECT * FROM students WHERE age BETWEEN 20 AND 22;

-- 4. Find students whose names start with 'A' or 'B'
SELECT * FROM students WHERE first_name LIKE 'A%' OR first_name LIKE 'B%';

-- 5. List students ordered by GPA (highest first)
SELECT * FROM students ORDER BY gpa DESC;

-- 6. Show full name and GPA status
SELECT CONCAT(first_name, ' ', last_name) AS full_name,
    CASE 
        WHEN gpa >= 3.7 THEN 'Excellent'
        WHEN gpa >= 3.0 THEN 'Good'
        ELSE 'Needs Improvement'
    END AS performance
FROM students;
```

### Exercise 3: Update and Delete Practice
```sql
-- 1. Update Bob's GPA to 3.7
UPDATE students SET gpa = 3.7 WHERE first_name = 'Bob' AND last_name = 'Smith';

-- 2. Increase all Computer Science students' GPA by 0.1
UPDATE students SET gpa = gpa + 0.1 WHERE major = 'Computer Science';

-- 3. Delete students with GPA below 3.0
DELETE FROM students WHERE gpa < 3.0;
```

---

## Common Mistakes to Avoid

1. **Forgetting WHERE clause in UPDATE/DELETE**
   ```sql
   -- WRONG: This updates ALL records!
   UPDATE employees SET salary = 50000;
   
   -- CORRECT: Use WHERE clause
   UPDATE employees SET salary = 50000 WHERE emp_id = 1;
   ```

2. **Not using quotes for string values**
   ```sql
   -- WRONG
   SELECT * FROM employees WHERE first_name = John;
   
   -- CORRECT
   SELECT * FROM employees WHERE first_name = 'John';
   ```

3. **Incorrect NULL comparisons**
   ```sql
   -- WRONG
   SELECT * FROM employees WHERE salary = NULL;
   
   -- CORRECT
   SELECT * FROM employees WHERE salary IS NULL;
   ```

---

## Next Steps
Continue with [Part 3: Intermediate SQL](03_Intermediate_SQL.md) to learn about aggregate functions, joins, and subqueries.