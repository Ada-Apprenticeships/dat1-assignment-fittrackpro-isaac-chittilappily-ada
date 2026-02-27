.open fittrackpro.db
.mode column

-- 8.1 
SELECT
  p.session_id,
  m.first_name || ' ' || m.last_name,
  p.session_date,
  p.start_time,
  p.end_time
FROM personal_training_sessions p
  JOIN members m ON p.member_id = m.member_id
