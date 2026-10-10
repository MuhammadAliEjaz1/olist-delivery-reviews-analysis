SELECT MIN(order_purchase_timestamp) AS first_order,
       MAX(order_purchase_timestamp) AS last_order
FROM orders;

WITH per_person AS (
    SELECT c.customer_unique_id, COUNT(*) AS n_orders
    FROM orders o
    JOIN customers c USING (customer_id)
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY c.customer_unique_id
)
SELECT COUNT(*)                                              AS people,
       COUNT(*) FILTER (WHERE n_orders >= 2)                 AS repeat_people,
       ROUND(100.0 * COUNT(*) FILTER (WHERE n_orders >= 2)
             / COUNT(*), 2)                                  AS repeat_pct
FROM per_person;