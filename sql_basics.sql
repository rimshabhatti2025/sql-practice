------------------------------------------------------
-- SQL Basics Practice (Week 1)
-- Schema + Queries covering CRUD, SELECT, Filtering,
-- Sorting, Aggregations, Joins, Mini Project
------------------------------------------------------

------------------------------------------------------
-- Schema Setup (Safe Re-Run with DROP + AUTO_INCREMENT)
------------------------------------------------------

-- Departments Table
DROP TABLE IF EXISTS departments;
CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50)
);

INSERT INTO departments (name) VALUES
('HR'),
('Finance'),
('IT'),
('Sales');

-- Employees Table
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    age INT,
    department_id INT,
    salary DECIMAL(10,2),
    hire_date DATE,
    status VARCHAR(20),
    manager_id INT,
    email VARCHAR(100),
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

INSERT INTO employees (name, age, department_id, salary, hire_date, status, manager_id, email) VALUES
('Ali', 28, 3, 75000, '2022-01-15', 'Active', NULL, 'ali@example.com'),
('Sara', 32, 2, 65000, '2021-03-10', 'Active', 1, 'sara@example.com'),
('Usman', 26, 3, 72000, '2023-06-01', 'Active', 1, NULL),
('Hina', 30, 1, 55000, '2020-09-12', 'Resigned', 2, 'hina@example.com'),
('Zara', 25, 4, 60000, '2024-02-20', 'Active', 2, 'zara@example.com');

-- Customers Table
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    city VARCHAR(50)
);

INSERT INTO customers (name, city) VALUES
('Ahmed', 'Lahore'),
('Fatima', 'Karachi'),
('Bilal', 'Islamabad'),
('Ayesha', 'Lahore'),
('Omar', 'Multan');

-- Products Table
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    price DECIMAL(10,2)
);

INSERT INTO products (name, price) VALUES
('Laptop', 1200.00),
('Mobile', 800.00),
('Tablet', 400.00),
('Headphones', 150.00),
('Monitor', 300.00);

-- Orders Table
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    product_id INT,
    quantity INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO orders (customer_id, product_id, quantity, order_date) VALUES
(1, 1, 1, '2024-07-01'),
(2, 2, 2, '2024-07-05'),
(3, 3, 3, '2024-07-10'),
(1, 4, 1, '2024-07-12'),
(4, 2, 1, '2024-07-15');

-- Sales Table
DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    region VARCHAR(50),
    amount DECIMAL(10,2),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO sales (product_id, region, amount) VALUES
(1, 'North', 5000.00),
(2, 'South', 7000.00),
(3, 'East', 3000.00),
(1, 'West', 4500.00),
(2, 'North', 6500.00);

------------------------------------------------------
-- Day 1 – SELECT Basics
------------------------------------------------------

-- Select all employees
SELECT * FROM employees;

-- Select specific columns
SELECT name, salary FROM employees;

-- Select distinct departments
SELECT DISTINCT department_id FROM employees;

-- HackerRank: Select All / Select By ID
SELECT * FROM employees WHERE id = 1;

------------------------------------------------------
-- Day 2 – CRUD Operations
------------------------------------------------------

-- Insert a new employee
INSERT INTO employees (name, age, department_id, salary, hire_date, status, manager_id, email)
VALUES ('Imran', 29, 2, 58000, '2024-05-01', 'Active', 1, 'imran@example.com');

-- Update employee salary
UPDATE employees
SET salary = 80000
WHERE name = 'Ali';

-- Delete resigned employees
DELETE FROM employees
WHERE status = 'Resigned';

------------------------------------------------------
-- Day 3 – Data Types & NULL Handling
------------------------------------------------------

-- Alter table: add column
ALTER TABLE employees ADD phone VARCHAR(15);

-- Alter table: drop column
ALTER TABLE employees DROP COLUMN phone;

-- Employees with missing email
SELECT * FROM employees WHERE email IS NULL;

-- Employees with email
SELECT * FROM employees WHERE email IS NOT NULL;

------------------------------------------------------
-- Day 4 – Filtering & Clauses
------------------------------------------------------

-- WHERE with AND/OR/NOT
SELECT * FROM employees
WHERE department_id = 3 AND salary > 70000;

-- BETWEEN
SELECT * FROM products
WHERE price BETWEEN 200 AND 1000;

-- IN
SELECT * FROM customers
WHERE city IN ('Lahore', 'Karachi');

-- LIKE
SELECT * FROM employees
WHERE name LIKE 'A%';

-- ORDER BY + LIMIT
SELECT * FROM employees
ORDER BY salary DESC
LIMIT 3;

------------------------------------------------------
-- Day 5 – Aggregations & Grouping
------------------------------------------------------

-- SUM
SELECT SUM(amount) AS total_sales FROM sales;

-- AVG
SELECT AVG(salary) AS avg_salary FROM employees;

-- COUNT
SELECT COUNT(*) AS total_employees FROM employees;

-- MIN/MAX
SELECT MIN(salary), MAX(salary) FROM employees;

-- GROUP BY
SELECT department_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id;

-- HAVING
SELECT department_id, COUNT(*) AS emp_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 1;

------------------------------------------------------
-- Day 6 – Joins
------------------------------------------------------

-- INNER JOIN employees with departments
SELECT e.name, d.name AS department
FROM employees e
INNER JOIN departments d ON e.department_id = d.id;

-- LEFT JOIN customers with orders
SELECT c.name, o.id AS order_id
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id;

-- RIGHT JOIN orders with customers
SELECT o.id AS order_id, c.name
FROM orders o
RIGHT JOIN customers c ON o.customer_id = c.id;

-- FULL OUTER JOIN (simulate in MySQL with UNION)
SELECT c.name, o.id AS order_id
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
UNION
SELECT c.name, o.id AS order_id
FROM customers c
RIGHT JOIN orders o ON c.id = o.customer_id;

------------------------------------------------------
-- Day 7 – Mini Assignment (Business Questions)
------------------------------------------------------

-- 1. Total sales by product
SELECT p.name, SUM(s.amount) AS total_sales
FROM sales s
JOIN products p ON s.product_id = p.id
GROUP BY p.name;

-- 2. Top 5 customers by total order value
SELECT c.name, SUM(p.price * o.quantity) AS total_spent
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN products p ON o.product_id = p.id
GROUP BY c.name
ORDER BY total_spent DESC
LIMIT 5;

-- 3. Monthly revenue trend
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(p.price * o.quantity) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY month
ORDER BY month;

-- 4. Average order value per customer
SELECT c.name, AVG(p.price * o.quantity) AS avg_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN products p ON o.product_id = p.id
GROUP BY c.name;

-- 5. Most popular product (by number of orders)
SELECT p.name, COUNT(o.id) AS order_count
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY p.name
ORDER BY order_count DESC
LIMIT 1;

-- 6. Region-wise sales distribution
SELECT region, SUM(amount) AS total_sales
FROM sales
GROUP BY region;

-- 7. Customers with more than 1 order
SELECT c.name, COUNT(o.id) AS order_count
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.name
HAVING COUNT(o.id) > 1;

-- 8. Products never ordered
SELECT p.name
FROM products p
LEFT JOIN orders o ON p.id = o.product_id
WHERE o.id IS NULL;

-- 9. Highest earning department (by total salary)
SELECT d.name, SUM(e.salary) AS total_salary
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY d.name
ORDER BY total_salary DESC
LIMIT 1;

-- 10. Employees without managers
SELECT * FROM employees
WHERE manager_id IS NULL;
