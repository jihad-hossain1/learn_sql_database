CREATE VIEW active_users AS
SELECT id, name, email, role
FROM users;

SELECT * FROM active_users WHERE id > 2;


CREATE VIEW post_with_authors AS (
	SELECT 
		p.id AS post_id,
		p.title,
		p.content,
		p.author_id,
		u.name AS author_name,
		p.created_at
	FROM posts AS p
	JOIN users AS u ON p.author_id = u.id
)

SELECT * FROM post_with_authors WHERE author_name ILIKE 'john%';

CREATE VIEW user_post_count AS (
	SELECT 
		u.id AS user_id,
		u.name,
		COUNT(p.id) AS total_posts
	FROM users AS u
	LEFT JOIN posts AS p ON u.id = p.author_id
	GROUP BY u.id, u.name
)

SELECT * FROM user_post_count WHERE total_posts > 1;

-- Recent published posts
CREATE MATERIALIZED VIEW recent_published_posts AS
SELECT id, title, author_id, published_at
FROM posts
WHERE published_at > NOW() - INTERVAL '7 days';

-- Post count by user
CREATE MATERIALIZED VIEW user_post_summary AS
SELECT author_id, COUNT(*) AS total_posts
FROM posts
GROUP BY author_id;

-- Top viewed posts
CREATE MATERIALIZED VIEW top_viewed_posts AS
SELECT 
  p.id AS post_id, 
  p.title, 
  pv.count AS view_count
FROM posts AS p
JOIN post_views AS pv ON p.id = pv.id
ORDER BY pv.count DESC
LIMIT 10;

REFRESH MATERIALIZED VIEW recent_published_posts;

-- Enable concurrent refresh | you need to create a index to do this
REFRESH MATERIALIZED VIEW CONCURRENTLY recent_published_posts;
CREATE UNIQUE INDEX idx_recent_published_posts_id ON recent_published_posts (id);
