------------------------------------------------------
-- (Data Analyst Focus)
------------------------------------------------------
-- Top 30 SQL Interview Questions (Complete: Week 1–3)
-- Covers: Fundamentals, Intermediate, Advanced
------------------------------------------------------

------------------------------------------------------
-- Week 1 – Fundamentals
-- SELECT, INSERT, UPDATE, DELETE, Filtering, Sorting,
-- Joins (Basics), GROUP BY, Aggregates, Basic Reporting
------------------------------------------------------

-- 1. Retrieve unique departments
SELECT DISTINCT department_id FROM employees;

-- 2. Get top 5 highest-paid employees
SELECT name, salary
FROM employees
ORDER BY salary DESC
LIMIT 5;

-- 3. Insert new employee
INSERT INTO employees (name, age, department_id, salary, hire_date, status, manager_id, email)
VALUES ('Ayesha', 27, 3, 75000, '2024-07-15', 'Active', 1, 'ayesha@example.com');

-- 4. Update salary of IT department employees by 10%
UPDATE employees
SET salary = salary * 1.10
WHERE department_id = (SELECT id FROM departments WHERE name = 'IT' LIMIT 1);

-- 5. Delete resigned employees
DELETE FROM employees WHERE status = 'Resigned';

-- 6. Employees without manager
SELECT id, name
FROM employees
WHERE manager_id IS NULL;

-- 7. Add new column
ALTER TABLE employees ADD bonus DECIMAL(10,2);

-- 8. Employees with missing email
SELECT * FROM employees
WHERE email IS NULL;

-- 9. Employees earning between 50k and 80k
SELECT name, salary
FROM employees
WHERE salary BETWEEN 50000 AND 80000;

-- 10. Employees in HR or Finance
SELECT name, department_id
FROM employees
WHERE department_id IN (SELECT id FROM departments WHERE name IN ('HR','Finance'));

------------------------------------------------------
-- Week 2 – Intermediate
-- DISTINCT, UNION/EXCEPT, Advanced Joins, CASE,
-- Subqueries, CTEs, Views, Indexing, Reporting
------------------------------------------------------

-- 11. Combine employee and customer names (no duplicates)
SELECT name FROM employees
UNION
SELECT name FROM customers;

-- 12. Employees categorized by salary
SELECT name, salary,
       CASE
         WHEN salary >= 75000 THEN 'High'
         WHEN salary BETWEEN 60000 AND 74999 THEN 'Medium'
         ELSE 'Low'
       END AS salary_category
FROM employees;

-- 13. Handle missing emails with IFNULL
SELECT name, IFNULL(email, 'Not Provided') AS email
FROM employees;

-- 14. Employees earning above average salary
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- 15. 2nd highest salary
SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);

-- 16. Monthly sales summary (CTE)
WITH monthly_sales AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
           SUM(p.price * o.quantity) AS revenue
    FROM orders o
    JOIN products p ON o.product_id = p.id
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT * FROM monthly_sales;

-- 17. Create view: daily sales report
CREATE OR REPLACE VIEW daily_sales AS
SELECT o.order_date, SUM(p.price * o.quantity) AS total_sales
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY o.order_date;

-- 18. Add index on customer_id in orders
CREATE INDEX idx_customer_id ON orders(customer_id);

-- 19. Top 3 customers by spending
SELECT c.name, SUM(p.price * o.quantity) AS total_spent
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN products p ON o.product_id = p.id
GROUP BY c.name
ORDER BY total_spent DESC
LIMIT 3;

-- 20. Departments where avg salary > overall avg
SELECT d.name, AVG(e.salary) AS dept_avg_salary
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY d.name
HAVING AVG(e.salary) > (SELECT AVG(salary) FROM employees);

------------------------------------------------------
-- Week 3 – Advanced
-- EXISTS, Window Functions, Optimization, Analytics
------------------------------------------------------

-- 21. Employees who have at least one order (EXISTS)
SELECT e.name
FROM employees e
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.employee_id = e.id
);

-- 22. Rank employees by salary
SELECT name, salary,
       RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees;

-- 23. Previous salary (LAG function)
SELECT name, salary,
       LAG(salary, 1) OVER (ORDER BY salary DESC) AS prev_salary
FROM employees;

-- 24. Running total of monthly revenue
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       SUM(p.price * o.quantity) AS monthly_revenue,
       SUM(SUM(p.price * o.quantity)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) AS running_total
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY DATE_FORMAT(order_date, '%Y-%m');

-- 25. Divide customers into 4 spending groups (NTILE)
SELECT c.name, SUM(p.price * o.quantity) AS total_spent,
       NTILE(4) OVER (ORDER BY SUM(p.price * o.quantity) DESC) AS spending_quartile
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN products p ON o.product_id = p.id
GROUP BY c.name;

-- 26. Query execution plan (MySQL example)
EXPLAIN SELECT * FROM orders WHERE customer_id = 10;

-- 27. Optimize with composite index
CREATE INDEX idx_customer_product ON orders(customer_id, product_id);

-- 28. Top 3 products per category
SELECT category, name, total_sales
FROM (
    SELECT p.category, p.name,
           SUM(o.quantity) AS total_sales,
           RANK() OVER (PARTITION BY p.category ORDER BY SUM(o.quantity) DESC) AS rnk
    FROM orders o
    JOIN products p ON o.product_id = p.id
    GROUP BY p.category, p.name
) t
WHERE rnk <= 3;

-- 29. Year-over-Year (YoY) Revenue Growth
SELECT YEAR(order_date) AS year,
       SUM(o.quantity * p.price) AS revenue,
       LAG(SUM(o.quantity * p.price)) OVER (ORDER BY YEAR(order_date)) AS prev_year_revenue
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY YEAR(order_date);

-- 30. Customer Lifetime Value (CLV)
SELECT c.id, c.name,
       SUM(p.price * o.quantity) AS lifetime_value
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN products p ON o.product_id = p.id
GROUP BY c.id, c.name
ORDER BY lifetime_value DESC;
