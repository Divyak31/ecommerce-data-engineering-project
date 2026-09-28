-- 02_cdc.sql
-- Simulates Change Data Capture (CDC)
-- INSERT, UPDATE and DELETE events are captured in staging_orders
-- and then applied to the warehouse.

USE ecommerce_de;

CREATE TABLE staging_orders (
    operation VARCHAR(10),
    order_id INT,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10,2),
    status VARCHAR(20),
    processed_at DATETIME
);

-- Simulated CDC events

INSERT INTO staging_orders
(operation, order_id, customer_id, order_date, amount, status, processed_at)
VALUES
('INSERT', 106, 5, '2026-09-16', 1500, 'Completed', NOW()),
('UPDATE', 102, 2, '2026-09-02', 800, 'Completed', NOW()),
('DELETE', 104, 3, NULL, NULL, NULL, NOW());

-- Initial warehouse load

CREATE TABLE warehouse_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10,2),
    status VARCHAR(20),
    loaded_at DATETIME
);

INSERT INTO warehouse_orders
(order_id, customer_id, order_date, amount, status, loaded_at)
SELECT
    order_id,
    customer_id,
    order_date,
    amount,
    status,
    NOW()
FROM orders;

-- Apply INSERT event

INSERT INTO warehouse_orders
(order_id, customer_id, order_date, amount, status, loaded_at)
SELECT
    order_id,
    customer_id,
    order_date,
    amount,
    status,
    NOW()
FROM staging_orders
WHERE operation = 'INSERT'
  AND order_id = 106;

-- Apply UPDATE event

UPDATE warehouse_orders w
JOIN staging_orders s
    ON w.order_id = s.order_id
SET
    w.customer_id = s.customer_id,
    w.order_date = s.order_date,
    w.amount = s.amount,
    w.status = s.status,
    w.loaded_at = NOW()
WHERE s.operation = 'UPDATE'
  AND s.order_id = 102;

-- Apply DELETE event

DELETE w
FROM warehouse_orders w
JOIN staging_orders s
    ON w.order_id = s.order_id
WHERE s.operation = 'DELETE'
  AND s.order_id = 104;