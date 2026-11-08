-- Monthly revenue growth from 2017 onward

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2017-01-01'
    GROUP BY month
),

revenue_with_previous AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM monthly_revenue
)

SELECT
    month,
    revenue,
    previous_month_revenue,
    ROUND(
        100.0 * (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS growth_rate_percent
FROM revenue_with_previous
ORDER BY month;

-- Rank customers by delivered-order value (product price + freight).
-- Aggregate to the customer grain before applying the ranking window.
WITH customer_value AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS delivered_orders,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS total_order_value
    FROM customers c
    JOIN orders o
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    delivered_orders,
    total_order_value,
    RANK() OVER (ORDER BY total_order_value DESC) AS value_rank
FROM customer_value
ORDER BY value_rank, customer_unique_id
LIMIT 20;


-- Cumulative delivered-order value by purchase month.
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS total_order_value
    FROM orders o
    JOIN order_items oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
)
SELECT
    month,
    total_order_value,
    SUM(total_order_value) OVER (
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_order_value
FROM monthly_revenue
ORDER BY month;
