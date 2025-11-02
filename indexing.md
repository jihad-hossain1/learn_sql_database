# MySQL Index Management Guide

## 📋 Index Operations Overview

| Operation | Syntax | Use Case |
|-----------|--------|----------|
| Create Index | `CREATE INDEX` or `ALTER TABLE ADD INDEX` | Add new index |
| Rename Index | `ALTER TABLE RENAME INDEX` | Change index name |
| Drop Index | `DROP INDEX` or `ALTER TABLE DROP INDEX` | Remove index |

## 🆕 Creating Indexes

### Method 1: During Table Creation

```sql
CREATE TABLE employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    department_id INT,
    salary DECIMAL(10,2),
    hire_date DATE,
    
    -- Single column index
    INDEX idx_last_name (last_name),
    
    -- Composite index (multiple columns)
    INDEX idx_department_salary (department_id, salary),
    
    -- Unique index
    UNIQUE INDEX idx_unique_email (email),
    
    -- Prefix index (first 10 characters)
    INDEX idx_first_name_prefix (first_name(10)),
    
    -- Foreign key (automatically creates index)
    FOREIGN KEY (department_id) REFERENCES departments(dept_id)
) ENGINE=InnoDB;
```

### Method 2: After Table Creation (ALTER TABLE)

```sql
-- Single column index
ALTER TABLE employees ADD INDEX idx_last_name (last_name);

-- Composite index
ALTER TABLE employees ADD INDEX idx_name_department (last_name, department_id);

-- Unique index
ALTER TABLE employees ADD UNIQUE INDEX idx_unique_email (email);

-- Full-text index (for text searching)
ALTER TABLE employees ADD FULLTEXT INDEX idx_fulltext_bio (bio);

-- Spatial index (for geometric data)
ALTER TABLE locations ADD SPATIAL INDEX idx_spatial_coords (coordinates);
```

### Method 3: Using CREATE INDEX Statement

```sql
-- Basic index
CREATE INDEX idx_last_name ON employees (last_name);

-- Composite index
CREATE INDEX idx_department_hire_date ON employees (department_id, hire_date);

-- Unique index
CREATE UNIQUE INDEX idx_unique_employee_code ON employees (employee_code);

-- Full-text index
CREATE FULLTEXT INDEX idx_fulltext_description ON products (description);

-- Descending order index (MySQL 8.0+)
CREATE INDEX idx_salary_desc ON employees (salary DESC);
```

## 🔧 Advanced Index Creation Examples

### Partial Index (Filtered Index)
```sql
-- Index only on active employees
CREATE INDEX idx_active_employees ON employees (department_id) 
WHERE status = 'active';

-- MySQL equivalent using generated columns (MySQL 8.0+)
ALTER TABLE employees ADD COLUMN is_active TINYINT GENERATED ALWAYS AS (IF(status='active',1,NULL));
CREATE INDEX idx_active_employees ON employees (department_id, is_active);
```

### Multi-Column Index with Different Sort Orders
```sql
-- Ascending on department, descending on salary
CREATE INDEX idx_dept_asc_salary_desc ON employees (department_id ASC, salary DESC);
```

### Covering Index (Includes all queried columns)
```sql
-- Index that covers all SELECT columns
CREATE INDEX idx_covering_employee_report ON employees 
(department_id, hire_date, last_name, first_name, salary);
```

## ✏️ Renaming Indexes

### Using ALTER TABLE RENAME INDEX (MySQL 8.0+)

```sql
-- Rename an existing index
ALTER TABLE employees RENAME INDEX old_index_name TO new_index_name;
```

### Practical Examples:
```sql
-- Rename single index
ALTER TABLE employees RENAME INDEX idx_lname TO idx_last_name;

-- Rename multiple indexes in separate statements
ALTER TABLE employees RENAME INDEX idx_dept TO idx_department_id;
ALTER TABLE employees RENAME INDEX idx_sal TO idx_salary;

-- Verify the rename
SHOW INDEX FROM employees;
```

### Workaround for Older MySQL Versions (< 8.0)
```sql
-- Step 1: Drop the old index
DROP INDEX old_index_name ON employees;

-- Step 2: Create new index with desired name
CREATE INDEX new_index_name ON employees (column_name);
```

## 🗑️ Dropping Indexes

### Method 1: Using DROP INDEX Statement

```sql
-- Drop regular index
DROP INDEX idx_last_name ON employees;

-- Drop unique index
DROP INDEX idx_unique_email ON employees;

-- Drop primary key (special case)
ALTER TABLE employees DROP PRIMARY KEY;
```

### Method 2: Using ALTER TABLE DROP INDEX

```sql
-- Drop regular index
ALTER TABLE employees DROP INDEX idx_last_name;

-- Drop unique index
ALTER TABLE employees DROP INDEX idx_unique_email;
```

## 🔍 Index Management and Verification

### View Existing Indexes
```sql
-- Show all indexes for a table
SHOW INDEX FROM employees;

-- More detailed information
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    SEQ_IN_INDEX,
    INDEX_TYPE,
    NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_NAME = 'employees'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;

-- Show create table (includes index definitions)
SHOW CREATE TABLE employees;
```

