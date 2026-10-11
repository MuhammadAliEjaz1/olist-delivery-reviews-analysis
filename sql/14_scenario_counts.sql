WITH orders_c AS (
    SELECT c.customer_unique_id AS cust, o.order_purchase_timestamp AS ts
    FROM orders o
    JOIN customers c USING (customer_id)
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
scen AS (
    SELECT * FROM (VALUES
        ('E', DATE '2018-01-01', 90),
        ('A', DATE '2018-03-01', 90),
        ('D', DATE '2018-04-01', 120),
        ('B', DATE '2018-05-01', 90),
        ('C', DATE '2018-06-01', 90)
    ) AS v(name, cutoff, win_days)
)
SELECT *, ROUND(100.0 * positives / population, 2) AS positive_pct
FROM (
    SELECT s.name, s.cutoff, s.win_days,
           s.cutoff + s.win_days * INTERVAL '1 day' AS window_end,
           (SELECT COUNT(DISTINCT cust) FROM orders_c
            WHERE ts < s.cutoff) AS population,
           (SELECT COUNT(DISTINCT a.cust) FROM orders_c a
            WHERE a.ts >= s.cutoff
              AND a.ts < s.cutoff + s.win_days * INTERVAL '1 day'
              AND EXISTS (SELECT 1 FROM orders_c b
                          WHERE b.cust = a.cust AND b.ts < s.cutoff)) AS positives
    FROM scen s
) t
ORDER BY cutoff;