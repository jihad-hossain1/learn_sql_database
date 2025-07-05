# SQL Database Guide - Part 8: Resources and Appendices

## Table of Contents
1. [SQL Reference Guide](#sql-reference-guide)
2. [Common SQL Functions](#common-sql-functions)
3. [Error Codes and Troubleshooting](#error-codes-and-troubleshooting)
4. [Database-Specific Syntax](#database-specific-syntax)
5. [Performance Tuning Checklist](#performance-tuning-checklist)
6. [Security Best Practices](#security-best-practices)
7. [Learning Resources](#learning-resources)
8. [Sample Datasets](#sample-datasets)
9. [SQL Interview Questions](#sql-interview-questions)
10. [Glossary](#glossary)

---

## SQL Reference Guide

### Data Definition Language (DDL)

#### CREATE TABLE
```sql
CREATE TABLE table_name (
    column1 datatype [constraints],
    column2 datatype [constraints],
    ...
    [table_constraints]
);

-- Example with all common constraints
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    salary DECIMAL(10,2) CHECK (salary > 0),
    department_id INT,
    manager_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id),
    INDEX idx_name (last_name, first_name),
    INDEX idx_department (department_id)
);
```

#### ALTER TABLE
```sql
-- Add column
ALTER TABLE table_name ADD COLUMN column_name datatype [constraints];

-- Modify column
ALTER TABLE table_name MODIFY COLUMN column_name new_datatype;

-- Drop column
ALTER TABLE table_name DROP COLUMN column_name;

-- Add constraint
ALTER TABLE table_name ADD CONSTRAINT constraint_name constraint_definition;

-- Drop constraint
ALTER TABLE table_name DROP CONSTRAINT constraint_name;

-- Add index
ALTER TABLE table_name ADD INDEX index_name (column1, column2);

-- Drop index
ALTER TABLE table_name DROP INDEX index_name;
```

### Data Manipulation Language (DML)

#### INSERT
```sql
-- Single row insert
INSERT INTO table_name (column1, column2, column3)
VALUES (value1, value2, value3);

-- Multiple rows insert
INSERT INTO table_name (column1, column2, column3)
VALUES 
    (value1a, value2a, value3a),
    (value1b, value2b, value3b),
    (value1c, value2c, value3c);

-- Insert from SELECT
INSERT INTO table_name (column1, column2)
SELECT column1, column2
FROM another_table
WHERE condition;

-- Insert with ON DUPLICATE KEY UPDATE (MySQL)
INSERT INTO table_name (id, name, value)
VALUES (1, 'John', 100)
ON DUPLICATE KEY UPDATE value = VALUES(value);
```

#### UPDATE
```sql
-- Basic update
UPDATE table_name
SET column1 = value1, column2 = value2
WHERE condition;

-- Update with JOIN
UPDATE table1 t1
JOIN table2 t2 ON t1.id = t2.id
SET t1.column1 = t2.column1
WHERE t2.condition = 'value';

-- Update with subquery
UPDATE table_name
SET column1 = (
    SELECT AVG(column1)
    FROM another_table
    WHERE condition
)
WHERE condition;
```

#### DELETE
```sql
-- Basic delete
DELETE FROM table_name
WHERE condition;

-- Delete with JOIN
DELETE t1
FROM table1 t1
JOIN table2 t2 ON t1.id = t2.id
WHERE t2.condition = 'value';

-- Delete with subquery
DELETE FROM table_name
WHERE column1 IN (
    SELECT column1
    FROM another_table
    WHERE condition
);
```

### Data Query Language (DQL)

#### SELECT Statement Structure
```sql
SELECT [DISTINCT] column_list
FROM table_list
[JOIN join_conditions]
[WHERE conditions]
[GROUP BY column_list]
[HAVING group_conditions]
[ORDER BY column_list [ASC|DESC]]
[LIMIT offset, count];
```

---

## Common SQL Functions

### String Functions

| Function | Description | Example |
|----------|-------------|----------|
| `CONCAT(str1, str2, ...)` | Concatenate strings | `CONCAT('Hello', ' ', 'World')` |
| `LENGTH(str)` | String length | `LENGTH('Hello')` returns 5 |
| `SUBSTRING(str, pos, len)` | Extract substring | `SUBSTRING('Hello', 2, 3)` returns 'ell' |
| `UPPER(str)` | Convert to uppercase | `UPPER('hello')` returns 'HELLO' |
| `LOWER(str)` | Convert to lowercase | `LOWER('HELLO')` returns 'hello' |
| `TRIM(str)` | Remove leading/trailing spaces | `TRIM(' hello ')` returns 'hello' |
| `REPLACE(str, old, new)` | Replace substring | `REPLACE('Hello World', 'World', 'SQL')` |
| `LEFT(str, len)` | Get leftmost characters | `LEFT('Hello', 3)` returns 'Hel' |
| `RIGHT(str, len)` | Get rightmost characters | `RIGHT('Hello', 3)` returns 'llo' |
| `LIKE` | Pattern matching | `name LIKE 'J%'` (starts with J) |

### Numeric Functions

| Function | Description | Example |
|----------|-------------|----------|
| `ABS(number)` | Absolute value | `ABS(-5)` returns 5 |
| `ROUND(number, decimals)` | Round number | `ROUND(3.14159, 2)` returns 3.14 |
| `CEIL(number)` | Round up | `CEIL(3.1)` returns 4 |
| `FLOOR(number)` | Round down | `FLOOR(3.9)` returns 3 |
| `MOD(number, divisor)` | Modulo operation | `MOD(10, 3)` returns 1 |
| `POWER(base, exponent)` | Power function | `POWER(2, 3)` returns 8 |
| `SQRT(number)` | Square root | `SQRT(16)` returns 4 |
| `RAND()` | Random number 0-1 | `RAND()` |

### Date and Time Functions

| Function | Description | Example |
|----------|-------------|----------|
| `NOW()` | Current date and time | `NOW()` |
| `CURDATE()` | Current date | `CURDATE()` |
| `CURTIME()` | Current time | `CURTIME()` |
| `DATE(datetime)` | Extract date part | `DATE('2023-12-25 10:30:00')` |
| `TIME(datetime)` | Extract time part | `TIME('2023-12-25 10:30:00')` |
| `YEAR(date)` | Extract year | `YEAR('2023-12-25')` returns 2023 |
| `MONTH(date)` | Extract month | `MONTH('2023-12-25')` returns 12 |
| `DAY(date)` | Extract day | `DAY('2023-12-25')` returns 25 |
| `DAYNAME(date)` | Day name | `DAYNAME('2023-12-25')` |
| `MONTHNAME(date)` | Month name | `MONTHNAME('2023-12-25')` |
| `DATE_ADD(date, INTERVAL value unit)` | Add time interval | `DATE_ADD('2023-01-01', INTERVAL 1 MONTH)` |
| `DATE_SUB(date, INTERVAL value unit)` | Subtract time interval | `DATE_SUB('2023-01-01', INTERVAL 1 DAY)` |
| `DATEDIFF(date1, date2)` | Difference in days | `DATEDIFF('2023-12-25', '2023-01-01')` |

### Aggregate Functions

| Function | Description | Example |
|----------|-------------|----------|
| `COUNT(*)` | Count all rows | `COUNT(*)` |
| `COUNT(column)` | Count non-NULL values | `COUNT(email)` |
| `SUM(column)` | Sum of values | `SUM(salary)` |
| `AVG(column)` | Average of values | `AVG(salary)` |
| `MIN(column)` | Minimum value | `MIN(salary)` |
| `MAX(column)` | Maximum value | `MAX(salary)` |
| `GROUP_CONCAT(column)` | Concatenate group values | `GROUP_CONCAT(name)` |

### Window Functions

| Function | Description | Example |
|----------|-------------|----------|
| `ROW_NUMBER()` | Sequential row number | `ROW_NUMBER() OVER (ORDER BY salary DESC)` |
| `RANK()` | Rank with gaps | `RANK() OVER (ORDER BY salary DESC)` |
| `DENSE_RANK()` | Rank without gaps | `DENSE_RANK() OVER (ORDER BY salary DESC)` |
| `LAG(column, offset)` | Previous row value | `LAG(salary, 1) OVER (ORDER BY hire_date)` |
| `LEAD(column, offset)` | Next row value | `LEAD(salary, 1) OVER (ORDER BY hire_date)` |
| `FIRST_VALUE(column)` | First value in window | `FIRST_VALUE(salary) OVER (ORDER BY hire_date)` |
| `LAST_VALUE(column)` | Last value in window | `LAST_VALUE(salary) OVER (ORDER BY hire_date)` |

---

## Error Codes and Troubleshooting

### Common MySQL Error Codes

| Error Code | Error Name | Description | Solution |
|------------|------------|-------------|----------|
| 1045 | Access Denied | Invalid username/password | Check credentials |
| 1049 | Unknown Database | Database doesn't exist | Create database or check name |
| 1054 | Unknown Column | Column doesn't exist | Check column name and table structure |
| 1062 | Duplicate Entry | Unique constraint violation | Check for duplicate values |
| 1064 | SQL Syntax Error | Invalid SQL syntax | Review SQL statement syntax |
| 1146 | Table Doesn't Exist | Referenced table not found | Create table or check table name |
| 1216 | Foreign Key Constraint | FK constraint violation | Check referenced table and values |
| 1451 | Cannot Delete Parent Row | FK constraint prevents deletion | Delete child records first |

### Common PostgreSQL Error Codes

| Error Code | Error Name | Description | Solution |
|------------|------------|-------------|----------|
| 08001 | Connection Exception | Cannot connect to server | Check server status and connection |
| 23505 | Unique Violation | Unique constraint violation | Check for duplicate values |
| 23503 | Foreign Key Violation | FK constraint violation | Check referenced values |
| 42P01 | Undefined Table | Table doesn't exist | Create table or check name |
| 42703 | Undefined Column | Column doesn't exist | Check column name |
| 42601 | Syntax Error | Invalid SQL syntax | Review SQL statement |

### Troubleshooting Tips

1. **Check Error Messages Carefully**
   - Read the complete error message
   - Note the line number and position
   - Look for specific table/column names mentioned

2. **Common Syntax Issues**
   ```sql
   -- Missing comma
   SELECT name, email phone FROM users; -- ERROR
   SELECT name, email, phone FROM users; -- CORRECT
   
   -- Incorrect quotes
   SELECT * FROM users WHERE name = "John"; -- ERROR (use single quotes)
   SELECT * FROM users WHERE name = 'John'; -- CORRECT
   
   -- Missing GROUP BY
   SELECT department, COUNT(*) FROM employees; -- ERROR
   SELECT department, COUNT(*) FROM employees GROUP BY department; -- CORRECT
   ```

3. **Performance Issues**
   - Check for missing indexes
   - Analyze query execution plans
   - Look for unnecessary JOINs or subqueries
   - Consider query optimization

---

## Database-Specific Syntax

### MySQL vs PostgreSQL vs SQL Server

| Feature | MySQL | PostgreSQL | SQL Server |
|---------|-------|------------|------------|
| **Auto Increment** | `AUTO_INCREMENT` | `SERIAL` or `IDENTITY` | `IDENTITY(1,1)` |
| **String Concatenation** | `CONCAT()` | `\|\|` or `CONCAT()` | `+` or `CONCAT()` |
| **Limit Results** | `LIMIT n` | `LIMIT n` | `TOP n` |
| **Date Functions** | `NOW()`, `CURDATE()` | `NOW()`, `CURRENT_DATE` | `GETDATE()`, `GETUTCDATE()` |
| **String Length** | `LENGTH()` | `LENGTH()` or `CHAR_LENGTH()` | `LEN()` |
| **Case Sensitivity** | Case-insensitive | Case-sensitive | Case-insensitive |
| **Boolean Type** | `BOOLEAN` (TINYINT) | `BOOLEAN` | `BIT` |
| **JSON Support** | `JSON` | `JSON`, `JSONB` | `NVARCHAR(MAX)` |

### MySQL Specific Features
```sql
-- MySQL specific syntax
INSERT INTO table_name (col1, col2) VALUES (val1, val2)
ON DUPLICATE KEY UPDATE col2 = VALUES(col2);

-- MySQL LIMIT with OFFSET
SELECT * FROM table_name LIMIT 10 OFFSET 20;
-- or
SELECT * FROM table_name LIMIT 20, 10;

-- MySQL specific functions
SELECT GROUP_CONCAT(column_name) FROM table_name;
SELECT FOUND_ROWS(); -- Get total rows without LIMIT
```

### PostgreSQL Specific Features
```sql
-- PostgreSQL specific syntax
INSERT INTO table_name (col1, col2) VALUES (val1, val2)
ON CONFLICT (col1) DO UPDATE SET col2 = EXCLUDED.col2;

-- PostgreSQL LIMIT with OFFSET
SELECT * FROM table_name LIMIT 10 OFFSET 20;

-- PostgreSQL specific functions
SELECT STRING_AGG(column_name, ',') FROM table_name;
SELECT EXTRACT(YEAR FROM date_column) FROM table_name;

-- Arrays
SELECT ARRAY[1, 2, 3];
SELECT column_name[1] FROM table_with_array_column;
```

### SQL Server Specific Features
```sql
-- SQL Server specific syntax
MERGE target_table AS target
USING source_table AS source
ON target.id = source.id
WHEN MATCHED THEN UPDATE SET target.col = source.col
WHEN NOT MATCHED THEN INSERT (col1, col2) VALUES (source.col1, source.col2);

-- SQL Server TOP
SELECT TOP 10 * FROM table_name;

-- SQL Server specific functions
SELECT STRING_AGG(column_name, ',') FROM table_name;
SELECT DATEPART(YEAR, date_column) FROM table_name;
```

---

## Performance Tuning Checklist

### Query Optimization
- [ ] Use appropriate indexes
- [ ] Avoid SELECT *
- [ ] Use LIMIT when possible
- [ ] Optimize WHERE clauses
- [ ] Use EXISTS instead of IN for subqueries
- [ ] Avoid functions in WHERE clauses
- [ ] Use appropriate JOIN types
- [ ] Consider query execution plan

### Index Optimization
- [ ] Create indexes on frequently queried columns
- [ ] Use composite indexes for multi-column queries
- [ ] Remove unused indexes
- [ ] Monitor index usage statistics
- [ ] Consider covering indexes
- [ ] Use partial indexes when appropriate

### Database Design
- [ ] Proper normalization
- [ ] Appropriate data types
- [ ] Efficient table structure
- [ ] Proper constraints
- [ ] Consider partitioning for large tables

### Server Configuration
- [ ] Adequate memory allocation
- [ ] Proper buffer pool size
- [ ] Optimize connection pooling
- [ ] Configure query cache (if available)
- [ ] Monitor disk I/O
- [ ] Regular maintenance tasks

---

## Security Best Practices

### Access Control
1. **Principle of Least Privilege**
   - Grant minimum necessary permissions
   - Use role-based access control
   - Regular permission audits

2. **User Management**
   ```sql
   -- Create user with limited privileges
   CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'strong_password';
   GRANT SELECT, INSERT, UPDATE ON app_database.* TO 'app_user'@'localhost';
   
   -- Create read-only user
   CREATE USER 'readonly_user'@'%' IDENTIFIED BY 'strong_password';
   GRANT SELECT ON app_database.* TO 'readonly_user'@'%';
   ```

### SQL Injection Prevention
1. **Use Parameterized Queries**
   ```sql
   -- Bad (vulnerable to SQL injection)
   query = "SELECT * FROM users WHERE username = '" + username + "'";
   
   -- Good (parameterized query)
   query = "SELECT * FROM users WHERE username = ?";
   ```

2. **Input Validation**
   - Validate all user inputs
   - Use whitelist validation
   - Escape special characters
   - Limit input length

### Data Protection
1. **Encryption**
   - Encrypt sensitive data at rest
   - Use SSL/TLS for data in transit
   - Implement column-level encryption for sensitive fields

2. **Backup Security**
   - Encrypt backup files
   - Secure backup storage
   - Test backup restoration
   - Implement backup retention policies

### Auditing and Monitoring
1. **Enable Audit Logging**
   ```sql
   -- MySQL audit log
   SET GLOBAL general_log = 'ON';
   SET GLOBAL log_output = 'TABLE';
   
   -- PostgreSQL logging
   -- In postgresql.conf:
   -- log_statement = 'all'
   -- log_connections = on
   ```

2. **Monitor Suspicious Activity**
   - Failed login attempts
   - Unusual query patterns
   - Privilege escalation attempts
   - Data access patterns

---

## Learning Resources

### Online Platforms
1. **Interactive Learning**
   - [SQLBolt](https://sqlbolt.com/) - Interactive SQL tutorial
   - [W3Schools SQL](https://www.w3schools.com/sql/) - Comprehensive SQL tutorial
   - [Codecademy SQL](https://www.codecademy.com/learn/learn-sql) - Interactive SQL course
   - [Khan Academy Intro to SQL](https://www.khanacademy.org/computing/computer-programming/sql) - Beginner-friendly

2. **Practice Platforms**
   - [HackerRank SQL](https://www.hackerrank.com/domains/sql) - SQL challenges
   - [LeetCode Database](https://leetcode.com/problemset/database/) - SQL interview questions
   - [SQLZoo](https://sqlzoo.net/) - SQL tutorials and exercises
   - [DB Fiddle](https://www.db-fiddle.com/) - Online SQL playground

### Books
1. **Beginner Level**
   - "Learning SQL" by Alan Beaulieu
   - "SQL in 10 Minutes, Sams Teach Yourself" by Ben Forta
   - "Head First SQL" by Lynn Beighley

2. **Intermediate/Advanced**
   - "SQL Cookbook" by Anthony Molinaro
   - "High Performance MySQL" by Baron Schwartz
   - "PostgreSQL: Up and Running" by Regina Obe

### Documentation
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [SQL Server Documentation](https://docs.microsoft.com/en-us/sql/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)

### Video Courses
- Coursera: "Introduction to Structured Query Language (SQL)"
- edX: "Introduction to Databases"
- Udemy: Various SQL courses
- YouTube: FreeCodeCamp SQL tutorials

---

## Sample Datasets

### 1. Sakila Database (MySQL)
**Description**: DVD rental store database
**Download**: [MySQL Sakila](https://dev.mysql.com/doc/sakila/en/)
**Tables**: actor, film, customer, rental, payment, etc.
**Use Cases**: Learning JOINs, aggregations, date functions

### 2. Northwind Database
**Description**: Trading company database
**Download**: Available for multiple databases
**Tables**: customers, orders, products, employees, suppliers
**Use Cases**: Business analytics, reporting queries

### 3. Chinook Database
**Description**: Digital music store database
**Download**: [GitHub Chinook](https://github.com/lerocha/chinook-database)
**Tables**: artists, albums, tracks, customers, invoices
**Use Cases**: Music industry analytics, sales reporting

### 4. World Database
**Description**: Countries, cities, and languages
**Download**: [MySQL World Database](https://dev.mysql.com/doc/world-setup/en/)
**Tables**: country, city, countrylanguage
**Use Cases**: Geographic queries, population analysis

### 5. Employee Database
**Description**: Large employee dataset
**Download**: [GitHub Employees DB](https://github.com/datacharmer/test_db)
**Tables**: employees, departments, salaries, titles
**Use Cases**: HR analytics, performance testing

---

## SQL Interview Questions

### Basic Level

1. **What is the difference between DELETE and TRUNCATE?**
   - DELETE removes rows one by one and can be rolled back
   - TRUNCATE removes all rows at once and cannot be rolled back
   - DELETE can use WHERE clause, TRUNCATE cannot

2. **Explain different types of JOINs**
   - INNER JOIN: Returns matching records from both tables
   - LEFT JOIN: Returns all records from left table and matching from right
   - RIGHT JOIN: Returns all records from right table and matching from left
   - FULL OUTER JOIN: Returns all records from both tables

3. **What is the difference between WHERE and HAVING?**
   - WHERE filters rows before grouping
   - HAVING filters groups after GROUP BY

### Intermediate Level

4. **Write a query to find the second highest salary**
   ```sql
   SELECT MAX(salary) as second_highest
   FROM employees
   WHERE salary < (SELECT MAX(salary) FROM employees);
   
   -- Or using window functions
   SELECT DISTINCT salary
   FROM (
       SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) as rank
       FROM employees
   ) ranked
   WHERE rank = 2;
   ```

5. **Find employees who earn more than their manager**
   ```sql
   SELECT e.name, e.salary, m.name as manager_name, m.salary as manager_salary
   FROM employees e
   JOIN employees m ON e.manager_id = m.employee_id
   WHERE e.salary > m.salary;
   ```

6. **Find duplicate records in a table**
   ```sql
   SELECT email, COUNT(*) as count
   FROM users
   GROUP BY email
   HAVING COUNT(*) > 1;
   ```

### Advanced Level

7. **Calculate running total**
   ```sql
   SELECT 
       order_date,
       amount,
       SUM(amount) OVER (ORDER BY order_date) as running_total
   FROM orders
   ORDER BY order_date;
   ```

8. **Find top N records per group**
   ```sql
   SELECT department, employee_name, salary
   FROM (
       SELECT 
           department,
           employee_name,
           salary,
           ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) as rn
       FROM employees
   ) ranked
   WHERE rn <= 3;
   ```

9. **Pivot table query**
   ```sql
   SELECT 
       product_id,
       SUM(CASE WHEN YEAR(order_date) = 2022 THEN quantity ELSE 0 END) as qty_2022,
       SUM(CASE WHEN YEAR(order_date) = 2023 THEN quantity ELSE 0 END) as qty_2023
   FROM orders
   GROUP BY product_id;
   ```

---

## Glossary

**ACID**: Atomicity, Consistency, Isolation, Durability - properties of database transactions

**Aggregate Function**: Function that performs calculation on multiple rows (SUM, COUNT, AVG, etc.)

**Cardinality**: Number of unique values in a column or relationship between tables

**Constraint**: Rule that limits the data that can be stored in a table

**CTE (Common Table Expression)**: Temporary named result set that exists within a single statement

**Cursor**: Database object used to retrieve data row by row

**Deadlock**: Situation where two or more transactions wait for each other indefinitely

**Denormalization**: Process of adding redundancy to improve performance

**Foreign Key**: Column that references the primary key of another table

**Index**: Database object that improves query performance

**Join**: Operation that combines rows from two or more tables

**Normalization**: Process of organizing data to reduce redundancy

**OLAP**: Online Analytical Processing - for complex analytical queries

**OLTP**: Online Transaction Processing - for day-to-day operations

**Primary Key**: Column(s) that uniquely identify each row in a table

**Query Optimizer**: Database component that determines the most efficient way to execute queries

**Referential Integrity**: Ensures relationships between tables remain consistent

**Schema**: Structure that defines the organization of data in a database

**Stored Procedure**: Precompiled SQL code stored in the database

**Subquery**: Query nested inside another query

**Transaction**: Unit of work that is either completed entirely or not at all

**Trigger**: Special stored procedure that automatically executes in response to events

**View**: Virtual table based on the result of a SELECT statement

**Window Function**: Function that performs calculations across a set of rows related to the current row

---

## Conclusion

This comprehensive SQL database guide covers everything from basic concepts to advanced techniques. The key to mastering SQL is consistent practice and real-world application. Use the resources, practice with the sample datasets, and work through the projects to build your expertise.

Remember:
- Start with the basics and build gradually
- Practice regularly with real datasets
- Focus on understanding concepts, not just memorizing syntax
- Learn database-specific features as needed
- Keep security and performance in mind
- Stay updated with new features and best practices

Good luck on your SQL learning journey!