.open fittrackpro.db
.mode column

-- 6.1 
INSERT INTO
  attendance (member_id, location_id, check_in_time)
VALUES (7, 1, '2025-02-14 16:30:00');

-- 6.2 
SELECT
  strftime('%Y-%m-%d', check_in_time) as visit_date,
  check_in_time,
  check_out_time
FROM attendance
WHERE member_id = 5;

-- 6.3 
SELECT
  CASE weekday_num
    WHEN '0' THEN 'Sunday'
    WHEN '1' THEN 'Monday'
    WHEN '2' THEN 'Tuesday'
    WHEN '3' THEN 'Wednesday'
    WHEN '4' THEN 'Thursday'
    WHEN '5' THEN 'Friday'
    WHEN '6' THEN 'Saturday'
  END as day_of_week,
  visit_count
FROM (
    SELECT
      strftime('%w', check_in_time) as weekday_num,
      COUNT(*) as visit_count
    FROM attendance
    GROUP BY weekday_num
  )
ORDER BY visit_count DESC
LIMIT 1;

-- 6.4 
SELECT
  l.name AS location_name,
  ROUND(
    COUNT(a.attendance_id) * 1.0 / (
      JULIANDAY(MAX(a.check_in_time)) - JULIANDAY(MIN(a.check_in_time)) + 1
    ),
    2
  ) AS avg_daily_attendance
FROM locations l
  JOIN attendance a ON l.location_id = a.location_id
GROUP BY l.location_id;