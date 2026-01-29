.open fittrackpro.db
.mode column

DROP TABLE IF EXISTS fittrackpro.locations;


CREATE TABLE locations(
    location_id INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    address VARCHAR(50) NOT NULL,
    phone_number VARCHAR(13) NOT NULL CHECK (phone_number GLOB '[0-9 ]+')
    email VARCHAR CHECK (email LIKE '%@%'),
    opening_hours VARCHAR(11) NOT NULL CHECK (opening_hours GLOB '[0-2][0-9]:[0-5][0-9]-[0-2][0-9]:[0-5][0-9]')
);
