CREATE OR REPLACE VIEW order_reviews_dedup AS
SELECT order_id, review_id, review_score, review_creation_date, review_answer_timestamp
FROM (
    SELECT r.*,
           ROW_NUMBER() OVER (
               PARTITION BY order_id
               ORDER BY review_answer_timestamp DESC NULLS LAST, review_id
           ) AS rn
    FROM order_reviews r
) t
WHERE rn = 1;

CREATE OR REPLACE VIEW order_delivery AS
SELECT o.order_id,
       o.customer_id,
       o.order_purchase_timestamp,
       o.order_delivered_customer_date,
       o.order_estimated_delivery_date,
       o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date AS days_vs_estimate,
       o.order_delivered_customer_date::date > o.order_estimated_delivery_date::date AS is_late,
       r.review_score
FROM orders o
LEFT JOIN order_reviews_dedup r USING (order_id)
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL;