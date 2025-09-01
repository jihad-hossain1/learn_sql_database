-- Select All
SELECT * FROM users;

-- Select specific columns
SELECT id, name, email FROM users;

-- Column aliases
SELECT id AS user_id, name AS full_name, email AS user_email FROM users;

-- Table aliases
SELECT u.id AS user_id, u.name AS full_name, u.email AS user_email FROM users u;

-- String functions
SELECT name, UPPER(name) AS name_in_uppercase, LENGTH(name) AS name_length FROM users;

-- Arithmetic operations and functions
SELECT 
  id, 
  count, 
  count * 10 AS estimated_reach 
FROM post_views;

SELECT COUNT(*) AS total_users FROM users;

-- Extract year from date
SELECT 
  id, 
  created_at, 
  EXTRACT(YEAR FROM created_at) AS year_created 
FROM posts;

-- Concatenation
SELECT 
  name, 
  'User: ' || name AS display_name 
FROM users;

-- Handle null values
SELECT 
  name, 
  COALESCE(bio, 'No bio provided') AS bio_summary 
FROM users;