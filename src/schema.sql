.open fittrackpro.db
.mode column

DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS equipment;
DROP TABLE IF EXISTS classes;
DROP TABLE IF EXISTS class_schedule;
DROP TABLE IF EXISTS memberships;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS class_attendance;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS personal_training_sessions;
DROP TABLE IF EXISTS member_health_metrics;
DROP TABLE IF EXISTS equipment_maintenance_log;

PRAGMA foreign_keys = ON;

CREATE TABLE
  locations(
    location_id INTEGER PRIMARY KEY AUTOINCREMENT,
    -- check name fields with a GLOB pattern
    -- sqlite doesn't enforce VARCHAR restrictions
    -- so we have to add a manual length check
    name VARCHAR(50) NOT NULL CHECK (
      name GLOB '[a-zA-Z0-9-."'',/ ]*'
      AND LENGTH(name) BETWEEN 1 AND 50
    ),
    address VARCHAR(100) NOT NULL CHECK (
      address GLOB '[a-zA-Z0-9-."'',/ ]*'
      AND LENGTH(address) BETWEEN 1 AND 100
    ),
    phone_number VARCHAR(20) NOT NULL CHECK (
      phone_number GLOB '[0-9 ]*'
      AND LENGTH(phone_number) BETWEEN 5 AND 20
    ),
    email VARCHAR(50) CHECK (
      email GLOB '?*@?*.*'
      AND LENGTH(email) <= 50
    ),
    opening_hours CHAR(11) NOT NULL CHECK (
      opening_hours GLOB '[0-2][0-9]:[0-5][0-9]-[0-2][0-9]:[0-5][0-9]'
      AND TIME(SUBSTR(opening_hours, 1, 5)) IS NOT NULL
      AND TIME(SUBSTR(opening_hours, 7, 5)) IS NOT NULL
      AND SUBSTR(opening_hours, 7, 5) > SUBSTR(opening_hours, 1, 5)
    )
  );

CREATE TABLE
  members(
    member_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name VARCHAR(50) NOT NULL CHECK (
      -- Double GLOB to reject unreasonable names
      -- But still accept cases like 'Anne-Marie' or "O'Niel"
      first_name GLOB '[a-zA-Z]*'
      AND first_name NOT GLOB '*[0-9/._+]*'
      AND LENGTH(first_name) BETWEEN 1 AND 50
    ),
    last_name VARCHAR(50) NOT NULL CHECK (
      last_name GLOB '[a-zA-Z]*'
      AND last_name NOT GLOB '*[0-9/._+]*'
      AND LENGTH(last_name) BETWEEN 1 AND 50
    ),
    email VARCHAR(50) CHECK (
      email GLOB '?*@?*.*'
      AND LENGTH(email) <= 50
    ),
    phone_number VARCHAR(20) NOT NULL CHECK (
      phone_number GLOB '[0-9 ]*'
      AND LENGTH(phone_number) BETWEEN 5 AND 20
    ),
    -- Check date validity by comparing against
    -- original with DATE()
    -- Checking if DATE() returns NULL is not enough
    -- as DATE(2025-04-31) internally converts to 2025-05-01
    -- and gets accepted, despite being an invalid date
    date_of_birth DATE NOT NULL CHECK (DATE(date_of_birth) = date_of_birth),
    join_date DATE NOT NULL CHECK (
      DATE(join_date) = join_date
      AND join_date > date_of_birth
    ),
    emergency_contact_name VARCHAR(50) NOT NULL CHECK (
      emergency_contact_name GLOB '[a-zA-Z]*'
      AND emergency_contact_name NOT GLOB '*[0-9/._+]*'
      AND LENGTH(emergency_contact_name) BETWEEN 1 AND 50
    ),
    emergency_contact_phone VARCHAR(20) NOT NULL CHECK (
      emergency_contact_phone GLOB '[0-9 ]*'
      AND LENGTH(emergency_contact_phone) BETWEEN 5 AND 20
    )
  );

CREATE TABLE
  staff(
    staff_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name VARCHAR(50) NOT NULL CHECK (
      first_name GLOB '[a-zA-Z]*'
      AND first_name NOT GLOB '*[0-9/._+]*'
      AND LENGTH(first_name) BETWEEN 1 AND 50
    ),
    last_name VARCHAR(50) NOT NULL CHECK (
      last_name GLOB '[a-zA-Z]*'
      AND last_name NOT GLOB '*[0-9/._+]*'
      AND LENGTH(last_name) BETWEEN 1 AND 50
    ),
    email VARCHAR(50) CHECK (
      email GLOB '?*@?*.*'
      AND LENGTH(email) <= 50
    ),
    phone_number VARCHAR(20) NOT NULL CHECK (
      phone_number GLOB '[0-9 ]*'
      AND LENGTH(phone_number) BETWEEN 5 AND 20
    ),
    position TEXT NOT NULL CHECK (
      position IN (
        'Trainer',
        'Manager',
        'Receptionist',
        'Maintenance'
      )
    ),
    hire_date DATE NOT NULL CHECK (DATE(hire_date) = hire_date),
    location_id INTEGER,
    -- Deleting a location should set staff location to NULL
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE SET NULL
  );

