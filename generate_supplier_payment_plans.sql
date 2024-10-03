-- Step 1: Calculate the initial summary for each supplier including total invoice amounts and the next payment date
WITH supplier_summary AS (
  SELECT
    s.supplier_id,
    s.name AS supplier_name,
    SUM(i.invoice_amount) AS total_invoice_amount,  -- Total amount due for all invoices from this supplier
    DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1' month AS next_payment_date  -- Set the next payment date as the end of the current month
  FROM SUPPLIER s
  INNER JOIN INVOICE i ON s.supplier_id = i.supplier_id  -- Join SUPPLIER and INVOICE tables to link suppliers with their invoices
  GROUP BY s.supplier_id, s.name  -- Group by supplier to calculate totals for each one
),

-- Step 2: Determine the outstanding balance for each supplier after considering the next payment date
outstanding_balances AS (
  SELECT
    ss.supplier_id,  -- Supplier ID from the supplier_summary
    ss.supplier_name,  -- Supplier name from the supplier_summary
    ss.total_invoice_amount,  -- Total invoice amount calculated earlier in supplier_summary
    SUM(
        CASE 
          WHEN i.due_date > ss.next_payment_date  -- Check if the invoice is due after the next payment date
          THEN i.invoice_amount  -- Include this invoice in the outstanding balance
          ELSE 0  -- Otherwise, do not include in the balance
        END
    ) AS balance_outstanding,  -- Calculate the outstanding balance for the supplier
    ss.next_payment_date  -- Pass the next payment date along to the next CTE
  FROM supplier_summary ss
  INNER JOIN INVOICE i ON ss.supplier_id = i.supplier_id  -- Join again with INVOICE table to get individual invoices
  GROUP BY ss.supplier_id, ss.supplier_name, ss.total_invoice_amount, ss.next_payment_date  -- Group by to maintain unique supplier rows
),

-- Step 3: Create a monthly payment plan, ensuring payments are capped at 1000 units per month
monthly_payments AS (
  SELECT
    supplier_id,  -- Supplier ID from the previous CTE
    supplier_name,  -- Supplier name from the previous CTE
    balance_outstanding,  -- Outstanding balance carried forward
    LEAST(balance_outstanding, 1000) AS payment_amount,  -- Monthly payment amount (1000 units or remaining balance, whichever is lower)
    next_payment_date AS payment_date  -- Payment date, which is the next payment date from the supplier_summary
  FROM outstanding_balances
)

-- Final Step: Select the relevant columns for display and order by supplier and payment date
SELECT
  supplier_id, 
  supplier_name,
  payment_amount,  -- Monthly payment amount
  balance_outstanding,  -- Remaining balance for the supplier
  payment_date  -- Payment date for the installment
FROM monthly_payments
WHERE balance_outstanding > 0  -- Only consider suppliers with an outstanding balance
ORDER BY supplier_id, payment_date;  -- Order by supplier and payment date for a clear view
