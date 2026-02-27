.open fittrackpro.db
.mode column

PRAGMA foreign_keys = ON;

INSERT INTO locations (location_id, name, address, phone_number, email, opening_hours)
VALUES 
    (1,'Downtown Fitness','123 Main St, London','020 555 1234','downtown@fittrackpro.com','06:00-22:00'),
    (2,'Suburban Wellness','45 Oak Ln, Manchester','0161 555 5678','suburban@fittrackpro.com','05:00-23:00');

INSERT INTO members (member_id, first_name, last_name, email, phone_number, date_of_birth, join_date, emergency_contact_name, emergency_contact_phone)
VALUES
    (1,'Alice','Smith','alice.smith@email.com','07700 900001','1990-05-15','2023-01-10','Bob Smith','07700 900002'),
    (2,'Bob','Jones','bob.jones@email.com','07700 900003','1985-08-22','2023-02-15','Carol Jones','07700 900004'),
    (3,'Charlie','Brown','charlie.brown@email.com','07700 900005','1992-03-30','2023-03-20','Dave Brown','07700 900006'),
    (4,'Diana','Prince','diana.prince@email.com','07700 900007','1988-11-05','2023-04-25','Steve Trevor','07700 900008'),
    (5,'Emily','Jones','emily.jones@email.com','07700 900009','1995-07-12','2023-05-10','Frank Jones','07700 900010'),
    (6,'Frank','Castle','frank.castle@email.com','07700 900011','1980-02-18','2023-06-15','Maria Castle','07700 900012'),
    (7,'Grace','Lee','grace.lee@email.com','07700 900013','1998-09-25','2023-07-20','Henry Lee','07700 900014'),
    (8,'Henry','Ford','henry.ford@email.com','07700 900015','1975-12-30','2023-08-05','Iris Ford','07700 900016'),
    (9,'Iris','West','iris.west@email.com','07700 900017','1993-04-14','2023-09-10','Barry Allen','07700 900018'),
    (10,'Jack','Ryan','jack.ryan@email.com','07700 900019','1982-10-08','2023-10-15','Cathy Ryan','07700 900020'),
    (11,'Kevin','Mitnick','kevin.mitnick@email.com','07700 900021','1996-01-22','2023-11-20','Unknown','07700 900022');

INSERT INTO staff (staff_id,first_name,last_name,email,phone_number,position,hire_date,location_id)
VALUES
    (1,'James','Bond','james.bond@fittrackpro.com','07007 007007','Manager','2022-01-01',1),
    (2,'Ivy','Irwin','ivy.irwin@fittrackpro.com','07123 456789','Trainer','2023-05-15',1),
    (3,'Sarah','Connor','sarah.connor@fittrackpro.com','07999 888777','Receptionist','2023-08-01',1),
    (4,'Lara','Croft','lara.croft@fittrackpro.com','07555 444333','Trainer','2023-09-10',2);

INSERT INTO equipment (equipment_id,name,type,purchase_date,last_maintenance_date,next_maintenance_date,location_id)
VALUES
    (1,'Treadmill 2000','Cardio','2023-01-15','2024-12-15','2025-01-15',1),
    (2,'Elliptical Trainer','Cardio','2023-02-20','2024-07-20','2025-02-20',1),
    (3,'Smith Machine','Strength','2023-03-10','2024-03-10','2025-03-10',1),
    (4,'Dumbbell Set','Strength','2023-04-05','2024-04-05','2025-04-05',2);

INSERT INTO classes (class_id,name,description,capacity,duration,location_id)
VALUES
    (1,'Spin Class','High intensity indoor cycling',20,45,1),
    (2,'Yoga Basics','Beginner level yoga',15,60,1),
    (3,'HIIT','High Interval Intensity Training',10,30,2);

INSERT INTO class_schedule (schedule_id,class_id,staff_id,start_time,end_time)
VALUES
    (1,1,2,'2025-02-01 09:00:00','2025-02-01 09:45:00'),
    (2,2,4,'2025-02-01 10:00:00','2025-02-01 11:00:00'),
    (3,3,2,'2025-02-02 18:00:00','2025-02-02 18:30:00'),
    (7,2,4,'2025-02-05 12:00:00','2025-02-05 13:00:00');

INSERT INTO memberships (membership_id,member_id,type,start_date,end_date,status)
VALUES
    (1,1,'Standard','2024-01-01','2025-01-01','Inactive'),
    (2,2,'Premium','2024-06-15','2025-06-15','Active'),
    (3,3,'Standard','2024-03-20','2025-03-20','Active'),
    (4,5,'Premium','2024-05-10','2025-05-10','Active');

INSERT INTO attendance (attendance_id,member_id,location_id,check_in_time,check_out_time)
VALUES
    (1,5,1,'2025-01-10 08:00:00','2025-01-10 09:30:00'),
    (2,5,1,'2025-01-12 18:00:00','2025-01-12 19:15:00'),
    (3,3,1,'2025-01-15 07:00:00','2025-01-15 08:00:00');

INSERT INTO class_attendance (class_attendance_id,schedule_id,member_id,attendance_status)
VALUES
    (1,1,5,'Registered'),
    (2,1,3,'Attended'),
    (3,7,3,'Registered'),
    (4,3,5,'Registered'),
    (5,2,1,'Attended'),
    (6,2,2,'Registered'),
    (7,3,4,'Attended'),
    (13,7,1,'Attended');
    -- (14,8,2,'Attended'),  - have been advised to remove these two as there are no schedules with id 8 or 9
    -- (15,9,5,'Attended');

INSERT INTO payments (payment_id,member_id,amount,payment_date,payment_method,payment_type)
VALUES
    (1,1,40.00,'2024-11-01 10:00:00','Credit Card','Monthly membership fee'),
    (2,2,60.00,'2024-11-15 12:00:00','Bank Transfer','Monthly membership fee'),
    (3,3,40.00,'2024-12-20 09:00:00','Credit Card','Monthly membership fee'),
    (4,5,60.00,'2024-12-10 14:00:00','PayPal','Monthly membership fee'),
    (5,1,40.00,'2025-01-01 10:00:00','Credit Card','Monthly membership fee'),
    (6,2,60.00,'2025-01-15 12:00:00','Bank Transfer','Monthly membership fee'),
    (7,11,20.00,'2025-01-20 15:30:00','Cash','Day pass');

INSERT INTO personal_training_sessions (session_id,member_id,staff_id,session_date,start_time,end_time,notes)
VALUES
    (1,1,2,'2025-01-25','09:00:00','10:00:00','Cardio focus'),
    (2,3,2,'2025-01-28','14:00:00','15:00:00','Strength training'),
    (3,5,2,'2025-02-04','10:00:00','11:00:00','Form check');

INSERT INTO member_health_metrics (metric_id,member_id,measurement_date,weight,body_fat_percentage,muscle_mass,bmi)
VALUES
    (1,5,'2025-01-10',65.0,22.5,48.0,24.1),
    (2,3,'2025-01-15',80.0,18.0,60.0,25.5);

INSERT INTO equipment_maintenance_log (log_id,equipment_id,maintenance_date,description,staff_id)
VALUES
    (1,1,'2024-12-15','Belt replacement',1),
    (2,2,'2024-07-20','Oiling and sensor check',1),
    (3,3,'2024-03-10','Safety bar adjustment',1);