CREATE TABLE
  equipment(
    equipment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(50) NOT NULL CHECK (
      name GLOB '[a-zA-Z0-9-."'',/ ]*'
      AND LENGTH(name) BETWEEN 1 AND 50
    ),
    type TEXT NOT NULL CHECK (type IN ('Cardio', 'Strength')),
    purchase_date DATE NOT NULL,
    last_maintenance_date DATE NOT NULL CHECK (
      DATE(last_maintenance_date) = last_maintenance_date
    ),
    next_maintenance_date DATE NOT NULL CHECK (
      DATE(next_maintenance_date) = next_maintenance_date
      AND next_maintenance_date > last_maintenance_date
    ),
    location_id INTEGER,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE SET NULL
  );

CREATE TABLE
  classes(
    class_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(50) NOT NULL CHECK (
      name GLOB '[a-zA-Z0-9-."'',/ ]*'
      AND LENGTH(name) BETWEEN 1 AND 50
    ),
    description TEXT,
    capacity INTEGER NOT NULL CHECK (capacity > 0),
    duration INTEGER NOT NULL CHECK (duration > 0 AND duration < 1440),
    location_id INTEGER NOT NULL,
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
  );

CREATE TABLE
  class_schedule(
    schedule_id INTEGER PRIMARY KEY AUTOINCREMENT,
    class_id INTEGER NOT NULL,
    staff_id INTEGER NOT NULL,
    start_time DATETIME NOT NULL CHECK (DATETIME(start_time) = start_time),
    end_time DATETIME NOT NULL CHECK (
      DATETIME(end_time) = end_time
      AND end_time > start_time
    ),
    FOREIGN KEY (class_id) REFERENCES classes(class_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
  );

CREATE TABLE
  memberships(
    membership_id INTEGER PRIMARY KEY AUTOINCREMENT,
    member_id INTEGER NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('Standard', 'Premium')),
    start_date DATE NOT NULL CHECK (DATE(start_date) = start_date),
    end_date DATE NOT NULL CHECK (
      DATE(end_date) = end_date
      AND end_date > start_date
    ),
    status TEXT NOT NULL CHECK (status IN ('Active', 'Inactive')),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
  );

CREATE TABLE
  attendance(
    attendance_id INTEGER PRIMARY KEY AUTOINCREMENT,
    member_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    check_in_time DATETIME NOT NULL CHECK (DATETIME(check_in_time) = check_in_time),
    check_out_time DATETIME CHECK (
      DATETIME(check_out_time) = check_out_time
      AND check_out_time > check_in_time
    ),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
  );

