-- Create user type enum
CREATE TYPE user_type AS ENUM ('freelancer', 'client');

-- Create account status enum
CREATE TYPE account_status AS ENUM ('active', 'inactive', 'suspended');

-- Create users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email TEXT UNIQUE NOT NULL, -- indexed
  password TEXT NOT NULL,
  user_type user_type NOT NULL DEFAULT 'freelancer', -- indexed
  account_status account_status NOT NULL DEFAULT 'active', -- indexed
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  average_rating DECIMAL(3, 2) DEFAULT 0.00
);

CREATE INDEX idx_users_email ON users(email); -- for login
CREATE INDEX idx_users_account_status ON users(account_status); -- for account management and filtering
CREATE INDEX idx_users_user_type ON users(user_type); -- for user type filtering

-- for user type and account status filtering
-- WHERE user_type = 'freelancer' AND account_status = 'active'
-- Could be important in our scenarios
CREATE INDEX idx_users_type_status ON users(user_type, account_status); 

-- Freelancer Profiles
CREATE TABLE freelancer_profiles (
  id INT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE, -- PK, FK to users
  name VARCHAR(100) NOT NULL,
  location TEXT NOT NULL, -- indexed
  hourly_rate DECIMAL(5, 2) NOT NULL DEFAULT 0.00, -- indexed
  is_available BOOLEAN NOT NULL DEFAULT TRUE, -- indexed
  portfolio JSONB,
  skills JSONB -- array of skill: Denormalized for fast lookup, indexed
);

-- find freelancers on dhaka
CREATE INDEX idx_freelancer_profiles_location ON freelancer_profiles(location);
-- Find freelancers under $50
CREATE INDEX idx_freelancer_profiles_hourly_rate ON freelancer_profiles(hourly_rate);
-- Find available freelancers
CREATE INDEX idx_freelancer_profiles_availability ON freelancer_profiles(is_available);
-- Find freelancers with specific skills
CREATE INDEX idx_freelancer_profiles_skills ON freelancer_profiles USING GIN(skills);

-- Clients Profiles
CREATE TABLE client_profiles (
  id INT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE, -- PK, FK to users
  company_name TEXT NOT NULL,
  description TEXT,
  location TEXT NOT NULL,
  contact_info JSONB -- email, phone, website
);

-- Find clients in Dhaka
CREATE INDEX idx_client_profiles_location ON client_profiles(location);

-- Categories
CREATE TABLE categories (
  id INT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT
);

-- Skills
CREATE TABLE skills (
  id INT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT
);

-- Jobs 

-- Budget type enum
CREATE TYPE budget_type AS ENUM ('fixed', 'hourly');

-- Job status enum
CREATE TYPE job_status AS ENUM ('open', 'in_progress', 'completed', 'closed');

-- Jobs table
CREATE TABLE jobs (
  id SERIAL PRIMARY KEY,
  client_id INT REFERENCES users(id) ON DELETE CASCADE, -- indexed
  title TEXT NOT NULL,
  description TEXT,
  category_id INT REFERENCES categories(id) ON DELETE SET NULL, -- indexed
  budget_type budget_type NOT NULL DEFAULT 'fixed',
  budget_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  deadline DATE,
  status job_status NOT NULL DEFAULT 'open', -- Indexed
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, -- partitioned
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  applications_count INT DEFAULT 0, -- Denormalized for fast lookup
  category_name TEXT -- Denormalized for fast lookup
);


-- Find jobs in a specific category
CREATE INDEX idx_jobs_category_id ON jobs(category_id);
-- Find jobs with a specific budget
CREATE INDEX idx_jobs_budget_amount ON jobs(budget_amount);
-- Find jobs with a specific status
CREATE INDEX idx_jobs_status ON jobs(status);
-- Find jobs with a specific client
CREATE INDEX idx_jobs_client_id ON jobs(client_id);

-- For advanced queries
CREATE INDEX idx_jobs_status_created_at ON jobs(status, created_at);
CREATE INDEX idx_jobs_client_id_status ON jobs(client_id, status);
CREATE INDEX idx_jobs_category_id_status ON jobs(category_id, status);
CREATE INDEX idx_jobs_status_budget_type_amount ON jobs(status, budget_type, budget_amount);

