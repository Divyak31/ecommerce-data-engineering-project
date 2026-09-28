-- 03_staging.sql
-- Staging layer inspection and validation

USE ecommerce_de;

-- Review staged CDC records

SELECT *
FROM staging_orders;

-- Check staged records by operation

SELECT
    operation,
    COUNT(*) AS record_count
FROM staging_orders
GROUP BY operation;

-- Review the staging records that will be processed

SELECT
    operation,
    order_id,
    customer_id,
    order_date,
    amount,
    status,
    processed_at
FROM staging_orders
ORDER BY processed_at;