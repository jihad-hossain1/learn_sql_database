
-- ### What Is Partitioning?

-- Partitioning lets you:

-- - Improve query performance by scanning only relevant partitions
-- - Manage data lifecycle (e.g., drop old partitions quickly)
-- - Distribute I/O across tablespaces or disks

-- PostgreSQL implements **declarative partitioning** (since v10) on top of table inheritance, and automatically routes DML to the correct child.

-- ### Partitioning Methods

-- 1. **Range Partitioning:** Splits rows by a continuous range of values (e.g., dates, IDs).
-- 2. **List Partitioning:** Splits rows by enumerated values (e.g., country codes, status flags).
-- 3. **Hash Partitioning:** Uses a hash of a key to spread rows evenly across N partitions.
-- 4. **Composite:** Combination of Range/List and Hash

-- ### Advantages and Disadvantages

-- **Advantages**

-- - **Query Performance:** Scans only relevant partitions
-- - **Maintenance:** `DETACH` + `DROP` old partitions in seconds
-- - **Bulk Loads:** Ingest into a new partition, then `ATTACH`

-- **Disadvantages**

-- - **Complexity:** More objects to manage
-- - **Planner Overhead:** Too many partitions can slow planning
-- - **Constraint Enforcement:** Improper partition bounds cause misrouting

-- ### When to Partition

-- - **High Volume:** Hundreds of millions of rows per table
-- - **Time-Series Data:** Logs, metrics, audit trails by date
-- - **Data Retention Policies:** Easily drop old partitions
-- - **I/O Distribution:** Place hot partitions on fast storage, cold ones elsewhere

-- If you’re unsure, start with a non-partitioned design and migrate once growth demands it.



-- Create a table with a partition
CREATE TABLE events (
  id SERIAL,
  title VARCHAR(255) NOT NULL,
  event_date DATE NOT NULL,
  PRIMARY KEY (id, event_date)
) PARTITION BY RANGE (event_date);

-- Partitioned tables: This won't work 
CREATE TABLE events_2024_01
PARTITION OF events
FOR VALUES FROM ('2024-01-01') TO ('2024-01-31');

CREATE TABLE events_2024_02
PARTITION of events
FOR VALUES FROM ('2024-02-01') TO ('2024-02-29');

CREATE TABLE events_2024_03
PARTITION of events
FOR VALUES FROM ('2024-03-01') TO ('2024-03-31');

CREATE TABLE events_2024_04
PARTITION of events
FOR VALUES FROM ('2024-04-01') TO ('2024-04-30');

-- DROP Partitions
DROP TABLE events_2024_01;
DROP TABLE events_2024_02;
DROP TABLE events_2024_03;
DROP TABLE events_2024_04;

-- Partitioned tables: This will work 
CREATE TABLE events_2024_01
PARTITION OF events
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE events_2024_02
PARTITION of events
FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

CREATE TABLE events_2024_03
PARTITION of events
FOR VALUES FROM ('2024-03-01') TO ('2024-04-01');

CREATE TABLE events_2024_04
PARTITION of events
FOR VALUES FROM ('2024-04-01') TO ('2024-05-01');


-- Month function
CREATE OR REPLACE FUNCTION month_name_from_int(m integer)
  RETURNS text
  LANGUAGE sql
AS $$
  SELECT to_char(make_date(2000, m, 1), 'FMMonth');
$$;

-- Group by month and count the number of events: Basic
SELECT 
  DATE_TRUNC('month', event_date) as month,
  COUNT(*) as event_count
FROM events 
GROUP BY DATE_TRUNC('month', event_date)
ORDER BY month;

-- Group by month and count the number of events: Advanced
SELECT 
  EXTRACT(MONTH FROM event_date) as month_no,
  month_name_from_int(EXTRACT(MONTH FROM event_date)::INT) as month,
  COUNT(*) as event_count
FROM events 
GROUP BY month_no
ORDER BY month_no;

-- Events per day of the week
SELECT 
  EXTRACT(DOW FROM event_date) as day_of_week,
  COUNT(*) as event_count
