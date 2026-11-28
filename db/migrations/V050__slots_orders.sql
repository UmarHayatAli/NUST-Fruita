-- V050: delivery slots, orders and order lines (F17, F21, BR1, BR3, BR5, BR7).

CREATE TABLE delivery_slots (
  slot_id    INT AUTO_INCREMENT PRIMARY KEY,
  slot_date  DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time   TIME NOT NULL,
  max_orders INT  NOT NULL DEFAULT 30,
  is_active  BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT uq_slots_start UNIQUE (slot_date, start_time),
  CONSTRAINT ck_slots_time     CHECK (end_time > start_time),
  CONSTRAINT ck_slots_capacity CHECK (max_orders > 0),
  INDEX ix_slots_date_active (slot_date, is_active)
) ENGINE=InnoDB;

-- The address and WhatsApp number are copied onto the order (a deliberate snapshot),
-- so editing a saved address later never changes where an old order went (A8).
CREATE TABLE orders (
  order_id        INT AUTO_INCREMENT PRIMARY KEY,
  user_id         INT NOT NULL,
  slot_id         INT NOT NULL,
  whatsapp_number VARCHAR(20) NOT NULL,
  delivery_type   ENUM('HOSTEL','HOME') NOT NULL,
  hostel_id       INT NULL,
  block_or_wing   VARCHAR(30)  NULL,
  room_no         VARCHAR(20)  NULL,
  house_no        VARCHAR(30)  NULL,
  street_area     VARCHAR(150) NULL,
  city            VARCHAR(60)  NOT NULL DEFAULT 'Islamabad',
  landmark        VARCHAR(150) NULL,
  customer_note   VARCHAR(255) NULL,
  total_amount    DECIMAL(10,2) NOT NULL,                  -- snapshot = SUM(order_items.line_total)
  order_status    ENUM('PLACED','CONFIRMED','PACKED','OUT_FOR_DELIVERY','DELIVERED','CANCELLED')
                  NOT NULL DEFAULT 'PLACED',
  placed_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_orders_user   FOREIGN KEY (user_id)   REFERENCES users(user_id),
  CONSTRAINT fk_orders_slot   FOREIGN KEY (slot_id)   REFERENCES delivery_slots(slot_id),
  CONSTRAINT fk_orders_hostel FOREIGN KEY (hostel_id) REFERENCES hostels(hostel_id),
  CONSTRAINT ck_orders_whatsapp CHECK (REGEXP_LIKE(whatsapp_number, '^(03[0-9]{9}|\\+923[0-9]{9})$')),
  CONSTRAINT ck_orders_total    CHECK (total_amount >= 0),
  CONSTRAINT ck_orders_address CHECK (
    (delivery_type = 'HOSTEL' AND hostel_id IS NOT NULL AND room_no IS NOT NULL) OR
    (delivery_type = 'HOME'   AND hostel_id IS NULL AND house_no IS NOT NULL AND street_area IS NOT NULL)),
  INDEX ix_orders_user_placed   (user_id, placed_at),
  INDEX ix_orders_status_placed (order_status, placed_at)
) ENGINE=InnoDB;

CREATE TABLE order_items (
  order_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id      INT NOT NULL,
  product_id    INT NOT NULL,
  quantity      DECIMAL(10,2) NOT NULL,
  unit_price    DECIMAL(10,2) NOT NULL,                    -- price at purchase time (A5)
  -- Derived, never written: a STORED generated column cannot disagree with quantity x price (C6).
  line_total    DECIMAL(10,2) AS (ROUND(quantity * unit_price, 2)) STORED,
  CONSTRAINT uq_order_items_line UNIQUE (order_id, product_id),
  -- The second CASCADE foreign key (change C5).
  CONSTRAINT fk_order_items_order   FOREIGN KEY (order_id)   REFERENCES orders(order_id) ON DELETE CASCADE,
  CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products(product_id),
  CONSTRAINT ck_order_items_qty   CHECK (quantity > 0),
  CONSTRAINT ck_order_items_price CHECK (unit_price > 0),
  INDEX ix_order_items_product (product_id)
) ENGINE=InnoDB;
