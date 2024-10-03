USE memory.default;

-- Create the SUPPLIER table to store supplier details.
CREATE TABLE SUPPLIER (
    supplier_id TINYINT,            -- Unique ID for each supplier
    name VARCHAR                    -- Supplier name must be unique and not NULL
);

-- Create the INVOICE table to store invoice details.
CREATE TABLE INVOICE (
    supplier_id TINYINT,          -- Supplier ID (references SUPPLIER table)
    invoice_amount DECIMAL(8, 2), -- Total invoice amount
    due_date DATE                 -- Due date of the invoice
);

-- Insert data into the SUPPLIER table.
INSERT INTO SUPPLIER (supplier_id, name) VALUES
(1, 'Catering Plus'),
(2, 'Dave\''s Discos'),
(3, 'Entertainment tonight'),
(4, 'Ice Ice Baby'),
(5, 'Party Animals');

-- Insert data into the INVOICE table.
-- Use last_day_of_month() to calculate the last day of each month.
INSERT INTO INVOICE (supplier_id, invoice_amount, due_date) VALUES
(5, 6000.00, last_day_of_month(DATE_ADD('month', 3, CURRENT_DATE))),  -- Party Animals (3 months)
(1, 2000.00, last_day_of_month(DATE_ADD('month', 2, CURRENT_DATE))),  -- Catering Plus (2 months)
(1, 1500.00, last_day_of_month(DATE_ADD('month', 3, CURRENT_DATE))),  -- Catering Plus (3 months)
(2, 500.00, last_day_of_month(DATE_ADD('month', 1, CURRENT_DATE))),   -- Dave's Discos (1 month)
(3, 6000.00, last_day_of_month(DATE_ADD('month', 3, CURRENT_DATE))),  -- Entertainment tonight (3 months)
(4, 4000.00, last_day_of_month(DATE_ADD('month', 6, CURRENT_DATE)));  -- Ice Ice Baby (6 months)
