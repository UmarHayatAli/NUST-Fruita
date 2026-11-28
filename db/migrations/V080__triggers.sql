-- V080: the 10 triggers (spec 8.2). Triggers run automatically inside MySQL, so these
-- rules hold even if someone bypasses the API and uses a SQL client directly.
-- Errors use SIGNAL SQLSTATE '45000' with MESSAGE_TEXT 'ERR_CODE|Human message' (spec 8.1).

DELIMITER $$

-- ------------------------------------------------------------------------------------
-- Order status history (BR23, change C4)
-- ------------------------------------------------------------------------------------

-- First history row when an order is created. place_order sets @app_user_id to the
-- customer; if it is missing, the order's own user is used.
CREATE TRIGGER trg_orders_ai AFTER INSERT ON orders FOR EACH ROW
BEGIN
  INSERT INTO order_status_history (order_id, status, changed_by)
  VALUES (NEW.order_id, NEW.order_status, COALESCE(@app_user_id, NEW.user_id));
END$$

-- One history row per status change, recording who made it. Every stored procedure sets
-- @app_user_id before changing a status, so a plain "UPDATE orders SET order_status = ..."
-- typed by hand (without @app_user_id) is rejected. This forces all status changes
-- through the procedures.
CREATE TRIGGER trg_orders_au AFTER UPDATE ON orders FOR EACH ROW
BEGIN
  IF NEW.order_status <> OLD.order_status THEN
    IF @app_user_id IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERR_NO_ACTOR|Status changes must go through a procedure';
    END IF;
    INSERT INTO order_status_history (order_id, status, changed_by)
    VALUES (NEW.order_id, NEW.order_status, @app_user_id);
  END IF;
END$$

-- ------------------------------------------------------------------------------------
-- Low-stock tracking (BR20): low_stock_since records when stock first dropped to the
-- threshold, and is cleared when the product is restocked above it.
-- ------------------------------------------------------------------------------------

CREATE TRIGGER trg_products_bi BEFORE INSERT ON products FOR EACH ROW
BEGIN
  SET NEW.low_stock_since = IF(NEW.stock_qty <= NEW.low_stock_threshold, NOW(), NULL);
END$$

CREATE TRIGGER trg_products_bu BEFORE UPDATE ON products FOR EACH ROW
BEGIN
  IF NEW.stock_qty <= NEW.low_stock_threshold THEN
    -- Keep the original time if it was already low; otherwise start counting now.
    SET NEW.low_stock_since = COALESCE(OLD.low_stock_since, NOW());
  ELSE
    SET NEW.low_stock_since = NULL;
  END IF;
END$$

-- ------------------------------------------------------------------------------------
-- No category may be its own ancestor (a CHECK cannot express this).
-- Walks up the parent chain from the new parent; if it reaches this category, it is a cycle.
-- The depth limit stops the loop even if the data were somehow already broken.
-- ------------------------------------------------------------------------------------

CREATE TRIGGER trg_categories_bu BEFORE UPDATE ON categories FOR EACH ROW
BEGIN
  DECLARE v_cur INT DEFAULT NEW.parent_category_id;
  DECLARE v_depth INT DEFAULT 0;
  WHILE v_cur IS NOT NULL AND v_depth < 20 DO
    IF v_cur = NEW.category_id THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERR_VALIDATION|A category cannot be inside itself';
    END IF;
    SELECT parent_category_id INTO v_cur FROM categories WHERE category_id = v_cur;
    SET v_depth = v_depth + 1;
  END WHILE;
END$$

-- ------------------------------------------------------------------------------------
-- BR11: only users with role RIDER may have a riders row (riders is a subtype of users).
-- ------------------------------------------------------------------------------------

CREATE TRIGGER trg_riders_bi BEFORE INSERT ON riders FOR EACH ROW
BEGIN
  IF (SELECT role FROM users WHERE user_id = NEW.rider_id) <> 'RIDER' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERR_VALIDATION|Only users with role RIDER can be riders';
  END IF;
END$$

-- ------------------------------------------------------------------------------------
-- BR21: quantity steps. DOZEN and PIECE must be whole numbers; KG must be a multiple of
-- 0.25 (1.5 kg is fine, 0.3 kg is not). The same body is used in three triggers.
-- ------------------------------------------------------------------------------------

CREATE TRIGGER trg_cart_items_bi BEFORE INSERT ON cart_items FOR EACH ROW
BEGIN
  DECLARE v_unit VARCHAR(10);
  SELECT unit INTO v_unit FROM products WHERE product_id = NEW.product_id;
  IF (v_unit IN ('DOZEN','PIECE') AND NEW.quantity <> FLOOR(NEW.quantity))
     OR (v_unit = 'KG' AND MOD(NEW.quantity * 100, 25) <> 0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERR_QUANTITY_STEP|Whole numbers for dozen and piece, 0.25 kg steps for kg';
  END IF;
END$$

CREATE TRIGGER trg_cart_items_bu BEFORE UPDATE ON cart_items FOR EACH ROW
BEGIN
  DECLARE v_unit VARCHAR(10);
  SELECT unit INTO v_unit FROM products WHERE product_id = NEW.product_id;
  IF (v_unit IN ('DOZEN','PIECE') AND NEW.quantity <> FLOOR(NEW.quantity))
     OR (v_unit = 'KG' AND MOD(NEW.quantity * 100, 25) <> 0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERR_QUANTITY_STEP|Whole numbers for dozen and piece, 0.25 kg steps for kg';
  END IF;
END$$

CREATE TRIGGER trg_order_items_bi BEFORE INSERT ON order_items FOR EACH ROW
BEGIN
  DECLARE v_unit VARCHAR(10);
  SELECT unit INTO v_unit FROM products WHERE product_id = NEW.product_id;
  IF (v_unit IN ('DOZEN','PIECE') AND NEW.quantity <> FLOOR(NEW.quantity))
     OR (v_unit = 'KG' AND MOD(NEW.quantity * 100, 25) <> 0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERR_QUANTITY_STEP|Whole numbers for dozen and piece, 0.25 kg steps for kg';
  END IF;
END$$

-- ------------------------------------------------------------------------------------
-- BR9: a review is allowed only for an item from the reviewer's own DELIVERED order.
-- product_id is always copied from the order item, whatever the client sent (test T34).
-- ------------------------------------------------------------------------------------

CREATE TRIGGER trg_reviews_bi BEFORE INSERT ON reviews FOR EACH ROW
BEGIN
  DECLARE v_owner INT; DECLARE v_product INT; DECLARE v_status VARCHAR(20);
  SELECT o.user_id, oi.product_id, o.order_status INTO v_owner, v_product, v_status
  FROM order_items oi JOIN orders o ON o.order_id = oi.order_id
  WHERE oi.order_item_id = NEW.order_item_id;
  IF v_owner IS NULL OR v_owner <> NEW.user_id OR v_status <> 'DELIVERED' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERR_REVIEW_NOT_ALLOWED|You can review only items from your delivered orders';
  END IF;
  SET NEW.product_id = v_product;
END$$

DELIMITER ;
