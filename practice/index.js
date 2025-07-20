const express = require("express");
const { faker } = require("@faker-js/faker");
const mysql = require("mysql2/promise");

const app = express();
const port = 7000;

// MySQL connection config
const pool = mysql.createPool({
  host: "localhost",
  user: "admin",
  password: "admin",
  database: "testdb",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

// Fake majors list
const majors = [
  "Computer Science",
  "Engineering",
  "Biology",
  "Business",
  "Psychology",
  "History",
  "Physics",
  "Economics",
  "Philosophy",
  "Nursing",
];

// Route to insert fake student data
app.get("/students", async (req, res) => {
  const count = parseInt(req.query.count) || 30;

  try {
    const connection = await pool.getConnection();

    const insertQuery = `
      INSERT INTO students (first_name, last_name, email, age, major, gpa)
      VALUES (?, ?, ?, ?, ?, ?)
    `;

    for (let i = 0; i < count; i++) {
      const firstName = faker.person.firstName();
      const lastName = faker.person.lastName();
      const email = faker.internet.email({ firstName, lastName });
      const age = faker.number.int({ min: 18, max: 25 });
      const major = faker.helpers.arrayElement(majors);
      const gpa = (Math.random() * 2 + 2).toFixed(2); // GPA: 2.00–4.00

      await connection.execute(insertQuery, [
        firstName,
        lastName,
        email,
        age,
        major,
        gpa,
      ]);
    }

    connection.release();
    res.send(`${count} fake students inserted successfully.`);
  } catch (err) {
    console.error(err);
    res.status(500).send("Database error");
  }
});

const departments = [
  "IT",
  "HR",
  "Finance",
  "Marketing",
  "Sales",
  "Operations",
  "Research",
  "Customer Service",
  "Production",
  "Quality Assurance",
];

// Route to insert fake employee data
app.get("/employees", async (req, res) => {
  const count = parseInt(req.query.count) || 30;

  try {
    const connection = await pool.getConnection();

    const insertQuery = `
      INSERT INTO employees (first_name, last_name, department, salary, hire_date)
      VALUES (?, ?, ?, ?, ?)
    `;

    for (let i = 0; i < count; i++) {
      const firstName = faker.person.firstName();
      const lastName = faker.person.lastName();
      const department = faker.helpers.arrayElement(departments);
      const salary = (Math.random() * 200000).toFixed(2); // 100000-30000
      const hire_date = faker.date.past();

      await connection.execute(insertQuery, [
        firstName,
        lastName,
        department,
        salary,
        hire_date,
      ]);
    }

    connection.release();
    res.send(`${count} fake employees inserted successfully.`);
  } catch (err) {
    console.error(err);
    res.status(500).send("Database error");
  }
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
