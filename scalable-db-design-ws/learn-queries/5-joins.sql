SELECT * FROM users, posts; -- Cartesian product or Cross Join

-- Explicit cross join
SELECT * FROM users CROSS JOIN posts;

-- Inner Join or Join
-- Combines rows from two tables where a matching condition is met.
SELECT 
  posts.id AS post_id, 
  posts.title, 
  users.name AS author_name
FROM posts
INNER JOIN users ON posts.author_id = users.id;

SELECT 
  comments.id AS comment_id, 
  comments.content, 
  users.name AS commenter_name
FROM comments
INNER JOIN users ON comments.user_id = users.id;

SELECT 
  post_views.id AS post_id, 
  post_views.count, 
  posts.title
FROM post_views
INNER JOIN posts ON post_views.id = posts.id;

-- LEFT JOIN
-- Returns all rows from the left table, matched rows from the right, NULL if no match. 

-- User without posts will be included.
SELECT 
  users.id, 
  users.name, 
  posts.title
FROM users
LEFT JOIN posts ON users.id = posts.author_id;

-- Posts with no views will be included.
SELECT 
  posts.id, 
  posts.title, 
  COALESCE(post_views.count, 0) AS view_count
FROM posts
LEFT JOIN post_views ON posts.id = post_views.id;


-- RIGHT JOIN
-- PostgreSQL supports RIGHT JOIN, though it's used less often when table order can be swapped.

SELECT 
  posts.id, 
  posts.title, 
  users.name
FROM users
RIGHT JOIN posts ON users.id = posts.author_id;


-- FULL OUTER JOIN
-- Combines results of LEFT and RIGHT JOIN.

SELECT 
  users.id AS user_id, 
  users.name, 
  posts.id AS post_id, 
  posts.title
FROM users
FULL JOIN posts ON users.id = posts.author_id;

-- Join on Multiple Tables
SELECT 
  comments.id AS comment_id, 
  comments.content, 
  posts.title AS post_title, 
  users.name AS commenter_name
FROM comments
INNER JOIN posts ON comments.post_id = posts.id
INNER JOIN users ON comments.user_id = users.id;

-- Complex Joins
-- Show all users, total number of posts for each, even if they have zero posts.

SELECT 
  u.id AS user_id,
  u.name,
  COUNT(p.id) AS total_posts
FROM users AS u
LEFT JOIN posts AS p ON u.id = p.author_id
GROUP BY u.id, u.name
ORDER BY total_posts DESC;

-- Show comments with post title and commenter name, only for approved comments.

SELECT 
  c.id as comment_id,
  c.content,
  p.title AS post_title,
  u.name AS commenter_name
FROM comments AS c
INNER JOIN posts AS p ON c.post_id = p.id
INNER JOIN users AS u ON c.user_id = u.id
WHERE c.status = 'approved'
ORDER BY c.created_at DESC
LIMIT 5;

-- Get all published posts with their author and category
SELECT
  p.id AS post_id,
  p.title,
  u.name AS author_name,
  c.name AS category_name,
  p.published_at
FROM posts AS p
INNER JOIN users AS u ON p.author_id = u.id
INNER JOIN post_categories AS pc ON p.id = pc.post_id
INNER JOIN categories AS c ON pc.category_id = c.id
WHERE p.published_at IS NOT NULL
ORDER BY p.published_at DESC
LIMIT 5;

