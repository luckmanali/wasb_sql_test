-- Step 1: Calculate the initial summary for each supplier, including total invoice amounts and the initial payment date.
WITH supplier_summary AS (
  SELECT
    s.supplier_id,  -- Unique ID for each supplier
    s.name AS supplier_name,  -- Supplier's name
    SUM(i.invoice_amount) AS total_invoice_amount,  -- Total amount due for all invoices from this supplier
    DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1' month AS next_payment_date  -- Set the next payment date as the end of the current month
  FROM SUPPLIER s
  INNER JOIN INVOICE i ON s.supplier_id = i.supplier_id  -- Join SUPPLIER and INVOICE tables to link suppliers with their invoices
  GROUP BY s.supplier_id, s.name  -- Group by supplier ID and name to calculate totals for each supplier
),

-- Step 2: Generate a list of potential payment dates (one per month for up to 12 months) for each supplier.
payment_months AS (
  SELECT DISTINCT
    supplier_id,  -- Supplier ID from the previous CTE
    DATE_ADD('MONTH', generate_series.number, next_payment_date) AS payment_date  -- Calculate monthly payment dates starting from next_payment_date
  FROM supplier_summary
  CROSS JOIN UNNEST(SEQUENCE(0, 11)) AS generate_series(number)  -- Create a sequence of numbers from 0 to 11 (representing 12 months)
),

-- Step 3: Calculate the payment plan for each month along with the running total of payments made.
payment_plan_with_running_total AS (
  SELECT
    s.supplier_id,  -- Supplier ID
    s.supplier_name,  -- Supplier name
    s.total_invoice_amount,  -- Total invoice amount due for the supplier
    pm.payment_date,  -- Current payment date being processed
    -- Calculate the current payment amount, ensuring it is capped at 1000 units or the remaining balance.
    LEAST(
      s.total_invoice_amount - COALESCE(SUM(LEAST(s.total_invoice_amount, 1000)) OVER (
        PARTITION BY s.supplier_id  -- Calculate the running total of payments for each supplier
        ORDER BY pm.payment_date  -- Order payments by date to maintain a sequential order
        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING  -- Sum payments up to the previous month
      ), 0),
      1000  -- Cap each monthly payment at 1000 units or less if the remaining balance is less than 1000
    ) AS payment_amount,

    -- Calculate the cumulative (running) total of all payments made up to and including the current payment date.
    COALESCE(SUM(LEAST(s.total_invoice_amount, 1000)) OVER (
      PARTITION BY s.supplier_id  -- Partition by supplier to calculate the cumulative sum for each supplier separately
      ORDER BY pm.payment_date  -- Order payments by date to maintain a sequential order
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW  -- Include the current payment in the cumulative total
    ), 0) AS running_total
  FROM supplier_summary s
  JOIN payment_months pm ON s.supplier_id = pm.supplier_id  -- Join each supplier with its corresponding payment months
)

-- Final Step: Select the relevant columns for display and filter for valid payments.
SELECT
  supplier_id,  -- Supplier ID
  supplier_name,  -- Supplier name
  payment_amount,  -- Amount to be paid in the current month
  -- Calculate the remaining balance after the current payment
  total_invoice_amount - running_total + payment_amount AS balance_outstanding,  
  payment_date  -- Payment date for the installment
FROM payment_plan_with_running_total
WHERE payment_amount > 0  -- Only include months where a payment is made (ignore months with zero payments)
  AND running_total <= total_invoice_amount  -- Ensure we don't overpay by stopping payments once the total invoice amount is met
ORDER BY supplier_id, payment_date;  -- Order by supplier and payment date for a clear view