CREATE TABLE
  class_attendance(
    class_attendance_id INTEGER PRIMARY KEY AUTOINCREMENT,
    schedule_id INTEGER NOT NULL,
    member_id INTEGER NOT NULL,
    attendance_status TEXT NOT NULL CHECK (
      attendance_status IN ('Registered', 'Attended', 'Unattended')
    ),
    -- Delete attendance entries if a member or class is deleted
    FOREIGN KEY (schedule_id) REFERENCES class_schedule(schedule_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
  );

CREATE TABLE
  payments(
    payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    member_id INTEGER NOT NULL,
    amount FLOAT NOT NULL CHECK (amount >= 0),
    payment_date DATETIME NOT NULL CHECK (DATETIME(payment_date) = payment_date),
    payment_method TEXT NOT NULL CHECK (
      payment_method IN (
        'Credit Card',
        'Bank Transfer',
        'PayPal',
        'Cash'
      )
    ),
    payment_type TEXT NOT NULL CHECK (
      payment_type IN ('Monthly membership fee', 'Day pass')
    ),
    -- Do NOT delete payments if a member is deleted
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE RESTRICT
  );

CREATE TABLE
  personal_training_sessions(
    session_id INTEGER PRIMARY KEY AUTOINCREMENT,
    member_id INTEGER NOT NULL,
    staff_id INTEGER NOT NULL,
    session_date DATE NOT NULL CHECK (DATE(session_date) = session_date),
    start_time TIME NOT NULL CHECK (TIME(start_time) = start_time),
    end_time TIME NOT NULL CHECK (
      TIME(end_time) = end_time
      AND end_time > start_time
    ),
    notes TEXT,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
  );

CREATE TABLE
  member_health_metrics(
    metric_id INTEGER PRIMARY KEY AUTOINCREMENT,
    member_id INTEGER NOT NULL,
    measurement_date DATE NOT NULL CHECK (
      DATE(measurement_date) = measurement_date
    ),
    weight FLOAT NOT NULL CHECK (
      weight BETWEEN 20.0 AND 500.0
    ),
    body_fat_percentage FLOAT NOT NULL CHECK (
      body_fat_percentage BETWEEN 1.0 AND 70.0
    ),
    muscle_mass FLOAT NOT NULL CHECK (
      muscle_mass BETWEEN 10.0 AND 400.0
    ),
    bmi FLOAT NOT NULL CHECK (
      bmi BETWEEN 5.0 AND 95.0
    ),
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
  );

CREATE TABLE
  equipment_maintenance_log(
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    equipment_id INTEGER NOT NULL,
    maintenance_date DATE NOT NULL CHECK (
      DATE(maintenance_date) = maintenance_date
    ),
    description TEXT,
    staff_id INTEGER NOT NULL,
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
  );


-- Sanitation triggers for critical tables
-- Ensures safer querying of database by trimming whitespace from text fields
CREATE TRIGGER members_trim_insert AFTER INSERT ON members BEGIN
UPDATE members
SET
  first_name = TRIM(NEW.first_name),
  last_name = TRIM(NEW.last_name),
  email = TRIM(NEW.email),
  emergency_contact_name = TRIM(NEW.emergency_contact_name)
WHERE member_id = NEW.member_id;

END;

CREATE TRIGGER members_trim_update AFTER
UPDATE
  ON members FOR EACH ROW
  WHEN (
    NEW.first_name != OLD.first_name
    OR NEW.last_name != OLD.last_name
    OR NEW.email != OLD.email
  ) BEGIN
UPDATE members
SET
  first_name = TRIM(NEW.first_name),
  last_name = TRIM(NEW.last_name),
  email = TRIM(NEW.email),
  emergency_contact_name = TRIM(NEW.emergency_contact_name)
WHERE member_id = NEW.member_id;

END;

CREATE TRIGGER staff_trim_insert AFTER INSERT ON staff BEGIN
UPDATE staff
SET
  first_name = TRIM(NEW.first_name),
  last_name = TRIM(NEW.last_name),
  email = TRIM(NEW.email)
WHERE staff_id = NEW.staff_id;

END;

CREATE TRIGGER staff_trim_update AFTER
UPDATE
  ON staff FOR EACH ROW
  WHEN (
    NEW.first_name != OLD.first_name
    OR NEW.last_name != OLD.last_name
    OR NEW.email != OLD.email
  ) BEGIN
UPDATE staff
SET
  first_name = TRIM(NEW.first_name),
  last_name = TRIM(NEW.last_name),
  email = TRIM(NEW.email)
WHERE staff_id = NEW.staff_id;

END;

CREATE TRIGGER locations_trim_insert AFTER INSERT ON locations BEGIN
UPDATE locations
SET
  name = TRIM(NEW.name),
  address = TRIM(NEW.address),
  email = TRIM(NEW.email)
WHERE location_id = NEW.location_id;

END;

CREATE TRIGGER locations_trim_update AFTER
UPDATE
  ON locations FOR EACH ROW
  WHEN (
    NEW.name != OLD.name
    OR NEW.address != OLD.address
    OR NEW.email != OLD.email
  ) BEGIN
UPDATE locations
SET
  name = TRIM(NEW.name),
  address = TRIM(NEW.address),
  email = TRIM(NEW.email)
WHERE location_id = NEW.location_id;

END;


-- Stop members from having more than 1 membership active at once
CREATE TRIGGER prevent_duplicate_active_membership BEFORE INSERT ON memberships
WHEN NEW.status = 'Active' BEGIN
SELECT
  CASE
    WHEN (
      SELECT COUNT(*)
      FROM memberships
      WHERE
        member_id = NEW.member_id
        AND status = 'Active'
    ) > 0 THEN RAISE(
      ABORT,
      'Member already has an active membership'
    )
  END;

END;

-- Disallow registering someone for a class that is at capacity
CREATE TRIGGER check_class_capacity_insert BEFORE INSERT ON class_attendance BEGIN
SELECT
  CASE
    WHEN (
      SELECT COUNT(*)
      FROM class_attendance
      WHERE
        schedule_id = NEW.schedule_id
        AND attendance_status = 'Registered'
    ) >= (
      SELECT c.capacity
      FROM classes c
        JOIN class_schedule cs ON c.class_id = cs.class_id
      WHERE
        cs.schedule_id = NEW.schedule_id
    ) THEN RAISE(
      ABORT,
      'This class is already at max capacity'
    )
  END;

END;

-- Disallow adding a maintenance date before the purchase date of equipment
CREATE TRIGGER validate_maintenance_date BEFORE INSERT ON equipment_maintenance_log BEGIN
SELECT
  CASE
    WHEN NEW.maintenance_date < (
      SELECT purchase_date
      FROM equipment
      WHERE
        equipment_id = NEW.equipment_id
    ) THEN RAISE(
      ABORT,
      'Maintenance date cannot be earlier than purchase date'
    )
  END;

END;

-- Indexes for more performant queries
CREATE INDEX idx_member_email ON members(email);

CREATE INDEX idx_staff_location ON staff(location_id);
