# SQL Database Learning Guide - Part 5: Database Administration

## Table of Contents
1. [User Management](#user-management)
2. [Backup and Restore](#backup-and-restore)
3. [Transactions](#transactions)
4. [Database Maintenance](#database-maintenance)
5. [Security](#security)
6. [Monitoring and Logging](#monitoring-and-logging)
7. [Configuration Management](#configuration-management)
8. [Practice Exercises](#practice-exercises)

---

## User Management

### Creating Users
```sql
-- Create a new user
CREATE USER 'newuser'@'localhost' IDENTIFIED BY 'secure_password123';
CREATE USER 'appuser'@'%' IDENTIFIED BY 'app_password456';
CREATE USER 'readonly'@'192.168.1.%' IDENTIFIED BY 'readonly_pass';

-- Create user with password expiration
CREATE USER 'tempuser'@'localhost' 
IDENTIFIED BY 'temp_password' 
PASSWORD EXPIRE INTERVAL 30 DAY;

-- Create user with account lock
CREATE USER 'lockeduser'@'localhost' 
IDENTIFIED BY 'password' 
ACCOUNT LOCK;
```

### Granting Privileges
```sql
-- Grant specific privileges on specific database
GRANT SELECT, INSERT, UPDATE ON company.employees TO 'appuser'@'%';
GRANT SELECT ON company.* TO 'readonly'@'192.168.1.%';

-- Grant all privileges on a database
GRANT ALL PRIVILEGES ON company.* TO 'admin'@'localhost';

-- Grant global privileges
GRANT CREATE, DROP ON *.* TO 'dbadmin'@'localhost';

-- Grant with grant option (allows user to grant privileges to others)
GRANT SELECT, INSERT ON company.employees TO 'manager'@'localhost' WITH GRANT OPTION;

-- Grant execute privilege for stored procedures
GRANT EXECUTE ON company.* TO 'appuser'@'%';
GRANT EXECUTE ON PROCEDURE company.GetEmployeesByDepartment TO 'reportuser'@'%';
```

### Managing Privileges
```sql
-- View user privileges
SHOW GRANTS FOR 'appuser'@'%';
SHOW GRANTS FOR CURRENT_USER();

-- Revoke privileges
REVOKE INSERT, UPDATE ON company.employees FROM 'appuser'@'%';
REVOKE ALL PRIVILEGES ON company.* FROM 'tempuser'@'localhost';

-- Flush privileges (reload privilege tables)
FLUSH PRIVILEGES;
```

### User Account Management
```sql
-- Change user password
ALTER USER 'appuser'@'%' IDENTIFIED BY 'new_secure_password';

-- Lock/unlock user account
ALTER USER 'tempuser'@'localhost' ACCOUNT LOCK;
ALTER USER 'tempuser'@'localhost' ACCOUNT UNLOCK;

-- Set password expiration
ALTER USER 'appuser'@'%' PASSWORD EXPIRE;
ALTER USER 'appuser'@'%' PASSWORD EXPIRE INTERVAL 90 DAY;
ALTER USER 'appuser'@'%' PASSWORD EXPIRE NEVER;

-- Rename user
RENAME USER 'oldname'@'localhost' TO 'newname'@'localhost';

-- Drop user
DROP USER 'tempuser'@'localhost';
DROP USER IF EXISTS 'maynotexist'@'localhost';
```

### Role-Based Access Control
```sql
-- Create roles (MySQL 8.0+)
CREATE ROLE 'app_read', 'app_write', 'app_admin';

-- Grant privileges to roles
GRANT SELECT ON company.* TO 'app_read';
GRANT INSERT, UPDATE, DELETE ON company.* TO 'app_write';
GRANT ALL PRIVILEGES ON company.* TO 'app_admin';

-- Assign roles to users
GRANT 'app_read' TO 'readonly_user'@'localhost';
GRANT 'app_read', 'app_write' TO 'regular_user'@'localhost';
GRANT 'app_admin' TO 'admin_user'@'localhost';

-- Set default roles
SET DEFAULT ROLE 'app_read' TO 'readonly_user'@'localhost';

-- Activate roles for current session
SET ROLE 'app_write';
SET ROLE ALL;

-- Drop roles
DROP ROLE 'app_read';
```

---

## Backup and Restore

### MySQL Backup Methods

#### Using mysqldump
```bash
# Backup entire database
mysqldump -u username -p database_name > backup.sql

# Backup with compression
mysqldump -u username -p database_name | gzip > backup.sql.gz

# Backup specific tables
mysqldump -u username -p database_name table1 table2 > tables_backup.sql

# Backup all databases
mysqldump -u username -p --all-databases > all_databases.sql

# Backup with additional options
mysqldump -u username -p \
  --single-transaction \
  --routines \
  --triggers \
  --events \
  database_name > complete_backup.sql

# Backup structure only (no data)
mysqldump -u username -p --no-data database_name > structure_only.sql

# Backup data only (no structure)
mysqldump -u username -p --no-create-info database_name > data_only.sql
```

#### Using MySQL Enterprise Backup (Commercial)
```bash
# Full backup
mysqlbackup --user=username --password --backup-dir=/backup/full backup

# Incremental backup
mysqlbackup --user=username --password --backup-dir=/backup/inc1 \
  --incremental --incremental-base=dir:/backup/full backup
```

### Restore Operations
```bash
# Restore database
mysql -u username -p database_name < backup.sql

# Restore compressed backup
gunzip < backup.sql.gz | mysql -u username -p database_name

# Restore all databases
mysql -u username -p < all_databases.sql

# Restore with progress monitoring
pv backup.sql | mysql -u username -p database_name
```

### Point-in-Time Recovery
```bash
# Enable binary logging (in my.cnf)
# log-bin=mysql-bin
# server-id=1

# Show binary logs
mysql> SHOW BINARY LOGS;

# Backup binary logs
mysqlbinlog mysql-bin.000001 > binlog_backup.sql

# Point-in-time recovery process:
# 1. Restore from last full backup
mysql -u username -p database_name < last_full_backup.sql

# 2. Apply binary logs up to specific time
mysqlbinlog --stop-datetime="2023-12-01 10:30:00" \
  mysql-bin.000001 mysql-bin.000002 | mysql -u username -p database_name
```

### Automated Backup Scripts
```bash
#!/bin/bash
# backup_script.sh

DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/backups"
DB_NAME="company"
DB_USER="backup_user"
DB_PASS="backup_password"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Perform backup
mysqldump -u $DB_USER -p$DB_PASS \
  --single-transaction \
  --routines \
  --triggers \
  $DB_NAME | gzip > $BACKUP_DIR/${DB_NAME}_${DATE}.sql.gz

# Remove backups older than 7 days
find $BACKUP_DIR -name "${DB_NAME}_*.sql.gz" -mtime +7 -delete

# Log backup completion
echo "$(date): Backup completed for $DB_NAME" >> /var/log/mysql_backup.log
```

---

## Transactions

### Basic Transaction Control
```sql
-- Start transaction
START TRANSACTION;
-- or
BEGIN;

-- Perform operations
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;

-- Commit changes
COMMIT;

-- Or rollback if something goes wrong
ROLLBACK;
```

### Transaction with Error Handling
```sql
DELIMITER //

CREATE PROCEDURE TransferMoney(
    IN from_account INT,
    IN to_account INT,
    IN amount DECIMAL(10,2)
)
BEGIN
    DECLARE from_balance DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Check sufficient balance
    SELECT balance INTO from_balance
    FROM accounts
    WHERE account_id = from_account
    FOR UPDATE;
    
    IF from_balance < amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds';
    END IF;
    
    -- Perform transfer
    UPDATE accounts SET balance = balance - amount WHERE account_id = from_account;
    UPDATE accounts SET balance = balance + amount WHERE account_id = to_account;
    
    COMMIT;
    
    SELECT 'Transfer completed successfully' as result;
END //

DELIMITER ;
```

### Transaction Isolation Levels
```sql
-- View current isolation level
SELECT @@transaction_isolation;

-- Set isolation level for current session
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Set isolation level for next transaction only
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
-- ... transaction operations ...
COMMIT;

-- Set global isolation level
SET GLOBAL TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

### Locking
```sql
-- Table-level locks
LOCK TABLES employees READ;
-- ... read operations ...
UNLOCK TABLES;

LOCK TABLES employees WRITE;
-- ... write operations ...
UNLOCK TABLES;

-- Row-level locks (within transactions)
START TRANSACTION;
SELECT * FROM employees WHERE emp_id = 1 FOR UPDATE;
-- This row is now locked for updates
UPDATE employees SET salary = 85000 WHERE emp_id = 1;
COMMIT;

-- Shared locks
START TRANSACTION;
SELECT * FROM employees WHERE emp_id = 1 LOCK IN SHARE MODE;
-- Other transactions can read but not modify
COMMIT;
```

### Deadlock Handling
```sql
-- Example of potential deadlock scenario
-- Session 1:
START TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
-- ... delay ...
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;

-- Session 2 (simultaneously):
START TRANSACTION;
UPDATE accounts SET balance = balance - 50 WHERE account_id = 2;
-- ... delay ...
UPDATE accounts SET balance = balance + 50 WHERE account_id = 1;
COMMIT;

-- MySQL will detect deadlock and rollback one transaction
-- Check deadlock information
SHOW ENGINE INNODB STATUS;
```

---

## Database Maintenance

### Table Maintenance
```sql
-- Analyze table (update statistics)
ANALYZE TABLE employees;
ANALYZE TABLE employees, departments, projects;

-- Optimize table (defragment and rebuild)
OPTIMIZE TABLE employees;

-- Check table for errors
CHECK TABLE employees;
CHECK TABLE employees EXTENDED;

-- Repair table
REPAIR TABLE employees;
REPAIR TABLE employees EXTENDED;

-- Check table status
SHOW TABLE STATUS LIKE 'employees';
```

### Index Maintenance
```sql
-- Show indexes
SHOW INDEXES FROM employees;
SHOW INDEX FROM employees;

-- Analyze index usage
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    INDEX_NAME,
    SEQ_IN_INDEX,
    COLUMN_NAME,
    CARDINALITY
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'company'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- Find unused indexes
SELECT 
    s.TABLE_SCHEMA,
    s.TABLE_NAME,
    s.INDEX_NAME
FROM INFORMATION_SCHEMA.STATISTICS s
LEFT JOIN performance_schema.table_io_waits_summary_by_index_usage i
    ON s.TABLE_SCHEMA = i.OBJECT_SCHEMA
    AND s.TABLE_NAME = i.OBJECT_NAME
    AND s.INDEX_NAME = i.INDEX_NAME
WHERE s.TABLE_SCHEMA = 'company'
    AND i.INDEX_NAME IS NULL
    AND s.INDEX_NAME != 'PRIMARY';
```

### Database Statistics
```sql
-- Database size information
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables
GROUP BY table_schema;

-- Table size information
SELECT 
    table_name AS 'Table',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)',
    table_rows AS 'Rows'
FROM information_schema.tables
WHERE table_schema = 'company'
ORDER BY (data_length + index_length) DESC;

-- Index size information
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    ROUND(STAT_VALUE * @@innodb_page_size / 1024 / 1024, 2) AS 'Size (MB)'
FROM mysql.innodb_index_stats
WHERE STAT_NAME = 'size' AND DATABASE_NAME = 'company'
ORDER BY STAT_VALUE DESC;
```

### Automated Maintenance
```sql
-- Create maintenance procedure
DELIMITER //

CREATE PROCEDURE PerformMaintenance()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE table_name VARCHAR(64);
    DECLARE cur CURSOR FOR 
        SELECT TABLE_NAME 
        FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_TYPE = 'BASE TABLE';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    maintenance_loop: LOOP
        FETCH cur INTO table_name;
        IF done THEN
            LEAVE maintenance_loop;
        END IF;
        
        SET @sql = CONCAT('ANALYZE TABLE ', table_name);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        SET @sql = CONCAT('OPTIMIZE TABLE ', table_name);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;
    
    CLOSE cur;
    
    SELECT 'Maintenance completed' AS result;
END //

DELIMITER ;

-- Schedule with MySQL Event Scheduler
SET GLOBAL event_scheduler = ON;

CREATE EVENT weekly_maintenance
ON SCHEDULE EVERY 1 WEEK
STARTS '2023-12-03 02:00:00'
DO
    CALL PerformMaintenance();
```

---

## Security

### SQL Injection Prevention
```sql
-- Use parameterized queries (examples in different contexts)

-- Stored procedure with parameters
DELIMITER //
CREATE PROCEDURE GetUserByCredentials(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(255)
)
BEGIN
    -- Safe: uses parameters
    SELECT user_id, username, email
    FROM users
    WHERE username = p_username AND password_hash = SHA2(p_password, 256);
END //
DELIMITER ;

-- Avoid dynamic SQL construction
-- BAD: Vulnerable to SQL injection
-- SET @sql = CONCAT('SELECT * FROM users WHERE username = "', username, '"');

-- GOOD: Use prepared statements
SET @sql = 'SELECT * FROM users WHERE username = ?';
PREPARE stmt FROM @sql;
SET @username = 'john_doe';
EXECUTE stmt USING @username;
DEALLOCATE PREPARE stmt;
```

### Data Encryption
```sql
-- Encrypt sensitive data
CREATE TABLE user_secrets (
    user_id INT PRIMARY KEY,
    username VARCHAR(50),
    encrypted_ssn VARBINARY(255),
    encrypted_credit_card VARBINARY(255)
);

-- Insert encrypted data
INSERT INTO user_secrets (user_id, username, encrypted_ssn, encrypted_credit_card)
VALUES (
    1, 
    'john_doe',
    AES_ENCRYPT('123-45-6789', 'encryption_key_ssn'),
    AES_ENCRYPT('1234-5678-9012-3456', 'encryption_key_cc')
);

-- Decrypt data (only when necessary)
SELECT 
    username,
    AES_DECRYPT(encrypted_ssn, 'encryption_key_ssn') as ssn,
    CONCAT('****-****-****-', RIGHT(AES_DECRYPT(encrypted_credit_card, 'encryption_key_cc'), 4)) as masked_cc
FROM user_secrets
WHERE user_id = 1;

-- Hash passwords (one-way)
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255),
    salt VARCHAR(32)
);

-- Insert user with hashed password
INSERT INTO users (username, password_hash, salt)
VALUES (
    'john_doe',
    SHA2(CONCAT('user_password', 'random_salt'), 256),
    'random_salt'
);
```

### SSL/TLS Configuration
```sql
-- Check SSL status
SHOW VARIABLES LIKE '%ssl%';
SHOW STATUS LIKE 'Ssl%';

-- Require SSL for specific users
CREATE USER 'secure_user'@'%' IDENTIFIED BY 'password' REQUIRE SSL;
ALTER USER 'existing_user'@'%' REQUIRE SSL;

-- Require specific SSL certificate
CREATE USER 'cert_user'@'%' IDENTIFIED BY 'password' 
REQUIRE X509;

-- Require specific certificate attributes
CREATE USER 'strict_user'@'%' IDENTIFIED BY 'password'
REQUIRE SUBJECT '/C=US/ST=CA/L=San Francisco/O=Company/CN=client'
AND ISSUER '/C=US/ST=CA/L=San Francisco/O=CA Company/CN=CA';
```

### Audit and Logging
```sql
-- Enable general query log
SET GLOBAL general_log = 'ON';
SET GLOBAL general_log_file = '/var/log/mysql/general.log';

-- Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL slow_query_log_file = '/var/log/mysql/slow.log';
SET GLOBAL long_query_time = 2;

-- Enable binary logging
SET GLOBAL log_bin = 'ON';

-- Create audit table
CREATE TABLE audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_name VARCHAR(50),
    action_type VARCHAR(20),
    table_name VARCHAR(50),
    record_id INT,
    old_values JSON,
    new_values JSON,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45)
);

-- Audit trigger example
DELIMITER //
CREATE TRIGGER audit_employee_changes
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        user_name, action_type, table_name, record_id, 
        old_values, new_values, ip_address
    )
    VALUES (
        USER(), 'UPDATE', 'employees', NEW.emp_id,
        JSON_OBJECT('salary', OLD.salary, 'department', OLD.department),
        JSON_OBJECT('salary', NEW.salary, 'department', NEW.department),
        CONNECTION_ID()
    );
END //
DELIMITER ;
```

---

## Monitoring and Logging

### Performance Monitoring
```sql
-- Check current connections
SHOW PROCESSLIST;
SHOW FULL PROCESSLIST;

-- Monitor database performance
SHOW STATUS LIKE 'Threads%';
SHOW STATUS LIKE 'Questions';
SHOW STATUS LIKE 'Uptime';
SHOW STATUS LIKE 'Slow_queries';

-- InnoDB status
SHOW ENGINE INNODB STATUS;

-- Query cache statistics
SHOW STATUS LIKE 'Qcache%';

-- Table lock statistics
SHOW STATUS LIKE 'Table_locks%';

-- Connection statistics
SHOW STATUS LIKE 'Connections';
SHOW STATUS LIKE 'Max_used_connections';
SHOW STATUS LIKE 'Aborted%';
```

### Performance Schema Queries
```sql
-- Top queries by execution time
SELECT 
    DIGEST_TEXT,
    COUNT_STAR,
    AVG_TIMER_WAIT/1000000000 AS avg_time_seconds,
    SUM_TIMER_WAIT/1000000000 AS total_time_seconds
FROM performance_schema.events_statements_summary_by_digest
ORDER BY SUM_TIMER_WAIT DESC
LIMIT 10;

-- Table I/O statistics
SELECT 
    OBJECT_SCHEMA,
    OBJECT_NAME,
    COUNT_READ,
    COUNT_WRITE,
    COUNT_FETCH,
    COUNT_INSERT,
    COUNT_UPDATE,
    COUNT_DELETE
FROM performance_schema.table_io_waits_summary_by_table
WHERE OBJECT_SCHEMA = 'company'
ORDER BY COUNT_READ + COUNT_WRITE DESC;

-- Index usage statistics
SELECT 
    OBJECT_SCHEMA,
    OBJECT_NAME,
    INDEX_NAME,
    COUNT_FETCH,
    COUNT_INSERT,
    COUNT_UPDATE,
    COUNT_DELETE
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE OBJECT_SCHEMA = 'company'
ORDER BY COUNT_FETCH DESC;
```

### Custom Monitoring Procedures
```sql
DELIMITER //

CREATE PROCEDURE GetDatabaseHealth()
BEGIN
    -- Connection information
    SELECT 'Connection Stats' as metric_type,
           'Current Connections' as metric_name,
           VARIABLE_VALUE as metric_value
    FROM performance_schema.global_status
    WHERE VARIABLE_NAME = 'Threads_connected'
    
    UNION ALL
    
    SELECT 'Connection Stats',
           'Max Used Connections',
           VARIABLE_VALUE
    FROM performance_schema.global_status
    WHERE VARIABLE_NAME = 'Max_used_connections'
    
    UNION ALL
    
    -- Query statistics
    SELECT 'Query Stats',
           'Total Queries',
           VARIABLE_VALUE
    FROM performance_schema.global_status
    WHERE VARIABLE_NAME = 'Questions'
    
    UNION ALL
    
    SELECT 'Query Stats',
           'Slow Queries',
           VARIABLE_VALUE
    FROM performance_schema.global_status
    WHERE VARIABLE_NAME = 'Slow_queries'
    
    UNION ALL
    
    -- InnoDB statistics
    SELECT 'InnoDB Stats',
           'Buffer Pool Hit Rate',
           CONCAT(ROUND(
               (1 - (VARIABLE_VALUE / 
                   (SELECT VARIABLE_VALUE 
                    FROM performance_schema.global_status 
                    WHERE VARIABLE_NAME = 'Innodb_buffer_pool_read_requests')
               )) * 100, 2
           ), '%')
    FROM performance_schema.global_status
    WHERE VARIABLE_NAME = 'Innodb_buffer_pool_reads';
END //

DELIMITER ;
```

---

## Configuration Management

### Important MySQL Configuration Parameters
```ini
# /etc/mysql/my.cnf or /etc/my.cnf

[mysqld]
# Basic settings
port = 3306
socket = /var/run/mysqld/mysqld.sock
datadir = /var/lib/mysql

# Memory settings
innodb_buffer_pool_size = 1G
key_buffer_size = 256M
max_connections = 200
thread_cache_size = 8
query_cache_size = 64M
query_cache_limit = 2M

# InnoDB settings
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit = 1
innodb_log_file_size = 256M
innodb_log_buffer_size = 8M

# Logging
log_error = /var/log/mysql/error.log
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2
log_queries_not_using_indexes = 1

# Binary logging
log_bin = mysql-bin
server_id = 1
binlog_format = ROW
expire_logs_days = 7

# Security
ssl_ca = /etc/mysql/ssl/ca-cert.pem
ssl_cert = /etc/mysql/ssl/server-cert.pem
ssl_key = /etc/mysql/ssl/server-key.pem
```

### Dynamic Configuration
```sql
-- View current configuration
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
SHOW VARIABLES LIKE '%cache%';

-- Change configuration dynamically (session level)
SET SESSION sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_DATE';
SET SESSION autocommit = 0;

-- Change configuration dynamically (global level)
SET GLOBAL max_connections = 300;
SET GLOBAL slow_query_log = ON;
SET GLOBAL long_query_time = 1;

-- Persist configuration changes (MySQL 8.0+)
SET PERSIST max_connections = 300;
SET PERSIST slow_query_log = ON;

-- Reset persisted variables
RESET PERSIST max_connections;
RESET PERSIST;
```

---

## Practice Exercises

### Exercise 1: User Management
```sql
-- 1. Create a database for a blog application
CREATE DATABASE blog_app;
USE blog_app;

-- 2. Create different user types
CREATE USER 'blog_admin'@'localhost' IDENTIFIED BY 'admin_pass123';
CREATE USER 'blog_writer'@'%' IDENTIFIED BY 'writer_pass456';
CREATE USER 'blog_reader'@'%' IDENTIFIED BY 'reader_pass789';

-- 3. Grant appropriate privileges
GRANT ALL PRIVILEGES ON blog_app.* TO 'blog_admin'@'localhost';
GRANT SELECT, INSERT, UPDATE ON blog_app.* TO 'blog_writer'@'%';
GRANT SELECT ON blog_app.* TO 'blog_reader'@'%';

-- 4. Test the privileges
SHOW GRANTS FOR 'blog_writer'@'%';
```

### Exercise 2: Backup and Restore
```bash
# 1. Create a backup script
#!/bin/bash
DATE=$(date +"%Y%m%d_%H%M%S")
mysqldump -u root -p blog_app > blog_backup_$DATE.sql

# 2. Test restore
mysql -u root -p blog_app_test < blog_backup_20231201_120000.sql

# 3. Create incremental backup using binary logs
mysqlbinlog --start-datetime="2023-12-01 12:00:00" mysql-bin.000001 > incremental.sql
```

### Exercise 3: Transaction Management
```sql
-- 1. Create a banking scenario
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    account_holder VARCHAR(100),
    balance DECIMAL(10,2)
);

INSERT INTO accounts VALUES
(1, 'Alice', 1000.00),
(2, 'Bob', 500.00);

-- 2. Create a safe transfer procedure
DELIMITER //
CREATE PROCEDURE SafeTransfer(
    IN from_account INT,
    IN to_account INT,
    IN amount DECIMAL(10,2)
)
BEGIN
    DECLARE from_balance DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    SELECT balance INTO from_balance
    FROM accounts
    WHERE account_id = from_account
    FOR UPDATE;
    
    IF from_balance < amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds';
    END IF;
    
    UPDATE accounts SET balance = balance - amount WHERE account_id = from_account;
    UPDATE accounts SET balance = balance + amount WHERE account_id = to_account;
    
    COMMIT;
END //
DELIMITER ;

-- 3. Test the transfer
CALL SafeTransfer(1, 2, 200.00);
SELECT * FROM accounts;
```

---

## Best Practices Summary

1. **Security**
   - Use strong passwords and change them regularly
   - Grant minimum necessary privileges
   - Use SSL/TLS for connections
   - Regularly audit user access

2. **Backup**
   - Implement automated backup procedures
   - Test restore procedures regularly
   - Store backups in multiple locations
   - Document recovery procedures

3. **Performance**
   - Monitor database performance regularly
   - Optimize queries and indexes
   - Configure appropriate buffer sizes
   - Use connection pooling

4. **Maintenance**
   - Schedule regular maintenance tasks
   - Monitor disk space and growth
   - Keep software updated
   - Document configuration changes

---

## Next Steps
Continue with [Part 6: Performance Optimization](06_Performance_Optimization.md) to learn about indexing strategies, query optimization, and performance tuning.