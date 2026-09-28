-- 05_transformations.sql
-- Transform source/warehouse data into order-line level data

USE ecommerce_de;


-- =====================================================
-- 1. BASIC ORDER-LINE TRANSFORMATION
-- =====================================================

SELECT
    od.order_id,
    od.product_id,
    p.product_name,
    od.quantity,
    p.price,
    od.quantity * p.price AS item_amount
FROM order_details od
JOIN products p
    ON od.product_id = p.product_id;


-- =====================================================
-- 2. VALID ORDERS FROM WAREHOUSE
-- =====================================================

SELECT
    w.order_id,
    w.customer_id,
    w.order_date,
    od.product_id,
    p.product_name,
    od.quantity,
    p.price,
    od.quantity * p.price AS item_amount
FROM warehouse_orders w
JOIN order_details od
    ON w.order_id = od.order_id
JOIN products p
    ON od.product_id = p.product_id;


-- =====================================================
-- 3. TRANSFORMED DATA USING DIMENSIONS
--    Used as the final input for the fact table
-- =====================================================

SELECT
    w.order_id,
    od.order_detail_id,
    dc.customer_key,
    dp.product_key,
    dd.date_key,
    od.quantity,
    od.quantity * dp.price AS item_amount
FROM warehouse_orders w
JOIN order_details od
    ON w.order_id = od.order_id
JOIN dim_customer dc
    ON w.customer_id = dc.customer_id
JOIN dim_product dp
    ON od.product_id = dp.product_id
JOIN dim_date dd
    ON w.order_date = dd.full_date;
    