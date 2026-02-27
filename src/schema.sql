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
    name VARCHAR(50) NOT NULL CHECK (name GLOB '[a-zA-Z0-9-."'',/ ]*'),
    address VARCHAR(100) NOT NULL CHECK (address GLOB '[a-zA-Z0-9-."'',/ ]*'),
    phone_number VARCHAR(13) NOT NULL CHECK (phone_number GLOB '[0-9 ]*'),
    email VARCHAR CHECK (email GLOB '?*@?*.*'),
    opening_hours VARCHAR(11) NOT NULL CHECK (
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
      first_name GLOB '[a-zA-Z]*'
      AND first_name NOT GLOB '*[0-9/._+]*'
    ),
    last_name VARCHAR(50) NOT NULL CHECK (
      last_name GLOB '[a-zA-Z]*'
      AND last_name NOT GLOB '*[0-9/._+]*'
    ),
    email VARCHAR CHECK (email GLOB '?*@?*.*'),
    phone_number VARCHAR(13) NOT NULL CHECK (phone_number GLOB '[0-9 ]*'),
    date_of_birth DATE NOT NULL CHECK (date_of_birth < join_date),
    join_date DATE NOT NULL,
    emergency_contact_name VARCHAR(50) NOT NULL,
    emergency_contact_phone VARCHAR(50) NOT NULL
  );

CREATE TABLE
  staff(
    staff_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name VARCHAR(50) NOT NULL CHECK (
      first_name GLOB '[a-zA-Z]*'
      AND first_name NOT GLOB '*[0-9/._+]*'
    ),
    last_name VARCHAR(50) NOT NULL CHECK (
      last_name GLOB '[a-zA-Z]*'
      AND last_name NOT GLOB '*[0-9/._+]*'
    ),
    email VARCHAR CHECK (email GLOB '?*@?*.*'),
    phone_number VARCHAR(13) NOT NULL CHECK (phone_number GLOB '[0-9 ]*'),
    position TEXT NOT NULL CHECK (
      position IN (
        'Trainer',
        'Manager',
        'Receptionist',
        'Maintenance'
      )
    ),
    hire_date DATE NOT NULL,
    location_id INTEGER,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE
    SET NULL
  );

CREATE TABLE
  equipment(
    equipment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(50) NOT NULL CHECK (name GLOB '[a-zA-Z0-9-."'',/ ]*'),
    type TEXT NOT NULL CHECK (type IN ('Cardio', 'Strength')),
    purchase_date DATE NOT NULL,
    last_maintenance_date DATE NOT NULL,
    next_maintenance_date DATE NOT NULL,
    location_id INTEGER,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE
    SET NULL
  );

CREATE TABLE
  classes(
    class_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(50) NOT NULL CHECK (name GLOB '[a-zA-Z0-9-."'',/ ]*'),
    description VARCHAR(300) NOT NULL,
    capacity INTEGER NOT NULL,
    duration INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
  );

CREATE TABLE
  class_schedule(
    schedule_id INTEGER PRIMARY KEY AUTOINCREMENT,
    class_id INTEGER NOT NULL,
    staff_id INTEGER NOT NULL,
    start_time DATETIME NOT NULL CHECK (DATETIME(start_time) = start_time),
    end_time DATETIME NOT NULL CHECK (DATETIME(end_time) = end_time),
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
      AND DATE(end_date) > DATE(start_date)
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
      weight > 0
      AND weight < 500
    ),
    body_fat_percentage FLOAT NOT NULL CHECK (
      body_fat_percentage > 0
      AND body_fat_percentage < 100
    ),
    muscle_mass FLOAT NOT NULL CHECK (
      muscle_mass > 0
      AND muscle_mass < 500
    ),
    bmi FLOAT NOT NULL CHECK (
      bmi > 0
      and bmi < 100
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

CREATE TRIGGER members_trim_insert AFTER INSERT ON members BEGIN
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

CREATE TRIGGER locations_trim_insert AFTER INSERT ON locations BEGIN
UPDATE locations
SET
  name = TRIM(NEW.name),
  address = TRIM(NEW.address),
  email = TRIM(NEW.email)
WHERE location_id = NEW.location_id;

END;

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

CREATE INDEX idx_member_email ON members(email);

CREATE INDEX idx_staff_location ON staff(location_id);
