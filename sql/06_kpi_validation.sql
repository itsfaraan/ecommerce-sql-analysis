-- KPI validation for the Olist PostgreSQL portfolio project.
-- Execute after importing the five Olist tables.
-- This file is read-only: it does not modify any database tables.
--
-- Definitions:
--   product_revenue = SUM(order_items.price) for delivered orders
--   freight_value   = SUM(order_items.freight_value) for delivered orders
--   total_order_value = product_revenue + freight_value
--   AOV = total_order_value / distinct delivered orders
--   customer_unique_id is the repeat-customer identifier.
--   Monthly results are grouped by order purchase month, not delivery month.


-- 1. Reconcile order counts, item-based value, and AOV.
-- The LEFT JOIN keeps delivered orders with no matching item rows in the
-- order count; missing items are surfaced by the final column.
WITH delivered_orders AS (
    SELECT order_id
    FROM orders
    WHERE order_status = 'delivered'
),
order_values AS (
    SELECT
        d.order_id,
        SUM(oi.price) AS product_value,
        SUM(oi.freight_value) AS freight_value,
        COUNT(oi.order_id) AS item_rows
    FROM delivered_orders d
    LEFT JOIN order_items oi
        ON oi.order_id = d.order_id
    GROUP BY d.order_id
)
SELECT
    COUNT(*) AS delivered_orders,
    ROUND(SUM(product_value), 2) AS product_revenue,
    ROUND(SUM(freight_value), 2) AS freight_value,
    ROUND(SUM(product_value + freight_value), 2) AS total_order_value,
    ROUND(
        SUM(product_value + freight_value) / NULLIF(COUNT(*), 0),
        2
    ) AS average_order_value,
    COUNT(*) FILTER (WHERE item_rows = 0) AS delivered_orders_without_items
FROM order_values;


-- 2. Reconcile the all-record customer count with the delivered-only
-- customer population used for repeat-purchase calculations.
WITH delivered_customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS delivered_order_count
    FROM orders o
    JOIN customers c
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    (SELECT COUNT(DISTINCT customer_unique_id) FROM customers)
        AS unique_customers_all_records,
    COUNT(*) AS unique_customers_with_delivered_orders,
    SUM(delivered_order_count) AS delivered_orders_linked_to_customers,
    COUNT(*) FILTER (WHERE delivered_order_count > 1) AS repeat_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE delivered_order_count > 1)
        / NULLIF(COUNT(*), 0),
        2
    ) AS repeat_customer_rate_percent,
    ROUND(AVG(delivered_order_count), 2)
        AS average_delivered_orders_per_customer
FROM delivered_customer_orders;


-- 3. Monthly value for October and November 2017, including the
-- month-over-month percentage change. November growth is only calculated
-- when an October row is available.
WITH monthly_values AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
        SUM(oi.price + oi.freight_value) AS total_order_value
    FROM orders o
    JOIN order_items oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= DATE '2017-01-01'
      AND o.order_purchase_timestamp < DATE '2017-12-01'
    GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
),
monthly_growth AS (
    SELECT
        month,
        total_order_value,
        LAG(total_order_value) OVER (ORDER BY month)
            AS previous_month_value
    FROM monthly_values
)
SELECT
    TO_CHAR(month, 'YYYY-MM') AS purchase_month,
    ROUND(total_order_value, 2) AS total_order_value,
    ROUND(
        100.0 * (total_order_value - previous_month_value)
        / NULLIF(previous_month_value, 0),
        2
    ) AS growth_from_previous_available_month_percent
FROM monthly_growth
WHERE month IN (DATE '2017-10-01', DATE '2017-11-01')
ORDER BY month;


-- 4. Detect potential duplication of identifiers before interpreting
-- revenue and customer joins.
SELECT
    (SELECT COUNT(*) - COUNT(DISTINCT order_id) FROM orders)
        AS duplicate_order_ids,
    (SELECT COUNT(*) - COUNT(DISTINCT customer_id) FROM customers)
        AS duplicate_customer_ids,
    (SELECT COUNT(*) - COUNT(DISTINCT product_id) FROM products)
        AS duplicate_product_ids;
