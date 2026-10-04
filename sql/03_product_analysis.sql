-- Top 10 product categories by revenue
SELECT
    p.product_category_name,
    ROUND(SUM(oi.price), 2) AS product_revenue
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
  AND p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
ORDER BY product_revenue DESC
LIMIT 10;


-- Top 10 product categories by number of items sold
SELECT
    p.product_category_name,
    COUNT(*) AS items_sold
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
  AND p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
ORDER BY items_sold DESC
LIMIT 10;


-- Average product price by category
SELECT
    p.product_category_name,
    ROUND(AVG(oi.price), 2) AS avg_product_price
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
  AND p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
HAVING COUNT(*) >= 100
ORDER BY avg_product_price DESC
LIMIT 10;