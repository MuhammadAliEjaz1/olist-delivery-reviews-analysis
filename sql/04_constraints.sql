ALTER TABLE customers ADD PRIMARY KEY (customer_id);
ALTER TABLE sellers ADD PRIMARY KEY (seller_id);
ALTER TABLE products ADD PRIMARY KEY (product_id);
ALTER TABLE product_category_translation ADD PRIMARY KEY (product_category_name);
ALTER TABLE orders ADD PRIMARY KEY (order_id);
ALTER TABLE order_items ADD PRIMARY KEY (order_id, order_item_id);
ALTER TABLE order_payments ADD PRIMARY KEY (order_id, payment_sequential);

ALTER TABLE orders ADD FOREIGN KEY (customer_id) REFERENCES customers (customer_id);
ALTER TABLE order_items ADD FOREIGN KEY (order_id) REFERENCES orders (order_id);
ALTER TABLE order_items ADD FOREIGN KEY (product_id) REFERENCES products (product_id);
ALTER TABLE order_items ADD FOREIGN KEY (seller_id) REFERENCES sellers (seller_id);
ALTER TABLE order_payments ADD FOREIGN KEY (order_id) REFERENCES orders (order_id);
ALTER TABLE order_reviews ADD FOREIGN KEY (order_id) REFERENCES orders (order_id);

CREATE INDEX idx_orders_customer ON orders (customer_id);
CREATE INDEX idx_items_product ON order_items (product_id);
CREATE INDEX idx_items_seller ON order_items (seller_id);
CREATE INDEX idx_reviews_order ON order_reviews (order_id);
CREATE INDEX idx_customers_unique ON customers (customer_unique_id);