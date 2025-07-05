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