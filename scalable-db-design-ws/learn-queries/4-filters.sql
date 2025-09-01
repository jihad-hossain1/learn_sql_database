SELECT * FROM users WHERE name = 'John Doe';
SELECT * FROM posts WHERE id = 5;

SELECT * FROM users WHERE dob > '2000-01-01';
SELECT * FROM posts WHERE created_at < '2024-01-01';

SELECT * FROM users WHERE name ILIKE 'A%';
SELECT * FROM posts WHERE title ILIKE '%Database%';

SELECT * FROM users WHERE role = 'admin';
SELECT * FROM comments WHERE status = 'approved';

SELECT * FROM users WHERE profile_picture IS NULL;
SELECT * FROM posts WHERE published_at IS NULL;

SELECT * FROM users WHERE role = 'admin' AND dob > '1990-01-01';
SELECT * FROM posts WHERE author_id = 3 OR author_id = 5;

SELECT * FROM users LIMIT 5;
SELECT * FROM posts ORDER BY created_at DESC LIMIT 10;

SELECT * FROM comments 
WHERE post_id = 10 AND status = 'approved' 
ORDER BY created_at DESC 
LIMIT 2 OFFSET 4;

-- GROUPING

-- Count total posts by author
SELECT author_id, COUNT(*) AS total_posts
FROM posts
GROUP BY author_id;

-- Count posts and show latest post by author
SELECT author_id, COUNT(*) AS total_posts, MAX(created_at) AS latest_post
FROM posts
GROUP BY author_id;

-- Only show posts with more than 2 posts
SELECT author_id, COUNT(*) AS total_posts
FROM posts
GROUP BY author_id
HAVING COUNT(*) > 2;

-- Count total users by role
SELECT role, COUNT(*) AS total_users
FROM users
GROUP BY role;

SELECT role, COUNT(*) AS total_users
FROM users
GROUP BY role
HAVING COUNT(*) > 1;

-- Find users who have at least 3 posts, and only show their ID, name, and post count

SELECT u.id, u.name, COUNT(p.id) AS post_count
FROM users AS u
JOIN posts AS p ON u.id = p.author_id
GROUP BY u.id, u.name
HAVING COUNT(p.id) >= 1
ORDER BY post_count DESC
LIMIT 5;
