
-- Role enum
CREATE TYPE ROLE AS ENUM ('admin', 'user');

-- Create email type
CREATE DOMAIN email_addr AS TEXT
  CHECK (
    VALUE ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
  );


-- Create users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  -- email email_addr NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  bio TEXT,
  role ROLE NOT NULL DEFAULT 'user',
  profile_picture TEXT,
  dob DATE
);

-- Create posts table
CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  content TEXT,
  author_id INT NOT NULL REFERENCES users(id), -- Foreign key to users table
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  published_at TIMESTAMPTZ
);

-- Create post views table
CREATE TABLE post_views (
  id INT PRIMARY KEY REFERENCES posts(id), -- Foreign key to posts table
  count INT NOT NULL DEFAULT 0
);

-- Create post view logs table
CREATE TABLE post_view_logs (
  id SERIAL PRIMARY KEY,
  post_id INT NOT NULL REFERENCES posts(id), -- Foreign key to posts table
  user_id INT NOT NULL REFERENCES users(id), -- Foreign key to users table
  timestamp TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Categories table
CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT
);

-- Create post categories table
CREATE TABLE post_categories (
  post_id INT NOT NULL REFERENCES posts(id), -- Foreign key to posts table
  category_id INT NOT NULL REFERENCES categories(id), -- Foreign key to categories table
  PRIMARY KEY (post_id, category_id)
);

-- Comment status enum
CREATE TYPE COMMENT_STATUS AS ENUM ('pending', 'approved', 'rejected');

CREATE TABLE comments (
  id SERIAL PRIMARY KEY,
  post_id INT NOT NULL REFERENCES posts(id), -- Foreign key to posts table
  user_id INT NOT NULL REFERENCES users(id), -- Foreign key to users table
  content TEXT NOT NULL,
  status COMMENT_STATUS NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
