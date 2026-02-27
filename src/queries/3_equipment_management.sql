.open fittrackpro.db
.mode column

-- 3.1 
SELECT
  equipment_id,
  name,
  next_maintenance_date
FROM equipment
WHERE
  next_maintenance_date >= DATE('2025-01-01')
  AND next_maintenance_date < DATE('2025-02-01');

-- 3.2 
SELECT
  type AS equipment_type,
  COUNT(*) AS count
FROM equipment
GROUP BY type;

-- 3.3 
SELECT
  type AS equipment_type,
  ROUND(
    AVG(
      JULIANDAY('now') - JULIANDAY(purchase_date)
    )
  ) AS average
FROM equipment
GROUP BY type;
