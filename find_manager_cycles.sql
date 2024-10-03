-- Recursive CTE to detect cycles in the employee-manager hierarchy
WITH RECURSIVE manager_chain(employee_id, manager_id, chain) AS (
    
    -- Base case: Start by selecting each employee's ID and manager ID
    -- Initialize the chain with the employee's own ID (as an array)
    SELECT 
        employee_id, 
        manager_id,
        ARRAY[CAST(employee_id AS VARCHAR)]  -- Create an array to track the path for cycle detection
    FROM 
        EMPLOYEE

    UNION ALL

    -- Recursive case: Follow the manager chain up the hierarchy
    -- Continue building the chain by adding each employee's manager to the path
    SELECT 
        mc.employee_id,                   -- Keep the initial employee ID
        e.manager_id,                     -- Get the manager ID from the hierarchy
        array_distinct(mc.chain || ARRAY[CAST(e.employee_id AS VARCHAR)])  -- Extend the path with the new manager ID
    FROM 
        manager_chain mc
    JOIN 
        EMPLOYEE e ON mc.manager_id = e.employee_id  -- Follow the manager chain
    WHERE 
        NOT contains(mc.chain, CAST(e.employee_id AS VARCHAR))  -- Stop if a cycle is detected
)

-- Final selection to identify cycles in the hierarchy
SELECT 
    CAST(m.employee_id AS INTEGER) AS employee_id,  -- Employee ID from the path
    array_join(m.chain, ',') || ',' || CAST(m.employee_id AS VARCHAR) AS cycle  -- Build the cycle path as a string
FROM 
    manager_chain m
JOIN 
    EMPLOYEE e ON m.manager_id = e.employee_id  -- Join to find the cycle
WHERE 
    contains(m.chain, CAST(e.employee_id AS VARCHAR))  -- Check if the manager appears again in the chain
ORDER BY 
    m.employee_id;  -- Order by employee ID for easy readability
