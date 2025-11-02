I'll create three comprehensive MySQL guide books in Markdown format for different skill levels.

## 📚 MySQL Learning Path

# 1. MySQL Beginner's Guide.md

# MySQL Beginner's Guide

## 🚀 Getting Started with MySQL

### What is MySQL?
MySQL is an open-source relational database management system that uses SQL (Structured Query Language) to manage data.

### Installation & Setup

#### Windows
```sql
-- Download MySQL Installer from dev.mysql.com
-- Run installer and follow setup wizard
-- Start MySQL Service
```

#### macOS
```bash
# Using Homebrew
brew install mysql
brew services start mysql
```

#### Linux (Ubuntu)
```bash
sudo apt update
sudo apt install mysql-server
sudo systemctl start mysql
```

### Basic Database Concepts

- **Database**: Collection of related data
- **Table**: Structure that holds data in rows and columns
- **Column**: Data attribute (name, age, email)
- **Row**: Single record in a table
- **Primary Key**: Unique identifier for each record

### Connecting to MySQL
```sql
-- Command Line
mysql -u root -p

-- Basic commands
SHOW DATABASES;
USE database_name;
SHOW TABLES;
```

### Creating Your First Database

```sql
-- Create database
CREATE DATABASE school;

-- Use database
USE school;

-- Create table
CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Basic SQL Operations

#### INSERT Data
```sql
INSERT INTO students (name, age, email) 
VALUES ('John Doe', 20, 'john@email.com');

INSERT INTO students (name, age, email) 
VALUES 
    ('Jane Smith', 22, 'jane@email.com'),
    ('Bob Johnson', 19, 'bob@email.com');
```

#### SELECT Data
```sql
-- Select all columns
SELECT * FROM students;

-- Select specific columns
SELECT name, age FROM students;

-- Select with condition
SELECT * FROM students WHERE age > 20;
```

#### UPDATE Data
```sql
UPDATE students 
SET age = 21, email = 'john.new@email.com'
WHERE name = 'John Doe';
```

#### DELETE Data
```sql
DELETE FROM students WHERE id = 3;
```

### Basic Filtering and Sorting

```sql
-- WHERE clause examples
SELECT * FROM students WHERE age >= 20;
SELECT * FROM students WHERE name LIKE 'J%';
SELECT * FROM students WHERE email IS NOT NULL;

-- ORDER BY
SELECT * FROM students ORDER BY age DESC;
SELECT * FROM students ORDER BY name ASC;

-- LIMIT
SELECT * FROM students LIMIT 5;
```

### Data Types in MySQL

| Category | Types | Description |
|----------|-------|-------------|
| Numeric | INT, DECIMAL, FLOAT | Numbers |
| String | VARCHAR, TEXT, CHAR | Text data |
| Date/Time | DATE, TIME, DATETIME | Date and time |
| Boolean | BOOLEAN, BOOL | True/False values |

### Practice Exercises

1. Create a database for a library system
2. Create tables for books and members
3. Insert sample data
4. Practice basic queries

### Common Errors & Solutions

```sql
-- Error: Table doesn't exist
-- Solution: Check table name or create table

-- Error: Column doesn't exist
-- Solution: Verify column names with DESCRIBE table_name

-- Error: Syntax error
-- Solution: Check SQL syntax and quotes
```

### Next Steps
- Learn about relationships between tables
- Understand different types of JOINs
- Practice with more complex queries

---

# 2. MySQL Intermediate Guide.md

# MySQL Intermediate Guide

## 🔧 Building on Basics

### Table Relationships

#### One-to-Many Relationship
```sql
CREATE DATABASE ecommerce;
USE ecommerce;

-- Customers table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- Orders table with foreign key
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

#### Many-to-Many Relationship
```sql
-- Products table
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2)
);

-- Order items (junction table)
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

### Advanced SELECT Queries

#### JOIN Operations
```sql
-- INNER JOIN
SELECT 
    c.name, 
    o.order_id, 
    o.order_date
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;

