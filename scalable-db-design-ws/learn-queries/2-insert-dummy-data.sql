
-- Insert users
INSERT INTO users (name, email, password, bio, role, profile_picture, dob) VALUES
('John Doe', 'john.doe@example.com', 'hashed_password_123', 'Software developer with 5 years of experience', 'user', 'https://example.com/john.jpg', '1990-05-15'),
('Jane Smith', 'jane.smith@example.com', 'hashed_password_456', 'Full-stack developer and tech enthusiast', 'admin', 'https://example.com/jane.jpg', '1988-12-03'),
('Mike Johnson', 'mike.johnson@example.com', 'hashed_password_789', 'Frontend specialist and UI/UX designer', 'user', 'https://example.com/mike.jpg', '1992-08-22'),
('Sarah Wilson', 'sarah.wilson@example.com', 'hashed_password_101', 'Backend developer and database expert', 'user', 'https://example.com/sarah.jpg', '1995-03-10'),
('David Brown', 'david.brown@example.com', 'hashed_password_202', 'DevOps engineer and cloud specialist', 'user', 'https://example.com/david.jpg', '1987-11-18');

-- Insert categories
INSERT INTO categories (name, description) VALUES
('Technology', 'Articles about latest technology trends and developments'),
('Programming', 'Programming tutorials and best practices'),
('Web Development', 'Frontend and backend web development topics'),
('Database', 'Database design, optimization, and management'),
('DevOps', 'DevOps practices, tools, and methodologies');

-- Insert posts
INSERT INTO posts (title, content, author_id, published_at) VALUES
('Getting Started with PostgreSQL', 'PostgreSQL is a powerful, open source object-relational database system...', 1, '2024-01-15 10:00:00'),
('Modern JavaScript Best Practices', 'JavaScript has evolved significantly over the years...', 2, '2024-01-16 14:30:00'),
('Docker for Beginners', 'Docker is a platform for developing, shipping, and running applications...', 3, '2024-01-17 09:15:00'),
('React Hooks Deep Dive', 'React Hooks have revolutionized how we write functional components...', 4, '2024-01-18 16:45:00'),
('Database Optimization Techniques', 'Optimizing database performance is crucial for any application...', 5, '2024-01-19 11:20:00'),
('Microservices Architecture', 'Microservices architecture is a software development approach...', 1, '2024-01-20 13:00:00'),
('TypeScript vs JavaScript', 'TypeScript adds static typing to JavaScript...', 2, '2024-01-21 15:30:00'),
('CI/CD Pipeline Setup', 'Setting up a proper CI/CD pipeline is essential for modern development...', 3, '2024-01-22 08:45:00');

-- Insert post categories
INSERT INTO post_categories (post_id, category_id) VALUES
(1, 4), -- PostgreSQL post -> Database category
(2, 2), -- JavaScript post -> Programming category
(3, 5), -- Docker post -> DevOps category
(4, 2), -- React post -> Programming category
(4, 3), -- React post -> Web Development category
(5, 4), -- Database optimization -> Database category
(6, 1), -- Microservices -> Technology category
(6, 5), -- Microservices -> DevOps category
(7, 2), -- TypeScript -> Programming category
(8, 5); -- CI/CD -> DevOps category

-- Insert post views
INSERT INTO post_views (id, count) VALUES
(1, 150),
(2, 89),
(3, 234),
(4, 167),
(5, 92),
(6, 201),
(7, 134),
(8, 78);

-- Insert post view logs
INSERT INTO post_view_logs (post_id, user_id) VALUES
(1, 2), (1, 3), (1, 4), (1, 5),
(2, 1), (2, 3), (2, 4),
(3, 1), (3, 2), (3, 4), (3, 5),
(4, 1), (4, 2), (4, 3), (4, 5),
(5, 1), (5, 2), (5, 3),
(6, 2), (6, 3), (6, 4), (6, 5),
(7, 1), (7, 3), (7, 4), (7, 5),
(8, 1), (8, 2), (8, 4);

-- Insert comments
INSERT INTO comments (post_id, user_id, content, status) VALUES
(1, 2, 'Great article! Very helpful for beginners.', 'approved'),
(1, 3, 'Could you add more examples?', 'approved'),
(2, 1, 'Excellent overview of modern JS practices.', 'approved'),
(2, 4, 'What about async/await patterns?', 'pending'),
(3, 2, 'Docker has been a game-changer for our team.', 'approved'),
(3, 5, 'How does this compare to Kubernetes?', 'approved'),
(4, 1, 'React Hooks are amazing!', 'approved'),
(4, 3, 'Still learning hooks, this helps a lot.', 'approved'),
(5, 2, 'Database optimization is crucial for performance.', 'approved'),
(6, 4, 'Microservices are complex but worth it.', 'approved'),
(7, 1, 'TypeScript has saved us from many bugs.', 'approved'),
(8, 2, 'CI/CD is essential for modern development.', 'approved');



-- Write a query to get post view logs for a specific user with post title and user name
SELECT p.title, u.name FROM post_view_logs pl
JOIN posts p ON pl.post_id = p.id
JOIN users u ON pl.user_id = u.id
WHERE pl.user_id = 1;

-- Write a query to get all posts with their categories and authors
SELECT p.title, c.name, u.name FROM posts p
JOIN post_categories pc ON p.id = pc.post_id
JOIN categories c ON pc.category_id = c.id

SELECT * FROM posts p
JOIN post_views pv ON p.id = pv.id
JOIN users u ON p.author_id = u.id;

SELECT p.id, p.title AS post_title FROM posts p
JOIN post_views pv ON p.id = pv.id
JOIN users u ON p.author_id = u.id;

-- Cartesian product
SELECT * FROM users, posts;