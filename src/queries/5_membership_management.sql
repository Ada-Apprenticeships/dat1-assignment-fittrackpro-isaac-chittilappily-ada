.open fittrackpro.db
.mode column

-- 5.1 
SELECT
  m.member_id,
  m.first_name,
  m.last_name,
  ms.type,
  m.join_date
FROM members m
  JOIN memberships ms ON m.member_id = ms.member_id
WHERE ms.status = 'Active';

-- 5.2 
SELECT
  ms.type AS membership_type,
  ROUND(
    AVG(
      (
        -- Get time diff in seconds
        strftime('%s', a.check_out_time) - strftime('%s', a.check_in_time)
      ) / 60.0
    ),
    1
  ) AS avg_visit_duration_minutes
FROM memberships ms
  JOIN members m ON ms.member_id = m.member_id
  JOIN attendance a ON m.member_id = a.member_id
GROUP BY ms.type;

-- 5.3 
SELECT
  ms.member_id,
  m.first_name,
  m.last_name,
  m.email,
  ms.end_date
FROM memberships ms
  JOIN members m ON m.member_id = ms.member_id
WHERE ms.end_date < DATE('2026-01-01')