-- LEFT JOIN
SELECT 
    c.name, 
    o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- Multiple JOINs
SELECT 
    c.name,
    o.order_id,
    p.product_name,
    oi.quantity
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;
```

#### Aggregate Functions
```sql
-- Basic aggregates
SELECT 
    COUNT(*) as total_orders,
    AVG(total_amount) as avg_order_value,
    MAX(total_amount) as highest_order,
    MIN(total_amount) as lowest_order,
    SUM(total_amount) as total_revenue
FROM orders;

-- GROUP BY
SELECT 
    customer_id,
    COUNT(*) as order_count,
    SUM(total_amount) as total_spent
FROM orders
GROUP BY customer_id;

-- HAVING clause
SELECT 
    customer_id,
    COUNT(*) as order_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 2;
```

### Subqueries

#### Single-value Subqueries
```sql
-- Find customers who spent more than average
SELECT name, email
FROM customers
WHERE customer_id IN (
    SELECT customer_id 
    FROM orders 
    GROUP BY customer_id 
    HAVING SUM(total_amount) > (
        SELECT AVG(total_amount) FROM orders
    )
);
```

#### Correlated Subqueries
```sql
-- Find customers with their last order date
SELECT 
    c.name,
    c.email,
    (SELECT MAX(order_date) 
     FROM orders o 
     WHERE o.customer_id = c.customer_id) as last_order_date
FROM customers c;
```

### Data Modification Techniques

#### INSERT with SELECT
```sql
-- Copy data between tables
INSERT INTO archive_customers (name, email)
SELECT name, email 
FROM customers 
WHERE created_at < '2023-01-01';
```

#### UPDATE with JOIN
```sql
-- Update based on related table data
UPDATE orders o
JOIN customers c ON o.customer_id = c.customer_id
SET o.priority = 'HIGH'
WHERE c.name = 'VIP Customer';
```

### Views

```sql
-- Create a view
CREATE VIEW customer_order_summary AS
SELECT 
    c.customer_id,
    c.name,
    c.email,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    MAX(o.order_date) as last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.email;

-- Use the view
SELECT * FROM customer_order_summary 
WHERE total_orders > 0
ORDER BY total_spent DESC;
```

### Indexes for Performance

```sql
-- Create indexes
CREATE INDEX idx_customer_email ON customers(email);
CREATE INDEX idx_order_customer_date ON orders(customer_id, order_date);
CREATE INDEX idx_product_name ON products(product_name);

-- Show indexes
SHOW INDEX FROM customers;

-- Drop index
DROP INDEX idx_customer_email ON customers;
```

### Transactions

```sql
-- Basic transaction
START TRANSACTION;

INSERT INTO orders (customer_id, order_date, total_amount)
VALUES (1, '2024-01-15', 99.99);

INSERT INTO order_items (order_id, product_id, quantity)
VALUES (LAST_INSERT_ID(), 1, 2);

COMMIT;
-- or ROLLBACK; in case of error
```

### Stored Procedures

```sql
-- Create stored procedure
DELIMITER //

CREATE PROCEDURE GetCustomerOrders(IN customer_id INT)
BEGIN
    SELECT 
        o.order_id,
        o.order_date,
        o.total_amount,
        COUNT(oi.product_id) as product_count
    FROM orders o
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = customer_id
    GROUP BY o.order_id, o.order_date, o.total_amount;
END //

DELIMITER ;

-- Call stored procedure
CALL GetCustomerOrders(1);
```

### Practice Exercises

1. Design a blog database with users, posts, and comments
2. Create complex reports with multiple JOINs and aggregates
3. Implement transaction handling for financial operations
4. Create views for common reporting queries

---

# 3. MySQL Advanced Guide.md

# MySQL Advanced Guide

## 🚀 Mastering MySQL

### Advanced Data Types and Features

#### JSON Data Type
```sql
-- Create table with JSON column
CREATE TABLE products_advanced (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    specifications JSON,
    metadata JSON
);

