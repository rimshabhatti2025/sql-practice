------------------------------------------------------
-- SQL Intermediate Practice (Week 2)
-- DISTINCT, UNION, Joins Deep Dive, CASE, Subqueries,
-- CTEs, Views, Indexing + Mini Project
------------------------------------------------------

------------------------------------------------------
-- Reuse Schema from Week 1
-- (departments, employees, customers, products,
--  orders, sales already created)
------------------------------------------------------

------------------------------------------------------
-- Day 1 – DISTINCT, UNION
------------------------------------------------------

-- DISTINCT example: unique cities of customers
SELECT DISTINCT city FROM customers;

-- UNION vs UNION ALL
-- Combine employee names and customer names
SELECT name FROM employees
UNION
SELECT name FROM customers;

-- UNION ALL (duplicates kept)
SELECT name FROM employees
UNION ALL
SELECT name FROM customers;

------------------------------------------------------
-- Day 2 – Joins Deep Dive
------------------------------------------------------

-- INNER JOIN: employees with their manager (self join)
SELECT e.name AS employee, m.name AS manager
FROM employees e
INNER JOIN employees m ON e.manager_id = m.id;

-- LEFT JOIN: orders with products (include orders without products if any)
SELECT o.id AS order_id, p.name AS product, o.quantity
FROM orders o
LEFT JOIN products p ON o.product_id = p.id;

-- RIGHT JOIN: orders with customers
SELECT o.id AS order_id, c.name AS customer
FROM orders o
RIGHT JOIN customers c ON o.customer_id = c.id;

-- FULL OUTER JOIN (simulate in MySQL using UNION)
SELECT c.name, o.id AS order_id
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
UNION
SELECT c.name, o.id AS order_id
FROM customers c
RIGHT JOIN orders o ON c.id = o.customer_id;

------------------------------------------------------
-- Day 3 – Aggregations & CASE
------------------------------------------------------

-- CASE WHEN example: categorize employees by salary
SELECT name,
       salary,
       CASE
         WHEN salary >= 75000 THEN 'High'
         WHEN salary BETWEEN 60000 AND 74999 THEN 'Medium'
         ELSE 'Low'
       END AS salary_category
FROM employees;

-- IFNULL / COALESCE: handle missing email
SELECT name, IFNULL(email, 'Not Provided') AS email
FROM employees;

-- Aggregates with HAVING
SELECT department_id, COUNT(*) AS emp_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) >= 2;

------------------------------------------------------
-- Day 4 – Subqueries
------------------------------------------------------

-- Subquery in WHERE: employees earning above average salary
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Subquery in SELECT: order total value
SELECT o.id,
       (SELECT SUM(p.price * o2.quantity)
        FROM orders o2
        JOIN products p ON o2.product_id = p.id
        WHERE o2.id = o.id) AS total_value
FROM orders o;

-- Nth Highest Salary (2nd highest here)
SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);

------------------------------------------------------
-- Day 5 – Common Table Expressions (CTEs)
------------------------------------------------------

-- Monthly sales summary
WITH monthly_sales AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
           SUM(p.price * o.quantity) AS revenue
    FROM orders o
    JOIN products p ON o.product_id = p.id
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT * FROM monthly_sales
ORDER BY month;

-- Employee with department info (using CTE)
WITH emp_dept AS (
    SELECT e.id, e.name, d.name AS department
    FROM employees e
    JOIN departments d ON e.department_id = d.id
)
SELECT * FROM emp_dept;

------------------------------------------------------
-- Day 6 – Views + Indexing Basics
------------------------------------------------------

-- Create view: daily sales report
CREATE OR REPLACE VIEW daily_sales AS
SELECT o.order_date, SUM(p.price * o.quantity) AS total_sales
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY o.order_date;

-- Query the view
SELECT * FROM daily_sales;

-- Create view: monthly sales report
CREATE OR REPLACE VIEW monthly_sales_report AS
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month,
       SUM(p.price * o.quantity) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY month;

-- Drop a view
DROP VIEW IF EXISTS daily_sales;

-- Indexing basics
CREATE INDEX idx_customer_id ON orders(customer_id);
CREATE INDEX idx_product_id ON orders(product_id);

------------------------------------------------------
-- Day 7 – Mini Project 2 (Reporting Dataset)
------------------------------------------------------

-- 1. Daily KPIs (total revenue per day)
SELECT o.order_date, SUM(p.price * o.quantity) AS daily_revenue
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY o.order_date
ORDER BY o.order_date;

-- 2. Monthly KPIs (revenue trend)
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month,
       SUM(p.price * o.quantity) AS monthly_revenue
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY month
ORDER BY month;

-- 3. Top 3 customers by spending
SELECT c.name, SUM(p.price * o.quantity) AS total_spent
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN products p ON o.product_id = p.id
GROUP BY c.name
ORDER BY total_spent DESC
LIMIT 3;

-- 4. Top 3 products by revenue
SELECT p.name, SUM(p.price * o.quantity) AS total_revenue
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY p.name
ORDER BY total_revenue DESC
LIMIT 3;

-- 5. Region-wise sales summary (from sales table)
SELECT region, SUM(amount) AS total_sales
FROM sales
GROUP BY region;

------------------------------------------------------

------------------------------------------------------
