-- ============================================================
-- TASK 3: SQL FOR DATA ANALYSIS
-- Dataset: E-commerce SQL Database
-- Database: MySQL 8.0+
-- ============================================================

CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- 1. CREATE TABLES
DROP VIEW IF EXISTS customer_revenue;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE,
    city VARCHAR(60),
    signup_date DATE
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(60),
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE NOT NULL,
    order_status VARCHAR(30),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 2. INSERT SAMPLE DATA
INSERT INTO customers VALUES
(1, 'Aarav Sharma', 'aarav@example.com', 'Hyderabad', '2025-01-10'),
(2, 'Meera Reddy', 'meera@example.com', 'Bengaluru', '2025-02-15'),
(3, 'Rahul Kumar', 'rahul@example.com', 'Hyderabad', '2025-03-20'),
(4, 'Priya Singh', 'priya@example.com', 'Chennai', '2025-04-05'),
(5, 'Kiran Rao', 'kiran@example.com', 'Mumbai', '2025-05-12'),
(6, 'Ananya Das', 'ananya@example.com', 'Pune', '2025-06-18');

INSERT INTO products VALUES
(101, 'Laptop', 'Electronics', 55000.00, 12),
(102, 'Smartphone', 'Electronics', 22000.00, 25),
(103, 'Headphones', 'Accessories', 1800.00, 40),
(104, 'Office Chair', 'Furniture', 6500.00, 15),
(105, 'Keyboard', 'Accessories', 1200.00, 30),
(106, 'Monitor', 'Electronics', 12000.00, 10);

INSERT INTO orders VALUES
(1001, 1, '2025-07-01', 'Delivered'),
(1002, 2, '2025-07-03', 'Delivered'),
(1003, 1, '2025-07-10', 'Shipped'),
(1004, 3, '2025-07-12', 'Delivered'),
(1005, 4, '2025-07-15', 'Pending'),
(1006, 5, '2025-07-20', 'Delivered');

INSERT INTO order_items VALUES
(1, 1001, 101, 1, 55000.00),
(2, 1001, 103, 2, 1800.00),
(3, 1002, 102, 1, 22000.00),
(4, 1002, 105, 1, 1200.00),
(5, 1003, 106, 2, 12000.00),
(6, 1004, 104, 1, 6500.00),
(7, 1004, 103, 1, 1800.00),
(8, 1005, 105, 2, 1200.00),
(9, 1006, 102, 1, 22000.00);

-- 3. BASIC SQL QUERIES: SELECT, WHERE, ORDER BY

-- Display all customers
SELECT * FROM customers;

-- Display products costing more than 5000
SELECT *
FROM products
WHERE price > 5000;

-- Display products from highest to lowest price
SELECT product_name, price
FROM products
ORDER BY price DESC;

-- 4. GROUP BY AND AGGREGATE FUNCTIONS

-- Number of customers in each city
SELECT city, COUNT(*) AS total_customers
FROM customers
GROUP BY city
ORDER BY total_customers DESC;

-- Total revenue from each order
SELECT o.order_id,
       SUM(oi.quantity * oi.unit_price) AS order_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id
ORDER BY order_revenue DESC;

-- Average product price
SELECT AVG(price) AS average_product_price
FROM products;

-- Total quantity sold for each product
SELECT p.product_name,
       SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC;

-- 5. JOINS

-- INNER JOIN: customers who have placed orders
SELECT c.customer_name, o.order_id, o.order_date, o.order_status
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;

-- LEFT JOIN: all customers, including customers without orders
SELECT c.customer_name, o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- RIGHT JOIN: all customers with their matching orders, if any
SELECT c.customer_name, o.order_id, o.order_date
FROM orders o
RIGHT JOIN customers c ON o.customer_id = c.customer_id;

-- 6. SUBQUERIES

-- Products whose price is above the average product price
SELECT product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- Customers who have placed at least one order
SELECT customer_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
);

-- 7. VIEWS

-- Create a view showing total revenue per customer
CREATE VIEW customer_revenue AS
SELECT c.customer_id,
       c.customer_name,
       COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_revenue
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name;

-- Display the view
SELECT * FROM customer_revenue
ORDER BY total_revenue DESC;

-- 8. INDEXES FOR QUERY OPTIMIZATION

CREATE INDEX idx_customers_city ON customers(city);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- Example query that can benefit from an index
SELECT *
FROM orders
WHERE customer_id = 1;

-- Examine the query execution plan
EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 1;

-- ============================================================
-- END OF TASK 3
-- Run this file in MySQL Workbench or another MySQL 8 client.
-- Take screenshots of query results for the task submission.
-- ============================================================
