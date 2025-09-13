------------------------------------------------------
-- Top 25 SQL Interview Questions (Data Analyst Focus)
-- Fixed for schema + with expected output descriptions
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
