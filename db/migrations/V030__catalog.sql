-- V030: fruit categories (a tree) and products (spec 7.2, F07-F09, BR2, BR20).

CREATE TABLE categories (
  category_id        INT AUTO_INCREMENT PRIMARY KEY,
  category_name      VARCHAR(80) NOT NULL,
  parent_category_id INT NULL,
  CONSTRAINT uq_categories_name UNIQUE (category_name),
  -- "Not its own parent / no cycles" is enforced by trigger trg_categories_bu,
  -- because a CHECK constraint cannot use an AUTO_INCREMENT column.
  CONSTRAINT fk_categories_parent FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
) ENGINE=InnoDB;

CREATE TABLE products (
  product_id          INT AUTO_INCREMENT PRIMARY KEY,
  category_id         INT NOT NULL,
  product_name        VARCHAR(100) NOT NULL,
  description         TEXT NULL,
  health_tip          VARCHAR(255) NULL,
  unit                ENUM('KG','DOZEN','PIECE') NOT NULL,
  price               DECIMAL(10,2) NOT NULL,
  stock_qty           DECIMAL(10,2) NOT NULL DEFAULT 0,
  low_stock_threshold INT NOT NULL DEFAULT 10,
  low_stock_since     TIMESTAMP NULL,                      -- maintained by triggers (BR20)
  origin              VARCHAR(60)  NULL,
  image_url           VARCHAR(255) NULL,
  is_featured         BOOLEAN NOT NULL DEFAULT FALSE,
  is_active           BOOLEAN NOT NULL DEFAULT TRUE,
  created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(category_id),
  CONSTRAINT ck_products_price     CHECK (price > 0),
  CONSTRAINT ck_products_stock     CHECK (stock_qty >= 0),  -- BR2: stock never goes negative
  CONSTRAINT ck_products_threshold CHECK (low_stock_threshold >= 0),
  INDEX ix_products_category_active (category_id, is_active),
  FULLTEXT INDEX ft_products_search (product_name, description)
) ENGINE=InnoDB;
