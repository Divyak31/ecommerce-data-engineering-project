-- 08_kpis.sql
-- Business KPI and analytical queries

USE ecommerce_de;


-- =====================================================
-- 1. TOTAL SALES BY CUSTOMER
-- =====================================================

SELECT
    dc.customer_id,
    COALESCE(SUM(f.item_amount), 0) AS total_sales
FROM dim_customer dc
LEFT JOIN fact_order_items f
    ON dc.customer_key = f.customer_key
GROUP BY dc.customer_id;


-- =====================================================
-- 2. TOTAL SALES BY PRODUCT CATEGORY
-- =====================================================

SELECT
    dp.category,
    COALESCE(SUM(f.item_amount), 0) AS total_sales
FROM dim_product dp
JOIN fact_order_items f
    ON dp.product_key = f.product_key
GROUP BY dp.category;


-- =====================================================
-- 3. CUSTOMER WITH HIGHEST TOTAL SALES
-- Tie-aware approach
-- =====================================================

WITH customer_sales AS (
    SELECT
        dc.customer_id,
        SUM(f.item_amount) AS total_sales
    FROM dim_customer dc
    JOIN fact_order_items f
        ON dc.customer_key = f.customer_key
    GROUP BY dc.customer_id
),
ranked AS (
    SELECT
        customer_id,
        total_sales,
        RANK() OVER (
            ORDER BY total_sales DESC
        ) AS rnk
    FROM customer_sales
)
SELECT
    customer_id,
    total_sales
FROM ranked
WHERE rnk = 1;


-- =====================================================
-- 4. NUMBER OF ORDERS PER CUSTOMER
-- =====================================================

SELECT
    dc.customer_id,
    COUNT(DISTINCT f.order_id) AS no_of_orders
FROM dim_customer dc
LEFT JOIN fact_order_items f
    ON dc.customer_key = f.customer_key
GROUP BY dc.customer_id;


-- =====================================================
-- 5. AVERAGE ORDER VALUE PER CUSTOMER
-- =====================================================

WITH order_totals AS (
    SELECT
        dc.customer_id,
        f.order_id,
        SUM(f.item_amount) AS order_total
    FROM dim_customer dc
    JOIN fact_order_items f
        ON dc.customer_key = f.customer_key
    GROUP BY
        dc.customer_id,
        f.order_id
)
SELECT
    customer_id,
    AVG(order_total) AS avg_order_value
FROM order_totals
GROUP BY customer_id;


-- =====================================================
-- 6. CUSTOMERS WITH MORE THAN ONE ORDER
-- =====================================================

SELECT
    dc.customer_id,
    COUNT(DISTINCT f.order_id) AS no_of_orders
FROM dim_customer dc
JOIN fact_order_items f
    ON dc.customer_key = f.customer_key
GROUP BY dc.customer_id
HAVING COUNT(DISTINCT f.order_id) > 1;


-- =====================================================
-- 7. PRODUCT WITH HIGHEST TOTAL SALES
-- =====================================================

WITH product_sales AS (
    SELECT
        dp.product_name,
        SUM(f.item_amount) AS total_sales
    FROM dim_product dp
    JOIN fact_order_items f
        ON dp.product_key = f.product_key
    GROUP BY dp.product_name
)
SELECT
    product_name,
    total_sales
FROM product_sales
WHERE total_sales = (
    SELECT MAX(total_sales)
    FROM product_sales
);


-- =====================================================
--  7. PRODUCT WITH HIGHEST TOTAL SALES
-- =====================================================

SELECT
    dd.year,
    dd.month,
    SUM(f.item_amount) AS total_sales
FROM dim_date dd
LEFT JOIN fact_order_items f
    ON dd.date_key = f.date_key
GROUP BY
    dd.year,
    dd.month
ORDER BY
    dd.year,
    dd.month;


-- =====================================================
-- 8. MONTHS WITH SALES GREATER THAN ₹50,000
-- =====================================================

SELECT
    dd.year,
    dd.month,
    SUM(f.item_amount) AS total_sales
FROM dim_date dd
JOIN fact_order_items f
    ON dd.date_key = f.date_key
GROUP BY
    dd.year,
    dd.month
HAVING SUM(f.item_amount) > 50000
ORDER BY
    dd.year,
    dd.month;


-- =====================================================
-- 9. MONTH WITH HIGHEST TOTAL SALES
-- =====================================================

SELECT
    dd.year,
    dd.month,
    SUM(f.item_amount) AS total_sales
FROM dim_date dd
JOIN fact_order_items f
    ON dd.date_key = f.date_key
GROUP BY
    dd.year,
    dd.month
ORDER BY total_sales DESC
LIMIT 1;