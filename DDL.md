 — let’s build a **practical SQL example** using **DDL (Data Definition Language)** commands:
`CREATE`, `ALTER`, and `DROP`.

I’ll use a **Library Management System** as the practice scenario.

---

## 1. `CREATE` – Create Database & Tables

```sql
-- Create a new database
CREATE DATABASE LibraryDB;

-- Switch to the database
USE LibraryDB;

-- Create a table for Authors
CREATE TABLE Authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50)
);

-- Create a table for Books
CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    published_year INT,
    author_id INT,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id)
);
```

👉 Here we created:

* A **database**: `LibraryDB`
* Two **tables**: `Authors` and `Books`
* A **foreign key** linking `Books` → `Authors`.

---

## 2. `ALTER` – Modify Tables

```sql
-- Add a new column to Authors
ALTER TABLE Authors
ADD email VARCHAR(100);

-- Change column type in Books
ALTER TABLE Books
MODIFY published_year YEAR;

-- Rename column in Authors
ALTER TABLE Authors
CHANGE country nationality VARCHAR(50);

-- Add a new table column with default value
ALTER TABLE Books
ADD stock INT DEFAULT 0;
```

👉 Practiced:

* Adding a column
* Changing datatype
* Renaming column
* Adding column with default

---

## 3. `DROP` – Remove Tables & Database

```sql
-- Drop a column from Books
ALTER TABLE Books
DROP COLUMN stock;

-- Drop the Books table
DROP TABLE Books;

-- Drop the entire database
DROP DATABASE LibraryDB;
```

👉 Practiced:

* Removing a column
* Removing a table
* Removing the whole database

---

✅ With these examples, you’ve covered the **3 core DDL operations**:

* **CREATE** → build structures
* **ALTER** → modify them
* **DROP** → remove them

---

