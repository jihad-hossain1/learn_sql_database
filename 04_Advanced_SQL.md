# SQL Database Learning Guide - Part 4: Advanced SQL

## Table of Contents
1. [Window Functions](#window-functions)
2. [Common Table Expressions (CTEs)](#common-table-expressions-ctes)
3. [Stored Procedures](#stored-procedures)
4. [Functions](#functions)
5. [Triggers](#triggers)
6. [Views](#views)
7. [Advanced Query Techniques](#advanced-query-techniques)
8. [Practice Exercises](#practice-exercises)

---

## Window Functions

### Basic Window Functions
```sql
-- Row number
SELECT 
    first_name, 
    last_name, 
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) as salary_rank
FROM employees;

-- Rank and Dense Rank
SELECT 
    first_name, 
    last_name, 
    salary,
    RANK() OVER (ORDER BY salary DESC) as rank_with_gaps,
    DENSE_RANK() OVER (ORDER BY salary DESC) as dense_rank
FROM employees;

-- Percent Rank
SELECT 
    first_name, 
    last_name, 
    salary,
    PERCENT_RANK() OVER (ORDER BY salary) as percentile
FROM employees;
```

### Partition By
```sql
-- Rank within departments
SELECT 
    first_name, 
    last_name, 
    department,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) as dept_rank
FROM employees;

-- Compare salary to department average
SELECT 
    first_name, 
    last_name, 
    department,
    salary,
    AVG(salary) OVER (PARTITION BY department) as dept_avg_salary,
    salary - AVG(salary) OVER (PARTITION BY department) as diff_from_dept_avg
FROM employees;
```

### Running Totals and Moving Averages
```sql
-- Running total
SELECT 
    first_name, 
    last_name,
    hire_date,
    salary,
    SUM(salary) OVER (ORDER BY hire_date) as running_total_payroll
FROM employees
ORDER BY hire_date;

-- Moving average (3-row window)
SELECT 
    first_name, 
    salary,
    AVG(salary) OVER (
        ORDER BY hire_date 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as moving_avg_3
FROM employees
ORDER BY hire_date;

-- Cumulative distribution
SELECT 
    first_name, 
    salary,
    CUME_DIST() OVER (ORDER BY salary) as cumulative_distribution
FROM employees;
```

### Lead and Lag Functions
```sql
-- Compare with next and previous values
SELECT 
    first_name, 
    last_name,
    salary,
    LAG(salary, 1) OVER (ORDER BY salary) as previous_salary,
    LEAD(salary, 1) OVER (ORDER BY salary) as next_salary,
    salary - LAG(salary, 1) OVER (ORDER BY salary) as salary_increase
FROM employees
ORDER BY salary;

-- First and last values in partition
SELECT 
    first_name, 
    department,
    salary,
    FIRST_VALUE(salary) OVER (
        PARTITION BY department 
        ORDER BY salary DESC
        ROWS UNBOUNDED PRECEDING
    ) as highest_in_dept,
    LAST_VALUE(salary) OVER (
        PARTITION BY department 
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as lowest_in_dept
FROM employees;
```

### Ntile Function
```sql
-- Divide employees into quartiles by salary
SELECT 
    first_name, 
    last_name,
    salary,
    NTILE(4) OVER (ORDER BY salary) as salary_quartile
FROM employees;

-- Divide into performance groups by department
SELECT 
    first_name, 
    department,
    salary,
    NTILE(3) OVER (PARTITION BY department ORDER BY salary DESC) as performance_group
FROM employees;
```

---

## Common Table Expressions (CTEs)

### Basic CTEs
```sql
-- Simple CTE
WITH high_earners AS (
    SELECT * FROM employees WHERE salary > 75000
)
SELECT department, COUNT(*) as high_earner_count
FROM high_earners
GROUP BY department;

-- Multiple CTEs
WITH 
high_earners AS (
    SELECT * FROM employees WHERE salary > 75000
),
dept_stats AS (
    SELECT department, AVG(salary) as avg_salary
    FROM employees
    GROUP BY department
)
SELECT 
    he.first_name, 
    he.last_name, 
    he.department,
    ds.avg_salary
FROM high_earners he
JOIN dept_stats ds ON he.department = ds.department;
```

### Recursive CTEs
```sql
-- Employee hierarchy (assuming manager_id column exists)
WITH RECURSIVE employee_hierarchy AS (
    -- Base case: top-level managers
    SELECT 
        emp_id, 
        first_name, 
        last_name, 
        manager_id, 
        1 as level,
        CAST(first_name AS CHAR(1000)) as hierarchy_path
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case: employees with managers
    SELECT 
        e.emp_id, 
        e.first_name, 
        e.last_name, 
        e.manager_id, 
        eh.level + 1,
        CONCAT(eh.hierarchy_path, ' -> ', e.first_name)
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.emp_id
    WHERE eh.level < 10  -- Prevent infinite recursion
)
SELECT * FROM employee_hierarchy ORDER BY level, emp_id;

-- Generate number sequence
WITH RECURSIVE number_sequence AS (
    SELECT 1 as n
    UNION ALL
    SELECT n + 1 FROM number_sequence WHERE n < 10
)
SELECT * FROM number_sequence;

-- Calculate factorial
WITH RECURSIVE factorial AS (
    SELECT 1 as n, 1 as fact
    UNION ALL
    SELECT n + 1, fact * (n + 1)
    FROM factorial
    WHERE n < 10
)
SELECT n, fact FROM factorial;
```

### Advanced CTE Usage
```sql
-- CTE with window functions
WITH ranked_employees AS (
    SELECT 
        first_name,
        last_name,
        department,
        salary,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) as dept_rank
    FROM employees
)
SELECT * FROM ranked_employees WHERE dept_rank <= 2;

-- CTE for complex calculations
WITH monthly_sales AS (
    SELECT 
        YEAR(order_date) as year,
        MONTH(order_date) as month,
        SUM(total_amount) as monthly_total
    FROM orders
    GROUP BY YEAR(order_date), MONTH(order_date)
),
sales_with_growth AS (
    SELECT 
        year,
        month,
        monthly_total,
        LAG(monthly_total) OVER (ORDER BY year, month) as prev_month_total,
        (monthly_total - LAG(monthly_total) OVER (ORDER BY year, month)) / 
        LAG(monthly_total) OVER (ORDER BY year, month) * 100 as growth_rate
    FROM monthly_sales
)
SELECT * FROM sales_with_growth WHERE growth_rate IS NOT NULL;
```

---

## Stored Procedures

### Basic Stored Procedures
```sql
DELIMITER //

-- Simple procedure
CREATE PROCEDURE GetEmployeesByDepartment(
    IN dept_name VARCHAR(50)
)
BEGIN
    SELECT * FROM employees WHERE department = dept_name;
END //

-- Procedure with multiple parameters
CREATE PROCEDURE GetEmployeesBySalaryRange(
    IN min_salary DECIMAL(10,2),
    IN max_salary DECIMAL(10,2)
)
BEGIN
    SELECT first_name, last_name, salary, department
    FROM employees
    WHERE salary BETWEEN min_salary AND max_salary
    ORDER BY salary DESC;
END //

DELIMITER ;

-- Call procedures
CALL GetEmployeesByDepartment('IT');
CALL GetEmployeesBySalaryRange(60000, 80000);
```

### Procedures with Output Parameters
```sql
DELIMITER //

CREATE PROCEDURE GetDepartmentStats(
    IN dept_name VARCHAR(50),
    OUT emp_count INT,
    OUT avg_salary DECIMAL(10,2),
    OUT total_payroll DECIMAL(12,2)
)
BEGIN
    SELECT 
        COUNT(*),
        AVG(salary),
        SUM(salary)
    INTO emp_count, avg_salary, total_payroll
    FROM employees
    WHERE department = dept_name;
END //

DELIMITER ;

-- Call with output parameters
CALL GetDepartmentStats('IT', @count, @avg, @total);
SELECT @count as employee_count, @avg as average_salary, @total as total_payroll;
```

### Procedures with Control Flow
```sql
DELIMITER //

CREATE PROCEDURE GiveBonusBasedOnPerformance(
    IN emp_id INT,
    IN performance_rating INT
)
BEGIN
    DECLARE current_salary DECIMAL(10,2);
    DECLARE bonus_amount DECIMAL(10,2);
    
    -- Get current salary
    SELECT salary INTO current_salary
    FROM employees
    WHERE emp_id = emp_id;
    
    -- Calculate bonus based on performance
    IF performance_rating >= 9 THEN
        SET bonus_amount = current_salary * 0.15;
    ELSEIF performance_rating >= 7 THEN
        SET bonus_amount = current_salary * 0.10;
    ELSEIF performance_rating >= 5 THEN
        SET bonus_amount = current_salary * 0.05;
    ELSE
        SET bonus_amount = 0;
    END IF;
    
    -- Update salary
    UPDATE employees
    SET salary = salary + bonus_amount
    WHERE emp_id = emp_id;
    
    -- Return bonus amount
    SELECT bonus_amount as bonus_given;
END //

DELIMITER ;
```

### Procedures with Error Handling
```sql
DELIMITER //

CREATE PROCEDURE TransferEmployee(
    IN emp_id INT,
    IN new_dept_id INT
)
BEGIN
    DECLARE dept_exists INT DEFAULT 0;
    DECLARE emp_exists INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Check if employee exists
    SELECT COUNT(*) INTO emp_exists
    FROM employees
    WHERE emp_id = emp_id;
    
    -- Check if department exists
    SELECT COUNT(*) INTO dept_exists
    FROM departments
    WHERE dept_id = new_dept_id;
    
    IF emp_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee not found';
    END IF;
    
    IF dept_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Department not found';
    END IF;
    
    -- Update employee department
    UPDATE employees
    SET dept_id = new_dept_id
    WHERE emp_id = emp_id;
    
    COMMIT;
    
    SELECT 'Employee transferred successfully' as result;
END //

DELIMITER ;
```

---

## Functions

### Scalar Functions
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

-- Function with multiple parameters
CREATE FUNCTION GetYearsOfService(hire_date DATE)
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, hire_date, CURDATE());
END //

DELIMITER ;

-- Use functions in queries
SELECT 
    first_name, 
    last_name, 
    salary, 
    CalculateBonus(salary) as bonus,
    GetYearsOfService(hire_date) as years_of_service
FROM employees;
```

### Table-Valued Functions (MySQL doesn't support, but concept)
```sql
-- This is how it would work in SQL Server/PostgreSQL
-- CREATE FUNCTION GetEmployeesByDepartment(@dept_name VARCHAR(50))
-- RETURNS TABLE
-- AS
-- RETURN (
--     SELECT * FROM employees WHERE department = @dept_name
-- );
```

---

## Triggers

### Before Insert Trigger
```sql
DELIMITER //

CREATE TRIGGER before_employee_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    -- Auto-generate employee ID if not provided
    IF NEW.emp_id IS NULL THEN
        SET NEW.emp_id = (SELECT COALESCE(MAX(emp_id), 0) + 1 FROM employees);
    END IF;
    
    -- Set default hire date if not provided
    IF NEW.hire_date IS NULL THEN
        SET NEW.hire_date = CURDATE();
    END IF;
    
    -- Validate salary
    IF NEW.salary < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary cannot be negative';
    END IF;
END //

DELIMITER ;
```

### After Update Trigger (Audit Trail)
```sql
-- Create audit table
CREATE TABLE employee_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    old_department VARCHAR(50),
    new_department VARCHAR(50),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(50)
);

DELIMITER //

CREATE TRIGGER after_employee_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    -- Log salary changes
    IF OLD.salary != NEW.salary OR OLD.department != NEW.department THEN
        INSERT INTO employee_audit (
            emp_id, 
            old_salary, 
            new_salary, 
            old_department, 
            new_department,
            changed_by
        )
        VALUES (
            NEW.emp_id, 
            OLD.salary, 
            NEW.salary, 
            OLD.department, 
            NEW.department,
            USER()
        );
    END IF;
END //

DELIMITER ;
```

### Before Delete Trigger
```sql
DELIMITER //

CREATE TRIGGER before_employee_delete
BEFORE DELETE ON employees
FOR EACH ROW
BEGIN
    -- Prevent deletion of employees with active projects
    IF EXISTS (SELECT 1 FROM employee_projects WHERE emp_id = OLD.emp_id) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot delete employee with active projects';
    END IF;
    
    -- Log deletion
    INSERT INTO employee_audit (
        emp_id, 
        old_salary, 
        new_salary, 
        old_department, 
        new_department,
        changed_by
    )
    VALUES (
        OLD.emp_id, 
        OLD.salary, 
        NULL, 
        OLD.department, 
        'DELETED',
        USER()
    );
END //

DELIMITER ;
```

---

## Views

### Simple Views
```sql
-- Create a view for employee summary
CREATE VIEW employee_summary AS
SELECT 
    emp_id,
    CONCAT(first_name, ' ', last_name) as full_name,
    department,
    salary,
    TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) as years_of_service
FROM employees;

-- Use the view
SELECT * FROM employee_summary WHERE years_of_service > 2;
```

### Complex Views with Joins
```sql
-- Department statistics view
CREATE VIEW department_stats AS
SELECT 
    d.dept_name,
    d.location,
    COUNT(e.emp_id) as employee_count,
    AVG(e.salary) as avg_salary,
    MIN(e.salary) as min_salary,
    MAX(e.salary) as max_salary,
    SUM(e.salary) as total_payroll
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name, d.location;

-- Project summary view
CREATE VIEW project_summary AS
SELECT 
    p.project_name,
    d.dept_name,
    p.budget,
    COUNT(ep.emp_id) as assigned_employees,
    SUM(ep.hours_worked) as total_hours
FROM projects p
JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employee_projects ep ON p.project_id = ep.project_id
GROUP BY p.project_id, p.project_name, d.dept_name, p.budget;
```

### Updatable Views
```sql
-- Simple updatable view
CREATE VIEW it_employees AS
SELECT emp_id, first_name, last_name, salary
FROM employees
WHERE department = 'IT'
WITH CHECK OPTION;

-- Update through view
UPDATE it_employees SET salary = salary * 1.1 WHERE emp_id = 1;

-- Insert through view (will automatically set department to 'IT')
-- Note: This requires the view to include all NOT NULL columns
```

### Materialized Views (Concept)
```sql
-- MySQL doesn't support materialized views natively
-- But you can simulate them with tables and events

CREATE TABLE mv_department_stats AS
SELECT 
    d.dept_name,
    COUNT(e.emp_id) as employee_count,
    AVG(e.salary) as avg_salary,
    NOW() as last_updated
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

-- Refresh procedure
DELIMITER //
CREATE PROCEDURE RefreshDepartmentStats()
BEGIN
    DELETE FROM mv_department_stats;
    INSERT INTO mv_department_stats
    SELECT 
        d.dept_name,
        COUNT(e.emp_id) as employee_count,
        AVG(e.salary) as avg_salary,
        NOW() as last_updated
    FROM departments d
    LEFT JOIN employees e ON d.dept_id = e.dept_id
    GROUP BY d.dept_id, d.dept_name;
END //
DELIMITER ;
```

---

## Advanced Query Techniques

### Pivot Tables (Manual)
```sql
-- Pivot department data
SELECT 
    YEAR(hire_date) as hire_year,
    SUM(CASE WHEN department = 'IT' THEN 1 ELSE 0 END) as IT_hires,
    SUM(CASE WHEN department = 'HR' THEN 1 ELSE 0 END) as HR_hires,
    SUM(CASE WHEN department = 'Finance' THEN 1 ELSE 0 END) as Finance_hires
FROM employees
GROUP BY YEAR(hire_date)
ORDER BY hire_year;

-- Pivot salary ranges
SELECT 
    department,
    SUM(CASE WHEN salary < 60000 THEN 1 ELSE 0 END) as low_salary,
    SUM(CASE WHEN salary BETWEEN 60000 AND 80000 THEN 1 ELSE 0 END) as mid_salary,
    SUM(CASE WHEN salary > 80000 THEN 1 ELSE 0 END) as high_salary
FROM employees
GROUP BY department;
```

### Dynamic SQL (Stored Procedure)
```sql
DELIMITER //

CREATE PROCEDURE DynamicEmployeeQuery(
    IN column_name VARCHAR(50),
    IN filter_value VARCHAR(100)
)
BEGIN
    SET @sql = CONCAT('SELECT * FROM employees WHERE ', column_name, ' = ?');
    PREPARE stmt FROM @sql;
    SET @filter = filter_value;
    EXECUTE stmt USING @filter;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;

-- Call dynamic procedure
CALL DynamicEmployeeQuery('department', 'IT');
```

### Advanced Analytical Queries
```sql
-- Running percentage of total
SELECT 
    first_name,
    salary,
    SUM(salary) OVER (ORDER BY salary DESC) as running_total,
    SUM(salary) OVER () as grand_total,
    (SUM(salary) OVER (ORDER BY salary DESC) / SUM(salary) OVER ()) * 100 as running_percentage
FROM employees
ORDER BY salary DESC;

-- Median calculation
SELECT 
    department,
    AVG(salary) as median_salary
FROM (
    SELECT 
        department,
        salary,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary) as row_num,
        COUNT(*) OVER (PARTITION BY department) as total_count
    FROM employees
) ranked
WHERE row_num IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2))
GROUP BY department;
```

---

## Practice Exercises

### Exercise 1: Window Functions
```sql
-- 1. Rank employees by salary within each department
SELECT 
    first_name, 
    last_name, 
    department, 
    salary,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) as dept_salary_rank
FROM employees;

-- 2. Calculate running total of salaries by hire date
SELECT 
    first_name, 
    hire_date, 
    salary,
    SUM(salary) OVER (ORDER BY hire_date) as running_payroll
FROM employees
ORDER BY hire_date;

-- 3. Find the salary difference between each employee and the next highest paid
SELECT 
    first_name, 
    salary,
    LEAD(salary) OVER (ORDER BY salary DESC) as next_higher_salary,
    salary - LEAD(salary) OVER (ORDER BY salary DESC) as salary_gap
FROM employees
ORDER BY salary DESC;
```

### Exercise 2: CTEs and Recursive Queries
```sql
-- 1. Find employees earning more than their department average using CTE
WITH dept_averages AS (
    SELECT department, AVG(salary) as avg_salary
    FROM employees
    GROUP BY department
)
SELECT e.first_name, e.last_name, e.department, e.salary, da.avg_salary
FROM employees e
JOIN dept_averages da ON e.department = da.department
WHERE e.salary > da.avg_salary;

-- 2. Generate a date series for the last 30 days
WITH RECURSIVE date_series AS (
    SELECT CURDATE() as date_value
    UNION ALL
    SELECT DATE_SUB(date_value, INTERVAL 1 DAY)
    FROM date_series
    WHERE date_value > DATE_SUB(CURDATE(), INTERVAL 30 DAY)
)
SELECT * FROM date_series ORDER BY date_value;
```

### Exercise 3: Stored Procedures and Functions
```sql
-- 1. Create a procedure to give raises based on performance
DELIMITER //
CREATE PROCEDURE GivePerformanceRaise(
    IN dept_name VARCHAR(50),
    IN raise_percentage DECIMAL(5,2)
)
BEGIN
    UPDATE employees
    SET salary = salary * (1 + raise_percentage / 100)
    WHERE department = dept_name;
    
    SELECT ROW_COUNT() as employees_updated;
END //
DELIMITER ;

-- 2. Create a function to calculate tax based on salary
DELIMITER //
CREATE FUNCTION CalculateTax(salary DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE tax_rate DECIMAL(5,4);
    
    CASE 
        WHEN salary <= 50000 THEN SET tax_rate = 0.15;
        WHEN salary <= 100000 THEN SET tax_rate = 0.25;
        ELSE SET tax_rate = 0.35;
    END CASE;
    
    RETURN salary * tax_rate;
END //
DELIMITER ;
```

---

## Best Practices

1. **Use meaningful names for procedures, functions, and variables**
2. **Include error handling in stored procedures**
3. **Document complex logic with comments**
4. **Use transactions for data consistency**
5. **Avoid cursors when set-based operations are possible**
6. **Test procedures thoroughly before deployment**
7. **Use views to simplify complex queries**
8. **Be cautious with triggers as they can impact performance**

---

## Next Steps
Continue with [Part 5: Database Administration](05_Database_Administration.md) to learn about user management, backup/restore, and performance optimization.