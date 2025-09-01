-- Find users who have at least 1 posts
SELECT * FROM users
WHERE id IN (
  SELECT author_id FROM posts
);

-- Find posts with view counts higher than the average view count
SELECT * FROM post_views
WHERE count > (
  SELECT AVG(count) FROM post_views
);

-- Show each post with its total view count
SELECT 
  id, 
  title, 
  (SELECT count FROM post_views WHERE post_views.id = posts.id) AS total_views
FROM posts;

-- Sub queries in FROM Clause (Derived Tables)
-- Find the top 3 most viewed posts
SELECT * 
FROM (
  SELECT p.id, p.title, pv.count
  FROM posts AS p
  JOIN post_views AS pv ON p.id = pv.id
  ORDER BY pv.count DESC
  LIMIT 3
) AS top_posts;

-- First CTE
WITH top_posts AS (
  SELECT p.id, p.title, pv.count
  FROM posts AS p
  JOIN post_views AS pv ON p.id = pv.id
  ORDER BY pv.count DESC
  LIMIT 3
)
SELECT * FROM top_posts;

-- Get users with more than 2 posts
WITH user_post_count AS (
  SELECT author_id, COUNT(*) AS post_count
  FROM posts
  GROUP BY author_id
)
SELECT u.id, u.name, upc.post_count
FROM users AS u
JOIN user_post_count AS upc ON u.id = upc.author_id
WHERE upc.post_count > 2;

-- Categories with at least 2 posts
WITH category_post_count AS (
  SELECT category_id, COUNT(*) AS post_count
  FROM post_categories
  GROUP BY category_id
)
SELECT c.id, c.name, cpc.post_count
FROM categories AS c
JOIN category_post_count AS cpc ON c.id = cpc.category_id
WHERE cpc.post_count >= 2;
