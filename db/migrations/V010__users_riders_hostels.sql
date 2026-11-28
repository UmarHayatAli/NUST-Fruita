-- V010: accounts, the rider subtype, and the fixed list of NUST hostels (spec 7.2).
-- Every person is one users row; users.role decides what they may do (spec 2).

CREATE TABLE users (
  user_id              INT AUTO_INCREMENT PRIMARY KEY,
  full_name            VARCHAR(100) NOT NULL,
  email                VARCHAR(120) NOT NULL,             -- stored lower-case by the API
  phone                VARCHAR(20)  NOT NULL,
  password_hash        VARCHAR(255) NOT NULL,
  role                 ENUM('CUSTOMER','ADMIN','RIDER') NOT NULL DEFAULT 'CUSTOMER',
  user_type            ENUM('STUDENT','STAFF','EXTERNAL') NOT NULL DEFAULT 'EXTERNAL',
  nust_reg_no          VARCHAR(30)  NULL,
  status               ENUM('ACTIVE','BLOCKED') NOT NULL DEFAULT 'ACTIVE',
  must_change_password BOOLEAN NOT NULL DEFAULT FALSE,
  blocked_reason       VARCHAR(200) NULL,
  blocked_at           TIMESTAMP NULL,
  created_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_login_at        TIMESTAMP NULL,
  CONSTRAINT uq_users_email       UNIQUE (email),
  CONSTRAINT uq_users_nust_reg_no UNIQUE (nust_reg_no),
  CONSTRAINT ck_users_block CHECK (
    (status = 'ACTIVE'  AND blocked_at IS NULL     AND blocked_reason IS NULL) OR
    (status = 'BLOCKED' AND blocked_at IS NOT NULL AND blocked_reason IS NOT NULL))
) ENGINE=InnoDB;

-- Subtype of users: rider_id is also the user_id (trigger trg_riders_bi checks the role, BR11).
CREATE TABLE riders (
  rider_id     INT PRIMARY KEY,                           -- = users.user_id (subtype)
  vehicle_type VARCHAR(30) NULL,
  is_available BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_riders_user FOREIGN KEY (rider_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

CREATE TABLE hostels (
  hostel_id   INT AUTO_INCREMENT PRIMARY KEY,
  hostel_name VARCHAR(80) NOT NULL,
  gender_type ENUM('MALE','FEMALE') NOT NULL,
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT uq_hostels_name UNIQUE (hostel_name)
) ENGINE=InnoDB;
