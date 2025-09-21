-- Create Database
CREATE DATABASE sql_practice;
USE sql_practice;

-- Customers Table
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50),
    signup_date DATE
);

-- Employees Table
CREATE TABLE Employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE
);

-- Products Table
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

-- Orders Table
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    employee_id INT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- OrderDetails Table (many-to-many: Orders <-> Products)
CREATE TABLE OrderDetails (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Insert Sample Customers
INSERT INTO Customers (customer_name, email, city, signup_date) VALUES
('Alice Johnson', 'alice@example.com', 'New York', '2023-01-10'),
('Bob Smith', 'bob@example.com', 'Chicago', '2023-02-15'),
('Charlie Brown', 'charlie@example.com', 'Los Angeles', '2023-03-05'),
('David Wilson', 'david@example.com', 'Houston', '2023-04-20'),
('Emma Davis', 'emma@example.com', 'Miami', '2023-05-12');

-- Insert Sample Employees
INSERT INTO Employees (employee_name, department, salary, hire_date) VALUES
('John Miller', 'Sales', 60000, '2021-03-01'),
('Sophia Lee', 'HR', 50000, '2022-06-10'),
('Michael Clark', 'Sales', 75000, '2020-08-15'),
('Olivia Hall', 'IT', 90000, '2019-09-25'),
('Daniel Young', 'Sales', 65000, '2021-12-01');

-- Insert Sample Products
INSERT INTO Products (product_name, category, price) VALUES
('Laptop', 'Electronics', 1200.00),
('Smartphone', 'Electronics', 800.00),
('Headphones', 'Accessories', 150.00),
('Office Chair', 'Furniture', 300.00),
('Coffee Maker', 'Home Appliance', 100.00);

-- Insert Sample Orders
INSERT INTO Orders (customer_id, order_date, employee_id) VALUES
(1, '2023-06-01', 1),
(2, '2023-06-05', 3),
(3, '2023-06-10', 1),
(4, '2023-06-12', 5),
(5, '2023-06-15', 3),
(1, '2023-06-20', 1);

-- Insert Sample OrderDetails
INSERT INTO OrderDetails (order_id, product_id, quantity) VALUES
(1, 1, 2), -- Alice bought 2 Laptops
(1, 3, 1), -- Alice bought 1 Headphone
(2, 2, 1), -- Bob bought 1 Smartphone
(3, 4, 2), -- Charlie bought 2 Chairs
(4, 5, 1), -- David bought 1 Coffee Maker
(5, 2, 2), -- Emma bought 2 Smartphones
(6, 1, 1), -- Alice again bought 1 Laptop
(6, 5, 1); -- Alice bought 1 Coffee Maker


-- 📘 SQL Interview Questions with Answers (MySQL)
-- Author: Rimsha Bhatti's SQL Practice Repo
-- Purpose: Covers 25 must-know SQL questions for fresher Data Analyst interviews

/* ------------------------------------------------------------------ */
-- 1. SQL Basics
/* ------------------------------------------------------------------ */

-- DDL, DML, DCL, TCL examples
-- DDL: CREATE TABLE employees (id INT, name VARCHAR(50));
-- DML: INSERT INTO employees VALUES (1, 'Ali');
-- DCL: GRANT SELECT ON employees TO user1;
-- TCL: COMMIT / ROLLBACK;

-- DELETE vs TRUNCATE vs DROP
DELETE FROM employees WHERE id = 1;
TRUNCATE TABLE employees;
DROP TABLE employees;

-- Primary Key vs Unique Key
-- Primary Key = NOT NULL + UNIQUE (only one per table)
-- Unique Key = UNIQUE (can have multiple per table)

/* ------------------------------------------------------------------ */
-- 2. Filtering & Sorting
/* ------------------------------------------------------------------ */

-- Salary between 50k and 80k
SELECT name, salary FROM employees
WHERE salary BETWEEN 50000 AND 80000;

-- Find duplicates
SELECT name, COUNT(*) 
FROM employees
GROUP BY name
HAVING COUNT(*) > 1;

-- WHERE vs HAVING example
SELECT department, AVG(salary)
FROM employees
GROUP BY department
HAVING AVG(salary) > 60000;

/* ------------------------------------------------------------------ */
-- 3. Aggregations
/* ------------------------------------------------------------------ */

-- Total sales per product
SELECT product_id, SUM(amount) AS total_sales
FROM sales
GROUP BY product_id;

-- 2nd highest salary
SELECT MAX(salary) AS second_highest
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);

