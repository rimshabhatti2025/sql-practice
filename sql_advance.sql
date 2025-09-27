------------------------------------------------------
-- SQL Advanced Practice (Week 3)
-- EXISTS, Nested Queries, Window Functions,
-- Optimization, Final Challenge + Final Project
------------------------------------------------------

------------------------------------------------------
-- Reuse Schema from Week 1 & Week 2
-- (departments, employees, customers, products,
--  orders, sales already created)
------------------------------------------------------

------------------------------------------------------
-- Day 1 – EXISTS, Nested Queries
------------------------------------------------------

-- EXISTS vs IN: customers who placed orders
SELECT c.name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.id
);

-- IN version
SELECT c.name
FROM customers c
WHERE c.id IN (SELECT customer_id FROM orders);

-- Nested query: top 3 spenders
SELECT c.name, SUM(p.price * o.quantity) AS total_spent
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN products p ON o.product_id = p.id
GROUP BY c.name
ORDER BY total_spent DESC
LIMIT 3;

-- LeetCode: Nth Highest Salary (3rd highest)
SELECT DISTINCT salary
FROM employees e1
WHERE 3 = (
  SELECT COUNT(DISTINCT salary)
  FROM employees e2
  WHERE e2.salary >= e1.salary
);

------------------------------------------------------
-- Day 2 – Window Functions (Intro)
------------------------------------------------------

-- ROW_NUMBER: rank employees by salary
SELECT id, name, salary,
       ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num
FROM employees;

-- RANK: handle ties
SELECT id, name, salary,
       RANK() OVER (ORDER BY salary DESC) AS rank_num
FROM employees;

-- DENSE_RANK: no gaps
SELECT id, name, salary,
       DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rank_num
FROM employees;

-- LeetCode: Rank Scores (simulate with employees salaries)
SELECT name, salary,
       DENSE_RANK() OVER (ORDER BY salary DESC) AS rank_score
FROM employees;

------------------------------------------------------
-- Day 3 – Window Functions (Advanced)
------------------------------------------------------