FROM events 
GROUP BY EXTRACT(DOW FROM event_date)
ORDER BY day_of_week;

-- Most common event titles
SELECT title, COUNT(*) as frequency
FROM events 
GROUP BY title 
ORDER BY frequency DESC 
LIMIT 10;

-- Events happening on weekends
SELECT title, event_date
FROM events 
WHERE EXTRACT(DOW FROM event_date) IN (0, 6)  -- Sunday = 0, Saturday = 6
ORDER BY event_date;


-- Insert 200 events across the date range 2024-01-01 to 2024-04-30
INSERT INTO events (title, event_date) VALUES
('Team Meeting', '2024-01-01'),
('Product Launch', '2024-01-02'),
('Client Presentation', '2024-01-03'),
('Code Review', '2024-01-04'),
('Sprint Planning', '2024-01-05'),
('Database Optimization', '2024-01-06'),
('API Integration', '2024-01-07'),
('Security Audit', '2024-01-08'),
('Performance Testing', '2024-01-09'),
('User Training', '2024-01-10'),
('System Maintenance', '2024-01-11'),
('Backup Verification', '2024-01-12'),
('Deployment Review', '2024-01-13'),
('Bug Fix Session', '2024-01-14'),
('Feature Demo', '2024-01-15'),
('Architecture Review', '2024-01-16'),
('Load Testing', '2024-01-17'),
('Documentation Update', '2024-01-18'),
('Code Refactoring', '2024-01-19'),
('Monitoring Setup', '2024-01-20'),
('Data Migration', '2024-01-21'),
('Server Configuration', '2024-01-22'),
('Network Optimization', '2024-01-23'),
('Application Testing', '2024-01-24'),
('Release Planning', '2024-01-25'),
('Infrastructure Review', '2024-01-26'),
('Compliance Check', '2024-01-27'),
('Performance Monitoring', '2024-01-28'),
('Security Update', '2024-01-29'),
('Database Backup', '2024-01-30'),
('System Upgrade', '2024-01-31'),
('Team Retrospective', '2024-02-01'),
('Feature Planning', '2024-02-02'),
('Code Quality Review', '2024-02-03'),
('Integration Testing', '2024-02-04'),
('User Acceptance Testing', '2024-02-05'),
('Deployment Preparation', '2024-02-06'),
('Environment Setup', '2024-02-07'),
('Configuration Management', '2024-02-08'),
('Version Control Review', '2024-02-09'),
('API Documentation', '2024-02-10'),
('Database Schema Update', '2024-02-11'),
('Performance Optimization', '2024-02-12'),
('Security Assessment', '2024-02-13'),
('Load Balancing Setup', '2024-02-14'),
('Monitoring Alert Setup', '2024-02-15'),
('Backup Strategy Review', '2024-02-16'),
('Disaster Recovery Test', '2024-02-17'),
('System Health Check', '2024-02-18'),
('Network Security Audit', '2024-02-19'),
('Application Deployment', '2024-02-20'),
('Database Performance Tuning', '2024-02-21'),
('Code Deployment', '2024-02-22'),
('User Interface Testing', '2024-02-23'),
('Mobile App Testing', '2024-02-24'),
('Web Application Testing', '2024-02-25'),
('API Performance Test', '2024-02-26'),
('Database Migration', '2024-02-27'),
('Server Maintenance', '2024-02-28'),
('Cloud Infrastructure Setup', '2024-02-29'),
('DevOps Pipeline Review', '2024-03-01'),
('Continuous Integration Setup', '2024-03-02'),
('Automated Testing', '2024-03-03'),
('Release Management', '2024-03-04'),
('Quality Assurance Review', '2024-03-05'),
('User Experience Testing', '2024-03-06'),
('Accessibility Testing', '2024-03-07'),
('Cross-browser Testing', '2024-03-08'),
('Mobile Responsiveness Test', '2024-03-09'),
('Performance Benchmarking', '2024-03-10'),
('Security Vulnerability Scan', '2024-03-11'),
('Penetration Testing', '2024-03-12'),
('Data Encryption Review', '2024-03-13'),
('Authentication System Test', '2024-03-14'),
('Authorization Check', '2024-03-15'),
('Session Management Review', '2024-03-16'),
('Input Validation Testing', '2024-03-17'),
('SQL Injection Prevention', '2024-03-18'),
('XSS Protection Review', '2024-03-19'),
('CSRF Token Validation', '2024-03-20'),
('File Upload Security', '2024-03-21'),
('Error Handling Review', '2024-03-22'),
('Logging System Setup', '2024-03-23'),
('Audit Trail Implementation', '2024-03-24'),
('Compliance Documentation', '2024-03-25'),
('Data Privacy Review', '2024-03-26'),
('GDPR Compliance Check', '2024-03-27'),
('Data Retention Policy', '2024-03-28'),
('Backup Encryption', '2024-03-29'),
('Recovery Procedure Test', '2024-03-30'),
('Business Continuity Plan', '2024-03-31'),
('Scalability Assessment', '2024-04-01'),
('High Availability Setup', '2024-04-02'),
('Load Testing Review', '2024-04-03'),
('Stress Testing', '2024-04-04'),
('Capacity Planning', '2024-04-05'),
('Resource Optimization', '2024-04-06'),
('Memory Usage Analysis', '2024-04-07'),
('CPU Performance Review', '2024-04-08'),
('Disk Space Management', '2024-04-09'),
('Network Bandwidth Test', '2024-04-10'),
('Database Connection Pool', '2024-04-11'),
('Query Optimization', '2024-04-12'),
('Index Performance Review', '2024-04-13'),
('Cache Implementation', '2024-04-14'),
('CDN Configuration', '2024-04-15'),
('Content Delivery Optimization', '2024-04-16'),
('Image Optimization', '2024-04-17'),
('CSS Minification', '2024-04-18'),
('JavaScript Bundling', '2024-04-19'),
('Asset Compression', '2024-04-20'),
('Lazy Loading Implementation', '2024-04-21'),
('Progressive Web App Setup', '2024-04-22'),
('Service Worker Configuration', '2024-04-23'),
('Offline Functionality Test', '2024-04-24'),
('Push Notification Setup', '2024-04-25'),
('App Store Optimization', '2024-04-26'),
('Play Store Configuration', '2024-04-27'),
('Mobile App Deployment', '2024-04-28'),
('Web App Deployment', '2024-04-29'),
('Production Environment Setup', '2024-04-30'),
('Staging Environment Test', '2024-01-15'),
('Development Environment Setup', '2024-01-20'),
('Testing Environment Configuration', '2024-01-25'),
('QA Environment Review', '2024-02-10'),
('UAT Environment Setup', '2024-02-15'),
('Pre-production Testing', '2024-02-20'),
('Production Readiness Review', '2024-02-25'),
('Go-live Preparation', '2024-03-05'),
('Post-deployment Monitoring', '2024-03-10'),
('Performance Baseline', '2024-03-15'),
('User Feedback Collection', '2024-03-20'),
('Bug Tracking Setup', '2024-03-25'),
('Issue Resolution Process', '2024-03-30'),
('Support Ticket System', '2024-04-05'),
('Customer Service Training', '2024-04-10'),
('Technical Support Setup', '2024-04-15'),
('Knowledge Base Creation', '2024-04-20'),
('Documentation Review', '2024-04-25'),
('User Manual Update', '2024-04-30'),
('API Versioning Strategy', '2024-01-08'),
('Backward Compatibility Test', '2024-01-12'),
('Version Migration Plan', '2024-01-16'),
('Legacy System Integration', '2024-01-20'),
('Third-party API Integration', '2024-01-24'),
('Payment Gateway Setup', '2024-01-28'),
('Email Service Configuration', '2024-02-01'),
('SMS Gateway Integration', '2024-02-05'),
('Social Media Integration', '2024-02-09'),
('Analytics Setup', '2024-02-13'),
('Tracking Implementation', '2024-02-17'),
('Conversion Optimization', '2024-02-21'),
('A/B Testing Setup', '2024-02-25'),
('Multivariate Testing', '2024-03-01'),
('User Behavior Analysis', '2024-03-05');