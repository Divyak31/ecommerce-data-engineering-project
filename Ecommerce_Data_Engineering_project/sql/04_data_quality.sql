-- 04_data_quality.sql
-- Data quality checks and quarantine handling

USE ecommerce_de;


-- =====================================================
-- 1. QUARANTINE TABLE
-- =====================================================

CREATE TABLE quarantine_orders (
    operation VARCHAR(10),
    order_id INT,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10,2),
    status VARCHAR(20),
    error_reason VARCHAR(255),
    quarantined_at DATETIME
);


-- =====================================================
-- 2. SAMPLE INVALID RECORD
-- =====================================================

INSERT INTO quarantine_orders
(
    operation,
    order_id,
    customer_id,
    order_date,
    amount,
    status,
    error_reason,
    quarantined_at
)
VALUES
(
    'INSERT',
    107,
    5,
    '2026-09-16',
    -500,
    'XYZ',
    'Invalid amount;Invalid status',
    NOW()
);


-- =====================================================
-- 3. REVIEW QUARANTINED RECORDS
-- =====================================================

SELECT *
FROM quarantine_orders;


-- =====================================================
-- 4. COMPLETENESS CHECK
-- =====================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_present,
    COUNT(customer_key) AS customer_present,
    COUNT(product_key) AS product_present,
    COUNT(date_key) AS date_present,
    COUNT(quantity) AS quantity_present,
    COUNT(item_amount) AS amount_present
FROM fact_order_items;


-- =====================================================
-- 5. DUPLICATE ORDER DETAIL CHECK
-- =====================================================

SELECT
    order_detail_id,
    COUNT(*) AS row_count
FROM fact_order_items
GROUP BY order_detail_id
HAVING COUNT(*) > 1;


-- =====================================================
-- 6. INVALID QUANTITY CHECK
-- =====================================================

SELECT *
FROM fact_order_items
WHERE quantity <= 0
   OR quantity IS NULL;


-- =====================================================
-- 7. INVALID AMOUNT CHECK
-- =====================================================

SELECT *
FROM fact_order_items
WHERE item_amount IS NULL
   OR item_amount < 0;


-- =====================================================
-- 8. CALCULATION CONSISTENCY CHECK
-- =====================================================

SELECT
    f.order_id,
    f.order_detail_id,
    f.quantity,
    dp.price,
    f.item_amount,
    f.quantity * dp.price AS expected_amount
FROM fact_order_items f
JOIN dim_product dp
    ON f.product_key = dp.product_key
WHERE f.item_amount <> f.quantity * dp.price;


-- =====================================================
-- 9. REFERENTIAL INTEGRITY CHECK
-- =====================================================

SELECT
    COUNT(*) AS invalid_references
FROM fact_order_items f
LEFT JOIN dim_customer dc
    ON f.customer_key = dc.customer_key
LEFT JOIN dim_product dp
    ON f.product_key = dp.product_key
LEFT JOIN dim_date dd
    ON f.date_key = dd.date_key
WHERE dc.customer_key IS NULL
   OR dp.product_key IS NULL
   OR dd.date_key IS NULL;