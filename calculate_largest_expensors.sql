USE memory.default;

-- Select the required columns to report for employees with high expenses.
SELECT 
    e1.employee_id,
    CONCAT(e1.first_name, ' ', e1.last_name) AS employee_name,  -- Full name of the employee
    e1.manager_id,
    CONCAT(e2.first_name, ' ', e2.last_name) AS manager_name,  -- Full name of the manager
    SUM(exp.unit_price * exp.quantity) AS total_expensed_amount  -- Calculate total expenses for each employee
FROM EXPENSE exp
-- Join the EXPENSE table with the EMPLOYEE table to get employee details.
INNER JOIN EMPLOYEE e1 ON exp.employee_id = e1.employee_id  
-- Left join the EMPLOYEE table again to get manager details.
LEFT JOIN EMPLOYEE e2 ON e1.manager_id = e2.employee_id  
-- Group by necessary fields to compute the total expenses per employee.
GROUP BY e1.employee_id, e1.first_name, e1.last_name, e1.manager_id, e2.first_name, e2.last_name  
-- Filter for employees who have total expenses greater than 1000.
HAVING SUM(exp.unit_price * exp.quantity) > 1000  
-- Order the result by the total expense amount in descending order.
ORDER BY total_expensed_amount DESC;
