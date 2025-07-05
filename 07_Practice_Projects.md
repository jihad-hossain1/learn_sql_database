# SQL Database Learning Guide - Part 7: Practice Projects

## Table of Contents
1. [Project 1: E-commerce Database](#project-1-e-commerce-database)
2. [Project 2: Library Management System](#project-2-library-management-system)
3. [Project 3: Employee Management System](#project-3-employee-management-system)
4. [Project 4: Social Media Analytics](#project-4-social-media-analytics)
5. [Project 5: Financial Transaction System](#project-5-financial-transaction-system)
6. [Project 6: Hospital Management System](#project-6-hospital-management-system)
7. [Advanced Challenges](#advanced-challenges)
8. [Real-World Scenarios](#real-world-scenarios)

---

## Project 1: E-commerce Database

### Project Overview
Design and implement a complete e-commerce database system with products, customers, orders, and inventory management.

### Database Schema
```sql
-- Create database
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- Categories table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- Products table
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    description TEXT,
    category_id INT NOT NULL,
    brand VARCHAR(100),
    sku VARCHAR(50) UNIQUE NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    cost_price DECIMAL(10,2),
    weight DECIMAL(8,3),
    dimensions JSON,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    INDEX idx_category (category_id),
    INDEX idx_sku (sku),
    INDEX idx_price (price),
    INDEX idx_brand (brand)
);

-- Product variants (for size, color, etc.)
CREATE TABLE product_variants (
    variant_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    variant_name VARCHAR(100) NOT NULL,
    variant_value VARCHAR(100) NOT NULL,
    price_adjustment DECIMAL(10,2) DEFAULT 0,
    sku_suffix VARCHAR(20),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_variant (product_id, variant_name, variant_value)
);

-- Inventory table
CREATE TABLE inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    variant_combination JSON, -- Store variant combinations
    quantity_available INT NOT NULL DEFAULT 0,
    quantity_reserved INT NOT NULL DEFAULT 0,
    reorder_level INT DEFAULT 10,
    warehouse_location VARCHAR(100),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    INDEX idx_product (product_id),
    INDEX idx_quantity (quantity_available)
);

-- Customers table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    gender ENUM('M', 'F', 'Other'),
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_name (last_name, first_name)
);

-- Customer addresses
CREATE TABLE customer_addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    address_type ENUM('billing', 'shipping', 'both') DEFAULT 'both',
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    company VARCHAR(100),
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    INDEX idx_customer (customer_id)
);

-- Orders table
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INT NOT NULL,
    order_status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded') DEFAULT 'pending',
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    subtotal DECIMAL(12,2) NOT NULL,
    tax_amount DECIMAL(12,2) DEFAULT 0,
    shipping_amount DECIMAL(12,2) DEFAULT 0,
    discount_amount DECIMAL(12,2) DEFAULT 0,
    total_amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    billing_address_id INT,
    shipping_address_id INT,
    notes TEXT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    shipped_date TIMESTAMP NULL,
    delivered_date TIMESTAMP NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (billing_address_id) REFERENCES customer_addresses(address_id),
    FOREIGN KEY (shipping_address_id) REFERENCES customer_addresses(address_id),
    INDEX idx_customer (customer_id),
    INDEX idx_order_date (order_date),
    INDEX idx_status (order_status),
    INDEX idx_order_number (order_number)
);

-- Order items table
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    variant_combination JSON,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    INDEX idx_order (order_id),
    INDEX idx_product (product_id)
);

-- Shopping cart table
CREATE TABLE shopping_cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    variant_combination JSON,
    quantity INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    UNIQUE KEY unique_cart_item (customer_id, product_id, variant_combination(255)),
    INDEX idx_customer (customer_id)
);

-- Product reviews table
CREATE TABLE product_reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    order_id INT,
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(200),
    review_text TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT FALSE,
    helpful_votes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    UNIQUE KEY unique_customer_product_review (customer_id, product_id, order_id),
    INDEX idx_product (product_id),
    INDEX idx_rating (rating)
);
```

### Sample Data
```sql
-- Insert sample categories
INSERT INTO categories (category_name, description) VALUES
('Electronics', 'Electronic devices and accessories'),
('Clothing', 'Apparel and fashion items'),
('Books', 'Books and educational materials'),
('Home & Garden', 'Home improvement and garden supplies'),
('Sports', 'Sports equipment and accessories');

INSERT INTO categories (category_name, description, parent_category_id) VALUES
('Smartphones', 'Mobile phones and accessories', 1),
('Laptops', 'Portable computers', 1),
('Men\'s Clothing', 'Clothing for men', 2),
('Women\'s Clothing', 'Clothing for women', 2);

-- Insert sample products
INSERT INTO products (product_name, description, category_id, brand, sku, price, cost_price, weight) VALUES
('iPhone 15 Pro', 'Latest iPhone with advanced features', 6, 'Apple', 'IPH15PRO', 999.99, 600.00, 0.221),
('MacBook Air M2', '13-inch laptop with M2 chip', 7, 'Apple', 'MBA13M2', 1199.99, 800.00, 1.24),
('Samsung Galaxy S24', 'Android smartphone with AI features', 6, 'Samsung', 'SGS24', 799.99, 500.00, 0.196),
('Men\'s Cotton T-Shirt', 'Comfortable cotton t-shirt', 8, 'BasicWear', 'MCT001', 19.99, 8.00, 0.2),
('Women\'s Denim Jeans', 'Classic blue denim jeans', 9, 'FashionPlus', 'WDJ001', 59.99, 25.00, 0.6);

-- Insert product variants
INSERT INTO product_variants (product_id, variant_name, variant_value, price_adjustment) VALUES
(1, 'Storage', '128GB', 0),
(1, 'Storage', '256GB', 100),
(1, 'Storage', '512GB', 300),
(1, 'Color', 'Natural Titanium', 0),
(1, 'Color', 'Blue Titanium', 0),
(1, 'Color', 'White Titanium', 0),
(4, 'Size', 'S', 0),
(4, 'Size', 'M', 0),
(4, 'Size', 'L', 0),
(4, 'Size', 'XL', 2),
(4, 'Color', 'White', 0),
(4, 'Color', 'Black', 0),
(4, 'Color', 'Navy', 0);

-- Insert inventory
INSERT INTO inventory (product_id, variant_combination, quantity_available, reorder_level, warehouse_location) VALUES
(1, '{"Storage": "128GB", "Color": "Natural Titanium"}', 50, 10, 'Warehouse A'),
(1, '{"Storage": "256GB", "Color": "Blue Titanium"}', 30, 10, 'Warehouse A'),
(2, '{}', 25, 5, 'Warehouse B'),
(3, '{}', 40, 15, 'Warehouse A'),
(4, '{"Size": "M", "Color": "White"}', 100, 20, 'Warehouse C'),
(4, '{"Size": "L", "Color": "Black"}', 75, 20, 'Warehouse C'),
(5, '{"Size": "32", "Color": "Blue"}', 60, 15, 'Warehouse C');

-- Insert sample customers
INSERT INTO customers (email, password_hash, first_name, last_name, phone, email_verified) VALUES
('john.doe@email.com', 'hashed_password_1', 'John', 'Doe', '+1234567890', TRUE),
('jane.smith@email.com', 'hashed_password_2', 'Jane', 'Smith', '+1234567891', TRUE),
('bob.wilson@email.com', 'hashed_password_3', 'Bob', 'Wilson', '+1234567892', FALSE);

-- Insert customer addresses
INSERT INTO customer_addresses (customer_id, address_type, first_name, last_name, address_line1, city, state, postal_code, country, is_default) VALUES
(1, 'both', 'John', 'Doe', '123 Main St', 'New York', 'NY', '10001', 'USA', TRUE),
(2, 'both', 'Jane', 'Smith', '456 Oak Ave', 'Los Angeles', 'CA', '90210', 'USA', TRUE),
(3, 'both', 'Bob', 'Wilson', '789 Pine Rd', 'Chicago', 'IL', '60601', 'USA', TRUE);
```

### Practice Queries
```sql
-- 1. Product catalog with category information
SELECT 
    p.product_id,
    p.product_name,
    p.brand,
    p.price,
    c.category_name,
    parent_c.category_name as parent_category,
    COALESCE(SUM(i.quantity_available), 0) as total_stock
FROM products p
JOIN categories c ON p.category_id = c.category_id
LEFT JOIN categories parent_c ON c.parent_category_id = parent_c.category_id
LEFT JOIN inventory i ON p.product_id = i.product_id
WHERE p.is_active = TRUE
GROUP BY p.product_id, p.product_name, p.brand, p.price, c.category_name, parent_c.category_name
ORDER BY c.category_name, p.product_name;

-- 2. Customer order history with totals
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    AVG(o.total_amount) as avg_order_value,
    MAX(o.order_date) as last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- 3. Product performance analysis
SELECT 
    p.product_id,
    p.product_name,
    p.brand,
    COUNT(oi.order_item_id) as times_ordered,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.total_price) as total_revenue,
    AVG(pr.rating) as avg_rating,
    COUNT(pr.review_id) as review_count
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN product_reviews pr ON p.product_id = pr.product_id AND pr.is_approved = TRUE
GROUP BY p.product_id, p.product_name, p.brand
HAVING times_ordered > 0
ORDER BY total_revenue DESC;

-- 4. Inventory alerts (low stock)
SELECT 
    p.product_name,
    p.sku,
    i.variant_combination,
    i.quantity_available,
    i.reorder_level,
    i.warehouse_location,
    (i.reorder_level - i.quantity_available) as shortage
FROM inventory i
JOIN products p ON i.product_id = p.product_id
WHERE i.quantity_available <= i.reorder_level
ORDER BY shortage DESC;

-- 5. Monthly sales report
SELECT 
    YEAR(o.order_date) as year,
    MONTH(o.order_date) as month,
    MONTHNAME(o.order_date) as month_name,
    COUNT(o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value
FROM orders o
WHERE o.order_status NOT IN ('cancelled', 'refunded')
GROUP BY YEAR(o.order_date), MONTH(o.order_date)
ORDER BY year DESC, month DESC;

-- 6. Customer segmentation by purchase behavior
SELECT 
    customer_segment,
    COUNT(*) as customer_count,
    AVG(total_spent) as avg_total_spent,
    AVG(order_count) as avg_order_count
FROM (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) as customer_name,
        COALESCE(SUM(o.total_amount), 0) as total_spent,
        COUNT(o.order_id) as order_count,
        CASE 
            WHEN COALESCE(SUM(o.total_amount), 0) >= 1000 THEN 'High Value'
            WHEN COALESCE(SUM(o.total_amount), 0) >= 500 THEN 'Medium Value'
            WHEN COALESCE(SUM(o.total_amount), 0) > 0 THEN 'Low Value'
            ELSE 'No Purchase'
        END as customer_segment
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id 
        AND o.order_status NOT IN ('cancelled', 'refunded')
    GROUP BY c.customer_id, c.first_name, c.last_name
) customer_analysis
GROUP BY customer_segment
ORDER BY avg_total_spent DESC;
```

### Advanced Features
```sql
-- Create stored procedure for order processing
DELIMITER //

CREATE PROCEDURE ProcessOrder(
    IN p_customer_id INT,
    IN p_billing_address_id INT,
    IN p_shipping_address_id INT,
    OUT p_order_id INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    DECLARE v_order_number VARCHAR(50);
    DECLARE v_subtotal DECIMAL(12,2) DEFAULT 0;
    DECLARE v_tax_rate DECIMAL(5,4) DEFAULT 0.0875; -- 8.75% tax
    DECLARE v_tax_amount DECIMAL(12,2);
    DECLARE v_shipping_amount DECIMAL(12,2) DEFAULT 9.99;
    DECLARE v_total_amount DECIMAL(12,2);
    DECLARE v_cart_count INT DEFAULT 0;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_message = 'Error processing order';
        SET p_order_id = NULL;
    END;
    
    START TRANSACTION;
    
    -- Check if customer has items in cart
    SELECT COUNT(*) INTO v_cart_count
    FROM shopping_cart
    WHERE customer_id = p_customer_id;
    
    IF v_cart_count = 0 THEN
        SET p_result_message = 'Shopping cart is empty';
        SET p_order_id = NULL;
        ROLLBACK;
    ELSE
        -- Generate order number
        SET v_order_number = CONCAT('ORD', YEAR(NOW()), MONTH(NOW()), DAY(NOW()), '-', LPAD(FLOOR(RAND() * 10000), 4, '0'));
        
        -- Calculate subtotal
        SELECT SUM(p.price * sc.quantity) INTO v_subtotal
        FROM shopping_cart sc
        JOIN products p ON sc.product_id = p.product_id
        WHERE sc.customer_id = p_customer_id;
        
        -- Calculate tax and total
        SET v_tax_amount = v_subtotal * v_tax_rate;
        SET v_total_amount = v_subtotal + v_tax_amount + v_shipping_amount;
        
        -- Create order
        INSERT INTO orders (
            order_number, customer_id, subtotal, tax_amount, 
            shipping_amount, total_amount, billing_address_id, shipping_address_id
        ) VALUES (
            v_order_number, p_customer_id, v_subtotal, v_tax_amount,
            v_shipping_amount, v_total_amount, p_billing_address_id, p_shipping_address_id
        );
        
        SET p_order_id = LAST_INSERT_ID();
        
        -- Move cart items to order items
        INSERT INTO order_items (order_id, product_id, variant_combination, quantity, unit_price, total_price)
        SELECT 
            p_order_id,
            sc.product_id,
            sc.variant_combination,
            sc.quantity,
            p.price,
            p.price * sc.quantity
        FROM shopping_cart sc
        JOIN products p ON sc.product_id = p.product_id
        WHERE sc.customer_id = p_customer_id;
        
        -- Update inventory
        UPDATE inventory i
        JOIN shopping_cart sc ON i.product_id = sc.product_id 
            AND JSON_EXTRACT(i.variant_combination, '$') = JSON_EXTRACT(sc.variant_combination, '$')
        SET i.quantity_available = i.quantity_available - sc.quantity
        WHERE sc.customer_id = p_customer_id;
        
        -- Clear shopping cart
        DELETE FROM shopping_cart WHERE customer_id = p_customer_id;
        
        SET p_result_message = CONCAT('Order created successfully: ', v_order_number);
        
        COMMIT;
    END IF;
END //

DELIMITER ;

-- Create function to calculate product rating
DELIMITER //

CREATE FUNCTION GetProductRating(p_product_id INT)
RETURNS DECIMAL(3,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_rating DECIMAL(3,2) DEFAULT 0;
    
    SELECT COALESCE(AVG(rating), 0) INTO v_rating
    FROM product_reviews
    WHERE product_id = p_product_id AND is_approved = TRUE;
    
    RETURN v_rating;
END //

DELIMITER ;

-- Create view for product catalog with ratings
CREATE VIEW product_catalog AS
SELECT 
    p.product_id,
    p.product_name,
    p.description,
    p.brand,
    p.sku,
    p.price,
    c.category_name,
    GetProductRating(p.product_id) as avg_rating,
    COUNT(pr.review_id) as review_count,
    COALESCE(SUM(i.quantity_available), 0) as stock_quantity,
    CASE 
        WHEN COALESCE(SUM(i.quantity_available), 0) > 0 THEN 'In Stock'
        ELSE 'Out of Stock'
    END as stock_status
FROM products p
JOIN categories c ON p.category_id = c.category_id
LEFT JOIN product_reviews pr ON p.product_id = pr.product_id AND pr.is_approved = TRUE
LEFT JOIN inventory i ON p.product_id = i.product_id
WHERE p.is_active = TRUE
GROUP BY p.product_id, p.product_name, p.description, p.brand, p.sku, p.price, c.category_name;
```

---

## Project 2: Library Management System

### Project Overview
Create a comprehensive library management system to handle books, members, borrowing, and returns.

### Database Schema
```sql
CREATE DATABASE library_db;
USE library_db;

-- Authors table
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    death_date DATE,
    nationality VARCHAR(100),
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_name (last_name, first_name)
);

-- Publishers table
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(200) NOT NULL UNIQUE,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(200),
    established_year YEAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INT,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- Books table
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(17) UNIQUE NOT NULL,
    title VARCHAR(300) NOT NULL,
    subtitle VARCHAR(300),
    publisher_id INT,
    publication_date DATE,
    edition VARCHAR(50),
    pages INT,
    language VARCHAR(50) DEFAULT 'English',
    description TEXT,
    category_id INT,
    location_code VARCHAR(20), -- Library shelf location
    acquisition_date DATE,
    acquisition_cost DECIMAL(8,2),
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    INDEX idx_isbn (isbn),
    INDEX idx_title (title),
    INDEX idx_category (category_id),
    INDEX idx_location (location_code),
    FULLTEXT idx_search (title, subtitle, description)
);

-- Book authors junction table (many-to-many)
CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    author_order TINYINT DEFAULT 1,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

-- Book copies table
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    copy_number VARCHAR(20) NOT NULL,
    condition_status ENUM('excellent', 'good', 'fair', 'poor', 'damaged') DEFAULT 'good',
    acquisition_date DATE,
    is_available BOOLEAN DEFAULT TRUE,
    notes TEXT,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    UNIQUE KEY unique_copy (book_id, copy_number),
    INDEX idx_book (book_id),
    INDEX idx_available (is_available)
);

-- Members table
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    member_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    date_of_birth DATE,
    membership_type ENUM('student', 'faculty', 'staff', 'public') NOT NULL,
    membership_start_date DATE NOT NULL,
    membership_end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    max_books_allowed INT DEFAULT 5,
    fine_balance DECIMAL(8,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_member_number (member_number),
    INDEX idx_email (email),
    INDEX idx_name (last_name, first_name),
    INDEX idx_membership_type (membership_type)
);

-- Borrowing transactions table
CREATE TABLE borrowing_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    copy_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    renewal_count INT DEFAULT 0,
    status ENUM('borrowed', 'returned', 'overdue', 'lost') DEFAULT 'borrowed',
    librarian_id INT, -- Staff member who processed the transaction
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id),
    INDEX idx_member (member_id),
    INDEX idx_copy (copy_id),
    INDEX idx_borrow_date (borrow_date),
    INDEX idx_due_date (due_date),
    INDEX idx_status (status)
);

-- Fines table
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NOT NULL,
    member_id INT NOT NULL,
    fine_type ENUM('overdue', 'damage', 'lost_book') NOT NULL,
    amount DECIMAL(8,2) NOT NULL,
    description TEXT,
    fine_date DATE NOT NULL,
    payment_date DATE NULL,
    payment_method ENUM('cash', 'card', 'online', 'waived') NULL,
    status ENUM('pending', 'paid', 'waived') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES borrowing_transactions(transaction_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    INDEX idx_member (member_id),
    INDEX idx_status (status),
    INDEX idx_fine_date (fine_date)
);

-- Reservations table
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    status ENUM('active', 'fulfilled', 'expired', 'cancelled') DEFAULT 'active',
    notification_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    INDEX idx_member (member_id),
    INDEX idx_book (book_id),
    INDEX idx_status (status),
    INDEX idx_reservation_date (reservation_date)
);

-- Staff table
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    position VARCHAR(100),
    department VARCHAR(100),
    hire_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Sample Data and Queries
```sql
-- Insert sample data
INSERT INTO categories (category_name, description) VALUES
('Fiction', 'Fictional literature'),
('Non-Fiction', 'Factual and educational books'),
('Science', 'Scientific literature'),
('History', 'Historical books and documents'),
('Technology', 'Computer science and technology'),
('Biography', 'Life stories of notable people');

INSERT INTO authors (first_name, last_name, birth_date, nationality) VALUES
('George', 'Orwell', '1903-06-25', 'British'),
('Jane', 'Austen', '1775-12-16', 'British'),
('Mark', 'Twain', '1835-11-30', 'American'),
('Agatha', 'Christie', '1890-09-15', 'British'),
('Isaac', 'Asimov', '1920-01-02', 'American');

INSERT INTO publishers (publisher_name, established_year) VALUES
('Penguin Random House', 1927),
('HarperCollins', 1989),
('Simon & Schuster', 1924),
('Macmillan', 1843),
('Oxford University Press', 1586);

-- Complex queries for library management

-- 1. Book availability report
SELECT 
    b.book_id,
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) as author,
    c.category_name,
    COUNT(bc.copy_id) as total_copies,
    SUM(CASE WHEN bc.is_available = TRUE THEN 1 ELSE 0 END) as available_copies,
    COUNT(bt.transaction_id) as currently_borrowed
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id
JOIN categories c ON b.category_id = c.category_id
LEFT JOIN book_copies bc ON b.book_id = bc.book_id
LEFT JOIN borrowing_transactions bt ON bc.copy_id = bt.copy_id AND bt.status = 'borrowed'
GROUP BY b.book_id, b.title, a.first_name, a.last_name, c.category_name
ORDER BY b.title;

-- 2. Overdue books report
SELECT 
    bt.transaction_id,
    CONCAT(m.first_name, ' ', m.last_name) as member_name,
    m.member_number,
    m.email,
    b.title,
    bt.borrow_date,
    bt.due_date,
    DATEDIFF(CURDATE(), bt.due_date) as days_overdue,
    CASE 
        WHEN DATEDIFF(CURDATE(), bt.due_date) <= 7 THEN 5.00
        WHEN DATEDIFF(CURDATE(), bt.due_date) <= 14 THEN 10.00
        ELSE 15.00
    END as fine_amount
FROM borrowing_transactions bt
JOIN members m ON bt.member_id = m.member_id
JOIN book_copies bc ON bt.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id
WHERE bt.status = 'borrowed' 
    AND bt.due_date < CURDATE()
ORDER BY days_overdue DESC;

-- 3. Member borrowing history
SELECT 
    m.member_id,
    CONCAT(m.first_name, ' ', m.last_name) as member_name,
    m.membership_type,
    COUNT(bt.transaction_id) as total_books_borrowed,
    COUNT(CASE WHEN bt.status = 'borrowed' THEN 1 END) as currently_borrowed,
    COUNT(CASE WHEN bt.return_date > bt.due_date THEN 1 END) as late_returns,
    SUM(f.amount) as total_fines,
    MAX(bt.borrow_date) as last_borrow_date
FROM members m
LEFT JOIN borrowing_transactions bt ON m.member_id = bt.member_id
LEFT JOIN fines f ON m.member_id = f.member_id AND f.status = 'pending'
WHERE m.is_active = TRUE
GROUP BY m.member_id, m.first_name, m.last_name, m.membership_type
ORDER BY total_books_borrowed DESC;

-- 4. Popular books report
SELECT 
    b.book_id,
    b.title,
    GROUP_CONCAT(CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') as authors,
    c.category_name,
    COUNT(bt.transaction_id) as borrow_count,
    AVG(DATEDIFF(COALESCE(bt.return_date, CURDATE()), bt.borrow_date)) as avg_borrow_duration
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id
JOIN categories c ON b.category_id = c.category_id
JOIN book_copies bc ON b.book_id = bc.book_id
JOIN borrowing_transactions bt ON bc.copy_id = bt.copy_id
WHERE bt.borrow_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY b.book_id, b.title, c.category_name
HAVING borrow_count >= 3
ORDER BY borrow_count DESC, avg_borrow_duration ASC;

-- 5. Library statistics dashboard
SELECT 
    'Total Books' as metric,
    COUNT(*) as value
FROM books
UNION ALL
SELECT 
    'Total Copies',
    COUNT(*)
FROM book_copies
UNION ALL
SELECT 
    'Active Members',
    COUNT(*)
FROM members WHERE is_active = TRUE
UNION ALL
SELECT 
    'Books Currently Borrowed',
    COUNT(*)
FROM borrowing_transactions WHERE status = 'borrowed'
UNION ALL
SELECT 
    'Overdue Books',
    COUNT(*)
FROM borrowing_transactions 
WHERE status = 'borrowed' AND due_date < CURDATE()
UNION ALL
SELECT 
    'Pending Fines ($)',
    ROUND(SUM(amount), 2)
FROM fines WHERE status = 'pending';
```

### Stored Procedures for Library Operations
```sql
-- Procedure to borrow a book
DELIMITER //

CREATE PROCEDURE BorrowBook(
    IN p_member_id INT,
    IN p_book_id INT,
    IN p_librarian_id INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    DECLARE v_available_copy_id INT DEFAULT NULL;
    DECLARE v_member_book_count INT DEFAULT 0;
    DECLARE v_max_books INT DEFAULT 0;
    DECLARE v_has_overdue BOOLEAN DEFAULT FALSE;
    DECLARE v_due_date DATE;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_message = 'Error processing book borrowing';
    END;
    
    START TRANSACTION;
    
    -- Check if member exists and is active
    SELECT max_books_allowed INTO v_max_books
    FROM members
    WHERE member_id = p_member_id AND is_active = TRUE;
    
    IF v_max_books IS NULL THEN
        SET p_result_message = 'Member not found or inactive';
        ROLLBACK;
    ELSE
        -- Check current borrowed books count
        SELECT COUNT(*) INTO v_member_book_count
        FROM borrowing_transactions
        WHERE member_id = p_member_id AND status = 'borrowed';
        
        -- Check for overdue books
        SELECT COUNT(*) > 0 INTO v_has_overdue
        FROM borrowing_transactions
        WHERE member_id = p_member_id 
            AND status = 'borrowed' 
            AND due_date < CURDATE();
        
        IF v_member_book_count >= v_max_books THEN
            SET p_result_message = 'Member has reached maximum book limit';
            ROLLBACK;
        ELSEIF v_has_overdue THEN
            SET p_result_message = 'Member has overdue books. Please return them first';
            ROLLBACK;
        ELSE
            -- Find available copy
            SELECT bc.copy_id INTO v_available_copy_id
            FROM book_copies bc
            WHERE bc.book_id = p_book_id 
                AND bc.is_available = TRUE
                AND bc.condition_status NOT IN ('damaged', 'poor')
            LIMIT 1;
            
            IF v_available_copy_id IS NULL THEN
                SET p_result_message = 'No available copies of this book';
                ROLLBACK;
            ELSE
                -- Calculate due date (14 days from now)
                SET v_due_date = DATE_ADD(CURDATE(), INTERVAL 14 DAY);
                
                -- Create borrowing transaction
                INSERT INTO borrowing_transactions (
                    member_id, copy_id, borrow_date, due_date, librarian_id
                ) VALUES (
                    p_member_id, v_available_copy_id, CURDATE(), v_due_date, p_librarian_id
                );
                
                -- Update copy availability
                UPDATE book_copies
                SET is_available = FALSE
                WHERE copy_id = v_available_copy_id;
                
                SET p_result_message = CONCAT('Book borrowed successfully. Due date: ', v_due_date);
                COMMIT;
            END IF;
        END IF;
    END IF;
END //

DELIMITER ;

-- Procedure to return a book
DELIMITER //

CREATE PROCEDURE ReturnBook(
    IN p_transaction_id INT,
    IN p_condition_status ENUM('excellent', 'good', 'fair', 'poor', 'damaged'),
    IN p_librarian_id INT,
    OUT p_result_message VARCHAR(255)
)
BEGIN
    DECLARE v_copy_id INT;
    DECLARE v_member_id INT;
    DECLARE v_due_date DATE;
    DECLARE v_days_overdue INT DEFAULT 0;
    DECLARE v_fine_amount DECIMAL(8,2) DEFAULT 0;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result_message = 'Error processing book return';
    END;
    
    START TRANSACTION;
    
    -- Get transaction details
    SELECT copy_id, member_id, due_date
    INTO v_copy_id, v_member_id, v_due_date
    FROM borrowing_transactions
    WHERE transaction_id = p_transaction_id AND status = 'borrowed';
    
    IF v_copy_id IS NULL THEN
        SET p_result_message = 'Transaction not found or book already returned';
        ROLLBACK;
    ELSE
        -- Calculate overdue days and fine
        SET v_days_overdue = GREATEST(0, DATEDIFF(CURDATE(), v_due_date));
        
        IF v_days_overdue > 0 THEN
            SET v_fine_amount = CASE 
                WHEN v_days_overdue <= 7 THEN 5.00
                WHEN v_days_overdue <= 14 THEN 10.00
                ELSE 15.00
            END;
            
            -- Create fine record
            INSERT INTO fines (
                transaction_id, member_id, fine_type, amount, 
                description, fine_date
            ) VALUES (
                p_transaction_id, v_member_id, 'overdue', v_fine_amount,
                CONCAT('Overdue fine for ', v_days_overdue, ' days'), CURDATE()
            );
        END IF;
        
        -- Update transaction
        UPDATE borrowing_transactions
        SET status = 'returned', return_date = CURDATE()
        WHERE transaction_id = p_transaction_id;
        
        -- Update copy availability and condition
        UPDATE book_copies
        SET is_available = TRUE, condition_status = p_condition_status
        WHERE copy_id = v_copy_id;
        
        -- Update member fine balance
        UPDATE members
        SET fine_balance = fine_balance + v_fine_amount
        WHERE member_id = v_member_id;
        
        SET p_result_message = CONCAT(
            'Book returned successfully. ',
            CASE WHEN v_fine_amount > 0 
                THEN CONCAT('Fine applied: $', v_fine_amount)
                ELSE 'No fine applied'
            END
        );
        
        COMMIT;
    END IF;
END //

DELIMITER ;
```

---

## Project 3: Employee Management System

### Project Overview
Develop a comprehensive HR system for managing employees, departments, payroll, and performance.

### Database Schema
```sql
CREATE DATABASE hr_management;
USE hr_management;

-- Departments table
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    department_code VARCHAR(10) UNIQUE,
    description TEXT,
    manager_id INT,
    budget DECIMAL(15,2),
    location VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_manager (manager_id)
);

-- Job positions table
CREATE TABLE job_positions (
    position_id INT AUTO_INCREMENT PRIMARY KEY,
    position_title VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    job_level ENUM('entry', 'junior', 'mid', 'senior', 'lead', 'manager', 'director', 'executive'),
    min_salary DECIMAL(12,2),
    max_salary DECIMAL(12,2),
    job_description TEXT,
    requirements TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    INDEX idx_department (department_id),
    INDEX idx_level (job_level)
);

-- Employees table
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    gender ENUM('M', 'F', 'Other'),
    address TEXT,
    emergency_contact_name VARCHAR(200),
    emergency_contact_phone VARCHAR(20),
    hire_date DATE NOT NULL,
    termination_date DATE NULL,
    employment_status ENUM('active', 'inactive', 'terminated', 'on_leave') DEFAULT 'active',
    position_id INT NOT NULL,
    manager_id INT,
    salary DECIMAL(12,2) NOT NULL,
    salary_currency VARCHAR(3) DEFAULT 'USD',
    work_location ENUM('office', 'remote', 'hybrid') DEFAULT 'office',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (position_id) REFERENCES job_positions(position_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id),
    INDEX idx_employee_number (employee_number),
    INDEX idx_email (email),
    INDEX idx_name (last_name, first_name),
    INDEX idx_position (position_id),
    INDEX idx_manager (manager_id),
    INDEX idx_hire_date (hire_date),
    INDEX idx_status (employment_status)
);

-- Add foreign key for department manager
ALTER TABLE departments 
ADD FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

-- Employee benefits table
CREATE TABLE benefits (
    benefit_id INT AUTO_INCREMENT PRIMARY KEY,
    benefit_name VARCHAR(100) NOT NULL,
    benefit_type ENUM('health', 'dental', 'vision', 'retirement', 'life_insurance', 'disability', 'other'),
    description TEXT,
    employer_contribution_percent DECIMAL(5,2),
    employee_contribution_percent DECIMAL(5,2),
    is_active BOOLEAN DEFAULT TRUE
);

-- Employee benefits enrollment
CREATE TABLE employee_benefits (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    benefit_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    termination_date DATE NULL,
    employee_contribution DECIMAL(10,2),
    employer_contribution DECIMAL(10,2),
    status ENUM('active', 'inactive', 'pending') DEFAULT 'active',
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (benefit_id) REFERENCES benefits(benefit_id),
    UNIQUE KEY unique_employee_benefit (employee_id, benefit_id, enrollment_date),
    INDEX idx_employee (employee_id),
    INDEX idx_benefit (benefit_id)
);

-- Payroll table
CREATE TABLE payroll (
    payroll_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    pay_period_start DATE NOT NULL,
    pay_period_end DATE NOT NULL,
    pay_date DATE NOT NULL,
    gross_salary DECIMAL(12,2) NOT NULL,
    overtime_hours DECIMAL(5,2) DEFAULT 0,
    overtime_rate DECIMAL(8,2) DEFAULT 0,
    overtime_pay DECIMAL(10,2) DEFAULT 0,
    bonus DECIMAL(10,2) DEFAULT 0,
    commission DECIMAL(10,2) DEFAULT 0,
    gross_pay DECIMAL(12,2) NOT NULL,
    federal_tax DECIMAL(10,2) DEFAULT 0,
    state_tax DECIMAL(10,2) DEFAULT 0,
    social_security DECIMAL(10,2) DEFAULT 0,
    medicare DECIMAL(10,2) DEFAULT 0,
    benefits_deduction DECIMAL(10,2) DEFAULT 0,
    other_deductions DECIMAL(10,2) DEFAULT 0,
    total_deductions DECIMAL(12,2) NOT NULL,
    net_pay DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    INDEX idx_employee (employee_id),
    INDEX idx_pay_period (pay_period_start, pay_period_end),
    INDEX idx_pay_date (pay_date)
);

-- Time tracking table
CREATE TABLE time_tracking (
    time_entry_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    work_date DATE NOT NULL,
    clock_in_time TIME,
    clock_out_time TIME,
    break_duration_minutes INT DEFAULT 0,
    total_hours DECIMAL(4,2),
    overtime_hours DECIMAL(4,2) DEFAULT 0,
    status ENUM('present', 'absent', 'late', 'half_day', 'holiday', 'sick_leave', 'vacation') DEFAULT 'present',
    notes TEXT,
    approved_by INT,
    approved_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (approved_by) REFERENCES employees(employee_id),
    UNIQUE KEY unique_employee_date (employee_id, work_date),
    INDEX idx_employee (employee_id),
    INDEX idx_work_date (work_date),
    INDEX idx_status (status)
);

-- Leave requests table
CREATE TABLE leave_requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    leave_type ENUM('vacation', 'sick', 'personal', 'maternity', 'paternity', 'bereavement', 'other') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_days INT NOT NULL,
    reason TEXT,
    status ENUM('pending', 'approved', 'rejected', 'cancelled') DEFAULT 'pending',
    requested_date DATE NOT NULL,
    reviewed_by INT,
    reviewed_date DATE,
    review_comments TEXT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (reviewed_by) REFERENCES employees(employee_id),
    INDEX idx_employee (employee_id),
    INDEX idx_dates (start_date, end_date),
    INDEX idx_status (status),
    INDEX idx_leave_type (leave_type)
);

-- Performance reviews table
CREATE TABLE performance_reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    reviewer_id INT NOT NULL,
    review_period_start DATE NOT NULL,
    review_period_end DATE NOT NULL,
    review_date DATE NOT NULL,
    overall_rating ENUM('exceeds_expectations', 'meets_expectations', 'below_expectations', 'unsatisfactory'),
    goals_achievement_score TINYINT CHECK (goals_achievement_score BETWEEN 1 AND 10),
    communication_score TINYINT CHECK (communication_score BETWEEN 1 AND 10),
    teamwork_score TINYINT CHECK (teamwork_score BETWEEN 1 AND 10),
    leadership_score TINYINT CHECK (leadership_score BETWEEN 1 AND 10),
    technical_skills_score TINYINT CHECK (technical_skills_score BETWEEN 1 AND 10),
    strengths TEXT,
    areas_for_improvement TEXT,
    goals_next_period TEXT,
    employee_comments TEXT,
    hr_approved BOOLEAN DEFAULT FALSE,
    hr_approved_by INT,
    hr_approved_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (reviewer_id) REFERENCES employees(employee_id),
    FOREIGN KEY (hr_approved_by) REFERENCES employees(employee_id),
    INDEX idx_employee (employee_id),
    INDEX idx_reviewer (reviewer_id),
    INDEX idx_review_date (review_date),
    INDEX idx_rating (overall_rating)
);

-- Training programs table
CREATE TABLE training_programs (
    program_id INT AUTO_INCREMENT PRIMARY KEY,
    program_name VARCHAR(200) NOT NULL,
    description TEXT,
    provider VARCHAR(100),
    duration_hours INT,
    cost_per_employee DECIMAL(10,2),
    max_participants INT,
    is_mandatory BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Employee training records
CREATE TABLE employee_training (
    training_record_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    program_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    start_date DATE,
    completion_date DATE,
    status ENUM('enrolled', 'in_progress', 'completed', 'cancelled', 'failed') DEFAULT 'enrolled',
    score DECIMAL(5,2),
    certificate_issued BOOLEAN DEFAULT FALSE,
    cost DECIMAL(10,2),
    notes TEXT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (program_id) REFERENCES training_programs(program_id),
    INDEX idx_employee (employee_id),
    INDEX idx_program (program_id),
    INDEX idx_status (status)
);
```

### Sample Queries and Reports
```sql
-- 1. Employee directory with department and manager info
SELECT 
    e.employee_number,
    CONCAT(e.first_name, ' ', e.last_name) as employee_name,
    e.email,
    e.phone,
    jp.position_title,
    d.department_name,
    CONCAT(m.first_name, ' ', m.last_name) as manager_name,
    e.hire_date,
    e.employment_status,
    e.work_location
FROM employees e
JOIN job_positions jp ON e.position_id = jp.position_id
JOIN departments d ON jp.department_id = d.department_id
LEFT JOIN employees m ON e.manager_id = m.employee_id
WHERE e.employment_status = 'active'
ORDER BY d.department_name, jp.position_title, e.last_name;

-- 2. Department headcount and salary analysis
SELECT 
    d.department_name,
    COUNT(e.employee_id) as headcount,
    AVG(e.salary) as avg_salary,
    MIN(e.salary) as min_salary,
    MAX(e.salary) as max_salary,
    SUM(e.salary) as total_salary_cost,
    COUNT(CASE WHEN e.work_location = 'remote' THEN 1 END) as remote_employees,
    COUNT(CASE WHEN e.work_location = 'hybrid' THEN 1 END) as hybrid_employees
FROM departments d
JOIN job_positions jp ON d.department_id = jp.department_id
JOIN employees e ON jp.position_id = e.position_id
WHERE e.employment_status = 'active'
GROUP BY d.department_id, d.department_name
ORDER BY headcount DESC;

-- 3. Payroll summary report
SELECT 
    YEAR(p.pay_date) as year,
    MONTH(p.pay_date) as month,
    MONTHNAME(p.pay_date) as month_name,
    COUNT(DISTINCT p.employee_id) as employees_paid,
    SUM(p.gross_pay) as total_gross_pay,
    SUM(p.total_deductions) as total_deductions,
    SUM(p.net_pay) as total_net_pay,
    AVG(p.net_pay) as avg_net_pay
FROM payroll p
GROUP BY YEAR(p.pay_date), MONTH(p.pay_date)
ORDER BY year DESC, month DESC;

-- 4. Employee performance dashboard
SELECT 
    e.employee_number,
    CONCAT(e.first_name, ' ', e.last_name) as employee_name,
    d.department_name,
    pr.overall_rating,
    ROUND((
        pr.goals_achievement_score + pr.communication_score + 
        pr.teamwork_score + pr.leadership_score + pr.technical_skills_score
    ) / 5, 2) as avg_score,
    pr.review_date,
    COUNT(et.training_record_id) as completed_trainings
FROM employees e
JOIN job_positions jp ON e.position_id = jp.position_id
JOIN departments d ON jp.department_id = d.department_id
LEFT JOIN performance_reviews pr ON e.employee_id = pr.employee_id
LEFT JOIN employee_training et ON e.employee_id = et.employee_id 
    AND et.status = 'completed'
WHERE e.employment_status = 'active'
    AND pr.review_date = (
        SELECT MAX(review_date) 
        FROM performance_reviews 
        WHERE employee_id = e.employee_id
    )
GROUP BY e.employee_id, e.employee_number, e.first_name, e.last_name, 
         d.department_name, pr.overall_rating, pr.review_date
ORDER BY avg_score DESC;

-- 5. Leave balance and usage report
SELECT 
    e.employee_number,
    CONCAT(e.first_name, ' ', e.last_name) as employee_name,
    d.department_name,
    COUNT(CASE WHEN lr.leave_type = 'vacation' AND lr.status = 'approved' THEN 1 END) as vacation_days_used,
    COUNT(CASE WHEN lr.leave_type = 'sick' AND lr.status = 'approved' THEN 1 END) as sick_days_used,
    COUNT(CASE WHEN lr.status = 'pending' THEN 1 END) as pending_requests,
    DATEDIFF(CURDATE(), e.hire_date) / 365 as years_employed
FROM employees e
JOIN job_positions jp ON e.position_id = jp.position_id
JOIN departments d ON jp.department_id = d.department_id
LEFT JOIN leave_requests lr ON e.employee_id = lr.employee_id 
    AND YEAR(lr.start_date) = YEAR(CURDATE())
WHERE e.employment_status = 'active'
GROUP BY e.employee_id, e.employee_number, e.first_name, e.last_name, 
         d.department_name, e.hire_date
ORDER BY d.department_name, e.last_name;
```

---

## Project 4: Social Media Analytics

### Project Overview
Build a social media analytics system to track posts, engagement, and user behavior.

### Database Schema
```sql
CREATE DATABASE social_media_analytics;
USE social_media_analytics;

-- Users table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(100),
    bio TEXT,
    profile_image_url VARCHAR(500),
    follower_count INT DEFAULT 0,
    following_count INT DEFAULT 0,
    post_count INT DEFAULT 0,
    account_type ENUM('personal', 'business', 'creator') DEFAULT 'personal',
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_active TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_account_type (account_type),
    INDEX idx_follower_count (follower_count)
);

-- Posts table
CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT,
    media_urls JSON,
    post_type ENUM('text', 'image', 'video', 'link', 'poll') DEFAULT 'text',
    hashtags JSON,
    mentions JSON,
    location VARCHAR(200),
    is_promoted BOOLEAN DEFAULT FALSE,
    promotion_budget DECIMAL(10,2),
    reach_count INT DEFAULT 0,
    impression_count INT DEFAULT 0,
    engagement_count INT DEFAULT 0,
    like_count INT DEFAULT 0,
    comment_count INT DEFAULT 0,
    share_count INT DEFAULT 0,
    save_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user (user_id),
    INDEX idx_created_at (created_at),
    INDEX idx_post_type (post_type),
    INDEX idx_engagement (engagement_count),
    FULLTEXT idx_content (content)
);

-- User interactions table
CREATE TABLE user_interactions (
    interaction_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    target_user_id INT,
    post_id INT,
    interaction_type ENUM('like', 'comment', 'share', 'save', 'follow', 'unfollow', 'view') NOT NULL,
    interaction_value TEXT, -- For comments, this stores the comment text
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (target_user_id) REFERENCES users(user_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    INDEX idx_user (user_id),
    INDEX idx_target_user (target_user_id),
    INDEX idx_post (post_id),
    INDEX idx_type (interaction_type),
    INDEX idx_created_at (created_at)
);

-- Analytics events table
CREATE TABLE analytics_events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    session_id VARCHAR(100),
    event_type VARCHAR(50) NOT NULL,
    event_category VARCHAR(50),
    event_data JSON,
    page_url VARCHAR(500),
    referrer_url VARCHAR(500),
    user_agent TEXT,
    ip_address VARCHAR(45),
    country VARCHAR(100),
    city VARCHAR(100),
    device_type ENUM('desktop', 'mobile', 'tablet') DEFAULT 'desktop',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user (user_id),
    INDEX idx_session (session_id),
    INDEX idx_event_type (event_type),
    INDEX idx_created_at (created_at),
    INDEX idx_device_type (device_type)
);
```

### Analytics Queries
```sql
-- 1. Top performing posts
SELECT 
    p.post_id,
    u.username,
    u.display_name,
    LEFT(p.content, 100) as content_preview,
    p.post_type,
    p.like_count,
    p.comment_count,
    p.share_count,
    p.engagement_count,
    ROUND(p.engagement_count / GREATEST(p.reach_count, 1) * 100, 2) as engagement_rate,
    p.created_at
FROM posts p
JOIN users u ON p.user_id = u.user_id
WHERE p.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY p.engagement_count DESC
LIMIT 20;

-- 2. User engagement analysis
SELECT 
    u.user_id,
    u.username,
    u.account_type,
    COUNT(p.post_id) as posts_last_30_days,
    AVG(p.engagement_count) as avg_engagement_per_post,
    SUM(p.like_count) as total_likes,
    SUM(p.comment_count) as total_comments,
    SUM(p.share_count) as total_shares,
    u.follower_count,
    ROUND(AVG(p.engagement_count) / GREATEST(u.follower_count, 1) * 100, 2) as engagement_rate
FROM users u
LEFT JOIN posts p ON u.user_id = p.user_id 
    AND p.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
WHERE u.is_active = TRUE
GROUP BY u.user_id, u.username, u.account_type, u.follower_count
HAVING posts_last_30_days > 0
ORDER BY engagement_rate DESC;

-- 3. Hashtag performance
SELECT 
    hashtag,
    COUNT(*) as usage_count,
    AVG(p.engagement_count) as avg_engagement,
    SUM(p.reach_count) as total_reach,
    COUNT(DISTINCT p.user_id) as unique_users
FROM posts p,
JSON_TABLE(p.hashtags, '$[*]' COLUMNS (hashtag VARCHAR(100) PATH '$')) as ht
WHERE p.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY hashtag
HAVING usage_count >= 5
ORDER BY avg_engagement DESC;
```

---

## Project 5: Financial Transaction System

### Project Overview
Develop a banking/financial system for managing accounts, transactions, and financial reporting.

### Database Schema
```sql
CREATE DATABASE financial_system;
USE financial_system;

-- Account types table
CREATE TABLE account_types (
    type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    minimum_balance DECIMAL(15,2) DEFAULT 0,
    monthly_fee DECIMAL(8,2) DEFAULT 0,
    interest_rate DECIMAL(5,4) DEFAULT 0,
    overdraft_limit DECIMAL(15,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
);

-- Customers table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE NOT NULL,
    ssn VARCHAR(11) UNIQUE, -- Encrypted in real system
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(50),
    zip_code VARCHAR(10),
    country VARCHAR(100) DEFAULT 'USA',
    customer_since DATE NOT NULL,
    credit_score INT,
    risk_level ENUM('low', 'medium', 'high') DEFAULT 'medium',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_customer_number (customer_number),
    INDEX idx_email (email),
    INDEX idx_name (last_name, first_name)
);

-- Accounts table
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    account_number VARCHAR(20) UNIQUE NOT NULL,
    customer_id INT NOT NULL,
    account_type_id INT NOT NULL,
    account_name VARCHAR(100),
    balance DECIMAL(15,2) DEFAULT 0,
    available_balance DECIMAL(15,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'USD',
    status ENUM('active', 'inactive', 'frozen', 'closed') DEFAULT 'active',
    opened_date DATE NOT NULL,
    closed_date DATE NULL,
    last_transaction_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (account_type_id) REFERENCES account_types(type_id),
    INDEX idx_account_number (account_number),
    INDEX idx_customer (customer_id),
    INDEX idx_status (status)
);

-- Transactions table
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_reference VARCHAR(50) UNIQUE NOT NULL,
    from_account_id INT,
    to_account_id INT,
    transaction_type ENUM('deposit', 'withdrawal', 'transfer', 'payment', 'fee', 'interest', 'refund') NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    description TEXT,
    category VARCHAR(50),
    merchant_name VARCHAR(200),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    posted_date TIMESTAMP NULL,
    status ENUM('pending', 'completed', 'failed', 'cancelled', 'reversed') DEFAULT 'pending',
    balance_after DECIMAL(15,2),
    fee_amount DECIMAL(8,2) DEFAULT 0,
    exchange_rate DECIMAL(10,6) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_account_id) REFERENCES accounts(account_id),
    FOREIGN KEY (to_account_id) REFERENCES accounts(account_id),
    INDEX idx_from_account (from_account_id),
    INDEX idx_to_account (to_account_id),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_type (transaction_type),
    INDEX idx_status (status),
    INDEX idx_reference (transaction_reference)
);
```

### Financial Reports
```sql
-- 1. Account balance summary
SELECT 
    c.customer_number,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    a.account_number,
    at.type_name as account_type,
    a.balance,
    a.available_balance,
    a.status,
    a.last_transaction_date
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN account_types at ON a.account_type_id = at.type_id
WHERE a.status = 'active'
ORDER BY c.last_name, c.first_name, a.account_number;

-- 2. Transaction volume analysis
SELECT 
    DATE(t.transaction_date) as transaction_date,
    t.transaction_type,
    COUNT(*) as transaction_count,
    SUM(t.amount) as total_amount,
    AVG(t.amount) as avg_amount,
    COUNT(CASE WHEN t.status = 'completed' THEN 1 END) as completed_count,
    COUNT(CASE WHEN t.status = 'failed' THEN 1 END) as failed_count
FROM transactions t
WHERE t.transaction_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY DATE(t.transaction_date), t.transaction_type
ORDER BY transaction_date DESC, t.transaction_type;

-- 3. Customer profitability analysis
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    COUNT(DISTINCT a.account_id) as account_count,
    SUM(a.balance) as total_balance,
    SUM(CASE WHEN t.transaction_type = 'fee' THEN t.amount ELSE 0 END) as total_fees_paid,
    COUNT(t.transaction_id) as total_transactions,
    DATEDIFF(CURDATE(), c.customer_since) as days_as_customer,
    ROUND(SUM(a.balance) / COUNT(DISTINCT a.account_id), 2) as avg_balance_per_account
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
LEFT JOIN transactions t ON (a.account_id = t.from_account_id OR a.account_id = t.to_account_id)
    AND t.transaction_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
WHERE c.is_active = TRUE AND a.status = 'active'
GROUP BY c.customer_id, c.first_name, c.last_name, c.customer_since
ORDER BY total_balance DESC;
```

---

## Project 6: Hospital Management System

### Project Overview
Create a comprehensive hospital management system for patients, doctors, appointments, and medical records.

### Database Schema
```sql
CREATE DATABASE hospital_management;
USE hospital_management;

-- Departments table
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    head_doctor_id INT,
    location VARCHAR(100),
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Doctors table
CREATE TABLE doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100),
    license_number VARCHAR(50) UNIQUE,
    department_id INT,
    phone VARCHAR(20),
    email VARCHAR(255),
    years_experience INT,
    consultation_fee DECIMAL(8,2),
    is_available BOOLEAN DEFAULT TRUE,
    hire_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    INDEX idx_specialization (specialization),
    INDEX idx_department (department_id)
);

