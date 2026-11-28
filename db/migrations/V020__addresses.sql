-- V020: saved delivery addresses (F05, BR1, BR8).

CREATE TABLE addresses (
  address_id    INT AUTO_INCREMENT PRIMARY KEY,
  user_id       INT NOT NULL,
  address_type  ENUM('HOSTEL','HOME') NOT NULL,
  hostel_id     INT NULL,
  block_or_wing VARCHAR(30)  NULL,
  room_no       VARCHAR(20)  NULL,
  house_no      VARCHAR(30)  NULL,
  street_area   VARCHAR(150) NULL,
  city          VARCHAR(60)  NOT NULL DEFAULT 'Islamabad',
  landmark      VARCHAR(150) NULL,
  is_default    BOOLEAN NOT NULL DEFAULT FALSE,
  -- Constraint device, not data: equals user_id only for the default address, NULL otherwise.
  -- UNIQUE ignores NULLs, so each user can have at most one default address (BR8).
  default_owner INT AS (IF(is_default, user_id, NULL)) STORED,
  CONSTRAINT uq_addresses_one_default UNIQUE (default_owner),
  CONSTRAINT fk_addresses_user   FOREIGN KEY (user_id)   REFERENCES users(user_id),
  CONSTRAINT fk_addresses_hostel FOREIGN KEY (hostel_id) REFERENCES hostels(hostel_id),
  -- BR1: a HOSTEL address needs hostel and room; a HOME address needs house and street.
  CONSTRAINT ck_addresses_type CHECK (
    (address_type = 'HOSTEL' AND hostel_id IS NOT NULL AND room_no IS NOT NULL) OR
    (address_type = 'HOME'   AND hostel_id IS NULL AND house_no IS NOT NULL AND street_area IS NOT NULL))
) ENGINE=InnoDB;