-- COUNT(*) vs COUNT(column)
SELECT COUNT(*) AS total_rows, COUNT(manager_id) AS total_managers
FROM employees;

/* ------------------------------------------------------------------ */
-- 4. Joins
/* ------------------------------------------------------------------ */

-- INNER JOIN
SELECT e.name, d.department_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.id;

-- LEFT JOIN
SELECT e.name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.id;

-- RIGHT JOIN
SELECT e.name, d.department_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.id;

-- FULL OUTER JOIN (simulate in MySQL)
SELECT e.name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.id
UNION
SELECT e.name, d.department_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.id;

-- Customers who placed orders + those who did not
SELECT c.customer_id, c.name, o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- JOIN vs UNION
-- JOIN → combine columns
-- UNION → combine rows

/* ------------------------------------------------------------------ */
-- 5. Advanced Filtering & Logic
/* ------------------------------------------------------------------ */

-- Combine customer + employee names
SELECT name FROM customers
UNION
SELECT name FROM employees;

-- CASE WHEN for salary grade
SELECT name, salary,
CASE 
  WHEN salary < 50000 THEN 'Low'
  WHEN salary BETWEEN 50000 AND 100000 THEN 'Medium'
  ELSE 'High'
END AS salary_grade
FROM employees;

-- NULL vs IS NULL vs COALESCE
SELECT COALESCE(manager_id, 'No Manager') AS manager
FROM employees;

/* ------------------------------------------------------------------ */
-- 6. Subqueries & CTEs
/* ------------------------------------------------------------------ */

-- Nth highest salary (example: 3rd highest)
SELECT DISTINCT salary
FROM employees e1
WHERE 3 = (
  SELECT COUNT(DISTINCT salary) 
  FROM employees e2
  WHERE e2.salary >= e1.salary
);

-- Subquery vs CTE example
WITH dept_salary AS (
  SELECT department, AVG(salary) AS avg_salary
  FROM employees
  GROUP BY department
)
SELECT * FROM dept_salary WHERE avg_salary > 60000;

-- EXISTS → customers with at least 1 order
SELECT c.customer_id, c.name
FROM customers c
WHERE EXISTS (
  SELECT 1 FROM orders o
  WHERE o.customer_id = c.customer_id
);

/* ------------------------------------------------------------------ */
-- 7. Window Functions
/* ------------------------------------------------------------------ */

-- ROW_NUMBER
SELECT name, salary,
ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num
FROM employees;

-- RANK vs DENSE_RANK vs ROW_NUMBER
SELECT name, salary,
RANK() OVER (ORDER BY salary DESC) AS rank_num,
DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rank_num,
ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num
FROM employees;

-- Running total of sales
SELECT order_date, SUM(amount) OVER (ORDER BY order_date) AS running_total
FROM sales;

/* ------------------------------------------------------------------ */
-- 8. Database Management
/* ------------------------------------------------------------------ */

-- Index basics
CREATE INDEX idx_customer_id ON orders(customer_id);

-- Clustered vs Non-clustered
-- MySQL InnoDB → clustered by Primary Key
-- Secondary indexes → non-clustered

-- View
CREATE VIEW dept_summary AS
SELECT department, COUNT(*) AS total_employees
FROM employees
GROUP BY department;

-- Updating through view (only if no joins/aggregates)
UPDATE dept_summary SET total_employees = 20 WHERE department = 'Sales';

/* ------------------------------------------------------------------ */
-- 9. Real-World / Business Queries
/* ------------------------------------------------------------------ */

-- Top 5 customers by revenue
SELECT c.customer_id, c.name, SUM(o.amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC
LIMIT 5;

-- Monthly revenue trend
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(amount) AS revenue
FROM orders
GROUP BY month
ORDER BY month;

-- Repeat customers
SELECT customer_id, COUNT(*) AS orders_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 1;
