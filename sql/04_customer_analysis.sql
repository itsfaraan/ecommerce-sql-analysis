-- Top 10 customers by total order value
SELECT
    c.customer_unique_id,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS customer_value,
    COUNT(DISTINCT o.order_id) AS orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY customer_value DESC
LIMIT 10;


-- Repeat customers
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)

SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE order_count > 1) AS repeat_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE order_count > 1)
        / COUNT(*),
        2
    ) AS repeat_customer_rate
FROM customer_orders;


-- Average number of orders per customer
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)

SELECT
    ROUND(AVG(order_count), 2) AS avg_orders_per_customer
FROM customer_orders;

-- Reconcile all customers with the delivered-order customer population.
-- customer_id identifies an order-specific customer record; customer_unique_id
-- is the identifier used for repeat purchasing across orders.
SELECT
    (SELECT COUNT(DISTINCT customer_unique_id) FROM customers)
        AS unique_customers_all_records,
    COUNT(DISTINCT c.customer_unique_id)
        AS unique_customers_with_delivered_orders,
    COUNT(DISTINCT o.order_id)
        AS delivered_orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered';
