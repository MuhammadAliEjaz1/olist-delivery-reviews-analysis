WITH purchases AS (
    SELECT DISTINCT c.customer_unique_id,
           DATE_TRUNC('month', o.order_purchase_timestamp)::date AS order_month
    FROM orders o
    JOIN customers c USING (customer_id)
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
cohorts AS (
    SELECT customer_unique_id, order_month,
           MIN(order_month) OVER (PARTITION BY customer_unique_id) AS cohort_month
    FROM purchases
),
indexed AS (
    SELECT cohort_month,
           (EXTRACT(YEAR FROM order_month) - EXTRACT(YEAR FROM cohort_month)) * 12
         + (EXTRACT(MONTH FROM order_month) - EXTRACT(MONTH FROM cohort_month)) AS months_since
    FROM cohorts
),
counts AS (
    SELECT cohort_month, months_since::int AS months_since, COUNT(*) AS active_users
    FROM indexed
    GROUP BY 1, 2
)
SELECT cohort_month,
       MAX(active_users) FILTER (WHERE months_since = 0) AS cohort_size,
       ROUND(100.0 * MAX(active_users) FILTER (WHERE months_since = 1)
             / MAX(active_users) FILTER (WHERE months_since = 0), 2) AS m1_pct,
       ROUND(100.0 * MAX(active_users) FILTER (WHERE months_since = 2)
             / MAX(active_users) FILTER (WHERE months_since = 0), 2) AS m2_pct,
       ROUND(100.0 * MAX(active_users) FILTER (WHERE months_since = 3)
             / MAX(active_users) FILTER (WHERE months_since = 0), 2) AS m3_pct,
       ROUND(100.0 * MAX(active_users) FILTER (WHERE months_since = 6)
             / MAX(active_users) FILTER (WHERE months_since = 0), 2) AS m6_pct
FROM counts
GROUP BY cohort_month
HAVING MAX(active_users) FILTER (WHERE months_since = 0) >= 100
ORDER BY cohort_month;