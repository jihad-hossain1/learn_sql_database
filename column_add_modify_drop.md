# MySQL Table Alteration Guide: Modify, Add, Delete Columns

## 📋 ALTER TABLE Overview

| Operation | Syntax | Description |
|-----------|--------|-------------|
| Add Column | `ALTER TABLE ADD COLUMN` | Add new column to table |
| Modify Column | `ALTER TABLE MODIFY COLUMN` | Change column definition |
| Rename Column | `ALTER TABLE RENAME COLUMN` | Change column name (MySQL 8.0+) |
| Drop Column | `ALTER TABLE DROP COLUMN` | Remove column from table |
| Change Column | `ALTER TABLE CHANGE COLUMN` | Change name and definition |

## ➕ ADDING COLUMNS

### Basic Syntax
```sql
ALTER TABLE table_name 
ADD COLUMN column_name column_definition [AFTER existing_column];
```

### Practical Examples

#### Add Single Column
```sql
-- Add a simple column
ALTER TABLE employees ADD COLUMN middle_name VARCHAR(50);

-- Add column with constraints
ALTER TABLE employees ADD COLUMN birth_date DATE NOT NULL;

-- Add column with default value
ALTER TABLE employees ADD COLUMN status VARCHAR(20) DEFAULT 'active';

-- Add auto-increment column (usually added during table creation)
ALTER TABLE employees ADD COLUMN seq_id INT AUTO_INCREMENT PRIMARY KEY;
```

#### Add Multiple Columns
```sql
-- Add multiple columns in one statement
ALTER TABLE employees 
ADD COLUMN phone_number VARCHAR(15),
ADD COLUMN address TEXT,
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
```

#### Add Column with Position
```sql
-- Add column after specific column
ALTER TABLE employees ADD COLUMN department_id INT AFTER last_name;

-- Add column as first column
ALTER TABLE employees ADD COLUMN employee_code VARCHAR(10) FIRST;

-- Add column at specific position
ALTER TABLE employees ADD COLUMN emergency_contact VARCHAR(100) AFTER phone_number;
```

#### Add Column with Foreign Key
```sql
-- First add the column
ALTER TABLE employees ADD COLUMN dept_id INT;

-- Then add foreign key constraint
ALTER TABLE employees 
ADD CONSTRAINT fk_employees_department 
FOREIGN KEY (dept_id) REFERENCES departments(dept_id);
```

## ✏️ MODIFYING COLUMNS

### Basic Syntax
```sql
ALTER TABLE table_name 
MODIFY COLUMN column_name new_definition;
```

### Practical Examples

#### Change Data Type
```sql
-- Change VARCHAR length
ALTER TABLE employees MODIFY COLUMN first_name VARCHAR(100);

-- Change data type (be careful with data loss)
ALTER TABLE employees MODIFY COLUMN employee_id BIGINT;

-- Change to allow NULL
ALTER TABLE employees MODIFY COLUMN middle_name VARCHAR(50) NULL;

-- Change to NOT NULL (ensure no NULL values exist first)
UPDATE employees SET phone_number = 'Unknown' WHERE phone_number IS NULL;
ALTER TABLE employees MODIFY COLUMN phone_number VARCHAR(15) NOT NULL;
```

#### Change Default Value
```sql
-- Add default value
ALTER TABLE employees MODIFY COLUMN status VARCHAR(20) DEFAULT 'active';

-- Change default value
ALTER TABLE employees MODIFY COLUMN status VARCHAR(20) DEFAULT 'pending';

-- Remove default value
ALTER TABLE employees MODIFY COLUMN status VARCHAR(20) DEFAULT NULL;
```

#### Change Column Position
```sql
-- Move column to different position
ALTER TABLE employees MODIFY COLUMN email VARCHAR(100) AFTER last_name;

-- Move column to first position
ALTER TABLE employees MODIFY COLUMN employee_code VARCHAR(10) FIRST;
```

#### Modify Multiple Columns
```sql
-- Modify multiple columns in one statement
ALTER TABLE employees 
MODIFY COLUMN first_name VARCHAR(100),
MODIFY COLUMN last_name VARCHAR(100),
MODIFY COLUMN salary DECIMAL(12,2);
```

## 🔄 RENAMING COLUMNS (MySQL 8.0+)

### Using RENAME COLUMN
```sql
-- Basic rename (MySQL 8.0+)
ALTER TABLE employees RENAME COLUMN old_name TO new_name;
```

