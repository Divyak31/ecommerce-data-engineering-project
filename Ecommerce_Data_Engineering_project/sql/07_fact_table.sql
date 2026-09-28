-- 07_fact_table.sql
-- Fact table creation and idempotent loading

USE ecommerce_de;


-- =====================================================
-- 1. FACT TABLE
-- Grain: One row = one product in one order
-- order_detail_id uniquely identifies the order line
-- =====================================================

CREATE TABLE fact_order_items (
    order_item_key INT AUTO_INCREMENT PRIMARY KEY,
    order_detail_id INT,
    order_id INT,
    customer_key INT,
    product_key INT,
    date_key INT,
    quantity INT,
    item_amount DECIMAL(10,2)
);


-- =====================================================
-- 2. UNIQUE CONSTRAINT
-- One order_detail_id = one fact row
-- =====================================================

ALTER TABLE fact_order_items
ADD CONSTRAINT uq_order_detail
UNIQUE (order_detail_id);


-- =====================================================
-- 3. LOAD FACT TABLE
-- =====================================================

INSERT INTO fact_order_items
(
    order_detail_id,
    order_id,
    customer_key,
    product_key,
    date_key,
    quantity,
    item_amount
)
SELECT
    od.order_detail_id,
    w.order_id,
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
    ON w.order_date = dd.full_date

ON DUPLICATE KEY UPDATE
    order_id = VALUES(order_id),
    customer_key = VALUES(customer_key),
    product_key = VALUES(product_key),
    date_key = VALUES(date_key),
    quantity = VALUES(quantity),
    item_amount = VALUES(item_amount);





-- =====================================================
-- 4. FACT TABLE INSPECTION
-- =====================================================

SELECT *
FROM fact_order_items
ORDER BY order_item_key;


-- =====================================================
-- 5. FACT ROW COUNT
-- =====================================================

SELECT COUNT(*) AS fact_row_count
FROM fact_order_items;