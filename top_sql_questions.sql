------------------------------------------------------
--(Data Analyst Focus)
------------------------------------------------------
-- Top 25 SQL Interview Questions (Week 1 – Fundamentals)
-- SELECT, INSERT, UPDATE, DELETE, Filtering, Sorting,
-- Joins (Basics), GROUP BY, Aggregates, Basic Reporting
------------------------------------------------------

-- 1. Retrieve unique departments
SELECT DISTINCT department_id FROM employees;
-- Output: List of unique department IDs from employees.


-- 2. Get top 5 highest-paid employees
SELECT name, salary
FROM employees
ORDER BY salary DESC
LIMIT 5;
-- Output: Names & salaries of the 5 highest-paid employees.


-- 3. Insert new employee
INSERT INTO employees (name, age, department_id, salary, hire_date, status, manager_id, email)
VALUES ('Ayesha', 27, 3, 75000, '2024-07-15', 'Active', 1, 'ayesha@example.com');
-- Output: 1 row inserted (new employee Ayesha).


-- 4. Update salary of IT department employees by 10%
UPDATE employees
SET salary = salary * 1.10
WHERE department_id = (
    SELECT id FROM departments WHERE name = 'IT' LIMIT 1
);
-- Output: Salaries of IT department employees increased by 10%.


-- 5. Delete resigned employees
DELETE FROM employees WHERE status = 'Resigned';
-- Output: All resigned employees removed from employees table.


-- 6. Employees without manager
SELECT id, name
FROM employees
WHERE manager_id IS NULL;
-- Output: Employee IDs & names who have no manager.


-- 7. Add new column
ALTER TABLE employees ADD bonus DECIMAL(10,2);
-- Output: New column `bonus` added to employees table.


-- 8. Employees with missing email
SELECT * FROM employees
WHERE email IS NULL;
-- Output: All employees without email addresses.


-- 9. Employees earning between 50k and 80k
SELECT name, salary
FROM employees
WHERE salary BETWEEN 50000 AND 80000;
-- Output: Employees whose salary is between 50,000 and 80,000.


-- 10. Employees in HR or Finance
SELECT name, department_id
FROM employees
WHERE department_id IN (SELECT id FROM departments WHERE name IN ('HR','Finance'));
-- Output: Employees working in HR or Finance departments.


-- 11. Names starting with 'S' and age < 30
SELECT name, age
FROM employees
WHERE name LIKE 'S%' AND age < 30;
-- Output: Employees whose names start with S and are under 30.


-- 12. Latest 10 orders
SELECT *
FROM orders
ORDER BY order_date DESC
LIMIT 10;
-- Output: 10 most recent orders with all details.


-- 13. Average salary by department
SELECT d.name AS department, AVG(e.salary) AS avg_salary
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY d.name;
-- Output: Each department with its average salary.


-- 14. Departments with more than 5 employees
SELECT d.name AS department, COUNT(*) AS total
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY d.name
HAVING COUNT(*) > 5;
-- Output: Departments that have more than 5 employees.


-- 15. Company salary stats
SELECT MAX(salary) AS max_salary,
       MIN(salary) AS min_salary,
       AVG(salary) AS avg_salary
FROM employees;
-- Output: Highest, lowest, and average salary across company.


-- 16. Monthly revenue (from orders)
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       SUM(o.quantity * p.price) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;
-- Output: Monthly revenue generated from orders.


-- 17. Employees with department names
SELECT e.name, d.name AS department
FROM employees e
JOIN departments d ON e.department_id = d.id;
-- Output: Employee names with their department names.


-- 18. Employees and managers
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
-- Output: Employees and their managers (NULL if no manager).


-- 19. Customers with/without orders
SELECT c.name, o.id AS order_id, o.order_date
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id;
-- Output: Customers with their orders; NULL if no orders.


-- 20. Orders and products (RIGHT JOIN)
SELECT o.id AS order_id, p.name AS product, o.quantity
FROM orders o
RIGHT JOIN products p ON o.product_id = p.id;
-- Output: All products with orders (NULL if never ordered).


-- 21. Full join simulation (MySQL)
SELECT c.id, c.name, o.id AS order_id
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
UNION
SELECT c.id, c.name, o.id AS order_id
FROM customers c
RIGHT JOIN orders o ON c.id = o.customer_id;
-- Output: All customers + all orders (full outer join effect).


-- 22. Top 5 customers by spending
SELECT c.name, SUM(o.quantity * p.price) AS total_spent
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN products p ON o.product_id = p.id
GROUP BY c.name
ORDER BY total_spent DESC
LIMIT 5;
-- Output: Top 5 customers by total money spent.


-- 23. Monthly revenue trend 2024
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       SUM(o.quantity * p.price) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.id
WHERE YEAR(order_date) = 2024
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;
-- Output: Month-by-month revenue trend for year 2024.


-- 24. Most frequently ordered product
SELECT p.name, COUNT(o.id) AS total_orders
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY p.name
ORDER BY total_orders DESC
LIMIT 1;
-- Output: The single most frequently ordered product.


-- 25. Year-over-Year (YoY) Revenue Growth
SELECT YEAR(order_date) AS year,
       SUM(o.quantity * p.price) AS revenue,
       COALESCE(LAG(SUM(o.quantity * p.price)) OVER (ORDER BY YEAR(order_date)), 0) AS prev_year_revenue,
       ROUND(
         (SUM(o.quantity * p.price) - COALESCE(LAG(SUM(o.quantity * p.price)) OVER (ORDER BY YEAR(order_date)), 0))
         / NULLIF(COALESCE(LAG(SUM(o.quantity * p.price)) OVER (ORDER BY YEAR(order_date)), 0), 0) * 100,
         2
       ) AS yoy_growth
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY YEAR(order_date)
ORDER BY year;
-- Output: Revenue per year, previous year revenue, and YoY % growth.

