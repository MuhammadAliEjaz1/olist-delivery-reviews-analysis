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
       c.customer_state,
       d.is_late,
       d.days_vs_estimate,
       d.review_score,
       t.n_items,
       t.items_price,
       t.freight_total,
       t.n_sellers
FROM order_delivery d
JOIN customers c USING (customer_id)
LEFT JOIN item_totals t USING (order_id)
WHERE d.review_score IS NOT NULL;