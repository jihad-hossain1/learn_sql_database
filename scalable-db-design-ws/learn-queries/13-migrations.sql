-- Table

-- Create
CREATE TABLE users (
  id   SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

-- Rename
ALTER TABLE users RENAME TO customers;

-- Drop
DROP TABLE IF EXISTS customers;


-- Columns
ALTER TABLE users
  -- Add a column
  ADD COLUMN email TEXT UNIQUE,

  -- Drop a column
  DROP COLUMN last_login,

  -- Rename a column
  RENAME COLUMN name TO full_name,

  -- Change data type
  ALTER COLUMN email TYPE VARCHAR(255),

  -- Set or drop NOT NULL
  ALTER COLUMN email SET NOT NULL,
  ALTER COLUMN email DROP NOT NULL,

  -- Set default
  ALTER COLUMN created_at SET DEFAULT now(),
  ALTER COLUMN created_at DROP DEFAULT;


-- Constraints
ALTER TABLE users
  -- Add a CHECK
  ADD CONSTRAINT chk_email_format CHECK (email ~* '^[^@]+@[^@]+\.[^@]+$'),

  -- Drop a constraint
  DROP CONSTRAINT IF EXISTS chk_email_format,

  -- Rename a constraint
  RENAME CONSTRAINT users_pkey TO pk_users;

-- Foreign key
ALTER TABLE orders
  ADD CONSTRAINT fk_orders_user
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE;

-- Drop foreign key
ALTER TABLE orders
  DROP CONSTRAINT IF EXISTS fk_orders_user;


-- Index

-- Create a normal or unique index
CREATE INDEX idx_users_email ON users(email);
CREATE UNIQUE INDEX idx_users_email_uniq ON users(email);

-- Partial index
CREATE INDEX idx_active_users ON users(id) WHERE active;

-- Concurrently (no table lock)
CREATE INDEX CONCURRENTLY idx_orders_created_at
  ON orders(created_at);

-- Drop or rename
DROP INDEX IF EXISTS idx_users_email;
ALTER INDEX idx_users_email RENAME TO idx_customers_email;


-- Views

-- Create or replace
CREATE OR REPLACE VIEW user_summary AS
SELECT id, email, created_at FROM users WHERE active;

-- Drop or rename
DROP VIEW IF EXISTS user_summary;
ALTER VIEW user_summary RENAME TO active_user_summary;


-- Materialized views

-- Create
CREATE MATERIALIZED VIEW user_order_stats AS
SELECT user_id, COUNT(*) AS orders
FROM orders GROUP BY user_id;

-- Refresh (locking)
REFRESH MATERIALIZED VIEW user_order_stats;

-- Concurrent refresh (needs unique index)
REFRESH MATERIALIZED VIEW CONCURRENTLY user_order_stats;

-- Drop or rename
DROP MATERIALIZED VIEW IF EXISTS user_order_stats;
ALTER MATERIALIZED VIEW user_order_stats RENAME TO uos;


-- Functions

-- Create or replace
CREATE OR REPLACE FUNCTION audit_changes() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  -- body…
  RETURN NEW;
END;
$$;

-- Drop or rename
DROP FUNCTION IF EXISTS audit_changes();
ALTER FUNCTION audit_changes() RENAME TO audit_row_changes;


-- Triggers
-- Create
CREATE TRIGGER trg_audit
  AFTER INSERT OR UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION audit_changes();

-- Drop or rename
DROP TRIGGER IF EXISTS trg_audit ON users;
-- (No direct RENAME; you must drop & recreate with new name)


-- Sequences

-- Create
CREATE SEQUENCE order_seq START 1 INCREMENT 1;

-- Alter
ALTER SEQUENCE order_seq RESTART WITH 1000;

-- Rename, drop
ALTER SEQUENCE order_seq RENAME TO seq_orders;
DROP SEQUENCE IF EXISTS seq_orders;


-- Schemas

-- Create
CREATE SCHEMA analytics AUTHORIZATION app_user;

-- Alter (change owner)
ALTER SCHEMA analytics OWNER TO admin;

-- Rename, drop
ALTER SCHEMA analytics RENAME TO reports;
DROP SCHEMA IF EXISTS reports CASCADE;


-- Extensions

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
ALTER EXTENSION pgcrypto UPDATE TO "1.3";
DROP EXTENSION IF EXISTS pgcrypto CASCADE;


-- Types & Domains

-- ENUM type
CREATE TYPE mood AS ENUM ('sad','ok','happy');
ALTER TYPE mood ADD VALUE 'ecstatic';
ALTER TYPE mood RENAME TO emotional_state;
DROP TYPE IF EXISTS emotional_state;

-- Domain
CREATE DOMAIN email_addr AS TEXT
  CHECK (VALUE ~* '^[^@]+@[^@]+\.[^@]+$');

ALTER DOMAIN email_addr SET DEFAULT '';
DROP DOMAIN IF EXISTS email_addr;
