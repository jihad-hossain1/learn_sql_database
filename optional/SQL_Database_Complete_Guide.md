# SQL Database Complete Learning Guide

## Table of Contents
1. [Introduction to Databases](#introduction-to-databases)
2. [Basic SQL Concepts](#basic-sql-concepts)
3. [Database Design Fundamentals](#database-design-fundamentals)
4. [Basic SQL Operations (CRUD)](#basic-sql-operations-crud)
5. [Data Types](#data-types)
6. [Constraints](#constraints)
7. [Intermediate SQL](#intermediate-sql)
8. [Advanced SQL](#advanced-sql)
9. [Database Administration](#database-administration)
10. [Performance Optimization](#performance-optimization)
11. [Security](#security)
12. [Practice Exercises](#practice-exercises)
13. [Resources and Next Steps](#resources-and-next-steps)

---

## Introduction to Databases

### What is a Database?
A database is an organized collection of structured information, or data, typically stored electronically in a computer system. A database is usually controlled by a database management system (DBMS).

### Types of Databases
- **Relational Databases (RDBMS)**: MySQL, PostgreSQL, SQL Server, Oracle
- **NoSQL Databases**: MongoDB, Cassandra, Redis
- **Graph Databases**: Neo4j, Amazon Neptune
- **Time-Series Databases**: InfluxDB, TimescaleDB

### Why Use Databases?
- Data persistence
- Data integrity
- Concurrent access
- Security
- Backup and recovery
- Scalability

---

## Basic SQL Concepts

### What is SQL?
SQL (Structured Query Language) is a programming language designed for managing and manipulating relational databases.

### SQL Categories
1. **DDL (Data Definition Language)**: CREATE, ALTER, DROP
2. **DML (Data Manipulation Language)**: INSERT, UPDATE, DELETE
3. **DQL (Data Query Language)**: SELECT
4. **DCL (Data Control Language)**: GRANT, REVOKE
5. **TCL (Transaction Control Language)**: COMMIT, ROLLBACK

### Basic Terminology
- **Table**: A collection of related data entries
- **Row/Record**: A single entry in a table
- **Column/Field**: A single attribute of a record
- **Primary Key**: Unique identifier for each record
- **Foreign Key**: Reference to primary key in another table

---

## Database Design Fundamentals

### Entity-Relationship (ER) Model
- **Entity**: A thing or object (e.g., Customer, Product)
- **Attribute**: Properties of entities (e.g., Name, Price)
- **Relationship**: Associations between entities

### Normalization
#### First Normal Form (1NF)
- Eliminate repeating groups
- Each cell contains atomic values

#### Second Normal Form (2NF)
- Must be in 1NF
- Eliminate partial dependencies

#### Third Normal Form (3NF)
- Must be in 2NF
- Eliminate transitive dependencies

### Example Database Schema
```sql
-- Customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0
);

-- Orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

---

## Basic SQL Operations (CRUD)

### CREATE - Creating Tables and Inserting Data

#### Creating Tables
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

#### Inserting Data
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
```

### READ - Querying Data

#### Basic SELECT Statements
```sql
-- Select all columns
SELECT * FROM employees;

-- Select specific columns
SELECT first_name, last_name, salary FROM employees;

-- Select with conditions
SELECT * FROM employees WHERE department = 'IT';

-- Select with multiple conditions
SELECT * FROM employees 
WHERE department = 'IT' AND salary > 70000;
```

#### Sorting and Limiting
```sql
-- Order by salary (ascending)
SELECT * FROM employees ORDER BY salary;

-- Order by salary (descending)
SELECT * FROM employees ORDER BY salary DESC;

-- Limit results
SELECT * FROM employees ORDER BY salary DESC LIMIT 5;

-- Offset and limit (pagination)
SELECT * FROM employees ORDER BY emp_id LIMIT 10 OFFSET 20;
```

### UPDATE - Modifying Data
```sql
-- Update single record
UPDATE employees 
SET salary = 85000.00 
WHERE emp_id = 1;

-- Update multiple records
UPDATE employees 
SET salary = salary * 1.1 
WHERE department = 'IT';

-- Update with conditions
UPDATE employees 
SET department = 'Engineering' 
WHERE department = 'IT' AND hire_date < '2023-02-01';
```

### DELETE - Removing Data
```sql
-- Delete specific record
DELETE FROM employees WHERE emp_id = 5;

-- Delete with conditions
DELETE FROM employees WHERE department = 'Temp';

-- Delete all records (be careful!)
DELETE FROM employees;
```

---

## Data Types

### Numeric Types
- **INT**: Integer numbers
- **DECIMAL(p,s)**: Fixed-point numbers
- **FLOAT**: Floating-point numbers
- **DOUBLE**: Double-precision floating-point

### String Types
- **VARCHAR(n)**: Variable-length string
- **CHAR(n)**: Fixed-length string
- **TEXT**: Large text data
- **BLOB**: Binary large object

### Date and Time Types
- **DATE**: Date (YYYY-MM-DD)
- **TIME**: Time (HH:MM:SS)
- **DATETIME**: Date and time
- **TIMESTAMP**: Timestamp with timezone

### Boolean Type
- **BOOLEAN**: True/False values

---

## Constraints

### Primary Key
```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL
);
```

### Foreign Key
```sql
CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    title VARCHAR(200),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

### Unique Constraint
```sql
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    email VARCHAR(100) UNIQUE,
    username VARCHAR(50) UNIQUE
);
```

### Check Constraint
```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    price DECIMAL(10,2) CHECK (price > 0),
    stock_quantity INT CHECK (stock_quantity >= 0)
);
```

### Not Null Constraint
```sql
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL
);
```

---

## Intermediate SQL

### Aggregate Functions
```sql
-- Count records
SELECT COUNT(*) FROM employees;

-- Sum values
SELECT SUM(salary) FROM employees;

-- Average
SELECT AVG(salary) FROM employees;

-- Min and Max
SELECT MIN(salary), MAX(salary) FROM employees;

-- Group by
SELECT department, COUNT(*), AVG(salary)
FROM employees
GROUP BY department;

-- Having clause
SELECT department, AVG(salary)
FROM employees
GROUP BY department
HAVING AVG(salary) > 70000;
```

### Joins

#### Inner Join
```sql
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;
```

#### Left Join
```sql
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;
```

#### Right Join
```sql
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id;
```

#### Full Outer Join
```sql
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
FULL OUTER JOIN departments d ON e.department_id = d.department_id;
```

### Subqueries
```sql
-- Subquery in WHERE clause
SELECT * FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Subquery in FROM clause
SELECT dept_avg.department, dept_avg.avg_salary
FROM (
    SELECT department, AVG(salary) as avg_salary
    FROM employees
    GROUP BY department
) dept_avg
WHERE dept_avg.avg_salary > 70000;

-- Correlated subquery
SELECT e1.first_name, e1.last_name, e1.salary
FROM employees e1
WHERE e1.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department = e1.department
);
```

### String Functions
```sql
-- Concatenation
SELECT CONCAT(first_name, ' ', last_name) as full_name FROM employees;

-- Length
SELECT first_name, LENGTH(first_name) FROM employees;

-- Substring
SELECT SUBSTRING(first_name, 1, 3) FROM employees;

-- Upper and Lower case
SELECT UPPER(first_name), LOWER(last_name) FROM employees;

-- Trim
SELECT TRIM(first_name) FROM employees;
```

### Date Functions
```sql
-- Current date and time
SELECT NOW(), CURDATE(), CURTIME();

-- Date formatting
SELECT DATE_FORMAT(hire_date, '%Y-%m-%d') FROM employees;

-- Date arithmetic
SELECT hire_date, DATE_ADD(hire_date, INTERVAL 1 YEAR) as anniversary
FROM employees;

-- Date difference
SELECT DATEDIFF(NOW(), hire_date) as days_employed FROM employees;
```

---

## Advanced SQL

### Window Functions
```sql
-- Row number
SELECT 
    first_name, 
    last_name, 
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) as rank
FROM employees;

-- Rank and Dense Rank
SELECT 
    first_name, 
    last_name, 
    salary,
    RANK() OVER (ORDER BY salary DESC) as rank,
    DENSE_RANK() OVER (ORDER BY salary DESC) as dense_rank
FROM employees;

-- Partition by
SELECT 
    first_name, 
    last_name, 
    department,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) as dept_rank
FROM employees;

-- Running totals
SELECT 
    first_name, 
    salary,
    SUM(salary) OVER (ORDER BY hire_date) as running_total
FROM employees;
```

### Common Table Expressions (CTEs)
```sql
-- Basic CTE
WITH high_earners AS (
    SELECT * FROM employees WHERE salary > 75000
)
SELECT department, COUNT(*) as high_earner_count
FROM high_earners
GROUP BY department;

-- Recursive CTE (for hierarchical data)
WITH RECURSIVE employee_hierarchy AS (
    -- Base case
    SELECT emp_id, first_name, last_name, manager_id, 1 as level
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case
    SELECT e.emp_id, e.first_name, e.last_name, e.manager_id, eh.level + 1
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.emp_id
)
SELECT * FROM employee_hierarchy ORDER BY level, emp_id;
```

### Stored Procedures
```sql
DELIMITER //

CREATE PROCEDURE GetEmployeesByDepartment(
    IN dept_name VARCHAR(50)
)
BEGIN
    SELECT * FROM employees WHERE department = dept_name;
END //

DELIMITER ;

-- Call the procedure
CALL GetEmployeesByDepartment('IT');
```

### Functions
```sql
DELIMITER //

CREATE FUNCTION CalculateBonus(salary DECIMAL(10,2))
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE bonus DECIMAL(10,2);
    
    IF salary > 80000 THEN
        SET bonus = salary * 0.15;
    ELSEIF salary > 60000 THEN
        SET bonus = salary * 0.10;
    ELSE
        SET bonus = salary * 0.05;
    END IF;
    
    RETURN bonus;
END //

DELIMITER ;

-- Use the function
SELECT first_name, last_name, salary, CalculateBonus(salary) as bonus
FROM employees;
```

### Triggers
```sql
-- Audit trigger
CREATE TABLE employee_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE TRIGGER salary_audit
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF OLD.salary != NEW.salary THEN
        INSERT INTO employee_audit (emp_id, old_salary, new_salary)
        VALUES (NEW.emp_id, OLD.salary, NEW.salary);
    END IF;
END //

DELIMITER ;
```

### Views
```sql
-- Create a view
CREATE VIEW employee_summary AS
SELECT 
    department,
    COUNT(*) as employee_count,
    AVG(salary) as avg_salary,
    MIN(salary) as min_salary,
    MAX(salary) as max_salary
FROM employees
GROUP BY department;

-- Use the view
SELECT * FROM employee_summary WHERE avg_salary > 70000;
```

---

## Database Administration

### User Management
```sql
-- Create user
CREATE USER 'newuser'@'localhost' IDENTIFIED BY 'password';

-- Grant privileges
GRANT SELECT, INSERT, UPDATE ON company.employees TO 'newuser'@'localhost';

-- Grant all privileges
GRANT ALL PRIVILEGES ON company.* TO 'admin'@'localhost';

-- Revoke privileges
REVOKE INSERT ON company.employees FROM 'newuser'@'localhost';

-- Drop user
DROP USER 'olduser'@'localhost';
```

### Backup and Restore
```bash
# Backup database
mysqldump -u username -p database_name > backup.sql

# Restore database
mysql -u username -p database_name < backup.sql

# Backup specific tables
mysqldump -u username -p database_name table1 table2 > tables_backup.sql
```

### Transactions
```sql
-- Basic transaction
START TRANSACTION;

UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;

COMMIT;

-- Transaction with rollback
START TRANSACTION;

UPDATE inventory SET quantity = quantity - 5 WHERE product_id = 1;

IF (SELECT quantity FROM inventory WHERE product_id = 1) < 0 THEN
    ROLLBACK;
ELSE
    COMMIT;
END IF;
```

---

## Performance Optimization

### Indexes
```sql
-- Create index
CREATE INDEX idx_employee_department ON employees(department);

-- Composite index
CREATE INDEX idx_employee_dept_salary ON employees(department, salary);

-- Unique index
CREATE UNIQUE INDEX idx_employee_email ON employees(email);

-- Drop index
DROP INDEX idx_employee_department ON employees;

-- Show indexes
SHOW INDEXES FROM employees;
```

### Query Optimization
```sql
-- Use EXPLAIN to analyze queries
EXPLAIN SELECT * FROM employees WHERE department = 'IT';

-- Avoid SELECT *
-- Bad
SELECT * FROM employees WHERE department = 'IT';

-- Good
SELECT emp_id, first_name, last_name FROM employees WHERE department = 'IT';

-- Use LIMIT for large datasets
SELECT * FROM employees ORDER BY hire_date DESC LIMIT 10;

-- Use EXISTS instead of IN for subqueries
-- Less efficient
SELECT * FROM employees WHERE department_id IN (
    SELECT department_id FROM departments WHERE location = 'New York'
);

-- More efficient
SELECT * FROM employees e WHERE EXISTS (
    SELECT 1 FROM departments d 
    WHERE d.department_id = e.department_id AND d.location = 'New York'
);
```

### Database Maintenance
```sql
-- Analyze table
ANALYZE TABLE employees;

-- Optimize table
OPTIMIZE TABLE employees;

-- Check table
CHECK TABLE employees;

-- Repair table
REPAIR TABLE employees;
```

---

## Security

### SQL Injection Prevention
```sql
-- Use parameterized queries (example in different languages)

-- PHP with PDO
$stmt = $pdo->prepare("SELECT * FROM users WHERE username = ? AND password = ?");
$stmt->execute([$username, $password]);

-- Python with parameterized queries
cursor.execute("SELECT * FROM users WHERE username = %s AND password = %s", (username, password))

-- Avoid string concatenation
-- BAD: "SELECT * FROM users WHERE id = " + user_id
-- GOOD: Use parameterized queries
```

### Data Encryption
```sql
-- Encrypt sensitive data
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50),
    password_hash VARCHAR(255), -- Store hashed passwords
    credit_card AES_ENCRYPT('1234567890123456', 'encryption_key')
);

-- Decrypt data
SELECT AES_DECRYPT(credit_card, 'encryption_key') as decrypted_cc FROM users;
```

### Access Control
```sql
-- Create roles
CREATE ROLE 'app_read';
CREATE ROLE 'app_write';

-- Grant privileges to roles
GRANT SELECT ON company.* TO 'app_read';
GRANT INSERT, UPDATE, DELETE ON company.* TO 'app_write';

-- Assign roles to users
GRANT 'app_read' TO 'readonly_user'@'localhost';
GRANT 'app_read', 'app_write' TO 'admin_user'@'localhost';
```

---

## Practice Exercises

### Beginner Level

1. **Create a Library Database**
   - Tables: books, authors, borrowers, loans
   - Practice basic CRUD operations

2. **E-commerce Database**
   - Tables: customers, products, orders, order_items
   - Practice joins and aggregations

### Intermediate Level

3. **Employee Management System**
   - Implement hierarchical data (manager-employee relationships)
   - Use window functions for ranking
   - Create views for reporting

4. **Banking System**
   - Implement transactions
   - Create triggers for audit trails
   - Practice stored procedures

### Advanced Level

5. **Data Warehouse Design**
   - Create fact and dimension tables
   - Implement slowly changing dimensions
   - Practice complex analytical queries

6. **Performance Optimization Challenge**
   - Create large datasets
   - Identify slow queries
   - Optimize using indexes and query rewriting

### Sample Database Schema for Practice
```sql
-- Complete e-commerce database
CREATE DATABASE ecommerce;
USE ecommerce;

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(200) NOT NULL,
    category_id INT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

---

## Resources and Next Steps

### Online Resources
- **W3Schools SQL Tutorial**: Comprehensive beginner guide
- **SQLBolt**: Interactive SQL lessons
- **HackerRank SQL**: Practice problems
- **LeetCode Database**: Advanced SQL problems
- **Mode Analytics SQL Tutorial**: Real-world examples

### Books
- "Learning SQL" by Alan Beaulieu
- "SQL in 10 Minutes, Sams Teach Yourself" by Ben Forta
- "High Performance MySQL" by Baron Schwartz
- "Database Design for Mere Mortals" by Michael Hernandez

### Database Systems to Practice
- **MySQL**: Most popular open-source database
- **PostgreSQL**: Advanced open-source database
- **SQLite**: Lightweight, file-based database
- **SQL Server**: Microsoft's enterprise database
- **Oracle**: Enterprise-grade database system

### Next Steps
1. **Choose a Database System**: Start with MySQL or PostgreSQL
2. **Set Up Development Environment**: Install database and GUI tools
3. **Practice Daily**: Solve SQL problems regularly
4. **Build Projects**: Create real-world applications
5. **Learn Database Administration**: Backup, security, performance tuning
6. **Explore NoSQL**: MongoDB, Redis for different use cases
7. **Study Data Modeling**: Advanced database design patterns
8. **Learn Big Data Technologies**: Hadoop, Spark, data warehousing

### Certification Paths
- **MySQL Certified Developer**
- **Oracle Certified Professional**
- **Microsoft SQL Server Certifications**
- **PostgreSQL Certified Professional**

### Tools and Software
- **Database Management**: phpMyAdmin, pgAdmin, MySQL Workbench
- **Query Tools**: DBeaver, DataGrip, Sequel Pro
- **Modeling Tools**: MySQL Workbench, Lucidchart, draw.io
- **Version Control**: Flyway, Liquibase for database migrations

---

## Conclusion

This guide provides a comprehensive roadmap for learning SQL databases from basic to advanced levels. Remember that mastering SQL requires consistent practice and hands-on experience. Start with the basics, build a solid foundation, and gradually move to more complex topics.

**Key Tips for Success:**
- Practice regularly with real datasets
- Focus on understanding concepts, not just memorizing syntax
- Build actual projects to apply your knowledge
- Join SQL communities and forums for help and discussion
- Stay updated with new features and best practices

Good luck on your SQL learning journey!