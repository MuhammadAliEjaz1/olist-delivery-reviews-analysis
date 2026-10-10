SELECT DATE_TRUNC('month', order_purchase_timestamp)::date AS month,
       COUNT(*) AS orders
FROM orders
WHERE order_purchase_timestamp >= '2018-06-01'
GROUP BY 1
ORDER BY 1;