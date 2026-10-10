WITH ranked AS (
    SELECT order_id, review_score,
           ROW_NUMBER() OVER (PARTITION BY order_id
               ORDER BY review_answer_timestamp DESC NULLS LAST, review_id) AS rn_latest,
           ROW_NUMBER() OVER (PARTITION BY order_id
               ORDER BY review_answer_timestamp ASC NULLS LAST, review_id)  AS rn_first,
           ROW_NUMBER() OVER (PARTITION BY order_id
               ORDER BY review_score ASC, review_id)                        AS rn_lowest
    FROM order_reviews
),
picked AS (
    SELECT order_id,
           MAX(review_score) FILTER (WHERE rn_latest = 1) AS score_latest,
           MAX(review_score) FILTER (WHERE rn_first  = 1) AS score_first,
           MAX(review_score) FILTER (WHERE rn_lowest = 1) AS score_lowest
    FROM ranked
    GROUP BY order_id
)
SELECT d.order_id, d.is_late, p.score_latest, p.score_first, p.score_lowest
FROM order_delivery d
JOIN picked p USING (order_id);