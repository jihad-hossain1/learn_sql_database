# MySQL Unique Key Constraints: Single & Multiple Columns

## 📋 Unique Key Overview

| Type | Description | Syntax |
|------|-------------|--------|
| Single Column Unique | Ensures unique values in one column | `UNIQUE KEY (column)` |
| Composite Unique Key | Ensures unique combination of multiple columns | `UNIQUE KEY (col1, col2)` |

## 🆕 Creating Unique Keys During Table Creation

### Single Column Unique Keys

```sql
-- Method 1: Using UNIQUE keyword with column definition
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE,  -- Single column unique
    email VARCHAR(100) UNIQUE,    -- Another single column unique
    password VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Method 2: Using separate UNIQUE CONSTRAINT
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_code VARCHAR(20),
    product_name VARCHAR(100),
    sku VARCHAR(50),
    UNIQUE KEY uk_product_code (product_code),  -- Named unique constraint
    UNIQUE KEY uk_sku (sku)                     -- Another named unique constraint
);

-- Method 3: Combining both approaches
CREATE TABLE employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_code VARCHAR(10) UNIQUE,           -- Inline unique
    email VARCHAR(100),
    national_id VARCHAR(20),
    UNIQUE KEY uk_email (email),                -- Separate unique constraint
    UNIQUE KEY uk_national_id (national_id)     -- Named constraint
);
```

### Multiple Column (Composite) Unique Keys

```sql
-- Composite unique key - combination must be unique
CREATE TABLE course_registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    semester VARCHAR(10),
    registration_date DATE,
    UNIQUE KEY uk_student_course_semester (student_id, course_id, semester)
);

-- Multiple composite unique keys in one table
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    variant_id INT,
    quantity INT,
    UNIQUE KEY uk_order_product (order_id, product_id),      -- Same product can't be added twice to same order
    UNIQUE KEY uk_order_product_variant (order_id, product_id, variant_id)
);

-- Real-world example: User permissions
CREATE TABLE user_roles (
    user_role_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    role_id INT,
    department_id INT,
    assigned_date DATE,
    UNIQUE KEY uk_user_role (user_id, role_id),              -- User can't have same role twice
    UNIQUE KEY uk_user_department_role (user_id, department_id, role_id)  -- Unique combination
);
```

### Mixed Example: Single and Composite Unique Keys

```sql
CREATE TABLE library_books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(13) UNIQUE,                    -- Single column unique
    title VARCHAR(255),
    author VARCHAR(100),
    edition INT,
    publication_year YEAR,
    UNIQUE KEY uk_title_author_edition (title, author, edition)  -- Composite unique
);

-- This ensures:
-- 1. Each ISBN is unique
-- 2. Same book title+author+edition combination can't exist twice
```

## 🔧 Adding Unique Keys After Table Creation

### Adding Single Column Unique Keys

```sql
-- Basic syntax
ALTER TABLE table_name ADD UNIQUE KEY key_name (column_name);

-- Practical examples
ALTER TABLE customers ADD UNIQUE KEY uk_customer_email (email);
ALTER TABLE products ADD UNIQUE KEY uk_product_sku (sku);
ALTER TABLE employees ADD UNIQUE KEY uk_employee_code (employee_code);

-- Add unique constraint to existing column
ALTER TABLE users ADD UNIQUE KEY uk_username (username);

-- Add unique constraint with specific index type
ALTER TABLE products ADD UNIQUE INDEX uk_barcode (barcode) USING BTREE;
```

### Adding Multiple Column Unique Keys

```sql
-- Basic syntax for composite unique key
ALTER TABLE table_name ADD UNIQUE KEY key_name (col1, col2, col3);

-- Practical examples
ALTER TABLE course_registrations 
ADD UNIQUE KEY uk_student_course (student_id, course_id);

ALTER TABLE order_items 
ADD UNIQUE KEY uk_order_product_variant (order_id, product_id, variant_id);

ALTER TABLE employee_departments 
ADD UNIQUE KEY uk_emp_dept_role (employee_id, department_id, role_id);
```