------------------------------------------------------
-- Top 25 SQL Interview Questions (Week 2 – Intermediate)
-- DISTINCT, UNION/INTERSECT/EXCEPT, Advanced Joins, CASE, Subqueries,
-- CTEs, Views, Indexing, Aggregations, Reporting
------------------------------------------------------

-- 1. Retrieve distinct customer cities
SELECT DISTINCT city FROM customers;
-- Output: List of unique cities where customers are located.

-- 2. Combine employee and customer names (no duplicates)
SELECT name FROM employees
UNION
SELECT name FROM customers;
-- Output: All names from employees and customers (unique).

-- 3. Combine employee and customer names (with duplicates)
SELECT name FROM employees
UNION ALL
SELECT name FROM customers;
-- Output: All names from both tables (duplicates included).

-- 4. Employees with their managers (self-join)
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
-- Output: Employees with their managers (NULL if none).

-- 5. Employees with department names
SELECT e.name, d.name AS department
FROM employees e
JOIN departments d ON e.department_id = d.id;
-- Output: Employee names and their department.

-- 6. Employees categorized by salary
SELECT name, salary,
       CASE
         WHEN salary >= 75000 THEN 'High'
         WHEN salary BETWEEN 60000 AND 74999 THEN 'Medium'
         ELSE 'Low'
       END AS salary_category
FROM employees;
-- Output: Each employee with a salary category.

-- 7. Handle missing emails with IFNULL
SELECT name, IFNULL(email, 'Not Provided') AS email
FROM employees;
-- Output: Employee names with email (or 'Not Provided').

-- 8. Departments with at least 2 employees
SELECT department_id, COUNT(*) AS emp_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) >= 2;
-- Output: Departments that have 2 or more employees.

-- 9. Employees earning above average salary
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
-- Output: Employees earning more than the average salary.

-- 10. 2nd highest salary
SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);
-- Output: The second highest salary in employees.

-- 11. Orders with total value using subquery
SELECT o.id,
       (SELECT SUM(p.price * o2.quantity)
        FROM orders o2
        JOIN products p ON o2.product_id = p.id
        WHERE o2.id = o.id) AS total_value
FROM orders o;
-- Output: Each order with its total value.

-- 12. Monthly sales summary (CTE)
WITH monthly_sales AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
           SUM(p.price * o.quantity) AS revenue
    FROM orders o
    JOIN products p ON o.product_id = p.id
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT * FROM monthly_sales;
-- Output: Month and revenue for each month.

-- 13. Employees with department info (CTE)
WITH emp_dept AS (
    SELECT e.id, e.name, d.name AS department
    FROM employees e
    JOIN departments d ON e.department_id = d.id
)
SELECT * FROM emp_dept;
-- Output: Employees with their department names.

-- 14. Create view: daily sales report
CREATE OR REPLACE VIEW daily_sales AS
SELECT o.order_date, SUM(p.price * o.quantity) AS total_sales
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY o.order_date;
-- Output: View created showing sales per day.

-- 15. Query daily sales view
SELECT * FROM daily_sales;
-- Output: Each day with its total sales.

-- 16. Drop daily_sales view
DROP VIEW IF EXISTS daily_sales;
-- Output: daily_sales view removed if exists.

-- 17. Add index on customer_id in orders
CREATE INDEX idx_customer_id ON orders(customer_id);
-- Output: Index created on customer_id column.

-- 18. Add index on product_id in orders
CREATE INDEX idx_product_id ON orders(product_id);
-- Output: Index created on product_id column.

-- 19. Daily KPIs – total revenue per day
SELECT o.order_date, SUM(p.price * o.quantity) AS daily_revenue
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY o.order_date
ORDER BY o.order_date;
-- Output: Each day with revenue generated.

-- 20. Monthly KPIs – revenue trend
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month,
       SUM(p.price * o.quantity) AS monthly_revenue
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY month
ORDER BY month;
-- Output: Monthly revenue across all orders.

-- 21. Top 3 customers by spending
SELECT c.name, SUM(p.price * o.quantity) AS total_spent
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN products p ON o.product_id = p.id
GROUP BY c.name
ORDER BY total_spent DESC
LIMIT 3;
-- Output: Top 3 customers by total money spent.

-- 22. Top 3 products by revenue
SELECT p.name, SUM(p.price * o.quantity) AS total_revenue
FROM orders o
JOIN products p ON o.product_id = p.id
GROUP BY p.name
ORDER BY total_revenue DESC
LIMIT 3;
-- Output: Top 3 products generating the highest revenue.

-- 23. Region-wise sales summary (using customers + orders)
SELECT c.region, SUM(p.price * o.quantity) AS total_sales
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN products p ON o.product_id = p.id
GROUP BY c.region;
-- Output: Sales totals grouped by customer region.

-- 24. Full outer join simulation (customers + orders)
SELECT c.name, o.id AS order_id
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
UNION
SELECT c.name, o.id AS order_id
FROM customers c
RIGHT JOIN orders o ON c.id = o.customer_id;
-- Output: All customers + all orders (like full outer join).

-- 25. Find departments where avg salary > overall avg
SELECT d.name, AVG(e.salary) AS dept_avg_salary
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY d.name
HAVING AVG(e.salary) > (SELECT AVG(salary) FROM employees);
-- Output: Departments whose avg salary is above company avg.

