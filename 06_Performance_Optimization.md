# SQL Database Learning Guide - Part 6: Performance Optimization

## Table of Contents
1. [Understanding Database Performance](#understanding-database-performance)
2. [Indexing Strategies](#indexing-strategies)
3. [Query Optimization](#query-optimization)
4. [Database Design for Performance](#database-design-for-performance)
5. [Hardware and Configuration Tuning](#hardware-and-configuration-tuning)
6. [Monitoring and Profiling](#monitoring-and-profiling)
7. [Caching Strategies](#caching-strategies)
8. [Practice Exercises](#practice-exercises)

---

## Understanding Database Performance

### Key Performance Metrics
```sql
-- Query execution time
SELECT SQL_NO_CACHE COUNT(*) FROM large_table WHERE condition;

-- Rows examined vs rows returned
EXPLAIN SELECT * FROM employees WHERE department = 'IT';

-- I/O operations
SHOW STATUS LIKE 'Innodb_data_reads';
SHOW STATUS LIKE 'Innodb_data_writes';

-- Buffer pool efficiency
SHOW STATUS LIKE 'Innodb_buffer_pool_read_requests';
SHOW STATUS LIKE 'Innodb_buffer_pool_reads';

-- Calculate buffer pool hit ratio
SELECT 
    ROUND(
        (1 - (
            (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_buffer_pool_reads') /
            (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_buffer_pool_read_requests')
        )) * 100, 2
    ) AS buffer_pool_hit_ratio_percent;
```

### Performance Bottlenecks
```sql
-- Identify slow queries
SELECT 
    DIGEST_TEXT,
    COUNT_STAR as execution_count,
    ROUND(AVG_TIMER_WAIT/1000000000, 3) as avg_time_seconds,
    ROUND(SUM_TIMER_WAIT/1000000000, 3) as total_time_seconds,
    ROUND(AVG_ROWS_EXAMINED/AVG_ROWS_SENT, 2) as rows_examined_ratio
FROM performance_schema.events_statements_summary_by_digest
WHERE AVG_TIMER_WAIT > 1000000000  -- More than 1 second
ORDER BY SUM_TIMER_WAIT DESC
LIMIT 10;

-- Check for table scans
SELECT 
    OBJECT_SCHEMA,
    OBJECT_NAME,
    COUNT_READ,
    COUNT_FETCH,
    SUM_TIMER_FETCH
FROM performance_schema.table_io_waits_summary_by_table
WHERE OBJECT_SCHEMA NOT IN ('mysql', 'performance_schema', 'information_schema')
ORDER BY SUM_TIMER_FETCH DESC;
```

---

## Indexing Strategies

### Types of Indexes
```sql
-- Primary index (automatically created)
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    category_id INT,
    price DECIMAL(10,2),
    created_at TIMESTAMP
);

-- Single column index
CREATE INDEX idx_product_name ON products(name);
CREATE INDEX idx_product_price ON products(price);

-- Composite index (order matters!)
CREATE INDEX idx_category_price ON products(category_id, price);
CREATE INDEX idx_category_name ON products(category_id, name);

-- Unique index
CREATE UNIQUE INDEX idx_product_sku ON products(sku);

-- Partial index (MySQL 8.0+)
CREATE INDEX idx_expensive_products ON products(name) WHERE price > 1000;

-- Functional index (MySQL 8.0+)
CREATE INDEX idx_product_name_lower ON products((LOWER(name)));
```

### Index Design Principles
```sql
-- 1. Selectivity - High selectivity is better
SELECT 
    'email' as column_name,
    COUNT(DISTINCT email) / COUNT(*) as selectivity
FROM users
UNION ALL
SELECT 
    'gender',
    COUNT(DISTINCT gender) / COUNT(*)
FROM users;

-- 2. Cardinality - Check index effectiveness
SHOW INDEX FROM products;

-- 3. Composite index column order
-- Good: WHERE category_id = 1 AND price > 100
CREATE INDEX idx_category_price ON products(category_id, price);

-- Less effective for: WHERE price > 100 AND category_id = 1
-- Better: CREATE INDEX idx_price_category ON products(price, category_id);

-- 4. Covering indexes (include all needed columns)
CREATE INDEX idx_product_covering ON products(category_id, price, name, description);

-- Query can be satisfied entirely from index
SELECT name, description FROM products WHERE category_id = 1 AND price > 100;
```

### Index Maintenance
```sql
-- Monitor index usage
SELECT 
    OBJECT_SCHEMA,
    OBJECT_NAME,
    INDEX_NAME,
    COUNT_FETCH,
    COUNT_INSERT,
    COUNT_UPDATE,
    COUNT_DELETE
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE OBJECT_SCHEMA = 'your_database'
ORDER BY COUNT_FETCH DESC;

-- Find unused indexes
SELECT 
    t.TABLE_SCHEMA,
    t.TABLE_NAME,
    t.INDEX_NAME
FROM information_schema.statistics t
LEFT JOIN performance_schema.table_io_waits_summary_by_index_usage p
    ON t.TABLE_SCHEMA = p.OBJECT_SCHEMA
    AND t.TABLE_NAME = p.OBJECT_NAME
    AND t.INDEX_NAME = p.INDEX_NAME
WHERE t.TABLE_SCHEMA = 'your_database'
    AND p.INDEX_NAME IS NULL
    AND t.INDEX_NAME != 'PRIMARY';

-- Index fragmentation (InnoDB)
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    ROUND(DATA_LENGTH/1024/1024, 2) as data_mb,
    ROUND(INDEX_LENGTH/1024/1024, 2) as index_mb,
    ROUND(DATA_FREE/1024/1024, 2) as free_mb,
    ROUND(DATA_FREE/(DATA_LENGTH+INDEX_LENGTH)*100, 2) as fragmentation_percent
FROM information_schema.tables
WHERE TABLE_SCHEMA = 'your_database'
    AND DATA_FREE > 0
ORDER BY fragmentation_percent DESC;
```

### Index Optimization Examples
```sql
-- Example 1: Range queries
-- Inefficient
SELECT * FROM orders WHERE order_date BETWEEN '2023-01-01' AND '2023-12-31';

-- Create appropriate index
CREATE INDEX idx_order_date ON orders(order_date);

-- Example 2: Sorting optimization
-- Query that needs sorting
SELECT * FROM products WHERE category_id = 1 ORDER BY price DESC;

-- Optimized index (matches WHERE and ORDER BY)
CREATE INDEX idx_category_price_desc ON products(category_id, price DESC);

-- Example 3: GROUP BY optimization
SELECT category_id, COUNT(*) FROM products GROUP BY category_id;

-- Index helps with grouping
CREATE INDEX idx_category ON products(category_id);

-- Example 4: JOIN optimization
SELECT p.name, c.category_name
FROM products p
JOIN categories c ON p.category_id = c.category_id;

-- Ensure foreign key is indexed
CREATE INDEX idx_product_category ON products(category_id);
```

---

## Query Optimization

### Using EXPLAIN
```sql
-- Basic EXPLAIN
EXPLAIN SELECT * FROM employees WHERE department = 'IT';

-- Extended EXPLAIN
EXPLAIN EXTENDED SELECT * FROM employees WHERE department = 'IT';
SHOW WARNINGS;

-- EXPLAIN FORMAT=JSON (more detailed)
EXPLAIN FORMAT=JSON SELECT * FROM employees WHERE department = 'IT';

-- EXPLAIN ANALYZE (MySQL 8.0+)
EXPLAIN ANALYZE SELECT * FROM employees WHERE department = 'IT';
```

### Understanding EXPLAIN Output
```sql
-- Key columns in EXPLAIN output:
-- id: Query identifier
-- select_type: Type of SELECT (SIMPLE, SUBQUERY, etc.)
-- table: Table being accessed
-- type: Join type (const, eq_ref, ref, range, index, ALL)
-- possible_keys: Indexes that could be used
-- key: Index actually used
-- key_len: Length of index used
-- ref: Columns compared to index
-- rows: Estimated rows examined
-- Extra: Additional information

-- Example of different access types
EXPLAIN SELECT * FROM employees WHERE emp_id = 1;          -- type: const
EXPLAIN SELECT * FROM employees WHERE department = 'IT';   -- type: ref
EXPLAIN SELECT * FROM employees WHERE salary > 50000;     -- type: range
EXPLAIN SELECT * FROM employees;                          -- type: ALL (table scan)
```

### Query Optimization Techniques

#### 1. Avoid SELECT *
```sql
-- Inefficient
SELECT * FROM employees WHERE department = 'IT';

-- Efficient
SELECT emp_id, first_name, last_name, salary FROM employees WHERE department = 'IT';
```

#### 2. Use Appropriate WHERE Clauses
```sql
-- Inefficient (function on column prevents index usage)
SELECT * FROM employees WHERE YEAR(hire_date) = 2023;

-- Efficient (sargable query)
SELECT * FROM employees WHERE hire_date >= '2023-01-01' AND hire_date < '2024-01-01';

-- Inefficient (leading wildcard)
SELECT * FROM employees WHERE last_name LIKE '%son';

-- Efficient (no leading wildcard)
SELECT * FROM employees WHERE last_name LIKE 'John%';
```

#### 3. Optimize JOINs
```sql
-- Ensure JOIN conditions use indexes
SELECT e.first_name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id  -- Both columns should be indexed
WHERE e.salary > 50000;

-- Use appropriate JOIN types
-- INNER JOIN when you only need matching records
SELECT e.first_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

-- LEFT JOIN when you need all records from left table
SELECT e.first_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
```

#### 4. Optimize Subqueries
```sql
-- Inefficient correlated subquery
SELECT * FROM employees e1
WHERE salary > (
    SELECT AVG(salary) FROM employees e2 WHERE e2.dept_id = e1.dept_id
);

-- More efficient with window function
SELECT emp_id, first_name, last_name, salary, dept_avg
FROM (
    SELECT emp_id, first_name, last_name, salary,
           AVG(salary) OVER (PARTITION BY dept_id) as dept_avg
    FROM employees
) t
WHERE salary > dept_avg;

-- Use EXISTS instead of IN for better performance
-- Less efficient
SELECT * FROM employees
WHERE dept_id IN (SELECT dept_id FROM departments WHERE location = 'New York');

-- More efficient
SELECT * FROM employees e
WHERE EXISTS (
    SELECT 1 FROM departments d 
    WHERE d.dept_id = e.dept_id AND d.location = 'New York'
);
```

#### 5. Use LIMIT Effectively
```sql
-- Always use LIMIT for large result sets
SELECT * FROM employees ORDER BY hire_date DESC LIMIT 10;

-- For pagination, use OFFSET carefully (can be slow for large offsets)
SELECT * FROM employees ORDER BY emp_id LIMIT 20 OFFSET 1000;

-- Better pagination using cursor-based approach
SELECT * FROM employees WHERE emp_id > 1000 ORDER BY emp_id LIMIT 20;
```

### Advanced Query Optimization
```sql
-- 1. Query rewriting
-- Original query
SELECT DISTINCT e.dept_id
FROM employees e
WHERE e.salary > 50000;

-- Rewritten for better performance
SELECT dept_id
FROM employees
WHERE salary > 50000
GROUP BY dept_id;

-- 2. Denormalization for read performance
-- Instead of joining every time
SELECT e.first_name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

-- Store department name in employees table
ALTER TABLE employees ADD COLUMN dept_name VARCHAR(50);
UPDATE employees e 
JOIN departments d ON e.dept_id = d.dept_id 
SET e.dept_name = d.dept_name;

-- 3. Materialized views (simulated in MySQL)
CREATE TABLE mv_employee_summary AS
SELECT 
    dept_id,
    COUNT(*) as employee_count,
    AVG(salary) as avg_salary,
    MAX(salary) as max_salary
FROM employees
GROUP BY dept_id;

-- Refresh procedure
DELIMITER //
CREATE PROCEDURE RefreshEmployeeSummary()
BEGIN
    DELETE FROM mv_employee_summary;
    INSERT INTO mv_employee_summary
    SELECT dept_id, COUNT(*), AVG(salary), MAX(salary)
    FROM employees
    GROUP BY dept_id;
END //
DELIMITER ;
```

---

## Database Design for Performance

### Normalization vs Denormalization
```sql
-- Normalized design (3NF)
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Denormalized for reporting (faster reads)
CREATE TABLE order_summary (
    order_id INT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(101), -- first_name + last_name
    customer_email VARCHAR(100),
    order_date DATE,
    total_amount DECIMAL(12,2),
    item_count INT
);
```

### Partitioning
```sql
-- Range partitioning by date
CREATE TABLE sales (
    sale_id INT,
    sale_date DATE,
    amount DECIMAL(10,2),
    customer_id INT
)
PARTITION BY RANGE (YEAR(sale_date)) (
    PARTITION p2020 VALUES LESS THAN (2021),
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Hash partitioning for even distribution
CREATE TABLE user_sessions (
    session_id VARCHAR(64),
    user_id INT,
    created_at TIMESTAMP,
    data JSON
)
PARTITION BY HASH(user_id)
PARTITIONS 8;

-- List partitioning by region
CREATE TABLE regional_data (
    id INT,
    region VARCHAR(20),
    data TEXT
)
PARTITION BY LIST COLUMNS(region) (
    PARTITION p_north VALUES IN ('north', 'northeast', 'northwest'),
    PARTITION p_south VALUES IN ('south', 'southeast', 'southwest'),
    PARTITION p_east VALUES IN ('east'),
    PARTITION p_west VALUES IN ('west')
);
```

### Data Types Optimization
```sql
-- Use appropriate data types
CREATE TABLE optimized_table (
    -- Use smallest integer type that fits
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,  -- vs BIGINT
    status TINYINT UNSIGNED,                     -- vs INT for 0-255 values
    
    -- Use fixed-length for known sizes
    country_code CHAR(2),                        -- vs VARCHAR(2)
    
    -- Use appropriate string lengths
    email VARCHAR(100),                          -- vs VARCHAR(255)
    
    -- Use DECIMAL for exact precision
    price DECIMAL(10,2),                         -- vs FLOAT for money
    
    -- Use appropriate date/time types
    created_date DATE,                           -- vs DATETIME if time not needed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Use ENUM for limited options
    priority ENUM('low', 'medium', 'high'),      -- vs VARCHAR
    
    -- Use JSON for flexible data (MySQL 5.7+)
    metadata JSON
);
```

---

## Hardware and Configuration Tuning

### Memory Configuration
```sql
-- Check current memory settings
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
SHOW VARIABLES LIKE 'key_buffer_size';
SHOW VARIABLES LIKE 'query_cache_size';
SHOW VARIABLES LIKE 'tmp_table_size';
SHOW VARIABLES LIKE 'max_heap_table_size';

-- Recommended settings (adjust based on available RAM)
-- For a server with 8GB RAM:
SET GLOBAL innodb_buffer_pool_size = 5368709120;  -- 5GB (60-70% of RAM)
SET GLOBAL key_buffer_size = 268435456;           -- 256MB
SET GLOBAL query_cache_size = 134217728;          -- 128MB
SET GLOBAL tmp_table_size = 134217728;            -- 128MB
SET GLOBAL max_heap_table_size = 134217728;       -- 128MB
```

### InnoDB Optimization
```sql
-- InnoDB settings
SHOW VARIABLES LIKE 'innodb%';

-- Key InnoDB parameters
SET GLOBAL innodb_log_file_size = 268435456;      -- 256MB
SET GLOBAL innodb_log_buffer_size = 16777216;     -- 16MB
SET GLOBAL innodb_flush_log_at_trx_commit = 1;    -- ACID compliance
SET GLOBAL innodb_file_per_table = 1;             -- Separate files per table
SET GLOBAL innodb_buffer_pool_instances = 8;      -- Multiple buffer pools

-- Check InnoDB status
SHOW ENGINE INNODB STATUS;
```

### Connection and Thread Tuning
```sql
-- Connection settings
SHOW VARIABLES LIKE 'max_connections';
SHOW VARIABLES LIKE 'thread_cache_size';
SHOW VARIABLES LIKE 'table_open_cache';

-- Optimize based on usage
SET GLOBAL max_connections = 200;                 -- Adjust based on concurrent users
SET GLOBAL thread_cache_size = 16;                -- Cache threads for reuse
SET GLOBAL table_open_cache = 2000;               -- Cache open table handles

-- Monitor connection usage
SHOW STATUS LIKE 'Threads_connected';
SHOW STATUS LIKE 'Threads_created';
SHOW STATUS LIKE 'Threads_cached';
```

---

## Monitoring and Profiling

### Performance Schema Monitoring
```sql
-- Enable performance schema (in my.cnf)
-- performance_schema = ON

-- Monitor statement performance
SELECT 
    SCHEMA_NAME,
    DIGEST_TEXT,
    COUNT_STAR,
    ROUND(AVG_TIMER_WAIT/1000000000, 3) as avg_seconds,
    ROUND(MAX_TIMER_WAIT/1000000000, 3) as max_seconds,
    ROUND(SUM_TIMER_WAIT/1000000000, 3) as total_seconds
FROM performance_schema.events_statements_summary_by_digest
WHERE SCHEMA_NAME IS NOT NULL
ORDER BY SUM_TIMER_WAIT DESC
LIMIT 10;

-- Monitor table I/O
SELECT 
    OBJECT_SCHEMA,
    OBJECT_NAME,
    COUNT_READ,
    COUNT_WRITE,
    COUNT_FETCH,
    COUNT_INSERT,
    COUNT_UPDATE,
    COUNT_DELETE,
    ROUND(SUM_TIMER_WAIT/1000000000, 3) as total_seconds
FROM performance_schema.table_io_waits_summary_by_table
WHERE OBJECT_SCHEMA NOT IN ('mysql', 'performance_schema', 'information_schema')
ORDER BY SUM_TIMER_WAIT DESC;

-- Monitor file I/O
SELECT 
    FILE_NAME,
    EVENT_NAME,
    COUNT_READ,
    COUNT_WRITE,
    ROUND(SUM_TIMER_READ/1000000000, 3) as read_seconds,
    ROUND(SUM_TIMER_WRITE/1000000000, 3) as write_seconds
FROM performance_schema.file_summary_by_event_name
WHERE COUNT_READ > 0 OR COUNT_WRITE > 0
ORDER BY (SUM_TIMER_READ + SUM_TIMER_WRITE) DESC;
```

### Query Profiling
```sql
-- Enable profiling
SET profiling = 1;

-- Run queries to profile
SELECT * FROM employees WHERE department = 'IT';
SELECT COUNT(*) FROM orders WHERE order_date > '2023-01-01';

-- View profiles
SHOW PROFILES;

-- Detailed profile for specific query
SHOW PROFILE FOR QUERY 1;
SHOW PROFILE CPU, BLOCK IO FOR QUERY 1;

-- Disable profiling
SET profiling = 0;
```

### Custom Monitoring Queries
```sql
-- Database size monitoring
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)',
    ROUND(SUM(data_free) / 1024 / 1024, 2) AS 'Free (MB)'
FROM information_schema.tables
GROUP BY table_schema
ORDER BY SUM(data_length + index_length) DESC;

-- Index efficiency
SELECT 
    t.TABLE_SCHEMA,
    t.TABLE_NAME,
    t.INDEX_NAME,
    t.CARDINALITY,
    ROUND(t.CARDINALITY / tr.TABLE_ROWS * 100, 2) as selectivity_percent
FROM information_schema.statistics t
JOIN information_schema.tables tr ON t.TABLE_SCHEMA = tr.TABLE_SCHEMA 
    AND t.TABLE_NAME = tr.TABLE_NAME
WHERE t.TABLE_SCHEMA NOT IN ('mysql', 'performance_schema', 'information_schema')
    AND tr.TABLE_ROWS > 0
ORDER BY selectivity_percent DESC;

-- Lock monitoring
SELECT 
    r.trx_id waiting_trx_id,
    r.trx_mysql_thread_id waiting_thread,
    r.trx_query waiting_query,
    b.trx_id blocking_trx_id,
    b.trx_mysql_thread_id blocking_thread,
    b.trx_query blocking_query
FROM information_schema.innodb_lock_waits w
INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id
INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id;
```

---

## Caching Strategies

### Query Cache (Deprecated in MySQL 8.0)
```sql
-- Query cache settings (MySQL 5.7 and earlier)
SHOW VARIABLES LIKE 'query_cache%';

-- Enable query cache
SET GLOBAL query_cache_type = ON;
SET GLOBAL query_cache_size = 134217728;  -- 128MB

-- Monitor query cache
SHOW STATUS LIKE 'Qcache%';

-- Calculate query cache hit ratio
SELECT 
    ROUND(
        (Qcache_hits / (Qcache_hits + Qcache_inserts)) * 100, 2
    ) as cache_hit_ratio
FROM (
    SELECT 
        VARIABLE_VALUE as Qcache_hits
    FROM performance_schema.global_status 
    WHERE VARIABLE_NAME = 'Qcache_hits'
) hits,
(
    SELECT 
        VARIABLE_VALUE as Qcache_inserts
    FROM performance_schema.global_status 
    WHERE VARIABLE_NAME = 'Qcache_inserts'
) inserts;
```

### Application-Level Caching
```sql
-- Create cache table
CREATE TABLE query_cache (
    cache_key VARCHAR(255) PRIMARY KEY,
    cache_value JSON,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Cache management procedures
DELIMITER //

CREATE PROCEDURE SetCache(
    IN p_key VARCHAR(255),
    IN p_value JSON,
    IN p_ttl INT  -- Time to live in seconds
)
BEGIN
    INSERT INTO query_cache (cache_key, cache_value, expires_at)
    VALUES (p_key, p_value, DATE_ADD(NOW(), INTERVAL p_ttl SECOND))
    ON DUPLICATE KEY UPDATE
        cache_value = p_value,
        expires_at = DATE_ADD(NOW(), INTERVAL p_ttl SECOND);
END //

CREATE FUNCTION GetCache(p_key VARCHAR(255))
RETURNS JSON
READS SQL DATA
BEGIN
    DECLARE result JSON DEFAULT NULL;
    
    SELECT cache_value INTO result
    FROM query_cache
    WHERE cache_key = p_key
        AND expires_at > NOW();
    
    RETURN result;
END //

CREATE PROCEDURE CleanExpiredCache()
BEGIN
    DELETE FROM query_cache WHERE expires_at <= NOW();
END //

DELIMITER ;

-- Usage example
CALL SetCache('user_stats_123', '{"total_orders": 45, "total_spent": 1250.50}', 3600);
SELECT GetCache('user_stats_123') as cached_data;
```

### Redis Integration (Conceptual)
```sql
-- While MySQL doesn't have built-in Redis support,
-- you can use UDFs or application logic

-- Example of cache-aside pattern in application:
-- 1. Check cache first
-- 2. If miss, query database
-- 3. Store result in cache
-- 4. Return result

-- Pseudo-code for expensive query caching:
/*
function getEmployeeStats(deptId) {
    cacheKey = `dept_stats_${deptId}`
    
    // Try cache first
    result = redis.get(cacheKey)
    if (result) {
        return JSON.parse(result)
    }
    
    // Cache miss - query database
    result = db.query(`
        SELECT 
            department,
            COUNT(*) as employee_count,
            AVG(salary) as avg_salary
        FROM employees 
        WHERE dept_id = ?
    `, [deptId])
    
    // Store in cache for 1 hour
    redis.setex(cacheKey, 3600, JSON.stringify(result))
    
    return result
}
*/
```

---

## Practice Exercises

### Exercise 1: Index Optimization
```sql
-- Create test table with sample data
CREATE TABLE performance_test (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    category VARCHAR(50),
    status ENUM('active', 'inactive', 'pending'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2),
    description TEXT
);

-- Insert sample data (you can use a procedure to generate more)
INSERT INTO performance_test (user_id, category, status, amount, description)
SELECT 
    FLOOR(RAND() * 10000) + 1,
    CASE FLOOR(RAND() * 5)
        WHEN 0 THEN 'electronics'
        WHEN 1 THEN 'clothing'
        WHEN 2 THEN 'books'
        WHEN 3 THEN 'home'
        ELSE 'sports'
    END,
    CASE FLOOR(RAND() * 3)
        WHEN 0 THEN 'active'
        WHEN 1 THEN 'inactive'
        ELSE 'pending'
    END,
    RAND() * 1000,
    CONCAT('Description ', FLOOR(RAND() * 1000))
FROM 
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) t1,
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) t2,
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) t3,
    (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) t4;

-- Test queries and optimize
-- 1. Find records by user_id
EXPLAIN SELECT * FROM performance_test WHERE user_id = 1234;
-- Create index: CREATE INDEX idx_user_id ON performance_test(user_id);

-- 2. Find records by category and status
EXPLAIN SELECT * FROM performance_test WHERE category = 'electronics' AND status = 'active';
-- Create index: CREATE INDEX idx_category_status ON performance_test(category, status);

-- 3. Find records in date range
EXPLAIN SELECT * FROM performance_test WHERE created_at BETWEEN '2023-01-01' AND '2023-12-31';
-- Create index: CREATE INDEX idx_created_at ON performance_test(created_at);

-- 4. Complex query optimization
EXPLAIN SELECT category, status, COUNT(*), AVG(amount)
FROM performance_test
WHERE created_at > '2023-06-01'
GROUP BY category, status
ORDER BY COUNT(*) DESC;
-- Optimal index: CREATE INDEX idx_date_category_status ON performance_test(created_at, category, status);
```

### Exercise 2: Query Optimization
```sql
-- Optimize these queries

-- 1. Inefficient query with function in WHERE
SELECT * FROM performance_test WHERE YEAR(created_at) = 2023;
-- Optimized version:
SELECT * FROM performance_test 
WHERE created_at >= '2023-01-01' AND created_at < '2024-01-01';

-- 2. Inefficient subquery
SELECT * FROM performance_test p1
WHERE amount > (
    SELECT AVG(amount) FROM performance_test p2 WHERE p2.category = p1.category
);
-- Optimized with window function:
SELECT id, user_id, category, amount, avg_amount
FROM (
    SELECT *,
           AVG(amount) OVER (PARTITION BY category) as avg_amount
    FROM performance_test
) t
WHERE amount > avg_amount;

-- 3. Inefficient pagination
SELECT * FROM performance_test ORDER BY id LIMIT 10000, 20;
-- Better cursor-based pagination:
SELECT * FROM performance_test WHERE id > 10000 ORDER BY id LIMIT 20;
```

### Exercise 3: Performance Monitoring
```sql
-- Create monitoring dashboard
CREATE VIEW performance_dashboard AS
SELECT 
    'Buffer Pool Hit Ratio' as metric,
    CONCAT(
        ROUND(
            (1 - (
                (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_buffer_pool_reads') /
                (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_buffer_pool_read_requests')
            )) * 100, 2
        ), '%'
    ) as value
UNION ALL
SELECT 
    'Current Connections',
    VARIABLE_VALUE
FROM performance_schema.global_status 
WHERE VARIABLE_NAME = 'Threads_connected'
UNION ALL
SELECT 
    'Slow Queries',
    VARIABLE_VALUE
FROM performance_schema.global_status 
WHERE VARIABLE_NAME = 'Slow_queries'
UNION ALL
SELECT 
    'Questions per Second',
    ROUND(
        (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Questions') /
        (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Uptime'), 2
    );

-- Use the dashboard
SELECT * FROM performance_dashboard;
```

---

## Performance Optimization Checklist

### Database Design
- [ ] Use appropriate data types
- [ ] Normalize to 3NF, denormalize where needed for performance
- [ ] Consider partitioning for large tables
- [ ] Design efficient primary keys

### Indexing
- [ ] Create indexes on frequently queried columns
- [ ] Use composite indexes for multi-column queries
- [ ] Monitor and remove unused indexes
- [ ] Consider covering indexes for read-heavy queries

### Query Optimization
- [ ] Use EXPLAIN to analyze query execution plans
- [ ] Avoid SELECT * in production queries
- [ ] Use appropriate WHERE clauses (sargable queries)
- [ ] Optimize JOINs and subqueries
- [ ] Use LIMIT for large result sets

### Configuration
- [ ] Optimize memory settings (buffer pool, caches)
- [ ] Configure appropriate connection limits
- [ ] Tune InnoDB settings
- [ ] Enable slow query logging

### Monitoring
- [ ] Set up performance monitoring
- [ ] Monitor key metrics regularly
- [ ] Identify and optimize slow queries
- [ ] Track index usage and efficiency

---

## Next Steps
Continue with [Part 7: Practice Projects](07_Practice_Projects.md) to apply your SQL knowledge in real-world scenarios and comprehensive projects.