### Using CHANGE COLUMN (All MySQL versions)
```sql
-- Rename and optionally modify definition
ALTER TABLE employees 
CHANGE COLUMN old_name new_name VARCHAR(50);

-- Rename with full definition
ALTER TABLE employees 
CHANGE COLUMN emp_name full_name VARCHAR(100) NOT NULL;
```

### Practical Examples
```sql
-- Simple rename
ALTER TABLE employees RENAME COLUMN emp_id TO employee_id;

-- Rename with CHANGE (can modify type too)
ALTER TABLE employees 
CHANGE COLUMN phone mob_phone VARCHAR(15);

-- Rename multiple columns (separate statements)
ALTER TABLE employees RENAME COLUMN fname TO first_name;
ALTER TABLE employees RENAME COLUMN lname TO last_name;
```

## 🗑️ DELETING COLUMNS

### Basic Syntax
```sql
ALTER TABLE table_name DROP COLUMN column_name;
```

### Practical Examples

#### Drop Single Column
```sql
-- Drop a column
ALTER TABLE employees DROP COLUMN middle_name;

-- Drop column with foreign key (drop constraint first)
ALTER TABLE employees DROP FOREIGN KEY fk_employees_department;
ALTER TABLE employees DROP COLUMN dept_id;
```

#### Drop Multiple Columns
```sql
-- Drop multiple columns in one statement
ALTER TABLE employees 
DROP COLUMN temporary_field,
DROP COLUMN old_status,
DROP COLUMN legacy_code;
```

## 🔧 CHANGE COLUMN vs MODIFY COLUMN

### CHANGE COLUMN (Renames and modifies)
```sql
-- Change name and definition
ALTER TABLE employees 
CHANGE COLUMN old_name new_name VARCHAR(100) NOT NULL;

-- Equivalent using MODIFY + RENAME (MySQL 8.0+)
ALTER TABLE employees 
MODIFY COLUMN old_name VARCHAR(100) NOT NULL;
ALTER TABLE employees 
RENAME COLUMN old_name TO new_name;
```

### MODIFY COLUMN (Only modifies definition)
```sql
-- Only change definition, keep same name
ALTER TABLE employees 
MODIFY COLUMN email VARCHAR(150) UNIQUE;
```

## 📊 Complete Practical Example

```sql
-- Create initial table
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(50),
    price DECIMAL(8,2)
);

-- Insert sample data
INSERT INTO products (product_name, price) VALUES 
('Laptop', 999.99),
('Mouse', 25.50);

-- 1. ADD COLUMNS
ALTER TABLE products 
ADD COLUMN category VARCHAR(50) AFTER product_name,
ADD COLUMN stock_quantity INT DEFAULT 0,
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- 2. MODIFY COLUMNS
ALTER TABLE products 
MODIFY COLUMN product_name VARCHAR(100) NOT NULL,
MODIFY COLUMN price DECIMAL(10,2);

-- 3. RENAME COLUMNS (MySQL 8.0+)
ALTER TABLE products RENAME COLUMN stock_quantity TO inventory_count;

-- 4. ADD MORE COLUMNS
ALTER TABLE products 
ADD COLUMN supplier_id INT,
ADD COLUMN is_active BOOLEAN DEFAULT TRUE;

-- 5. MODIFY WITH POSITION
ALTER TABLE products 
MODIFY COLUMN category VARCHAR(100) AFTER product_id;

-- 6. DROP COLUMNS
ALTER TABLE products 
DROP COLUMN is_active;

-- View final structure
DESCRIBE products;
SHOW CREATE TABLE products;
```

## ⚠️ Data Safety Considerations

### Backup Before Major Changes
```sql
-- Create backup table
CREATE TABLE products_backup AS SELECT * FROM products;

-- Or use mysqldump
-- mysqldump -u username -p database_name products > products_backup.sql
```

### Check Existing Data
```sql
-- Check for NULLs before setting NOT NULL
SELECT COUNT(*) FROM employees WHERE phone_number IS NULL;

-- Check data compatibility before changing type
SELECT MAX(LENGTH(product_name)) FROM products;

-- Check foreign key relationships
SELECT * FROM information_schema.KEY_COLUMN_USAGE 
WHERE TABLE_NAME = 'employees' AND COLUMN_NAME = 'dept_id';
```

## 🚨 Common Issues and Solutions

