
-- B-Tree index for filtering by role
CREATE INDEX idx_users_role ON users(role);

-- Improve queries
SELECT * FROM users WHERE role = 'admin';


-- B-tree index for published posts filtering
CREATE INDEX idx_posts_published_at ON posts(published_at);
SELECT * FROM posts WHERE published_at IS NOT NULL ORDER BY published_at DESC;

-- B-tree index for author_id filtering
CREATE INDEX idx_posts_author_id ON posts(author_id);

-- B-Tree index for post_id and category_id filtering
CREATE INDEX idx_post_categories_post_category ON post_categories(post_id, category_id);

-- Gin index for full text search
CREATE INDEX idx_posts_title_fts ON posts USING GIN (to_tsvector('english', title));
SELECT * FROM posts WHERE to_tsvector('english', title) @@ plainto_tsquery('database');

DROP INDEX idx_posts_author_id;
DROP INDEX CONCURRENTLY idx_posts_author_id;
SELECT * FROM pg_indexes WHERE tablename = 'users';


-- Force Index
EXPLAIN ANALYZE SELECT * FROM users WHERE role = 'admin';
SET enable_seqscan = OFF;
EXPLAIN ANALYZE SELECT * FROM users WHERE role = 'admin';