-- LAG: previous order date per customer
SELECT customer_id, order_date,
       LAG(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order
FROM orders;

-- LEAD: next order date per customer
SELECT customer_id, order_date,
       LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order
FROM orders;

-- NTILE: quartiles of salaries
SELECT id, name, salary,
       NTILE(4) OVER (ORDER BY salary DESC) AS quartile
FROM employees;

-- Running total: cumulative revenue per customer
SELECT o.customer_id,
       SUM(p.price * o.quantity) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS running_total
FROM orders o
JOIN products p ON o.product_id = p.id;

-- HackerRank: Ollivander’s Inventory (simulate: products cheapest per name)
SELECT name, MIN(price) AS cheapest_price
FROM products
GROUP BY name;

------------------------------------------------------
-- Day 4 – Optimization Basics
------------------------------------------------------

-- EXPLAIN usage
EXPLAIN SELECT * FROM orders WHERE customer_id = 1;

-- Indexes for optimization
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_employees_salary ON employees(salary);

-- Partitioning basics (example syntax, MySQL 8+)
-- Split sales by region (RANGE partition on amount)
-- Note: only works if partitioning enabled
-- CREATE TABLE sales_partitioned (
--   id INT,
--   product_id INT,
--   region VARCHAR(50),
--   amount DECIMAL(10,2)
-- )
-- PARTITION BY RANGE (amount) (
--   PARTITION p0 VALUES LESS THAN (4000),
--   PARTITION p1 VALUES LESS THAN (7000),
--   PARTITION p2 VALUES LESS THAN MAXVALUE
-- );

-- Practice: optimize slow query
EXPLAIN
SELECT c.name, SUM(p.price * o.quantity) AS total_spent
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN products p ON o.product_id = p.id
GROUP BY c.name;

------------------------------------------------------
-- Day 5 – Final Challenge
------------------------------------------------------

-- Top 3 products per category (simulate using product_id as category group)
SELECT product_id, name, total_revenue
FROM (
    SELECT p.id AS product_id, p.name,
           SUM(o.quantity * p.price) AS total_revenue,
           RANK() OVER (PARTITION BY p.id ORDER BY SUM(o.quantity * p.price) DESC) AS rank_num
    FROM orders o
    JOIN products p ON o.product_id = p.id
    GROUP BY p.id, p.name
) ranked
WHERE rank_num <= 3;

-- Month-wise growth rate
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
           SUM(p.price * o.quantity) AS revenue
    FROM orders o
    JOIN products p ON o.product_id = p.id
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
       ROUND(((revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month)) * 100, 2) AS growth_rate
FROM monthly_revenue;

-- Random LeetCode/HackerRank problems (examples)
-- Employees who earn more than their manager
SELECT e.name, e.salary, m.name AS manager, m.salary AS manager_salary
FROM employees e
JOIN employees m ON e.manager_id = m.id
WHERE e.salary > m.salary;

------------------------------------------------------
-- Day 6 – Final Project (Sales Database Analysis)
------------------------------------------------------

-- Build e-commerce dataset already exists (customers, orders, products, payments/sales)

-- 15 Business Questions

-- 1. Total revenue
SELECT SUM(p.price * o.quantity) AS total_revenue
FROM orders o
JOIN products p ON o.product_id = p.id;

-- 2. Monthly revenue
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(p.price * o.quantity) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY month;

-- 3. Customer lifetime value
SELECT c.name, SUM(p.price * o.quantity) AS lifetime_value
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN products p ON o.product_id = p.id
GROUP BY c.name;

-- 4. Retention: customers with repeat orders
SELECT c.name, COUNT(o.id) AS order_count
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.name
HAVING COUNT(o.id) > 1;

-- 5. Top 5 products by revenue
SELECT p.name, SUM(o.quantity * p.price) AS total_revenue
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY p.name
ORDER BY total_revenue DESC
LIMIT 5;

-- 6. Region-wise sales
SELECT region, SUM(amount) AS total_sales
FROM sales
GROUP BY region;

-- 7. Average order value
SELECT AVG(p.price * o.quantity) AS avg_order_value
FROM orders o
JOIN products p ON o.product_id = p.id;

-- 8. Highest revenue month
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(p.price * o.quantity) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY month
ORDER BY revenue DESC
LIMIT 1;

-- 9. Most loyal customer (max orders)
SELECT c.name, COUNT(o.id) AS order_count
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.name
ORDER BY order_count DESC
LIMIT 1;

-- 10. Product never sold
SELECT p.name
FROM products p
LEFT JOIN orders o ON p.id = o.product_id
WHERE o.id IS NULL;

-- 11. Revenue by department (simulate using employees salaries as cost factor)
SELECT d.name, SUM(e.salary) AS total_cost
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY d.name;

-- 12. Customer with max single order value
SELECT c.name, MAX(p.price * o.quantity) AS max_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN products p ON o.product_id = p.id
GROUP BY c.name
ORDER BY max_order_value DESC
LIMIT 1;

-- 13. Month-over-month growth rate (reuse CTE)
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
           SUM(p.price * o.quantity) AS revenue
    FROM orders o
    JOIN products p ON o.product_id = p.id
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
       ROUND(((revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month)) * 100, 2) AS growth_rate
FROM monthly_revenue;

-- 14. Employees earning above department average
SELECT e.name, e.salary, d.name AS department
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.salary > (
    SELECT AVG(salary) FROM employees WHERE department_id = e.department_id
);

-- 15. Total sales per product per region
SELECT p.name, s.region, SUM(s.amount) AS total_sales
FROM sales s
JOIN products p ON s.product_id = p.id
GROUP BY p.name, s.region;

------------------------------------------------------
-- Day 7 – Wrap Up & Showcase
------------------------------------------------------

-- Review queries, export dataset as CSV, clean repo
-- GitHub repo: SQL-Final-Project
-- Deliverables: queries.sql, dataset.csv, README.md
-- LinkedIn Post Example:
-- "Completed 3-Week SQL Roadmap ✅ | Final SQL Project – Sales Database Analysis 🚀📊"
------------------------------------------------------