### Problem: Data Truncation
```sql
-- Error: Data truncated for column

-- Solution: Check max length first
SELECT MAX(LENGTH(column_name)) FROM table_name;
ALTER TABLE table_name MODIFY COLUMN column_name VARCHAR(adequate_length);
```

### Problem: Default Value Issues
```sql
-- Error: Invalid default value

-- Solution: Use compatible default values
ALTER TABLE table_name 
MODIFY COLUMN created_date DATE DEFAULT '2024-01-01';
```

### Problem: Foreign Key Constraints
```sql
-- Error: Cannot drop column needed in foreign key constraint

-- Solution: Drop constraint first
ALTER TABLE child_table DROP FOREIGN KEY constraint_name;
ALTER TABLE child_table DROP COLUMN column_name;
```

### Problem: Auto-increment Conflicts
```sql
-- Error: Multiple primary key defined

-- Solution: Remove existing primary key first
ALTER TABLE table_name DROP PRIMARY KEY;
ALTER TABLE table_name ADD COLUMN new_id INT AUTO_INCREMENT PRIMARY KEY FIRST;
```

## 🎯 Advanced Alter Operations

### Adding Generated Columns
```sql
-- Add virtual generated column
ALTER TABLE employees 
ADD COLUMN full_name VARCHAR(200) 
GENERATED ALWAYS AS (CONCAT(first_name, ' ', last_name)) VIRTUAL;

-- Add stored generated column
ALTER TABLE products 
ADD COLUMN total_value DECIMAL(10,2) 
GENERATED ALWAYS AS (price * inventory_count) STORED;
```

### Adding ENUM Columns
```sql
-- Add ENUM column
ALTER TABLE employees 
ADD COLUMN employment_type ENUM('full-time', 'part-time', 'contractor') 
DEFAULT 'full-time';
```

### Modifying ENUM Values
```sql
-- Add new value to ENUM
ALTER TABLE employees 
MODIFY COLUMN employment_type 
ENUM('full-time', 'part-time', 'contractor', 'intern') 
DEFAULT 'full-time';
```

## 🔍 Verification and Monitoring

### Check Table Structure
```sql
-- Basic table info
DESCRIBE employees;
DESC employees;  -- Short version

-- Detailed column information
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT,
    EXTRA
FROM information_schema.COLUMNS 
WHERE TABLE_NAME = 'employees'
ORDER BY ORDINAL_POSITION;

-- Show all ALTER TABLE operations
SHOW TABLE STATUS LIKE 'employees';
```

### Monitor Alter Operations
```sql
-- Check for ongoing operations (MySQL 5.6+)
SELECT * FROM information_schema.INNODB_TRX 
WHERE trx_query LIKE '%ALTER TABLE%';

-- For large tables, consider using online DDL
ALTER TABLE employees 
ALGORITHM=INPLACE, 
LOCK=NONE,
ADD COLUMN new_column VARCHAR(100);
```

## 💡 Best Practices

1. **Always backup** before structural changes
2. **Test changes** on development environment first
3. **Use descriptive column names** that follow naming conventions
4. **Consider data types carefully** to optimize storage and performance
5. **Add indexes** after adding columns that will be queried frequently
6. **Use transactions** when possible for multiple changes
7. **Schedule structural changes** during maintenance windows for production
8. **Document changes** for team reference

## 🎯 Quick Reference Cheat Sheet

```sql
-- ADD
ALTER TABLE t ADD COLUMN new_col INT;
ALTER TABLE t ADD COLUMN col2 VARCHAR(50) AFTER col1;
ALTER TABLE t ADD COLUMN (col3 DATE, col4 DECIMAL(10,2));

-- MODIFY
ALTER TABLE t MODIFY COLUMN col1 VARCHAR(100);
ALTER TABLE t MODIFY COLUMN col2 INT NOT NULL DEFAULT 0;

-- RENAME (MySQL 8.0+)
ALTER TABLE t RENAME COLUMN old_name TO new_name;

-- RENAME (All versions)
ALTER TABLE t CHANGE COLUMN old_name new_name INT;

-- DROP
ALTER TABLE t DROP COLUMN col1;
ALTER TABLE t DROP COLUMN col2, DROP COLUMN col3;

-- VERIFY
DESCRIBE t;
SHOW CREATE TABLE t;
```

This comprehensive guide covers all aspects of modifying table structure in MySQL with practical examples and best practices!
