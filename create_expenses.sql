USE memory.default;

-- Create the EXPENSE table to store employee expenses.
CREATE TABLE EXPENSE (
    employee_id TINYINT,        -- ID of the employee making the expense
    unit_price DECIMAL(8, 2),   -- Price per unit of the item or service
    quantity TINYINT            -- Number of units purchased
);

-- Insert expense data from the finance/receipts_from_last_night directory.
INSERT INTO EXPENSE (employee_id, unit_price, quantity) VALUES
(3, 6.50, 14),          -- Alex Jacobson, drinkies.txt
(3, 11.00, 20),         -- Alex Jacobson, drinks.txt
(3, 22.00, 18),         -- Alex Jacobson, drinkss.txt
(3, 13.00, 75),         -- Alex Jacobson, duh_i_think_i_got_too_many.txt
(9, 300.00, 1),         -- Andrea Ghibaudi, i_got_lost_on_the_way_home_and_now_im_in_mexico.txt
(4, 40.00, 9),          -- Darren Poynton, uber.txt
(2, 17.50, 4);          -- Umberto Torrielli, we_stopped_for_a_kebabs.txt
