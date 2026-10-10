-- Uniqueness: a count above 0 means the proposed key is not unique
SELECT 'orders: dup order_id' AS check_name,
       COUNT(*) - COUNT(DISTINCT order_id) AS problem_rows FROM orders
UNION ALL
SELECT 'customers: dup customer_id', COUNT(*) - COUNT(DISTINCT customer_id) FROM customers
UNION ALL
SELECT 'products: dup product_id', COUNT(*) - COUNT(DISTINCT product_id) FROM products
UNION ALL
SELECT 'sellers: dup seller_id', COUNT(*) - COUNT(DISTINCT seller_id) FROM sellers
UNION ALL
SELECT 'translation: dup category', COUNT(*) - COUNT(DISTINCT product_category_name) FROM product_category_translation
UNION ALL
SELECT 'order_items: dup (order_id, order_item_id)', COUNT(*) - COUNT(DISTINCT (order_id, order_item_id)) FROM order_items
UNION ALL
SELECT 'order_payments: dup (order_id, payment_sequential)', COUNT(*) - COUNT(DISTINCT (order_id, payment_sequential)) FROM order_payments
UNION ALL
SELECT 'order_reviews: dup review_id', COUNT(*) - COUNT(DISTINCT review_id) FROM order_reviews
UNION ALL
SELECT 'order_reviews: orders with more than 1 review', COUNT(*)
FROM (SELECT order_id FROM order_reviews GROUP BY order_id HAVING COUNT(*) > 1) t

-- Orphans: child rows whose parent is missing (a foreign key would reject these)
UNION ALL
SELECT 'orphan: orders.customer_id', COUNT(*) FROM orders o
WHERE NOT EXISTS (SELECT 1 FROM customers c WHERE c.customer_id = o.customer_id)
UNION ALL
SELECT 'orphan: order_items.order_id', COUNT(*) FROM order_items i
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.order_id = i.order_id)
UNION ALL
SELECT 'orphan: order_items.product_id', COUNT(*) FROM order_items i
WHERE NOT EXISTS (SELECT 1 FROM products p WHERE p.product_id = i.product_id)
UNION ALL
SELECT 'orphan: order_items.seller_id', COUNT(*) FROM order_items i
WHERE NOT EXISTS (SELECT 1 FROM sellers s WHERE s.seller_id = i.seller_id)
UNION ALL
SELECT 'orphan: order_payments.order_id', COUNT(*) FROM order_payments p
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.order_id = p.order_id)
UNION ALL
SELECT 'orphan: order_reviews.order_id', COUNT(*) FROM order_reviews r
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.order_id = r.order_id)
UNION ALL
SELECT 'orphan: products.category not in translation', COUNT(*) FROM products p
WHERE p.product_category_name IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM product_category_translation t
                  WHERE t.product_category_name = p.product_category_name);

-- Not a defect check: how many real people vs. per-order customer IDs?
SELECT COUNT(*) AS customer_rows,
       COUNT(DISTINCT customer_unique_id) AS distinct_people
FROM customers;