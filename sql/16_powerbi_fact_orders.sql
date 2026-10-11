CREATE OR REPLACE VIEW v_fact_orders AS
WITH item_totals AS (
    SELECT order_id,
           COUNT(*)                  AS n_items,
           SUM(price)                AS items_price,
           SUM(freight_value)        AS freight_total,
           COUNT(DISTINCT seller_id) AS n_sellers
    FROM order_items
    GROUP BY order_id
)
SELECT d.order_id,
       c.customer_unique_id,
       c.customer_state,
       d.order_purchase_timestamp::date AS purchase_date,
       d.days_vs_estimate,
       d.is_late::int                   AS is_late,
       d.review_score,
       t.n_items,
       t.items_price,
       t.freight_total,
       t.n_sellers
FROM order_delivery d
JOIN customers c USING (customer_id)
LEFT JOIN item_totals t USING (order_id);

\copy (SELECT * FROM v_fact_orders) TO 'dashboard/fact_orders.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')