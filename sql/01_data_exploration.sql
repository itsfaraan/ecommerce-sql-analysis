-- Preview customers
SELECT *
FROM customers
LIMIT 5;

-- Preview orders
SELECT *
FROM orders
LIMIT 5;

-- Preview order items
SELECT *
FROM order_items
LIMIT 5;

-- Preview payments
SELECT *
FROM order_payments
LIMIT 5;

-- Preview products
SELECT *
FROM products
LIMIT 5;

-- Order status distribution
SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Payment type distribution
SELECT
    payment_type,
    COUNT(*) AS payment_count
FROM order_payments
GROUP BY payment_type
ORDER BY payment_count DESC;

-- Unique customers
SELECT
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers;

-- Join customers and orders
SELECT
    o.order_id,
    c.customer_unique_id,
    o.order_status,
    o.order_purchase_timestamp
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
LIMIT 10;