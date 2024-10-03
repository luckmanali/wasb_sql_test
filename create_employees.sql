USE memory.default;

-- Create the EMPLOYEE table.
CREATE TABLE EMPLOYEE (
    employee_id TINYINT,       -- Unique identifier for the employee
    first_name VARCHAR,        -- First name of the employee
    last_name VARCHAR,         -- Last name of the employee
    job_title VARCHAR,         -- Job title of the employee
    manager_id TINYINT         -- ID of the manager (references another employee_id)
);


-- Insert data from employee_index.csv into the EMPLOYEE table.
INSERT INTO EMPLOYEE (employee_id, first_name, last_name, job_title, manager_id) VALUES
(1, 'Ian', 'James', 'CEO', 4),
(2, 'Umberto', 'Torrielli', 'CSO', 1),
(3, 'Alex', 'Jacobson', 'MD EMEA', 2),
(4, 'Darren', 'Poynton', 'CFO', 2),
(5, 'Tim', 'Beard', 'MD APAC', 2),
(6, 'Gemma', 'Dodd', 'COS', 1),
(7, 'Lisa', 'Platten', 'CHR', 6),
(8, 'Stefano', 'Camisaca', 'GM Activation', 2),
(9, 'Andrea', 'Ghibaudi', 'MD NAM', 2);