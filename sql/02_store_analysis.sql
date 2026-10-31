-- =========================================================
-- 02_SALES_ANALYSIS.SQL
-- Project: Superstore Sales Analysis
-- Database: superstore_db
-- Table: superstore
-- =========================================================


USE superstore_db;

-- OVERALL SALES PERFORMANCE

SELECT
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    SUM(Quantity) AS total_quantity,
    COUNT(DISTINCT `order_id`) AS total_orders,
    COUNT(DISTINCT `customer_id`) AS total_customers
FROM superstore;


-- SALES AND PROFIT BY YEAR

SELECT
    YEAR(STR_TO_DATE(order_date, '%Y-%m-%d')) AS order_year,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY order_year
ORDER BY order_year;

-- MONTHLY SALES ANALYSIS

SELECT
    DATE_FORMAT(
        STR_TO_DATE(`order_date`, '%Y-%m-%d'),
        '%Y-%m'
    ) AS sales_month,
    ROUND(SUM(Sales), 2) AS monthly_sales,
    ROUND(SUM(Profit), 2) AS monthly_profit
FROM superstore
GROUP BY sales_month
ORDER BY sales_month;

-- SALES BY CATEGORY 

SELECT
    Category,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    SUM(Quantity) AS total_quantity
FROM superstore
GROUP BY Category
ORDER BY total_sales DESC;

-- SALES BY SUB-CATEGORY

SELECT
    `sub-category`,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY `sub-category`
ORDER BY total_sales DESC;

-- SALES AND PROFIT BY REGION

SELECT
    Region,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY Region
ORDER BY total_sales DESC;

-- SALES  BY CUSTOMER SEGMENT

SELECT
    Segment,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    COUNT(DISTINCT `customer_id`) AS total_customers
FROM superstore
GROUP BY Segment
ORDER BY total_sales DESC;

-- TOP 10 PRODUCTS BY SALES

SELECT
    `product_name`,
    ROUND(SUM(Sales), 2) AS total_sales
FROM superstore
GROUP BY `product_name`
ORDER BY total_sales DESC
LIMIT 10;

-- TOP 10 MOST PROFITABLE PRODUCTS

SELECT
    `product_name`,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY `product_name`
ORDER BY total_profit DESC
LIMIT 10;

-- TOP 10 LOSS MAKING PRODUCTS

SELECT
    `product_name`,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY `product_name`
HAVING SUM(Profit) < 0
ORDER BY total_profit ASC
LIMIT 10;

-- SALES BY STATE

SELECT
    State,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY State
ORDER BY total_sales DESC;

-- TOP 10 CUSTOMERS BY SALES

SELECT
    `customer_id`,
    `customer_name`,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY `customer_id`, `customer_name`
ORDER BY total_sales DESC
LIMIT 10;

-- PROFIT MARGIN BY CATEGORY

SELECT
    Category,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS profit_margin_percentage
FROM superstore
GROUP BY Category
ORDER BY profit_margin_percentage DESC;

-- ANALYZE THE IMPACT OF DISCOUNTS

SELECT
    CASE
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount <= 0.20 THEN 'Low Discount'
        WHEN Discount <= 0.40 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_level,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    AVG(Discount) AS average_discount
FROM superstore
GROUP BY discount_level
ORDER BY average_discount;

-- SALES BY SHIPPING MODE

SELECT
    `ship_mode`,
    COUNT(DISTINCT `order_id`) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY `ship_mode`
ORDER BY total_sales DESC;

-- SALES BY REGION AND CATEGORY

SELECT
    Region,
    Category,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY Region, Category
ORDER BY Region, total_sales DESC;

-- ORDER WITH NEGATIVE PROFIT

SELECT
    `order_id`,
    `product_name`,
    Category,
    Sales,
    Discount,
    Profit
FROM superstore
WHERE Profit < 0
ORDER BY Profit ASC;

-- AVERAGE ORDER VALUE

SELECT
    ROUND(SUM(order_sales) / NULLIF(COUNT(*), 0), 2)
        AS average_order_value
FROM (
    SELECT
        `order_id`,
        SUM(Sales) AS order_sales
    FROM superstore
    GROUP BY `order_id`
) AS orders;

-- SALES BY CITY

SELECT
    City,
    State,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY City, State
ORDER BY total_sales DESC
LIMIT 10;

-- FINAL SALES SUMMARY

SELECT
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS profit_margin_percentage,
    SUM(Quantity) AS total_quantity,
    COUNT(DISTINCT `order_id`) AS total_orders,
    COUNT(DISTINCT `customer_id`) AS total_customers
FROM superstore;