### Adding Multiple Unique Constraints in One Statement

```sql
-- Add multiple unique keys at once
ALTER TABLE products 
ADD UNIQUE KEY uk_product_code (product_code),
ADD UNIQUE KEY uk_manufacturer_sku (manufacturer_id, sku),
ADD UNIQUE KEY uk_barcode (barcode);
```

## 🎯 Complete Practical Examples

### Example 1: E-commerce System
```sql
-- Create table first without unique constraints
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255),
    category_id INT,
    supplier_id INT,
    sku VARCHAR(50),
    upc_code VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert some data first
INSERT INTO products (product_name, category_id, supplier_id, sku, upc_code) VALUES
('Laptop Dell XPS', 1, 1, 'DLXPS13-001', '123456789012'),
('Laptop Dell XPS', 1, 1, 'DLXPS13-002', '123456789013');

-- Now add unique constraints
ALTER TABLE products 
ADD UNIQUE KEY uk_sku (sku),                           -- Each SKU must be unique
ADD UNIQUE KEY uk_upc_code (upc_code),                 -- Each UPC must be unique
ADD UNIQUE KEY uk_product_supplier (product_name, supplier_id);  -- Same product from same supplier can't exist twice

-- Test the constraints (this will fail)
INSERT INTO products (product_name, category_id, supplier_id, sku, upc_code) 
VALUES ('Laptop Dell XPS', 1, 1, 'DLXPS13-003', '123456789014');
-- Error: Duplicate entry 'Laptop Dell XPS-1' for key 'uk_product_supplier'
```

### Example 2: University System
```sql
-- Create students table
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    student_number VARCHAR(20) UNIQUE,  -- Each student has unique student number
    email VARCHAR(100) UNIQUE,          -- Each student has unique email
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE
);

-- Create courses table
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(10) UNIQUE,     -- Unique course code
    course_name VARCHAR(100),
    credits INT
);

-- Create enrollments table with composite unique key
CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    academic_year YEAR,
    semester ENUM('Fall', 'Spring', 'Summer'),
    enrollment_date DATE,
    UNIQUE KEY uk_student_course_year_semester (student_id, course_id, academic_year, semester),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- This ensures a student can't enroll in the same course in the same semester/year twice
```

### Example 3: Social Media Platform
```sql
CREATE TABLE friendships (
    friendship_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id1 INT,
    user_id2 INT,
    status ENUM('pending', 'accepted', 'blocked'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_friendship_pair (user_id1, user_id2),  -- Prevent duplicate friendships
    CHECK (user_id1 < user_id2)  -- Ensure consistent ordering
);

CREATE TABLE user_follows (
    follow_id INT AUTO_INCREMENT PRIMARY KEY,
    follower_id INT,
    following_id INT,
    followed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_follow_relationship (follower_id, following_id)  -- Can't follow same person twice
);
```

## 🔍 Managing Existing Unique Keys

### View Existing Unique Constraints
```sql
-- Show all indexes including unique keys
SHOW INDEX FROM table_name;

-- More detailed information
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    NON_UNIQUE,
    INDEX_TYPE
FROM information_schema.STATISTICS
WHERE TABLE_NAME = 'your_table'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;

-- Show only unique constraints
SELECT 
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'your_database'
AND TABLE_NAME = 'your_table'
AND CONSTRAINT_NAME != 'PRIMARY';
```

### Drop Unique Constraints
```sql
-- Drop unique constraint by index name
ALTER TABLE products DROP INDEX uk_sku;

-- Drop composite unique key
ALTER TABLE enrollments DROP INDEX uk_student_course_year_semester;

-- Check index name first if unsure
SHOW INDEX FROM products;
```

