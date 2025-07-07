# Data Warehouse and Analytics Project

## 📊 Project Overview
This project focuses on building a **Data Warehouse** to consolidate and analyze data from multiple sources.  
It uses **ETL processes**, **star schema modeling**, and **SQL-based data transformations** to create a foundation for insightful business analytics.

---

## 🎯 Objectives
- Design and implement a scalable data warehouse schema (star schema with fact & dimension tables).
- Integrate multiple raw data sources into a unified model.
- Build ETL pipelines to transform and load data into the warehouse.
- Write analytical SQL queries to uncover business insights.
- Create visual dashboards for stakeholders (Power BI / Looker Studio / Tableau).

---

## 🛠 Technologies & Tools Used
- **SQL** ( MySQL)
- **ETL Scripts:** Python (pandas, psycopg2)
- **Visualization:** Power BI / Tableau
- **Git & GitHub** for version control

---

## 🗄️ Data Warehouse Schema


- **Fact Table:** `sales_fact`
  - sales_id (PK)
  - product_id (FK)
  - customer_id (FK)
  - store_id (FK)
  - time_id (FK)
  - quantity_sold
  - total_amount

- **Dimension Tables:**
  - `product_dim` (product details)
  - `customer_dim` (customer demographics)
  - `store_dim` (store locations)
  - `time_dim` (date breakdown)

---

## 🚀 ETL Pipeline
- Extract data from CSV / JSON sources.
- Clean & transform data using Python scripts.
- Load data into staging tables.
- Populate fact and dimension tables using `INSERT SELECT` statements.

---

## 🔍 Sample Analytical Queries
```sql
-- Total sales by product category
SELECT p.category, SUM(f.total_amount) AS total_sales
FROM sales_fact f
JOIN product_dim p ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY total_sales DESC;

-- Monthly sales trend
SELECT t.month, SUM(f.total_amount) AS monthly_sales
FROM sales_fact f
JOIN time_dim t ON f.time_id = t.time_id
GROUP BY t.month
ORDER BY t.month;
