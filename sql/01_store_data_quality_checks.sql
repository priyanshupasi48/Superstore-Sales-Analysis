-- =========================================================
-- 01_DATA_QUALITY_CHECKS.SQL
-- Project: Superstore Sales Analysis
-- Database: superstore_db
-- Table: superstore
-- =========================================================

USE superstore_db;


-- =========================================================
-- 1. DATASET OVERVIEW
-- =========================================================

-- 1.1 Total rows
SELECT COUNT(*) AS total_rows
FROM superstore;

-- 1.2 Total columns
SELECT COUNT(*) AS total_columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'superstore_db'
  AND TABLE_NAME = 'superstore';

-- 1.3 Table structure and data types
DESCRIBE superstore;

-- 1.4 Preview records
SELECT *
FROM superstore
LIMIT 10;

-- 1.5 Unique orders, customers and products
SELECT
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT product_id) AS unique_products
FROM superstore;


-- =========================================================
-- 2. DUPLICATE CHECKS
-- =========================================================

-- 2.1 Duplicate row IDs
SELECT
    row_id,
    COUNT(*) AS occurrences
FROM superstore
GROUP BY row_id
HAVING COUNT(*) > 1;

-- 2.2 Exact duplicate records across all 21 columns
SELECT
    row_id,
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code,
    region,
    product_id,
    category,
    `sub-category`,
    product_name,
    sales,
    quantity,
    discount,
    profit,
    COUNT(*) AS occurrences
FROM superstore
GROUP BY
    row_id,
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code,
    region,
    product_id,
    category,
    `sub-category`,
    product_name,
    sales,
    quantity,
    discount,
    profit
HAVING COUNT(*) > 1;

-- 2.3 Repeated order and product combinations
SELECT
    order_id,
    product_id,
    COUNT(*) AS occurrences
FROM superstore
GROUP BY order_id, product_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;


-- =========================================================
-- 3. MISSING-VALUE CHECKS
-- =========================================================

-- 3.1 Missing values in important columns
SELECT
    COUNT(*) AS total_rows,
    SUM(order_id IS NULL OR TRIM(order_id) = '') AS missing_order_id,
    SUM(customer_id IS NULL OR TRIM(customer_id) = '') AS missing_customer_id,
    SUM(product_id IS NULL OR TRIM(product_id) = '') AS missing_product_id,
    SUM(customer_name IS NULL OR TRIM(customer_name) = '') AS missing_customer_name,
    SUM(product_name IS NULL OR TRIM(product_name) = '') AS missing_product_name,
    SUM(category IS NULL OR TRIM(category) = '') AS missing_category,
    SUM(`sub-category` IS NULL OR TRIM(`sub-category`) = '') AS missing_sub_category,
    SUM(sales IS NULL) AS missing_sales,
    SUM(profit IS NULL) AS missing_profit,
    SUM(quantity IS NULL) AS missing_quantity,
    SUM(discount IS NULL) AS missing_discount,
    SUM(order_date IS NULL) AS missing_order_date,
    SUM(ship_date IS NULL) AS missing_ship_date
FROM superstore;

-- 3.2 Find rows with blank or missing identifiers
SELECT *
FROM superstore
WHERE order_id IS NULL OR TRIM(order_id) = ''
   OR customer_id IS NULL OR TRIM(customer_id) = ''
   OR product_id IS NULL OR TRIM(product_id) = '';

-- 3.3 Find blank product and category information
SELECT *
FROM superstore
WHERE product_name IS NULL OR TRIM(product_name) = ''
   OR category IS NULL OR TRIM(category) = ''
   OR `sub-category` IS NULL OR TRIM(`sub-category`) = '';

-- 3.4 Find blank text values in other important columns
SELECT *
FROM superstore
WHERE customer_name IS NULL OR TRIM(customer_name) = ''
   OR segment IS NULL OR TRIM(segment) = ''
   OR ship_mode IS NULL OR TRIM(ship_mode) = ''
   OR region IS NULL OR TRIM(region) = '';