### Modify Unique Constraints
```sql
-- To modify a unique constraint, you need to drop and recreate it

-- Step 1: Drop existing unique constraint
ALTER TABLE products DROP INDEX uk_product_supplier;

-- Step 2: Add new unique constraint with modified columns
ALTER TABLE products 
ADD UNIQUE KEY uk_product_supplier_category (product_name, supplier_id, category_id);
```

## ⚠️ Important Considerations

### Handling NULL Values in Unique Constraints
```sql
-- MySQL allows multiple NULL values in unique columns
CREATE TABLE demo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    unique_col VARCHAR(50) UNIQUE,  -- Can have multiple NULLs
    col1 VARCHAR(50),
    col2 VARCHAR(50),
    UNIQUE KEY uk_composite (col1, col2)  -- (NULL, NULL) can appear multiple times
);

INSERT INTO demo (unique_col, col1, col2) VALUES 
(NULL, NULL, NULL),  -- Allowed
(NULL, NULL, NULL),  -- Allowed
('value1', 'A', 'B'),
('value2', 'A', 'B');  -- This would fail: Duplicate entry 'A-B'
```

### Data Validation Before Adding Constraints
```sql
-- Check for existing duplicates before adding unique constraint
SELECT sku, COUNT(*) 
FROM products 
GROUP BY sku 
HAVING COUNT(*) > 1;

SELECT product_name, supplier_id, COUNT(*)
FROM products
GROUP BY product_name, supplier_id
HAVING COUNT(*) > 1;

-- Clean duplicates if found
DELETE p1 FROM products p1
INNER JOIN products p2 
WHERE p1.product_id < p2.product_id 
AND p1.sku = p2.sku;
```

## 🚀 Performance Considerations

### Indexing Strategy
```sql
-- Unique keys automatically create indexes
-- Consider the order of columns in composite unique keys

-- Good: Most selective column first
UNIQUE KEY uk_category_product (category_id, product_id);

-- Also consider query patterns
-- If you often query by product_id alone, you might need separate index
CREATE INDEX idx_product_id ON products(product_id);
```

### Storage Impact
```sql
-- Check index sizes
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    ROUND(SUM(INDEX_LENGTH)/1024/1024, 2) as size_mb
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'your_database'
GROUP BY TABLE_NAME, INDEX_NAME;
```

## 💡 Best Practices

1. **Use descriptive names** for unique constraints (`uk_table_columns`)
2. **Validate data** before adding constraints to existing tables
3. **Consider business rules** carefully when defining composite unique keys
4. **Order columns** in composite keys by selectivity (most unique first)
5. **Document unique constraints** as they represent important business rules
6. **Handle duplicate data** scenarios in your application code
7. **Use meaningful natural keys** when appropriate (email, username, etc.)

## 🎯 Quick Reference Cheat Sheet

```sql
-- 🆕 DURING TABLE CREATION
CREATE TABLE t (
    id INT PRIMARY KEY,
    col1 VARCHAR(50) UNIQUE,                    -- Single column unique
    col2 VARCHAR(50),
    col3 VARCHAR(50),
    UNIQUE KEY uk_name (col2),                  -- Named single unique
    UNIQUE KEY uk_composite (col2, col3)        -- Composite unique
);

-- 🔧 AFTER TABLE CREATION
ALTER TABLE t ADD UNIQUE KEY uk_col1 (col1);                    -- Single column
ALTER TABLE t ADD UNIQUE KEY uk_col2_col3 (col2, col3);         -- Multiple columns
ALTER TABLE t ADD UNIQUE KEY uk1 (col1), ADD UNIQUE KEY uk2 (col2, col3);  -- Multiple

-- 🔍 VIEWING
SHOW INDEX FROM t;
SHOW CREATE TABLE t;

-- 🗑️ DELETING
ALTER TABLE t DROP INDEX uk_name;
```

This comprehensive guide covers all aspects of creating and managing single and multiple column unique constraints in MySQL!
