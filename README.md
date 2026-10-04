### Customer Insights

- Only about 3% of customers placed more than one delivered order.
- The average number of delivered orders per customer was 1.03.
- This indicates very low repeat purchasing and suggests a strong opportunity for customer retention strategies.
- Several high-value customers generated substantial revenue from a single order, showing that revenue concentration does not necessarily imply loyalty.

# E-commerce SQL Analysis

## Project Overview

This project analyzes the Brazilian Olist e-commerce dataset using PostgreSQL.

The goal is to explore sales performance, customer behavior, product categories, payment methods, and revenue trends using SQL.

The project focuses on writing business-oriented queries rather than simple data extraction.

## Tools

- PostgreSQL
- SQL
- Git
- GitHub
- VS Code

## Dataset

The project uses the Olist Brazilian E-commerce dataset.

Main tables used:

- customers
- orders
- order_items
- order_payments
- products

The raw CSV files are excluded from this repository and can be downloaded from the original dataset source.

## SQL Skills Demonstrated

- SELECT
- JOIN
- GROUP BY
- HAVING
- CASE / filtering logic
- CTEs
- Aggregate functions
- Window Functions
- RANK()
- LAG()
- Running totals
- Monthly growth calculations

## Key Metrics

- Delivered Orders: 96,478
- Product Revenue: 13.22M
- Freight Value: 2.20M
- Total Order Value: 15.42M
- Average Order Value: 159.83
- Unique Customers: 96,096
- Repeat Customer Rate: 3.0%
- Average Orders per Customer: 1.03

## Key Insights

### Revenue Performance

- Total delivered-order value reached approximately 15.42M.
- November 2017 recorded the highest monthly revenue at approximately 1.15M.
- Revenue increased by approximately 53.6% from October to November 2017.
- Monthly revenue remained relatively stable around 1M during much of 2018.

### Customer Behavior

- Only around 3% of customers placed more than one delivered order.
- Average orders per customer was approximately 1.03.
- This suggests low repeat purchasing and a significant opportunity for customer retention.
- Several high-value customers generated large amounts of revenue from only one order.

### Payment Behavior

- Credit card was the most frequently used payment method.
- Boleto was the second most common payment method.

### Order Status

- The majority of orders were successfully delivered.
- A smaller number of orders were shipped, canceled, unavailable, processing, or invoiced.

## Advanced SQL Analysis

The project includes:

- Customer revenue ranking using `RANK()`
- Monthly cumulative revenue using window functions
- Month-over-month revenue growth using `LAG()`
- Customer repeat purchase analysis using CTEs

## Project Structure

```text
ecommerce-sql-analysis/
│
├── sql/
│   ├── 01_data_exploration.sql
│   ├── 02_revenue_analysis.sql
│   ├── 03_product_analysis.sql
│   ├── 04_customer_analysis.sql
│   └── 05_advanced_sql.sql
│
├── results/
├── README.md
└── .gitignore