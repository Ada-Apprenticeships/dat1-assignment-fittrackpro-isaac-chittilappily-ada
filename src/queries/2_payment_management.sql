.open fittrackpro.db
.mode column

-- 2.1 
INSERT INTO payments (member_id, amount, payment_date, payment_method, payment_type)
VALUES
  (11, 50.00, DATETIME(), 'Credit Card', 'Monthly membership fee');

-- 2.2 
SELECT
  strftime('%Y-%m', payment_date),
  SUM(amount) AS total_revenue
FROM payments
WHERE
  payment_date >= DATE('2024-11-01')
  AND payment_date < DATE('2025-03-01')
  AND payment_type = 'Monthly membership fee'
GROUP BY strftime('%m', payment_date);

-- 2.3 
SELECT
  payment_id,
  amount,
  payment_date,
  payment_method
FROM payments
WHERE payment_type = 'Day pass'
