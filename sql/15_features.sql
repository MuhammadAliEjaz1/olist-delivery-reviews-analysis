WITH base AS (
    SELECT c.customer_unique_id AS cust, c.customer_state, o.order_id,
           o.order_purchase_timestamp      AS ts,
           o.order_delivered_customer_date AS delivered,
           o.order_estimated_delivery_date AS est
    FROM orders o
    JOIN customers c USING (customer_id)
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
),
past AS (
    SELECT * FROM base WHERE ts < CAST(:cutoff AS date)
),
item_tot AS (
    SELECT order_id, COUNT(*) AS n_items,
           SUM(price) AS price, SUM(freight_value) AS freight
    FROM order_items GROUP BY order_id
),
rev AS (
    SELECT order_id, AVG(review_score) AS score
    FROM order_reviews
    WHERE review_answer_timestamp < CAST(:cutoff AS date)
    GROUP BY order_id
),
feat AS (
    SELECT p.cust,
           COUNT(*)                                      AS n_orders,
           CAST(:cutoff AS date) - MIN(p.ts)::date       AS days_since_first,
           CAST(:cutoff AS date) - MAX(p.ts)::date       AS days_since_last,
           COALESCE(SUM(t.price), 0)                     AS total_spend,
           COALESCE(SUM(t.freight), 0)                   AS total_freight,
           COALESCE(SUM(t.n_items), 0)                   AS total_items,
           COUNT(*) FILTER (WHERE p.delivered < CAST(:cutoff AS date)) AS n_delivered_known,
           COUNT(*) FILTER (WHERE p.delivered < CAST(:cutoff AS date)
                              AND p.delivered::date > p.est::date)     AS n_late_known,
           AVG(r.score)                                  AS avg_score_known
    FROM past p
    LEFT JOIN item_tot t USING (order_id)
    LEFT JOIN rev r USING (order_id)
    GROUP BY p.cust
),
last_state AS (
    SELECT DISTINCT ON (cust) cust, customer_state
    FROM past
    ORDER BY cust, ts DESC
),
label AS (
    SELECT DISTINCT cust FROM base
    WHERE ts >= CAST(:cutoff AS date)
      AND ts <  CAST(:cutoff AS date) + CAST(:win AS integer) * INTERVAL '1 day'
)
SELECT f.*, s.customer_state, (l.cust IS NOT NULL)::int AS label
FROM feat f
JOIN last_state s USING (cust)
LEFT JOIN label l USING (cust);