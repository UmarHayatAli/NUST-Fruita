-- V070: order status audit trail and product reviews (BR23, BR9, F37, F50).

-- Written only by triggers on orders, with the acting user from @app_user_id (change C4).
CREATE TABLE order_status_history (
  history_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id   INT NOT NULL,
  status     ENUM('PLACED','CONFIRMED','PACKED','OUT_FOR_DELIVERY','DELIVERED','CANCELLED') NOT NULL,
  changed_by INT NOT NULL,
  changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_history_order FOREIGN KEY (order_id)   REFERENCES orders(order_id),
  CONSTRAINT fk_history_user  FOREIGN KEY (changed_by) REFERENCES users(user_id),
  INDEX ix_history_order_time (order_id, changed_at)
) ENGINE=InnoDB;

CREATE TABLE reviews (
  review_id     INT AUTO_INCREMENT PRIMARY KEY,
  order_item_id INT NOT NULL,
  user_id       INT NOT NULL,                              -- checked against the order by trigger
  product_id    INT NOT NULL,                              -- copied from the order item by trigger
  rating        TINYINT NOT NULL,
  comment       VARCHAR(500) NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_reviews_item    UNIQUE (order_item_id),    -- one review per order item (F37)
  CONSTRAINT fk_reviews_item    FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id),
  CONSTRAINT fk_reviews_user    FOREIGN KEY (user_id)       REFERENCES users(user_id),
  CONSTRAINT fk_reviews_product FOREIGN KEY (product_id)    REFERENCES products(product_id),
  CONSTRAINT ck_reviews_rating CHECK (rating BETWEEN 1 AND 5),
  INDEX ix_reviews_product (product_id)
) ENGINE=InnoDB;
