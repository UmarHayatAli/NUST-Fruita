-- V040: shopping cart, wishlist and editable site settings (F13, F12, F53).

-- One cart per customer, created on the first add (users-carts is 1 : 0..1, change C11).
CREATE TABLE carts (
  cart_id    INT AUTO_INCREMENT PRIMARY KEY,
  user_id    INT NOT NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT uq_carts_user UNIQUE (user_id),
  CONSTRAINT fk_carts_user FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

CREATE TABLE cart_items (
  cart_item_id INT AUTO_INCREMENT PRIMARY KEY,
  cart_id      INT NOT NULL,
  product_id   INT NOT NULL,
  quantity     DECIMAL(10,2) NOT NULL,
  CONSTRAINT uq_cart_items_line UNIQUE (cart_id, product_id),
  -- One of the two CASCADE foreign keys (change C5): cart lines belong to their cart.
  CONSTRAINT fk_cart_items_cart    FOREIGN KEY (cart_id)    REFERENCES carts(cart_id) ON DELETE CASCADE,
  CONSTRAINT fk_cart_items_product FOREIGN KEY (product_id) REFERENCES products(product_id),
  CONSTRAINT ck_cart_items_qty CHECK (quantity > 0)
) ENGINE=InnoDB;

CREATE TABLE wishlist_items (
  user_id    INT NOT NULL,
  product_id INT NOT NULL,
  added_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, product_id),
  CONSTRAINT fk_wishlist_user    FOREIGN KEY (user_id)    REFERENCES users(user_id),
  CONSTRAINT fk_wishlist_product FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

CREATE TABLE site_settings (
  setting_key   VARCHAR(50) PRIMARY KEY,
  setting_value TEXT NOT NULL,
  updated_by    INT NULL,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_settings_user FOREIGN KEY (updated_by) REFERENCES users(user_id)
) ENGINE=InnoDB;