-- =========================================================
-- 4. INVALID NUMERICAL VALUES
-- =========================================================

-- 4.1 Zero or negative sales
SELECT *
FROM superstore
WHERE sales <= 0;

-- 4.2 Zero or negative quantity
SELECT *
FROM superstore
WHERE quantity <= 0;

-- 4.3 Discounts outside the expected 0 to 1 range
SELECT *
FROM superstore
WHERE discount < 0 OR discount > 1;

-- 4.4 Missing numerical values
SELECT *
FROM superstore
WHERE sales IS NULL
   OR profit IS NULL
   OR quantity IS NULL
   OR discount IS NULL;

-- 4.5 Negative profit records for investigation
SELECT
    order_id,
    product_id,
    sales,
    discount,
    profit
FROM superstore
WHERE profit < 0
ORDER BY profit ASC;


-- =========================================================
-- 5. DATE VALIDATION
-- =========================================================

-- 5.1 Missing order and shipping dates
SELECT *
FROM superstore
WHERE order_date IS NULL
   OR ship_date IS NULL;

-- 5.2 Shipping date earlier than order date
SELECT *
FROM superstore
WHERE order_date IS NOT NULL
  AND ship_date IS NOT NULL
  AND ship_date < order_date;

-- 5.3 Earliest and latest dates
SELECT
    MIN(order_date) AS earliest_order_date,
    MAX(order_date) AS latest_order_date,
    MIN(ship_date) AS earliest_ship_date,
    MAX(ship_date) AS latest_ship_date
FROM superstore;

-- 5.4 Shipping duration in days
SELECT
    order_id,
    order_date,
    ship_date,
    DATEDIFF(ship_date, order_date) AS shipping_days
FROM superstore
WHERE order_date IS NOT NULL
  AND ship_date IS NOT NULL
ORDER BY shipping_days DESC;

-- 5.5 Negative shipping duration check
SELECT COUNT(*) AS invalid_shipping_records
FROM superstore
WHERE ship_date < order_date;


-- =========================================================
-- 6. CATEGORY AND TEXT CONSISTENCY
-- =========================================================

-- 6.1 Distinct categories
SELECT DISTINCT category
FROM superstore
ORDER BY category;

-- 6.2 Distinct sub-categories
SELECT DISTINCT `sub-category`
FROM superstore
ORDER BY `sub-category`;

-- 6.3 Distinct customer segments
SELECT DISTINCT segment
FROM superstore
ORDER BY segment;

-- 6.4 Distinct shipping modes
SELECT DISTINCT ship_mode
FROM superstore
ORDER BY ship_mode;

-- 6.5 Leading or trailing spaces in text fields
SELECT *
FROM superstore
WHERE (customer_name IS NOT NULL
       AND customer_name <> TRIM(customer_name))
   OR (product_name IS NOT NULL
       AND product_name <> TRIM(product_name))
   OR (category IS NOT NULL
       AND category <> TRIM(category))
   OR (`sub-category` IS NOT NULL
       AND `sub-category` <> TRIM(`sub-category`))
   OR (segment IS NOT NULL
       AND segment <> TRIM(segment))
   OR (ship_mode IS NOT NULL
       AND ship_mode <> TRIM(ship_mode));

-- 6.6 Check unexpected category values
SELECT *
FROM superstore
WHERE category IS NOT NULL
  AND category NOT IN ('Furniture', 'Office Supplies', 'Technology');

-- 6.7 Check unexpected customer segments
SELECT *
FROM superstore
WHERE segment IS NOT NULL
  AND segment NOT IN ('Consumer', 'Corporate', 'Home Office');

-- 6.8 Check unexpected shipping modes
SELECT *
FROM superstore
WHERE ship_mode IS NOT NULL
  AND ship_mode NOT IN (
      'Second Class',
      'Standard Class',
      'First Class',
      'Same Day'
  );


-- =========================================================
-- 7. GEOGRAPHICAL DATA CHECKS
-- =========================================================

