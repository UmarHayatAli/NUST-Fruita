-- V060: one cash-on-delivery payment per order, and delivery attempts (F28-F36).

CREATE TABLE payments (
  payment_id   INT AUTO_INCREMENT PRIMARY KEY,
  order_id     INT NOT NULL,
  amount       DECIMAL(10,2) NOT NULL,                     -- = orders.total_amount
  status       ENUM('PENDING','COLLECTED','CANCELLED') NOT NULL DEFAULT 'PENDING',
  collected_by INT NULL,
  collected_at TIMESTAMP NULL,
  CONSTRAINT uq_payments_order UNIQUE (order_id),          -- exactly one payment per order (A3)
  CONSTRAINT fk_payments_order FOREIGN KEY (order_id)     REFERENCES orders(order_id),
  CONSTRAINT fk_payments_rider FOREIGN KEY (collected_by) REFERENCES riders(rider_id),
  CONSTRAINT ck_payments_collected CHECK (
    (status = 'COLLECTED'  AND collected_by IS NOT NULL AND collected_at IS NOT NULL) OR
    (status <> 'COLLECTED' AND collected_by IS NULL     AND collected_at IS NULL))
) ENGINE=InnoDB;

-- One row per delivery attempt; FAILED rows are kept forever for rider statistics (change C1).
CREATE TABLE deliveries (
  delivery_id     INT AUTO_INCREMENT PRIMARY KEY,
  order_id        INT NOT NULL,
  rider_id        INT NOT NULL,
  delivery_status ENUM('ASSIGNED','PICKED_UP','DELIVERED','FAILED') NOT NULL DEFAULT 'ASSIGNED',
  assigned_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  picked_up_at    TIMESTAMP NULL,
  delivered_at    TIMESTAMP NULL,
  delivery_code   CHAR(4) NULL,
  code_attempts   INT NOT NULL DEFAULT 0,
  override_reason VARCHAR(200) NULL,
  failure_reason  VARCHAR(200) NULL,
  -- At most one non-FAILED delivery per order (BR15): FAILED rows become NULL here,
  -- and UNIQUE ignores NULLs. This is how two riders can never hold the same order.
  active_order_id INT AS (IF(delivery_status = 'FAILED', NULL, order_id)) STORED,
  CONSTRAINT uq_deliveries_active_order UNIQUE (active_order_id),
  CONSTRAINT fk_deliveries_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
  CONSTRAINT fk_deliveries_rider FOREIGN KEY (rider_id) REFERENCES riders(rider_id),
  CONSTRAINT ck_deliveries_code     CHECK (delivery_code IS NULL OR REGEXP_LIKE(delivery_code, '^[0-9]{4}$')),
  CONSTRAINT ck_deliveries_attempts CHECK (code_attempts BETWEEN 0 AND 5),
  CONSTRAINT ck_deliveries_failed   CHECK (delivery_status <> 'FAILED' OR failure_reason IS NOT NULL),
  CONSTRAINT ck_deliveries_done     CHECK (delivery_status <> 'DELIVERED' OR delivered_at IS NOT NULL),
  INDEX ix_deliveries_rider_status (rider_id, delivery_status),
  INDEX ix_deliveries_delivered_at (delivered_at)
) ENGINE=InnoDB;
