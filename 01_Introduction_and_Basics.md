# SQL Database Learning Guide - Part 1: Introduction and Basics

## Table of Contents
1. [Introduction to Databases](#introduction-to-databases)
2. [Basic SQL Concepts](#basic-sql-concepts)
3. [Database Design Fundamentals](#database-design-fundamentals)
4. [Data Types](#data-types)
5. [Constraints](#constraints)

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
1. **DDL (Data Definition Language)**: CREATE, ALTER, DROP (Details)[./DDL.md]
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

Great question!

---

### 📘 **What is a Clause in SQL?**

A **clause** is a **part of an SQL statement** that performs a specific task.
> You can think of a clause like a section of a sentence — each clause has a job, like selecting data, filtering it, grouping it, etc.
---

### 🧱 Common SQL Clauses (with simple meanings):

| Clause     | Purpose                                                         |
| ---------- | --------------------------------------------------------------- |
| `SELECT`   | Specifies **what columns or values** to return                  |
| `FROM`     | Tells SQL **which table(s)** to get the data from               |
| `WHERE`    | Filters rows based on a **condition**                           |
| `GROUP BY` | Groups rows that have the same values in specified columns      |
| `HAVING`   | Filters groups (used with `GROUP BY`)                           |
| `ORDER BY` | Sorts the result set (ASC/DESC)                                 |
| `LIMIT`    | Limits the number of rows returned                              |
| `JOIN`     | Combines rows from two or more tables based on a related column |

---

### 📌 Example with Clauses Labeled:

```sql
SELECT name, salary          -- SELECT clause
FROM employees               -- FROM clause
WHERE department = 'IT'      -- WHERE clause
ORDER BY salary DESC         -- ORDER BY clause
LIMIT 5;                     -- LIMIT clause
```

Each of those lines is a **clause** — together they form a complete SQL statement.

---

### 💡 In Summary:

> A **clause** is a **building block** of an SQL statement.
> Think of it as a **keyword + its logic** that tells the database *what to do* at each step.

--- 
Understanding the **names of parts** of an SQL query will help you **read and write** queries more effectively. Let’s break down this example:

```sql
SELECT COUNT(salary)
FROM employee
WHERE hire_date = '2023-01-13';
```

---

### 🔍 Breakdown with Part Names:

| SQL Code                   | What It’s Called (Name)              | Description                                                     |
| -------------------------- | ------------------------------------ | --------------------------------------------------------------- |
| `SELECT`                   | **Keyword / Clause** (SELECT clause) | Used to specify **what to return** (columns, expressions, etc.) |
| `COUNT(salary)`            | **Aggregate Function / Expression**  | Function that counts non-NULL `salary` values                   |
| `salary`                   | **Column Name**                      | Refers to a specific field in the `employee` table              |
| `FROM`                     | **Keyword / Clause** (FROM clause)   | Specifies **which table** the data comes from                   |
| `employee`                 | **Table Name**                       | The table being queried                                         |
| `WHERE`                    | **Keyword / Clause** (WHERE clause)  | Filters rows based on a condition                               |
| `hire_date = '2023-01-13'` | **Condition / Predicate**            | Logical test to filter rows (only those hired on this date)     |
| `'2023-01-13'`             | **Literal (String / Date Constant)** | A hardcoded date value used in the condition                    |

---

### 🧠 Category Summary

| SQL Part                 | Category Type           | Example                         |
| ------------------------ | ----------------------- | ------------------------------- |
| SQL Clauses              | Control query structure | `SELECT`, `FROM`, `WHERE`, etc. |
| Functions                | Built-in operations     | `COUNT()`, `SUM()`, `AVG()`     |
| Columns & Tables         | Schema elements         | `salary`, `employee`            |
| Conditions / Expressions | Logic filters           | `hire_date = '2023-01-13'`      |
| Literals / Constants     | Fixed values            | `'2023-01-13'`, `5000`, `'HR'`  |

---

### 🌐 Full Named Version of the Query:

```sql
-- SELECT clause with an aggregate function expression
SELECT COUNT(salary) 

-- FROM clause identifying the source table
FROM employee

-- WHERE clause filtering rows by a condition
WHERE hire_date = '2023-01-13';
```

---


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

## Next Steps
Continue with [Part 2: Basic Operations](02_Basic_Operations.md) to learn about CRUD operations and basic querying.
