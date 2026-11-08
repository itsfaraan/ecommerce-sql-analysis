# E-commerce Business Performance Analysis with PostgreSQL

**SQL portfolio case study | Revenue analytics · Customer behavior · Product performance · Business KPIs**

## Executive Summary

This project analyzes the **Olist Brazilian E-Commerce** dataset using PostgreSQL. The goal is to move beyond extracting rows and answer practical business questions: How is delivered-order value changing? Which categories contribute the most product revenue? How frequently do customers purchase again? What do payment records reveal about payment preferences?

The repository contains reproducible SQL queries for data exploration, revenue and product analysis, customer analysis, and advanced window-function reporting. Findings are **descriptive**, not evidence of causality or profitability.

## Business Questions

1. How much product revenue and freight value is associated with delivered orders?
2. How does delivered-order value vary over time, and which months perform best?
3. Which product categories lead by product revenue, unit volume, and average item price?
4. What share of delivered-order customers purchase more than once?
5. Which customers contribute the most delivered-order value?
6. How do payment-method records and order statuses distribute across the dataset?

## Data Source and Scope

**Source:** [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The analysis uses five related tables:

| Table | Analytical purpose |
| --- | --- |
| `customers` | Links order-specific customer IDs to persistent `customer_unique_id` |
| `orders` | Order status, purchase timestamp, and customer linkage |
| `order_items` | Item prices and freight values |
| `order_payments` | Payment method and payment-record information |
| `products` | Product categories and attributes |

The source CSV files are not committed to this repository. The SQL expects these tables to be loaded into PostgreSQL using the table and column names shown in the queries.

**Scope matters:** Most revenue and customer KPIs below use `orders.order_status = 'delivered'`. Exploratory payment-type and order-status distributions are dataset-wide unless explicitly filtered. Monthly figures are grouped by **purchase month**, not delivery month.

## Tools and Methods

- **PostgreSQL / SQL:** relational joins, aggregation, `CASE`, `HAVING`, CTEs, `FILTER`, and `NULLIF`
- **Analytical window functions:** `LAG()`, `RANK()`, and cumulative `SUM() OVER (...)`
- **Business analysis:** delivered-order value, AOV, customer repeat purchasing, category contribution, monthly trends
- **Workflow:** VS Code, Git, GitHub

## KPI Definitions

| Metric | Definition | Scope |
| --- | --- | --- |
| Product revenue | `SUM(order_items.price)` | Delivered orders |
| Freight value | `SUM(order_items.freight_value)` | Delivered orders |
| Total order value | `SUM(price + freight_value)` | Delivered orders |
| Delivered orders | `COUNT(DISTINCT orders.order_id)` | Delivered orders |
| Average order value (AOV) | Total order value / distinct delivered orders | Delivered orders |
| Unique customers — entire dataset | `COUNT(DISTINCT customers.customer_unique_id)` | All customer records |
| Delivered-order customers | Distinct `customer_unique_id` joined to delivered orders | Delivered orders |
| Repeat customers | Delivered-order customers with more than one distinct delivered order | Delivered orders |
| Repeat customer rate | Repeat customers / delivered-order customers × 100 | Delivered orders |

**Important distinctions:**
- `customer_id` is associated with an order; `customer_unique_id` is used to identify repeat purchasers.
- **Total order value is not profit.** It includes freight and does not subtract costs, refunds, or other expenses.
- Product-category revenue uses **item price only**, so it is not directly comparable with freight-inclusive total order value without adjusting the definition.
- Joining order items to payment rows can multiply values when an order has multiple items or payments. Queries avoid that join when calculating item-based revenue.

## Reported Key Metrics

The following are figures previously reported for this project; rerun the linked SQL on the source data to independently reproduce them.

| KPI | Reported value | Definition |
| --- | ---: | --- |
| Delivered orders | 96,478 | Distinct delivered order IDs |
| Product revenue | 13,221,498.11 | Sum of item prices for delivered orders |
| Freight value | 2,198,275.64 | Sum of freight for delivered orders |
| Total order value | 15,419,773.75 | Product revenue + freight |
| Average order value | 159.83 | Total order value / delivered orders |
| Unique customers (all customer records) | 96,096 | **Not** the delivered-only repeat-rate denominator |
| Repeat customer rate | Approximately 3.0% | Delivered-only customers, identified by `customer_unique_id` |
| Average delivered orders per customer | Approximately 1.03 | Delivered-only customers |

To obtain the **delivered-order unique-customer count and repeat-customer denominator**, run the validation query in [`04_customer_analysis.sql`](sql/04_customer_analysis.sql). The all-record count of 96,096 must not be substituted for that denominator.

## Analysis and Findings

### 1. Revenue and Monthly Performance

[`02_revenue_analysis.sql`](sql/02_revenue_analysis.sql) calculates product revenue, freight, total delivered-order value, AOV, and monthly delivered-order value.

- The reported total delivered-order value is approximately **15.42 million** in source-data monetary units.
- **November 2017** was reported as the strongest month at approximately **1.15 million**.
- A previously reported increase of approximately **53.6%** from October to November 2017 should be checked against the monthly query output before external publication.

**Business interpretation:** A strong revenue month may reflect a seasonal event, changes in order volume, higher order values, or a combination. These queries describe the pattern; they do not establish its cause.

### 2. Product-Category Performance

[`03_product_analysis.sql`](sql/03_product_analysis.sql) ranks categories by:
- Product revenue (excluding freight)
- Number of items sold
- Average item price, limited to categories with at least 100 sold items

**Business interpretation:** High unit volume does not necessarily mean high revenue; comparing volume, item price, and product revenue helps distinguish different category performance patterns. The 100-item threshold reduces instability in the average-price comparison.

### 3. Customer Behavior and Repeat Purchasing

[`04_customer_analysis.sql`](sql/04_customer_analysis.sql) measures:
- Highest-value customers based on delivered-order value
- Delivered-order repeat customers and repeat rate
- Average delivered orders per unique customer
- A reconciliation of **all-record customers** versus **delivered-order customers**

The reported delivered-only repeat rate is around **3%**, suggesting that repeat purchasing is relatively uncommon in this historical dataset.

**Business interpretation:** This is a descriptive observation, not proof that a particular retention campaign would succeed. The observation window, marketplace context, and dataset coverage limit conclusions about long-term loyalty.

### 4. Payment Methods and Order Status

[`01_data_exploration.sql`](sql/01_data_exploration.sql) inspects payment-type **record counts** and order statuses.

**Interpretation caution:** Counting rows in `order_payments` is not the same as counting distinct orders or calculating payment-method revenue. These are different business questions and should be labeled separately.

### 5. Advanced SQL Reporting

[`05_advanced_sql.sql`](sql/05_advanced_sql.sql) demonstrates:
- Month-over-month delivered-order value growth using `LAG()`
- Customer value ranking using `RANK()`
- Running cumulative monthly delivered-order value using `SUM() OVER (...)`

The monthly growth query starts in 2017 to reduce distortion from sparse 2016 observations. Missing months do not automatically appear as zero rows, so adjacent returned rows should not always be assumed to represent consecutive calendar months.

## Business Recommendations

These are **hypotheses for further investigation**, not validated interventions:

1. **Explore retention opportunities:** Segment first-time and repeat purchasers, then evaluate cohort-level repeat behavior before selecting campaigns.
2. **Separate value from volume:** Compare category product revenue, unit sales, and average item price rather than optimizing on one measure alone.
3. **Investigate seasonal peaks:** Compare November performance across periods and assess order count versus order value before attributing changes to promotions.
4. **Improve KPI consistency:** Define the order-status filter, customer identifier, and inclusion of freight before comparing metrics across reports.
5. **Build a monitoring layer:** Use a BI dashboard with documented measures and clear time-period coverage.

## Repository Structure

```text
ecommerce-sql-analysis/
├── sql/
│   ├── 01_data_exploration.sql
│   ├── 02_revenue_analysis.sql
│   ├── 03_product_analysis.sql
│   ├── 04_customer_analysis.sql
│   ├── 05_advanced_sql.sql
│   └── 06_kpi_validation.sql
├── README.md
└── .gitignore
```

## How to Reproduce

1. Download the Olist dataset from the linked source.
2. Create a PostgreSQL database and load the five required CSV tables with the expected column names and compatible data types.
3. Run `sql/01_data_exploration.sql` to inspect the imported data and distributions.
4. Run `sql/02_revenue_analysis.sql` and `sql/03_product_analysis.sql` for delivered-order and category KPIs.
5. Run `sql/04_customer_analysis.sql` to verify customer denominators and repeat behavior.
6. Run `sql/05_advanced_sql.sql` for month-over-month growth, customer ranking, and running totals.
7. Run [`sql/06_kpi_validation.sql`](sql/06_kpi_validation.sql) to reconcile delivered-order value, customer denominators, October/November 2017 growth, and key identifier uniqueness. Compare the results with the reported KPI table before publishing or merging.

**Reproducibility note:** This repository contains analytical queries, not a complete ETL pipeline or database schema creation scripts. Table import and setup are prerequisites.

## Limitations

- Historical marketplace data may not represent current purchasing behavior.
- The observation window is finite; customers may purchase again outside it.
- Delivered-order filtering excludes other order statuses from primary sales/customer metrics.
- Freight-inclusive order value is not net revenue or profit.
- Payment records can have a different grain from orders and order items.
- Category labels come from the original product-category field; no translated-category mapping is included.
- Observational patterns and correlations do not establish causal drivers.
- Reported summary figures should be validated by rerunning SQL before use in external presentations.

## Portfolio Focus

This case study demonstrates how SQL can support a structured analytical workflow: defining business questions, choosing a consistent metric grain, checking denominators, identifying patterns, and communicating findings with appropriate limitations.
