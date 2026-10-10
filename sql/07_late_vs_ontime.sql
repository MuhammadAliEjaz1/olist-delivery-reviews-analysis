SELECT is_late,
       COUNT(*)                                          AS n_orders,
       COUNT(review_score)                               AS n_reviewed,
       ROUND(AVG(review_score), 3)                       AS avg_score,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY review_score) AS median_score,
       ROUND(COUNT(*) FILTER (WHERE review_score = 1)::NUMERIC
             / COUNT(review_score), 3)                   AS pct_1_star
FROM order_delivery
GROUP BY is_late
ORDER BY is_late;