### Check Index Usage
```sql
-- Check if index is being used
EXPLAIN SELECT * FROM employees WHERE last_name = 'Smith';

-- Check index usage statistics (MySQL 8.0+)
SELECT * FROM sys.schema_index_statistics 
WHERE table_name = 'employees';
```

## 📊 Complete Practical Example

```sql
-- Create table with initial indexes
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category_id INT,
    price DECIMAL(10,2),
    stock_quantity INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_category (category_id),
    INDEX idx_price (price)
);

-- Insert sample data
INSERT INTO products (product_name, category_id, price, stock_quantity) VALUES
('Laptop', 1, 999.99, 50),
('Mouse', 1, 25.50, 100),
('Desk', 2, 299.99, 20);

-- Add additional indexes after table creation
ALTER TABLE products 
ADD INDEX idx_name_category (product_name, category_id),
ADD INDEX idx_stock_price (stock_quantity, price);

-- Create a unique index
ALTER TABLE products 
ADD UNIQUE INDEX idx_unique_product_name (product_name);

-- Rename indexes (MySQL 8.0+)
ALTER TABLE products RENAME INDEX idx_category TO idx_category_id;
ALTER TABLE products RENAME INDEX idx_price TO idx_product_price;

-- Verify all indexes
SHOW INDEX FROM products;

-- Drop unnecessary indexes
DROP INDEX idx_stock_price ON products;

-- Final index structure
SHOW CREATE TABLE products;
```

## 🎯 Performance Considerations

### When to Create Indexes:
```sql
-- Columns frequently used in WHERE clauses
CREATE INDEX idx_status ON orders (status);

-- Columns used in JOIN conditions
CREATE INDEX idx_customer_id ON orders (customer_id);

-- Columns used in ORDER BY
CREATE INDEX idx_hire_date ON employees (hire_date);

-- Columns used in GROUP BY
CREATE INDEX idx_department_id ON employees (department_id);
```

### When to Avoid Indexes:
```sql
-- Tables with frequent write operations and few reads
-- Columns with low cardinality (few unique values)
-- Very small tables
-- Columns rarely used in queries
```

## ⚠️ Common Issues and Solutions

### Problem: Duplicate Index Name
```sql
-- Error: Duplicate key name 'idx_name'

-- Solution: Use unique index names or drop existing first
DROP INDEX IF EXISTS idx_name ON table_name;
CREATE INDEX idx_name ON table_name (column_name);
```

### Problem: Index Too Large
```sql
-- Solution: Use prefix indexes for long strings
CREATE INDEX idx_product_name ON products (product_name(50));
```

### Problem: Index Not Used
```sql
-- Check why index isn't being used
EXPLAIN FORMAT=JSON 
SELECT * FROM employees WHERE first_name LIKE 'A%' AND last_name LIKE 'B%';

-- Consider creating composite index
CREATE INDEX idx_first_last_name ON employees (first_name, last_name);
```

## 🛠️ Utility Queries for Index Management

### Find Duplicate Indexes
```sql
SELECT 
    TABLE_NAME,
    GROUP_CONCAT(INDEX_NAME) as indexes,
    GROUP_CONCAT(COLUMN_NAME) as columns,
    COUNT(*) as index_count
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'your_database'
GROUP BY TABLE_NAME, COLUMN_NAME
HAVING COUNT(*) > 1;
```

### Find Unused Indexes
```sql
-- MySQL 8.0+
SELECT 
    OBJECT_SCHEMA,
    OBJECT_NAME,
    INDEX_NAME
FROM sys.schema_unused_indexes
WHERE OBJECT_NAME = 'employees';
```

### Index Size Information
```sql
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    ROUND(SUM(INDEX_LENGTH)/1024/1024, 2) as size_mb
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'your_database'
AND TABLE_NAME = 'employees'
GROUP BY TABLE_NAME, INDEX_NAME;
```

## 💡 Best Practices

1. **Use descriptive index names** (`idx_table_column_purpose`)
2. **Create composite indexes** for frequently queried column combinations
3. **Monitor index usage** and remove unused indexes
4. **Consider index order** in composite indexes (equality → range → sort)
5. **Use covering indexes** when possible
6. **Avoid over-indexing** - each index adds overhead for writes
7. **Regularly analyze and optimize** your index strategy

## 🎯 Quick Reference Cheat Sheet

```sql
-- CREATE
CREATE TABLE t (id INT, INDEX idx_id (id));
ALTER TABLE t ADD INDEX idx_name (name);
CREATE INDEX idx_email ON t (email);

-- RENAME (MySQL 8.0+)
ALTER TABLE t RENAME INDEX old_name TO new_name;

-- DROP
DROP INDEX idx_name ON t;
ALTER TABLE t DROP INDEX idx_name;

-- VERIFY
SHOW INDEX FROM t;
SHOW CREATE TABLE t;
EXPLAIN SELECT * FROM t WHERE id = 1;
```

This comprehensive guide covers all aspects of MySQL index management from creation to deletion with practical examples and best practices!
