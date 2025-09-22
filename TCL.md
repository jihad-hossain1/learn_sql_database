- let’s dive into **TCL (Transaction Control Language)**.
TCL manages **transactions** in SQL (a set of operations that run together).

The two most important commands are:

* **`COMMIT`** → permanently save the changes
* **`ROLLBACK`** → undo the changes (before commit)

---

## 🔹 Key Points

1. A **transaction** = one or more SQL statements executed as a unit.
2. Until you **COMMIT**, changes are **temporary** (can be rolled back).
3. Once you **COMMIT**, changes are **permanent**.

---

## 🔹 Example Database

Let’s assume we’re working with the `LibraryDB` from earlier.

```sql
-- Table
CREATE TABLE Accounts (
    account_id INT PRIMARY KEY,
    holder_name VARCHAR(100),
    balance DECIMAL(10,2)
);

-- Insert sample data
INSERT INTO Accounts VALUES (1, 'Alice', 1000.00);
INSERT INTO Accounts VALUES (2, 'Bob', 500.00);
```

---

## 1. **Using COMMIT**

```sql
-- Start a transaction
START TRANSACTION;

-- Deduct 200 from Alice
UPDATE Accounts
SET balance = balance - 200
WHERE account_id = 1;

-- Add 200 to Bob
UPDATE Accounts
SET balance = balance + 200
WHERE account_id = 2;

-- Save permanently
COMMIT;
```

👉 Money transfer is successful.
If we don’t `COMMIT`, the database won’t save these updates.

---

## 2. **Using ROLLBACK**

```sql
-- Start a transaction
START TRANSACTION;

-- Deduct 300 from Alice
UPDATE Accounts
SET balance = balance - 300
WHERE account_id = 1;

-- Oops! Wrong account, cancel transaction
ROLLBACK;
```

👉 After `ROLLBACK`, Alice’s balance goes back to the original value.

---

## 🔹 Quick Practice Exercises for You:

1. Insert a new account (`3, 'Charlie', 200`) inside a transaction.

   * Then use `ROLLBACK` so it doesn’t get saved.
2. Update Bob’s balance to `1000`.

   * Use `COMMIT` so it is permanently saved.
3. Try transferring `150` from Alice to Bob but **forget to commit**.

   * Check balances → you’ll see no change after session ends.

