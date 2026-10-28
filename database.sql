-- IIUC Railway E-Ticketing and Seat Management System
CREATE DATABASE IF NOT EXISTS iiuc_railway_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE iiuc_railway_system;

CREATE TABLE users (
  user_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  mobile VARCHAR(20) NOT NULL,
  category ENUM('Student','Teacher','Staff') NOT NULL,
  gender ENUM('Male','Female') NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE TABLE admin_users (
  admin_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE TABLE stations (
  station_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  station_name VARCHAR(120) NOT NULL,
  station_code VARCHAR(20) NOT NULL UNIQUE,
  station_order SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  distance_from_start DECIMAL(7,2) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_station_name (station_name), INDEX idx_station_active_order (is_active,station_order)
) ENGINE=InnoDB;
CREATE TABLE routes (
  route_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  route_name VARCHAR(150) NOT NULL,
  origin_station_id BIGINT UNSIGNED NOT NULL,
  destination_station_id BIGINT UNSIGNED NOT NULL,
  distance_km DECIMAL(7,2) NULL,
  estimated_minutes SMALLINT UNSIGNED NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (origin_station_id) REFERENCES stations(station_id) ON DELETE RESTRICT,
  FOREIGN KEY (destination_station_id) REFERENCES stations(station_id) ON DELETE RESTRICT,
  UNIQUE KEY uq_route_pair (origin_station_id,destination_station_id),
  INDEX idx_route_active (is_active)
) ENGINE=InnoDB;
CREATE TABLE trains (
  train_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  train_name VARCHAR(120) NOT NULL,
  train_code VARCHAR(30) NOT NULL UNIQUE,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE TABLE schedules (
  schedule_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  train_id BIGINT UNSIGNED NOT NULL,
  route_id BIGINT UNSIGNED NOT NULL,
  departure_time TIME NOT NULL,
  arrival_time TIME NOT NULL,
  service_days VARCHAR(80) NOT NULL DEFAULT 'Daily',
  valid_from DATE NULL,
  valid_until DATE NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (train_id) REFERENCES trains(train_id) ON DELETE RESTRICT,
  FOREIGN KEY (route_id) REFERENCES routes(route_id) ON DELETE RESTRICT,
  INDEX idx_schedule_search (is_active,route_id,departure_time),
  INDEX idx_schedule_train (train_id,is_active)
) ENGINE=InnoDB;
CREATE TABLE bogies (
  bogie_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  train_id BIGINT UNSIGNED NOT NULL,
  bogie_code VARCHAR(10) NOT NULL,
  category ENUM('Student','Teacher','Staff') NOT NULL,
  gender ENUM('Male','Female') NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  FOREIGN KEY (train_id) REFERENCES trains(train_id) ON DELETE RESTRICT,
  UNIQUE KEY uq_train_bogie_code (train_id,bogie_code),
  UNIQUE KEY uq_train_allocation (train_id,category,gender),
  INDEX idx_bogie_allocation (train_id,category,gender,is_active)
) ENGINE=InnoDB;
CREATE TABLE seats (
  seat_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  bogie_id BIGINT UNSIGNED NOT NULL,
  seat_number VARCHAR(10) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  FOREIGN KEY (bogie_id) REFERENCES bogies(bogie_id) ON DELETE RESTRICT,
  UNIQUE KEY uq_bogie_seat (bogie_id,seat_number),
  INDEX idx_seat_active (bogie_id,is_active)
) ENGINE=InnoDB;
CREATE TABLE booking_groups (
  booking_group_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  booking_ref CHAR(12) NOT NULL UNIQUE,
  host_user_id BIGINT UNSIGNED NOT NULL,
  active_host_user_id BIGINT UNSIGNED NULL,
  schedule_id BIGINT UNSIGNED NOT NULL,
  journey_date DATE NOT NULL,
  status ENUM('Confirmed','Cancelled') NOT NULL DEFAULT 'Confirmed',
  booking_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  cancelled_at DATETIME NULL,
  FOREIGN KEY (host_user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
  FOREIGN KEY (active_host_user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
  FOREIGN KEY (schedule_id) REFERENCES schedules(schedule_id) ON DELETE RESTRICT,
  UNIQUE KEY uq_active_host_trip (active_host_user_id,schedule_id,journey_date),
  INDEX idx_group_user_date (host_user_id,journey_date,status),
  INDEX idx_group_schedule_date (schedule_id,journey_date,status)
) ENGINE=InnoDB;
CREATE TABLE bookings (
  booking_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  booking_group_id BIGINT UNSIGNED NOT NULL,
  schedule_id BIGINT UNSIGNED NOT NULL,
  journey_date DATE NOT NULL,
  passenger_name VARCHAR(120) NOT NULL,
  category ENUM('Student','Teacher','Staff') NOT NULL,
  gender ENUM('Male','Female') NOT NULL,
  seat_id BIGINT UNSIGNED NULL,
  seat_label VARCHAR(10) NOT NULL,
  bogie_label VARCHAR(10) NOT NULL,
  is_guest TINYINT(1) NOT NULL DEFAULT 0,
  status ENUM('Confirmed','Cancelled') NOT NULL DEFAULT 'Confirmed',
  cancelled_at DATETIME NULL,
  FOREIGN KEY (booking_group_id) REFERENCES booking_groups(booking_group_id) ON DELETE RESTRICT,
  FOREIGN KEY (schedule_id) REFERENCES schedules(schedule_id) ON DELETE RESTRICT,
  FOREIGN KEY (seat_id) REFERENCES seats(seat_id) ON DELETE RESTRICT,
  UNIQUE KEY uq_schedule_date_seat (schedule_id,journey_date,seat_id),
  INDEX idx_booking_schedule_date_status (schedule_id,journey_date,status),
  INDEX idx_booking_group_status (booking_group_id,status)
) ENGINE=InnoDB;

INSERT INTO stations(station_id,station_name,station_code,station_order,distance_from_start) VALUES
(1,'Chattogram Railway Station','CTG',1,0.00),
(2,'Sholosohor','SHO',2,5.50),
(3,'Kumira','KUM',3,12.00),
(4,'IIUC Campus (Proposed)','IIUC',4,15.50);
INSERT INTO routes(route_id,route_name,origin_station_id,destination_station_id,distance_km,estimated_minutes) VALUES
(1,'Chattogram Railway Station to IIUC Campus',1,4,15.50,45),
(2,'Sholashohor to IIUC Campus',2,4,10.00,30),
(3,'Kumira to IIUC Campus',3,4,3.50,15),
(4,'IIUC Campus to Chattogram Railway Station',4,1,15.50,45),
(5,'IIUC Campus to Sholashohor',4,2,10.00,30),
(6,'IIUC Campus to Kumira',4,3,3.50,15);
INSERT INTO trains(train_id,train_name,train_code) VALUES
(1,'IIUC Morning Shuttle','IIUC-MOR'),
(2,'IIUC Afternoon Shuttle','IIUC-AFT'),
(3,'IIUC Evening Return','IIUC-EVE'),
(4,'IIUC Night Return','IIUC-NGT');
INSERT INTO schedules(schedule_id,train_id,route_id,departure_time,arrival_time,service_days) VALUES
(1,1,1,'07:00:00','07:45:00','Daily'),
(2,2,1,'13:00:00','13:45:00','Daily'),
(3,3,4,'17:00:00','17:45:00','Daily'),
(4,4,4,'20:00:00','20:45:00','Daily');
INSERT INTO bogies(train_id,bogie_code,category,gender) VALUES
(1,'B1','Teacher','Male'),(1,'B2','Teacher','Female'),(1,'B3','Student','Male'),(1,'B4','Student','Female'),(1,'B5','Staff','Male'),(1,'B6','Staff','Female'),
(2,'B1','Teacher','Male'),(2,'B2','Teacher','Female'),(2,'B3','Student','Male'),(2,'B4','Student','Female'),(2,'B5','Staff','Male'),(2,'B6','Staff','Female'),
(3,'B1','Teacher','Male'),(3,'B2','Teacher','Female'),(3,'B3','Student','Male'),(3,'B4','Student','Female'),(3,'B5','Staff','Male'),(3,'B6','Staff','Female'),
(4,'B1','Teacher','Male'),(4,'B2','Teacher','Female'),(4,'B3','Student','Male'),(4,'B4','Student','Female'),(4,'B5','Staff','Male'),(4,'B6','Staff','Female');
INSERT INTO seats(bogie_id,seat_number)
SELECT b.bogie_id,CONCAT('S',LPAD(n.seq,2,'0'))
FROM bogies b
CROSS JOIN (SELECT a.n*10+d.n+1 AS seq FROM
 (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
 CROSS JOIN
 (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d
 WHERE a.n*10+d.n+1<=40) n;