-- Patients table
CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('M', 'F', 'Other') NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    emergency_contact_name VARCHAR(200),
    emergency_contact_phone VARCHAR(20),
    blood_group VARCHAR(5),
    allergies TEXT,
    medical_history TEXT,
    insurance_provider VARCHAR(100),
    insurance_number VARCHAR(50),
    registration_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_patient_number (patient_number),
    INDEX idx_name (last_name, first_name),
    INDEX idx_phone (phone)
);

-- Appointments table
CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    duration_minutes INT DEFAULT 30,
    appointment_type ENUM('consultation', 'follow_up', 'emergency', 'surgery', 'checkup') DEFAULT 'consultation',
    status ENUM('scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show') DEFAULT 'scheduled',
    reason TEXT,
    notes TEXT,
    consultation_fee DECIMAL(8,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
    INDEX idx_patient (patient_id),
    INDEX idx_doctor (doctor_id),
    INDEX idx_appointment_date (appointment_date),
    INDEX idx_status (status)
);

-- Medical records table
CREATE TABLE medical_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_id INT,
    visit_date DATE NOT NULL,
    chief_complaint TEXT,
    diagnosis TEXT,
    treatment_plan TEXT,
    medications_prescribed TEXT,
    lab_tests_ordered TEXT,
    follow_up_instructions TEXT,
    vital_signs JSON, -- Store BP, temperature, pulse, etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id),
    INDEX idx_patient (patient_id),
    INDEX idx_doctor (doctor_id),
    INDEX idx_visit_date (visit_date)
);
```

### Hospital Analytics
```sql
-- 1. Doctor performance report
SELECT 
    d.doctor_id,
    CONCAT(d.first_name, ' ', d.last_name) as doctor_name,
    d.specialization,
    dept.department_name,
    COUNT(a.appointment_id) as total_appointments,
    COUNT(CASE WHEN a.status = 'completed' THEN 1 END) as completed_appointments,
    COUNT(CASE WHEN a.status = 'cancelled' THEN 1 END) as cancelled_appointments,
    COUNT(CASE WHEN a.status = 'no_show' THEN 1 END) as no_shows,
    ROUND(COUNT(CASE WHEN a.status = 'completed' THEN 1 END) / COUNT(a.appointment_id) * 100, 2) as completion_rate,
    SUM(a.consultation_fee) as total_revenue