-- Job Skills
CREATE TABLE job_skills (
  job_id INT REFERENCES jobs(id) ON DELETE CASCADE,
  skill_id INT REFERENCES skills(id) ON DELETE CASCADE,
  PRIMARY KEY (job_id, skill_id)
);

-- Application status enum
CREATE TYPE application_status AS ENUM ('pending', 'accepted', 'rejected');

-- Applications Table
CREATE TABLE applications (
  id SERIAL PRIMARY KEY,
  job_id INT REFERENCES jobs(id) ON DELETE CASCADE, -- indexed
  freelancer_id INT REFERENCES users(id) ON DELETE CASCADE, -- indexed
  cover_letter TEXT,
  proposed_rate DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  status application_status NOT NULL DEFAULT 'pending',
  applied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_applications_job_id ON applications(job_id);
CREATE INDEX idx_applications_freelancer_id ON applications(freelancer_id);

-- Project status enum
CREATE TYPE project_status AS ENUM ('pending', 'in_progress', 'completed', 'cancelled');

-- Projects Table
CREATE TABLE projects (
  id SERIAL PRIMARY KEY,
  job_id INT REFERENCES jobs(id) ON DELETE CASCADE,
  freelancer_id INT REFERENCES users(id) ON DELETE CASCADE,
  status project_status NOT NULL DEFAULT 'pending',
  start_date DATE,
  end_date DATE,
  total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_projects_job_id ON projects(job_id);
CREATE INDEX idx_projects_freelancer_id ON projects(freelancer_id);
CREATE INDEX idx_projects_status ON projects(status);

-- Milestones status enum
CREATE TYPE milestone_status AS ENUM ('pending', 'completed', 'paid');

-- Milestones Table
CREATE TABLE milestones (
  id SERIAL PRIMARY KEY,
  project_id INT REFERENCES projects(id) ON DELETE CASCADE,
  description TEXT,
  due_date DATE,
  amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  status milestone_status NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_milestones_project_id ON milestones(project_id);

-- Messages Table
CREATE TABLE messages (
  id BIGSERIAL,
  sender_id INT REFERENCES users(id) ON DELETE CASCADE, -- indexed
  receiver_id INT REFERENCES users(id) ON DELETE CASCADE, -- indexed
  job_id INT REFERENCES jobs(id) ON DELETE CASCADE, -- indexed (optional)
  project_id INT REFERENCES projects(id) ON DELETE CASCADE, -- indexed (optional)
  content TEXT NOT NULL,
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, -- partitioned monthly
  PRIMARY KEY (id, sent_at)
) PARTITION BY RANGE(sent_at);

-- Partitioned by month
CREATE TABLE messages_partitioned_2025_01
PARTITION OF messages
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE messages_partitioned_2025_02
PARTITION OF messages
FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

CREATE TABLE messages_partitioned_2025_03
PARTITION OF messages
FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');

CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);

-- Notification table
CREATE TABLE notifications (
  id BIGSERIAL,
  user_id INT REFERENCES users(id) ON DELETE CASCADE, -- indexed
  type TEXT,
  content TEXT,
  is_read BOOLEAN NOT NULL DEFAULT FALSE, -- indexed
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, -- partitioned monthly / weekly / daily
  PRIMARY KEY (id, created_at)
) PARTITION BY RANGE(created_at);

-- Partitioned by month
CREATE TABLE notifications_partitioned_2025_01
PARTITION OF notifications
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE notifications_partitioned_2025_02
PARTITION OF notifications
FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

CREATE TABLE notifications_partitioned_2025_03
PARTITION OF notifications
FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- Reviews Table
CREATE TABLE reviews (
  id SERIAL PRIMARY KEY,
  project_id INT REFERENCES projects(id) ON DELETE CASCADE,
  reviewer_id INT REFERENCES users(id) ON DELETE CASCADE,
  reviewee_id INT REFERENCES users(id) ON DELETE CASCADE, -- indexed for average rating
  rating DECIMAL(3, 2) NOT NULL DEFAULT 0.00,
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_reviews_reviewee_id ON reviews(reviewee_id);

-- Freelancer skills table
CREATE TABLE freelancer_skills (
  freelancer_id INT REFERENCES users(id) ON DELETE CASCADE,
  skill_id INT REFERENCES skills(id) ON DELETE CASCADE,
  PRIMARY KEY (freelancer_id, skill_id)
);