SELECT (SELECT COUNT(*) FROM order_reviews_dedup)                    AS dedup_rows,
       (SELECT COUNT(DISTINCT order_id) FROM order_reviews)          AS distinct_review_orders,
       (SELECT COUNT(*) FROM order_delivery)                         AS delivered_rows,
       (SELECT COUNT(*) FROM order_delivery WHERE review_score IS NULL) AS delivered_no_review,
       (SELECT COUNT(*) FROM order_delivery WHERE is_late)           AS late_rows;