FROM doctors d
JOIN departments dept ON d.department_id = dept.department_id
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id 
    AND a.appointment_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
WHERE d.is_available = TRUE
GROUP BY d.doctor_id, d.first_name, d.last_name, d.specialization, dept.department_name
ORDER BY total_revenue DESC;

-- 2. Patient visit frequency
SELECT 
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) as patient_name,
    p.age,
    COUNT(mr.record_id) as total_visits,
    MAX(mr.visit_date) as last_visit,
    COUNT(DISTINCT mr.doctor_id) as doctors_seen,
    GROUP_CONCAT(DISTINCT d.specialization) as specializations_visited
FROM patients p
LEFT JOIN medical_records mr ON p.patient_id = mr.patient_id
LEFT JOIN doctors d ON mr.doctor_id = d.doctor_id
WHERE p.is_active = TRUE
GROUP BY p.patient_id, p.first_name, p.last_name, p.age
HAVING total_visits > 0
ORDER BY total_visits DESC;

-- 3. Department utilization
SELECT 
    dept.department_name,
    COUNT(DISTINCT d.doctor_id) as doctor_count,
    COUNT(a.appointment_id) as total_appointments,
    AVG(a.consultation_fee) as avg_consultation_fee,
    SUM(a.consultation_fee) as total_revenue,
    COUNT(CASE WHEN a.appointment_date = CURDATE() THEN 1 END) as appointments_today
FROM departments dept
JOIN doctors d ON dept.department_id = d.department_id
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id 
    AND a.status IN ('completed', 'in_progress')
    AND a.appointment_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
WHERE dept.is_active = TRUE
GROUP BY dept.department_id, dept.department_name
ORDER BY total_revenue DESC;
```

---

## Advanced Challenges

### Challenge 1: Data Warehouse Design
```sql
-- Create a data warehouse for sales analytics
CREATE DATABASE sales_warehouse;
USE sales_warehouse;

-- Dimension tables
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR(20),
    week INT,
    day_of_month INT,
    day_of_week INT,
    day_name VARCHAR(20),
    is_weekend BOOLEAN,
    is_holiday BOOLEAN
);

CREATE TABLE dim_product (
    product_key INT PRIMARY KEY,
    product_id INT,
    product_name VARCHAR(200),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    brand VARCHAR(100),
    unit_cost DECIMAL(10,2),
    unit_price DECIMAL(10,2)
);

CREATE TABLE dim_customer (
    customer_key INT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(200),
    customer_segment VARCHAR(50),
    country VARCHAR(100),
    region VARCHAR(100),
    city VARCHAR(100)
);

-- Fact table
CREATE TABLE fact_sales (
    sale_key INT AUTO_INCREMENT PRIMARY KEY,
    date_key INT,
    product_key INT,
    customer_key INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    unit_cost DECIMAL(10,2),
    total_sales DECIMAL(12,2),
    total_cost DECIMAL(12,2),
    profit DECIMAL(12,2),
    discount_amount DECIMAL(10,2),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key)
);