-- Insert JSON data
INSERT INTO products_advanced (name, specifications, metadata)
VALUES (
    'Smartphone',
    '{"screen": "6.1 inch", "storage": "128GB", "camera": "12MP"}',
    '{"tags": ["electronics", "mobile"], "reviews": 45}'
);

-- Query JSON data
SELECT 
    name,
    specifications->>"$.screen" as screen_size,
    specifications->>"$.storage" as storage,
    JSON_EXTRACT(metadata, '$.tags[0]') as primary_tag
FROM products_advanced;

-- Update JSON data
UPDATE products_advanced
SET specifications = JSON_SET(
    specifications,
    '$.battery', '4000mAh',
    '$.storage', '256GB'
)
WHERE product_id = 1;
```

#### Full-Text Search
```sql
-- Create table with full-text index
CREATE TABLE articles (
    article_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200),
    content TEXT,
    FULLTEXT(title, content)
);

-- Perform full-text search
SELECT 
    article_id,
    title,
    MATCH(title, content) AGAINST('mysql database' IN NATURAL LANGUAGE MODE) as relevance
FROM articles
WHERE MATCH(title, content) AGAINST('mysql database' IN NATURAL LANGUAGE MODE)
ORDER BY relevance DESC;

-- Boolean mode search
SELECT * FROM articles
WHERE MATCH(title, content) AGAINST('+mysql -oracle' IN BOOLEAN MODE);
```

### Advanced Performance Optimization

#### Query Execution Plans
```sql
-- Analyze query performance
EXPLAIN FORMAT=JSON
SELECT 
    c.name,
    COUNT(o.order_id) as order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- Check index usage
EXPLAIN 
SELECT * FROM orders 
WHERE customer_id = 1 
AND order_date BETWEEN '2023-01-01' AND '2023-12-31';
```

#### Partitioning
```sql
-- Create partitioned table
CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT,
    sale_date DATE,
    amount DECIMAL(10,2),
    region VARCHAR(50),
    PRIMARY KEY (sale_id, sale_date)
)
PARTITION BY RANGE (YEAR(sale_date)) (
    PARTITION p2020 VALUES LESS THAN (2021),
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Query specific partition
SELECT * FROM sales PARTITION (p2023);
```

### Advanced Stored Programs

#### Complex Stored Procedures
```sql
DELIMITER //

CREATE PROCEDURE ProcessMonthlySales(IN report_month DATE, OUT total_revenue DECIMAL(15,2))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE current_amount DECIMAL(10,2);
    DECLARE sale_cursor CURSOR FOR 
        SELECT amount FROM sales 
        WHERE YEAR(sale_date) = YEAR(report_month) 
        AND MONTH(sale_date) = MONTH(report_month);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    SET total_revenue = 0;
    
    OPEN sale_cursor;
    
    read_loop: LOOP
        FETCH sale_cursor INTO current_amount;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET total_revenue = total_revenue + current_amount;
    END LOOP;
    
    CLOSE sale_cursor;
    
    -- Insert report
    INSERT INTO monthly_reports (report_month, total_revenue)
    VALUES (report_month, total_revenue);
    
END //

DELIMITER ;
```

#### Triggers
```sql
-- Audit trigger
CREATE TABLE customer_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    action VARCHAR(10),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_data JSON,
    new_data JSON
);

DELIMITER //

CREATE TRIGGER before_customer_update
    BEFORE UPDATE ON customers
    FOR EACH ROW
BEGIN
    INSERT INTO customer_audit (customer_id, action, old_data, new_data)
    VALUES (
        OLD.customer_id,
        'UPDATE',
        JSON_OBJECT('name', OLD.name, 'email', OLD.email),
        JSON_OBJECT('name', NEW.name, 'email', NEW.email)
    );
END //

