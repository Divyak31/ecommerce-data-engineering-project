-- 09_scd2.sql
-- Slowly Changing Dimension Type 2 implementation
-- Customer history is preserved when customer attributes change

USE ecommerce_de;


-- =====================================================
-- 1. ADD SCD2 COLUMNS
-- =====================================================

ALTER TABLE dim_customer
ADD COLUMN effective_from DATE,
ADD COLUMN effective_to DATE,
ADD COLUMN is_current BOOLEAN;


-- =====================================================
-- 2. INITIALIZE EXISTING CUSTOMER RECORDS
-- =====================================================

UPDATE dim_customer
SET
    effective_from = signup_date,
    effective_to = NULL,
    is_current = 1;


-- =====================================================
-- 3. EXPIRE OLD CUSTOMER VERSION
-- Example: Amit changes city from Pune to Mumbai
-- =====================================================

UPDATE dim_customer
SET
    effective_to = '2026-09-24',
    is_current = 0
WHERE customer_id = 1
  AND is_current = 1;


-- =====================================================
-- 4. INSERT NEW CUSTOMER VERSION
-- =====================================================

INSERT INTO dim_customer
(
    customer_id,
    customer_name,
    city,
    signup_date,
    effective_from,
    effective_to,
    is_current
)
VALUES
(
    1,
    'Amit',
    'Mumbai',
    '2025-01-10',
    '2026-09-24',
    NULL,
    1
);


-- =====================================================
-- 5. VIEW CUSTOMER HISTORY
-- =====================================================

SELECT
    customer_key,
    customer_id,
    customer_name,
    city,
    effective_from,
    effective_to,
    is_current
FROM dim_customer
WHERE customer_id = 1
ORDER BY effective_from;


-- =====================================================
-- 6. CHECK FOR MULTIPLE CURRENT VERSIONS
-- Expected result: 0 rows
-- =====================================================

SELECT
    customer_id,
    COUNT(*) AS current_versions
FROM dim_customer
WHERE is_current = 1
GROUP BY customer_id
HAVING COUNT(*) > 1;