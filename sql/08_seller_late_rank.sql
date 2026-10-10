WITH seller_orders AS (
    SELECT DISTINCT i.seller_id, d.order_id, d.is_late
    FROM order_items i
    JOIN order_delivery d USING (order_id)
),
seller_stats AS (
    SELECT seller_id,
           COUNT(*)                                   AS n_orders,
           COUNT(*) FILTER (WHERE is_late)            AS n_late,
           ROUND(COUNT(*) FILTER (WHERE is_late)::NUMERIC / COUNT(*), 3) AS late_rate
    FROM seller_orders
    GROUP BY seller_id
    HAVING COUNT(*) >= 30
)
SELECT seller_id, n_orders, n_late, late_rate,
       RANK() OVER (ORDER BY late_rate DESC) AS late_rank
FROM seller_stats
ORDER BY late_rank, n_orders DESC
LIMIT 15;