DELIMITER ;
```

### Window Functions
```sql
-- Ranking and analytics
SELECT 
    customer_id,
    order_date,
    total_amount,
    -- Running total
    SUM(total_amount) OVER (
        PARTITION BY customer_id 
        ORDER BY order_date 
        ROWS UNBOUNDED PRECEDING
    ) as running_total,
    
    -- Rank orders by amount per customer
    RANK() OVER (
        PARTITION BY customer_id 
        ORDER BY total_amount DESC
    ) as order_rank,
    
    -- Moving average (3-month)
    AVG(total_amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as moving_avg
    
FROM orders
ORDER BY customer_id, order_date;
```

### Advanced Security

#### User Management and Privileges
```sql
-- Create user with specific privileges
CREATE USER 'report_user'@'localhost' IDENTIFIED BY 'secure_password';
GRANT SELECT ON ecommerce.* TO 'report_user'@'localhost';

-- Create role-based access
CREATE ROLE 'data_analyst';
GRANT SELECT, CREATE VIEW ON ecommerce.* TO 'data_analyst';

-- Assign role to user
GRANT 'data_analyst' TO 'analyst_user'@'localhost';
SET DEFAULT ROLE 'data_analyst' TO 'analyst_user'@'localhost';

-- Show privileges
SHOW GRANTS FOR 'report_user'@'localhost';
```

### Replication and High Availability

#### Basic Replication Setup
```sql
-- On master server
SHOW MASTER STATUS;

-- On slave server
CHANGE MASTER TO
MASTER_HOST='master_host',
MASTER_USER='replication_user',
MASTER_PASSWORD='replication_password',
MASTER_LOG_FILE='mysql-bin.000001',
MASTER_LOG_POS=107;

START SLAVE;
SHOW SLAVE STATUS\G
```

### Advanced Monitoring and Troubleshooting

#### Performance Schema Queries
```sql
-- Top queries by execution time
SELECT 
    DIGEST_TEXT as query,
    COUNT_STAR as executions,
    AVG_TIMER_WAIT/1000000000 as avg_time_sec
FROM performance_schema.events_statements_summary_by_digest
ORDER BY avg_time_sec DESC
LIMIT 10;

-- Table access statistics
SELECT 
    OBJECT_SCHEMA as database_name,
    OBJECT_NAME as table_name,
    COUNT_READ,
    COUNT_WRITE,
    COUNT_FETCH
FROM performance_schema.table_io_waits_summary_by_table
ORDER BY COUNT_READ + COUNT_WRITE DESC;
```

#### Deadlock Analysis
```sql
-- Enable deadlock logging
SET GLOBAL innodb_print_all_deadlocks = 1;

-- Check recent deadlocks
SHOW ENGINE INNODB STATUS;
```

### Best Practices for Large-scale Applications

#### Connection Pooling
```sql
-- Monitor connections
SHOW STATUS LIKE 'Threads_connected';
SHOW VARIABLES LIKE 'max_connections';

-- Optimize connection settings
SET GLOBAL max_connections = 500;
SET GLOBAL thread_cache_size = 32;
```

#### Backup Strategies
```bash
# Logical backup with mysqldump
mysqldump -u root -p --single-transaction --routines --triggers ecommerce > backup.sql

# Physical backup (requires downtime)
# Using MySQL Enterprise Backup or Percona XtraBackup
```

### Advanced Optimization Techniques

#### Query Rewriting Patterns
```sql
-- Instead of correlated subquery
-- Slow:
SELECT name, 
       (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.customer_id) as order_count
FROM customers c;

-- Fast:
SELECT c.name, COUNT(o.order_id) as order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;
```

### Practice Projects

1. Design and implement a social media database with advanced features
2. Create a data warehouse with partitioning and materialized views
3. Implement real-time analytics with window functions
4. Set up replication and failover strategies
5. Performance tune a high-traffic application

These three guides provide a comprehensive learning path from MySQL basics to advanced enterprise-level features. Practice each concept thoroughly before moving to the next level!