-- 7.1 Missing geographical information
SELECT *
FROM superstore
WHERE country IS NULL OR TRIM(country) = ''
   OR city IS NULL OR TRIM(city) = ''
   OR state IS NULL OR TRIM(state) = ''
   OR region IS NULL OR TRIM(region) = '';

-- 7.2 Missing postal codes
SELECT *
FROM superstore
WHERE postal_code IS NULL
   OR TRIM(postal_code) = '';

-- 7.3 Distinct regions
SELECT DISTINCT region
FROM superstore
ORDER BY region;

-- 7.4 Check states assigned to multiple regions
SELECT
    state,
    COUNT(DISTINCT region) AS region_count
FROM superstore
WHERE state IS NOT NULL
  AND region IS NOT NULL
GROUP BY state
HAVING COUNT(DISTINCT region) > 1
ORDER BY region_count DESC;

-- Review these results before deciding they are errors:
-- some states may legitimately have records in multiple regions
-- depending on the dataset's geographic definitions.


-- =========================================================
-- 8. OUTLIER CHECKS
-- =========================================================

-- 8.1 Unusually high sales
-- Flags sales greater than mean + 3 standard deviations
SELECT *
FROM superstore
WHERE sales > (
    SELECT AVG(sales) + 3 * STDDEV_POP(sales)
    FROM superstore
)
ORDER BY sales DESC;

-- 8.2 Large quantities
SELECT *
FROM superstore
WHERE quantity > 20
ORDER BY quantity DESC;

-- 8.3 High discounts
SELECT *
FROM superstore
WHERE discount > 0.50
ORDER BY discount DESC;

-- 8.4 Extreme profits and losses
SELECT *
FROM superstore
WHERE profit > (
    SELECT AVG(profit) + 3 * STDDEV_POP(profit)
    FROM superstore
)
OR profit < (
    SELECT AVG(profit) - 3 * STDDEV_POP(profit)
    FROM superstore
)
ORDER BY profit;

-- Investigate flagged records.
-- An outlier is not automatically an error.


-- =========================================================
-- 9. FINAL DATA QUALITY SUMMARY
-- =========================================================

SELECT
    COUNT(*) AS total_records,

    COUNT(DISTINCT row_id) AS unique_row_ids,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT product_id) AS unique_products,

    SUM(row_id IS NULL) AS missing_row_ids,

    SUM(order_id IS NULL OR TRIM(order_id) = '')
        AS missing_order_ids,

    SUM(customer_id IS NULL OR TRIM(customer_id) = '')
        AS missing_customer_ids,

    SUM(product_id IS NULL OR TRIM(product_id) = '')
        AS missing_product_ids,

    SUM(customer_name IS NULL OR TRIM(customer_name) = '')
        AS missing_customer_names,

    SUM(product_name IS NULL OR TRIM(product_name) = '')
        AS missing_product_names,

    SUM(category IS NULL OR TRIM(category) = '')
        AS missing_categories,

    SUM(`sub-category` IS NULL OR TRIM(`sub-category`) = '')
        AS missing_sub_categories,

    SUM(order_date IS NULL) AS missing_order_dates,
    SUM(ship_date IS NULL) AS missing_ship_dates,

    SUM(sales IS NULL) AS missing_sales,
    SUM(profit IS NULL) AS missing_profit,
    SUM(quantity IS NULL) AS missing_quantity,
    SUM(discount IS NULL) AS missing_discount,

    SUM(sales <= 0) AS nonpositive_sales,
    SUM(quantity <= 0) AS nonpositive_quantity,

    SUM(discount < 0 OR discount > 1)
        AS invalid_discounts,

    SUM(profit < 0) AS loss_making_records,

    SUM(
        order_date IS NOT NULL
        AND ship_date IS NOT NULL
        AND ship_date < order_date
    ) AS invalid_shipping_dates

FROM superstore;

-- END OF DATA QUALITY CHECKS
