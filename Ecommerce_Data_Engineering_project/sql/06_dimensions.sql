-- 06_dimensions.sql
-- Dimension tables for the dimensional warehouse

USE ecommerce_de;


-- =====================================================
-- 1. CUSTOMER DIMENSION
-- =====================================================

CREATE TABLE dim_customer (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    customer_name VARCHAR(100),
    city VARCHAR(100),
    signup_date DATE
);

INSERT INTO dim_customer
(
    customer_id,
    customer_name,
    city,
    signup_date
)
SELECT
    customer_id,
    name,
    city,
    signup_date
FROM customers;

SELECT *
FROM dim_customer;


-- =====================================================
-- 2. PRODUCT DIMENSION
-- =====================================================

CREATE TABLE dim_product (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    product_name VARCHAR(100),
    category VARCHAR(100),
    price DECIMAL(10,2)
);

INSERT INTO dim_product
(
    product_id,
    product_name,
    category,
    price
)
SELECT
    product_id,
    product_name,
    category,
    price
FROM products;

SELECT *
FROM dim_product;


-- =====================================================
-- 3. DATE DIMENSION
-- =====================================================

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day INT,
    month INT,
    quarter INT,
    year INT
);

INSERT INTO dim_date
(
    date_key,
    full_date,
    day,
    month,
    quarter,
    year
)
VALUES
(20260801, '2026-08-01', 1, 8, 3, 2026),
(20260802, '2026-08-02', 2, 8, 3, 2026),
(20260803, '2026-08-03', 3, 8, 3, 2026),
(20260804, '2026-08-04', 4, 8, 3, 2026),
(20260805, '2026-08-05', 5, 8, 3, 2026),
(20260902, '2026-09-02', 2, 9, 3, 2026);

SELECT *
FROM dim_date
ORDER BY full_date;