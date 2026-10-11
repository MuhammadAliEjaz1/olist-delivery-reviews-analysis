CREATE OR REPLACE VIEW v_seller_summary AS
WITH seller_orders AS (
    SELECT DISTINCT i.seller_id, d.order_id, d.is_late, d.review_score
    FROM order_items i
    JOIN order_delivery d USING (order_id)
)
SELECT so.seller_id,
       s.seller_state,
       COUNT(*)                                  AS n_orders,
       COUNT(*) FILTER (WHERE so.is_late)        AS n_late,
       ROUND(COUNT(*) FILTER (WHERE so.is_late)::NUMERIC / COUNT(*), 4) AS late_rate,
       ROUND(AVG(so.review_score), 3)            AS avg_score
FROM seller_orders so
JOIN sellers s USING (seller_id)
GROUP BY so.seller_id, s.seller_state;

CREATE OR REPLACE VIEW v_cohort_retention AS
WITH purchases AS (
    SELECT DISTINCT c.customer_unique_id,
           DATE_TRUNC('month', o.order_purchase_timestamp)::date AS order_month
    FROM orders o
    JOIN customers c USING (customer_id)
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
      AND o.order_purchase_timestamp < DATE '2018-09-01'
),
cohorts AS (
    SELECT customer_unique_id, order_month,
           MIN(order_month) OVER (PARTITION BY customer_unique_id) AS cohort_month
    FROM purchases
),
indexed AS (
    SELECT cohort_month,
           ((EXTRACT(YEAR FROM order_month) - EXTRACT(YEAR FROM cohort_month)) * 12
            + EXTRACT(MONTH FROM order_month) - EXTRACT(MONTH FROM cohort_month))::int AS months_since
    FROM cohorts
),
counts AS (
    SELECT cohort_month, months_since, COUNT(*) AS active_users
    FROM indexed
    GROUP BY 1, 2
)
SELECT c.cohort_month, c.months_since, c.active_users,
       z.active_users AS cohort_size,
       ROUND(100.0 * c.active_users / z.active_users, 2) AS retention_pct
FROM counts c
JOIN counts z ON z.cohort_month = c.cohort_month AND z.months_since = 0
WHERE z.active_users >= 100;

\copy (SELECT * FROM v_seller_summary) TO 'dashboard/seller_summary.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy (SELECT * FROM v_cohort_retention ORDER BY cohort_month, months_since) TO 'dashboard/cohort_retention.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')