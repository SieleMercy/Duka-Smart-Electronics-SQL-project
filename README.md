# Retail Sales & Customer Intelligence SQL Project

A comprehensive data analytics project examining retail sales performance, customer segmentation, profitability, and temporal trends for **Duka Smart Electronics** using PostgreSQL and DBeaver.


## 1. What the Project Is

This project models and analyzes a Kenyan retail business dataset containing customer details and transaction logs across multiple towns (such as Nairobi, Mombasa, Meru, and Machakos). 

The repository contains end-to-end analytical solutions answering **46 core business questions**, covering:
- **SQL Fundamentals & Filtering:** Basic selection, text matching, and range queries.
- **Aggregations & Grouping:** Calculating total revenue, average order values, and category performance, and filtering groups using `HAVING`.
- **Joins & Customer Analytics:** Inner and left joins to track customer lifetime spending and identify dormant clients.
- **Subqueries & CTEs:** Breaking down complex multi-step financial calculations, profit margins, and revenue shares into modular steps.
- **Window Functions:** Computing running totals (`SUM() OVER`), ranking (`RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`), month-over-month growth (`LAG()`, `LEAD()`), and customer tiering (`NTILE()`).
- **Advanced BI:** Creating database views, PL/pgSQL stored functions, and executive management reporting queries.


## 2. Database Schema & Business Rules

### Tables Overview
- **`customers`** (150 rows): Stores demographic data (`customer_id`, `customer_name`, `gender`, `city`, `registration_date`, `customer_segment`).
- **`orders`** (800 rows): Stores transaction details (`order_id`, `customer_id`, `order_date`, `product_name`, `product_category`, `quantity`, `unit_price`, `cost_price`, `discount`, `payment_method`, `order_status`).

### Financial Formulas
* **Revenue:** `quantity * unit_price * (1 - discount / 100)`
* **Cost:** `quantity * cost_price`
* **Profit:** `revenue - cost`
* **Profit Margin %:** `(profit / NULLIF(revenue, 0)) * 100`

## 3. How to Set It Up in DBeaver

Follow these steps to initialize your environment and load the database using **DBeaver**:

1. **Create the Database:**
   - Open DBeaver and connect to your PostgreSQL server.
   - Right-click on your connection or the **Databases** node, and select **Create → Database**.
   - Name the database **`retail_analytics`** and click **OK**.

2. **Connect to the New Database:**
   - Create a new connection profile specifically for `retail_analytics`, or switch your active editor connection profile so it targets the newly created `retail_analytics` database.

3. **Execute Setup Scripts Sequentially:**
   Open the setup script files in DBeaver's SQL Editor and run them in this exact order:
   - **`02_create_tables.sql`** — Creates the `customers` and `orders` tables with primary/foreign key constraints.
   - **`03_insert_customers.sql`** — Loads the 150 customer data records.
   - **`04_insert_orders.sql`** — Loads the 800 transactional order records.
   - **`05_verify_data.sql`** — Validates row counts, date ranges, and constraint integrity.

## 4. How to Run Your Queries

1. Open your main script file (`queries.sql`) inside DBeaver’s SQL Editor.
2. Verify that the active database selector in the DBeaver toolbar reads **`retail_analytics`**.
3. Highlight the specific query section or individual query you wish to execute.
4. Press **`Ctrl + Enter`**  to run the selected query.