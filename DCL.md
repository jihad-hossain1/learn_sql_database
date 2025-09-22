 — let’s go into **DCL (Data Control Language)** which is about **permissions & access control**.
The two main commands are:

* **`GRANT`** → give permissions to a user/role
* **`REVOKE`** → take permissions back

---

## 🔹 Example Scenario:

We have a database called `LibraryDB`.
We want to create some **users** and control what they can/can’t do.

---

## 1. Create Users (for practice)

*(In MySQL or PostgreSQL, syntax may slightly vary)*

```sql
-- Create users
CREATE USER 'librarian'@'localhost' IDENTIFIED BY 'lib123';
CREATE USER 'student'@'localhost' IDENTIFIED BY 'stud123';
```

---

## 2. `GRANT` – Give Permissions

```sql
-- Librarian can do everything in LibraryDB
GRANT ALL PRIVILEGES
ON LibraryDB.*
TO 'librarian'@'localhost';

-- Student can only read (SELECT) from Books
GRANT SELECT
ON LibraryDB.Books
TO 'student'@'localhost';

-- Student can insert new records but not delete
GRANT INSERT
ON LibraryDB.Books
TO 'student'@'localhost';
```

👉 Here:

* **Librarian** = full access
* **Student** = can read and insert books, but **cannot delete or update**

---

## 3. `REVOKE` – Take Away Permissions

```sql
-- Take away INSERT privilege from student
REVOKE INSERT
ON LibraryDB.Books
FROM 'student'@'localhost';

-- Remove all librarian privileges
REVOKE ALL PRIVILEGES
ON LibraryDB.*
FROM 'librarian'@'localhost';
```

👉 Now:

* Student can only **read** from Books
* Librarian has no access

---

## 🔹 Quick Practice Exercises for You:

1. Create a new user **assistant** with password `"help123"`.

   * Give them only `SELECT` on `Authors`.
2. Create a user **admin** with password `"admin123"`.

   * Grant them `ALL PRIVILEGES` on `LibraryDB`.
   * Then revoke `DROP` privilege (so they can’t delete tables).
3. Give the **student** user permission to `UPDATE` book titles, but not authors.

---