-- OLAP queries
SELECT 
    dd.year,
    dd.quarter,
    dp.category,
    dc.region,
    SUM(fs.total_sales) as total_sales,
    SUM(fs.profit) as total_profit,
    COUNT(*) as transaction_count
FROM fact_sales fs
JOIN dim_date dd ON fs.date_key = dd.date_key
JOIN dim_product dp ON fs.product_key = dp.product_key
JOIN dim_customer dc ON fs.customer_key = dc.customer_key
GROUP BY dd.year, dd.quarter, dp.category, dc.region
WITH ROLLUP;
```

### Challenge 2: Real-time Analytics
```sql
-- Create real-time dashboard views
CREATE VIEW real_time_sales_dashboard AS
SELECT 
    'Today Sales' as metric,
    CONCAT('$', FORMAT(SUM(total_amount), 2)) as value
FROM orders 
WHERE DATE(order_date) = CURDATE()
UNION ALL
SELECT 
    'Orders Today',
    COUNT(*)
FROM orders 
WHERE DATE(order_date) = CURDATE()
UNION ALL
SELECT 
    'Active Users',
    COUNT(DISTINCT customer_id)
FROM orders 
WHERE order_date >= DATE_SUB(NOW(), INTERVAL 1 HOUR);
```

---

## Real-World Scenarios

### Scenario 1: Database Migration
```sql
-- Migrate data from old system to new system
-- Step 1: Create mapping tables
CREATE TABLE migration_mapping (
    old_id INT,
    new_id INT,
    table_name VARCHAR(50),
    migration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 2: Data validation
SELECT 
    'customers' as table_name,
    COUNT(*) as old_count,
    (SELECT COUNT(*) FROM new_customers) as new_count,
    COUNT(*) - (SELECT COUNT(*) FROM new_customers) as difference
FROM old_customers;
```

### Scenario 2: Performance Optimization
```sql
-- Identify and fix performance issues
-- Find slow queries
SELECT 
    query_time,
    lock_time,
    rows_sent,
    rows_examined,
    sql_text
FROM mysql.slow_log
WHERE start_time >= DATE_SUB(NOW(), INTERVAL 1 DAY)
ORDER BY query_time DESC;

-- Optimize with proper indexing
ALTER TABLE large_table ADD INDEX idx_composite (column1, column2, column3);
```

---

## Conclusion

These practice projects provide comprehensive, real-world experience with:

- **Database Design**: Proper normalization, relationships, and constraints
- **Complex Queries**: JOINs, subqueries, window functions, and CTEs
- **Performance Optimization**: Indexing strategies and query optimization
- **Business Logic**: Stored procedures, functions, and triggers
- **Analytics**: Reporting, dashboards, and data analysis
- **Real-world Scenarios**: Migration, optimization, and troubleshooting

### Next Steps for Continued Learning:

1. **Implement these projects** in your preferred database system
2. **Add more features** and complexity to each project
3. **Practice with real data** using public datasets
4. **Learn database administration** tasks like backup, recovery, and monitoring
5. **Explore advanced topics** like data warehousing, NoSQL, and distributed databases
6. **Build applications** that use these databases
7. **Study database security** and compliance requirements

### Additional Resources:

- Practice with online SQL platforms (HackerRank, LeetCode, SQLBolt)
- Work with sample databases (Sakila, Northwind, Chinook)
- Contribute to open-source database projects
- Take advanced database courses and certifications
- Join database communities and forums

Remember: The key to mastering SQL is consistent practice with real-world scenarios. Start with simpler projects and gradually work your way up to more complex systems.