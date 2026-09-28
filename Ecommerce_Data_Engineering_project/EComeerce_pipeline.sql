CREATE DATABASE ecommerce_de;
USE ecommerce_de;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    signup_date DATE
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE,
    amount DECIMAL(10,2),
    status VARCHAR(20),

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

INSERT INTO customers VALUES
(1, 'Amit', 'Pune', '2025-01-10'),
(2, 'Neha', 'Mumbai', '2025-02-15'),
(3, 'Rahul', 'Delhi', '2025-03-20'),
(4, 'Priya', 'Pune', '2025-04-05'),
(5, 'Karan', 'Bangalore', '2025-05-12');

INSERT INTO products VALUES
(1, 'Laptop', 'Electronics', 60000),
(2, 'Mouse', 'Electronics', 800),
(3, 'Keyboard', 'Electronics', 1500),
(4, 'Chair', 'Furniture', 7000),
(5, 'Backpack', 'Accessories', 2000);

INSERT INTO orders VALUES
(101, 1, '2026-08-01', 500, 'Completed'),
(102, 2, '2026-08-02', 750, 'Pending'),
(103, 1, '2026-08-03', 1200, 'Completed'),
(104, 3, '2026-08-04', 300, 'Cancelled'),
(105, 4, '2026-08-05', 900, 'Completed');

INSERT INTO order_details VALUES
(1, 101, 1, 1),
(2, 101, 2, 2),
(3, 102, 3, 1),
(4, 103, 4, 1),
(5, 103, 5, 2),
(6, 104, 2, 1),
(7, 105, 1, 1);

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_details;


CREATE TABLE staging_orders (
    operation VARCHAR(10),
    order_id INT,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10,2),
    status VARCHAR(20),
    processed_at DATETIME
);

INSERT INTO staging_orders
(operation, order_id, customer_id, order_date, amount, status, processed_at)
VALUES
('INSERT', 106, 5, '2026-09-16', 1500, 'Completed', NOW()),
('UPDATE', 102, 2, '2026-09-02', 800, 'Completed', NOW()),
('DELETE', 104, 3, NULL, NULL, NULL, NOW());

SELECT * FROM staging_orders;

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

INSERT INTO quarantine_orders
(operation, order_id, customer_id, order_date, amount, status, error_reason, quarantined_at)
VALUES
('INSERT', 107, 5, '2026-09-16', -500, 'XYZ', 'Invalid amount;Invalid status', NOW());

SELECT *
FROM quarantine_orders;

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

SELECT *
FROM warehouse_orders;

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
  
  SELECT *
FROM warehouse_orders
ORDER BY order_id;

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
  
  SELECT *
FROM warehouse_orders
WHERE order_id = 102;

DELETE w
FROM warehouse_orders w
JOIN staging_orders s
    ON w.order_id = s.order_id
WHERE s.operation = 'DELETE'
  AND s.order_id = 104;
  
  SELECT *
FROM warehouse_orders
ORDER BY order_id;

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
  AND order_id = 106
ON DUPLICATE KEY UPDATE
    customer_id = VALUES(customer_id),
    order_date = VALUES(order_date),
    amount = VALUES(amount),
    status = VALUES(status),
    loaded_at = NOW();
    
    SELECT *
FROM warehouse_orders
WHERE order_id = 106;

select * from warehouse_orders;

select * from warehouse_orders where order_id=104;

select count(*)as row_count from warehouse_orders where order_id=104;

describe warehouse_orders;

describe orders;
describe order_details;
describe products;

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
    
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    od.product_id,
    p.product_name,
    od.quantity,
    p.price,
    od.quantity * p.price AS item_amount
FROM orders o
JOIN order_details od
    ON o.order_id = od.order_id
JOIN products p
    ON od.product_id = p.product_id;
    
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
    
CREATE TABLE dim_customer (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    customer_name VARCHAR(100),
    city VARCHAR(100),
    signup_date DATE
);

INSERT INTO dim_customer
(customer_id, customer_name, city, signup_date)
SELECT
    customer_id,
    name,
    city,
    signup_date
FROM customers;

SELECT * FROM dim_customer;

CREATE TABLE dim_product (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    product_name VARCHAR(100),
    category VARCHAR(100),
    price DECIMAL(10,2)
);
INSERT INTO dim_product
(product_id, product_name, category, price)
SELECT
    product_id,
    product_name,
    category,
    price
FROM products;

SELECT * FROM dim_product;

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day INT,
    month INT,
    quarter INT,
    year INT
);

INSERT INTO dim_date
(date_key, full_date, day, month, quarter, year)
VALUES
(20260801, '2026-08-01', 1, 8, 3, 2026),
(20260802, '2026-08-02', 2, 8, 3, 2026),
(20260803, '2026-08-03', 3, 8, 3, 2026),
(20260804, '2026-08-04', 4, 8, 3, 2026),
(20260805, '2026-08-05', 5, 8, 3, 2026);
SELECT * FROM dim_date
ORDER BY full_date;

SELECT
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
    ON w.order_date = dd.full_date;
    
CREATE TABLE fact_order_items (
    order_item_key INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    customer_key INT,
    product_key INT,
    date_key INT,
    quantity INT,
    item_amount DECIMAL(10,2)
);

INSERT INTO fact_order_items
(
    order_id,
    customer_key,
    product_key,
    date_key,
    quantity,
    item_amount
)
SELECT
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
    ON w.order_date = dd.full_date;
    
SELECT *
FROM fact_order_items
ORDER BY order_item_key;

SELECT *
FROM warehouse_orders
WHERE order_id = 102;

SELECT *
FROM dim_date
WHERE full_date = '2026-09-02';

SELECT * FROM dim_date;

SELECT COUNT(*) AS row_count
FROM dim_date;

SELECT *
FROM dim_date
WHERE full_date IS NULL;

INSERT INTO dim_date
(date_key, full_date, day, month, quarter, year)
VALUES
(20260902, '2026-09-02', 2, 9, 3, 2026);

SELECT *
FROM dim_date;

SELECT *
FROM fact_order_items
ORDER BY order_id, product_key;

SELECT
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
WHERE w.order_id = 102;

INSERT INTO fact_order_items
(
    order_id,
    customer_key,
    product_key,
    date_key,
    quantity,
    item_amount
)
SELECT
    w.order_id,
    dc.customer_key,
    dp.product_key,
    dd.date_key,
    od.quantity,
    od.quantity * dp.price
FROM warehouse_orders w
JOIN order_details od
    ON w.order_id = od.order_id
JOIN dim_customer dc
    ON w.customer_id = dc.customer_id
JOIN dim_product dp
    ON od.product_id = dp.product_id
JOIN dim_date dd
    ON w.order_date = dd.full_date
WHERE w.order_id = 102;

SELECT
    dc.customer_name,
    dp.product_name,
    dd.full_date,
    f.quantity,
    f.item_amount
FROM fact_order_items f
JOIN dim_customer dc
    ON f.customer_key = dc.customer_key
JOIN dim_product dp
    ON f.product_key = dp.product_key
JOIN dim_date dd
    ON f.date_key = dd.date_key
ORDER BY dd.full_date, f.order_id;

SELECT
    dc.customer_name,
    SUM(f.item_amount) AS total_sales
FROM fact_order_items f
JOIN dim_customer dc
    ON f.customer_key = dc.customer_key
GROUP BY dc.customer_name
ORDER BY total_sales DESC;

SELECT
    dp.category,
    SUM(f.item_amount) AS total_sales
FROM fact_order_items f
JOIN dim_product dp
    ON f.product_key = dp.product_key
GROUP BY dp.category
ORDER BY total_sales DESC;

SELECT
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_present,
    COUNT(customer_key) AS customer_present,
    COUNT(product_key) AS product_present,
    COUNT(date_key) AS date_present,
    COUNT(quantity) AS quantity_present,
    COUNT(item_amount) AS amount_present
FROM fact_order_items;

SELECT
    order_id,
    product_key,
    COUNT(*) AS row_count
FROM fact_order_items
GROUP BY order_id, product_key
HAVING COUNT(*) > 1;

SELECT *
FROM fact_order_items
WHERE quantity <= 0
   OR quantity IS NULL;
   
SELECT COUNT(*) AS invalid_quantity_rows
FROM fact_order_items
WHERE quantity <= 0
   OR quantity IS NULL;
   
SELECT COUNT(*) AS invalid_amount_rows
FROM fact_order_items
WHERE item_amount IS NULL
   OR item_amount < 0;
   
SELECT
    f.order_id,
    f.product_key,
    f.quantity,
    dp.price,
    f.item_amount,
    f.quantity * dp.price AS expected_amount
FROM fact_order_items f
JOIN dim_product dp
    ON f.product_key = dp.product_key
WHERE f.item_amount <> f.quantity * dp.price;

SELECT f.customer_key
FROM fact_order_items f
LEFT JOIN dim_customer dc
    ON f.customer_key = dc.customer_key
WHERE dc.customer_key IS NULL;

SELECT f.product_key
FROM fact_order_items f
LEFT JOIN dim_product dp
    ON f.product_key = dp.product_key
WHERE dp.product_key IS NULL;

SELECT f.date_key
FROM fact_order_items f
LEFT JOIN dim_date dd
    ON f.date_key = dd.date_key
WHERE dd.date_key IS NULL;

SELECT
    w.order_id,
    w.amount AS order_amount,
    SUM(f.item_amount) AS fact_amount
FROM warehouse_orders w
JOIN fact_order_items f
    ON w.order_id = f.order_id
GROUP BY w.order_id, w.amount
HAVING w.amount <> SUM(f.item_amount);

SELECT
    w.order_id,
    w.amount AS order_amount,
    SUM(f.item_amount) AS fact_amount,
    w.amount - SUM(f.item_amount) AS difference
FROM warehouse_orders w
JOIN fact_order_items f
    ON w.order_id = f.order_id
GROUP BY w.order_id, w.amount
HAVING w.amount <> SUM(f.item_amount);

SELECT
    order_id,
    loaded_at
FROM warehouse_orders
ORDER BY loaded_at;

SELECT
    s.order_id,
    s.processed_at,
    w.loaded_at,
    TIMESTAMPDIFF(
        MINUTE,
        s.processed_at,
        w.loaded_at
    ) AS load_delay_minutes
FROM staging_orders s
JOIN warehouse_orders w
    ON s.order_id = w.order_id
WHERE s.operation IN ('INSERT', 'UPDATE');

SELECT COUNT(*) AS fact_row_count
FROM fact_order_items;

SHOW CREATE TABLE fact_order_items;

SELECT
    w.order_id,
    od.product_id,
    COUNT(f.order_id) AS existing_rows
FROM warehouse_orders w
JOIN order_details od
    ON w.order_id = od.order_id
LEFT JOIN fact_order_items f
    ON f.order_id = w.order_id
   AND f.product_key = (
       SELECT dp.product_key
       FROM dim_product dp
       WHERE dp.product_id = od.product_id
   )
GROUP BY w.order_id, od.product_id
ORDER BY w.order_id, od.product_id;

DESCRIBE fact_order_items;

ALTER TABLE fact_order_items
ADD COLUMN order_detail_id INT;

SET SQL_SAFE_UPDATES = 0;

UPDATE fact_order_items f
JOIN order_details od
    ON f.order_id = od.order_id
JOIN dim_product dp
    ON dp.product_id = od.product_id
   AND f.product_key = dp.product_key
SET f.order_detail_id = od.order_detail_id;

SELECT *
FROM fact_order_items;

SELECT
    order_item_key,
    order_detail_id,
    order_id,
    product_key,
    quantity,
    item_amount
FROM fact_order_items
ORDER BY order_item_key;

ALTER TABLE fact_order_items
ADD CONSTRAINT uq_order_detail UNIQUE (order_detail_id);

SHOW CREATE TABLE fact_order_items;

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
VALUES
(
    1,
    101,
    1,
    1,
    20260801,
    1,
    60000
);

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
    
    SELECT COUNT(*) AS fact_row_count
FROM fact_order_items;

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

select * from fact_order_items;
select * from dim_customer;
select * from dim_product;
select * from dim_date;

/*1.calculate total sales for each customer*/
select dc.customer_id,coalesce(sum(f.item_amount),0)as total_sales from dim_customer dc left join fact_order_items f on dc.customer_key=f.customer_key group by dc.customer_id;

/*2.Calculate total sales by product category*/
select pd.category,coalesce(sum(f.item_amount),0)as total_sales from dim_product pd join fact_order_items f on pd.product_key=f.product_key group by pd.category;

/*3.Find the customer who generated the highest total sales*/
/*approach-1*/
select dc.customer_id,sum(f.item_amount)as total_sales from dim_customer dc  join fact_order_items f on dc.customer_key=f.customer_key group by dc.customer_id order by total_sales desc limit 1;
/*approach-2*/
SELECT
    customer_id,
    total_sales
FROM (
    SELECT
        dc.customer_id,
        SUM(f.item_amount) AS total_sales
    FROM dim_customer dc
    JOIN fact_order_items f
        ON dc.customer_key = f.customer_key
    GROUP BY dc.customer_id
) t
WHERE total_sales = (
    SELECT MAX(total_sales)
    FROM (
        SELECT
            dc.customer_id,
            SUM(f.item_amount) AS total_sales
        FROM dim_customer dc
        JOIN fact_order_items f
            ON dc.customer_key = f.customer_key
        GROUP BY dc.customer_id
    ) x
); 

/*approach-3*/
SELECT
    customer_id,
    total_sales
FROM (
    SELECT
        dc.customer_id,
        SUM(f.item_amount) AS total_sales,
        RANK() OVER (
            ORDER BY SUM(f.item_amount) DESC
        ) AS rnk
    FROM dim_customer dc
    JOIN fact_order_items f
        ON dc.customer_key = f.customer_key
    GROUP BY dc.customer_id
) t
WHERE rnk = 1;

/*approach-4*/
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
        RANK() OVER (ORDER BY total_sales DESC) AS rnk
    FROM customer_sales
)
SELECT
    customer_id,
    total_sales
FROM ranked
WHERE rnk = 1;
 
 /*4.Calculate the number of orders placed by each customer.*/
 select dc.customer_id,count(distinct f.order_id)as no_of_orders from dim_customer dc left join fact_order_items f on dc.customer_key=f.customer_key group by dc.customer_id;
 
 /*5 Calculate the average order value for each customer */
 /*approach-1*/
 with order_totals as
 ( select  dc.customer_id,f.order_id,sum(item_amount) as order_total from dim_customer dc join fact_order_items f on dc.customer_key=f.customer_key group by dc.customer_id,f.order_id)
 select  customer_id,avg(order_total)as avg_order_value from order_totals group by customer_id;
 
 /*approach-2*/
 SELECT
    dc.customer_id,
    SUM(f.item_amount) / COUNT(DISTINCT f.order_id) AS avg_order_value
FROM dim_customer dc
JOIN fact_order_items f
    ON dc.customer_key = f.customer_key
GROUP BY dc.customer_id;

/*6.Find customers who have placed more than one order.*/
select dc.customer_id,count(distinct f.order_id) as no_of_orders from dim_customer dc  join fact_order_items f on dc.customer_key=f.customer_key group by dc.customer_id having count(distinct f.order_id)>1;

/*7.Find the product with the highest total sales.*/
select dp.product_name,sum(f.item_amount)as total_sales from dim_product dp left join fact_order_items f on dp.product_key=f.product_key group by dp.product_name order by sum(f.item_amount) desc limit 1;
/*approach-2*/
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

/*Calculate total sales for each month.*/
select dd.year, dd.month,sum(f.item_amount)as total_sales from dim_date dd left join fact_order_items f on dd.date_key=f.date_key group by dd.month,dd.year order by dd.year,dd.month;

/*Calculate monthly sales and show only months where total sales are greater than ₹50,000*/
select dd.year, dd.month,sum(f.item_amount)as total_sales from dim_date dd  join fact_order_items f on dd.date_key=f.date_key group by dd.month,dd.year having sum(f.item_amount)>50000 order by dd.year,dd.month;

/*Find the month with the highest total sales.*/
select dd.month,sum(f.item_amount)as total_sales from dim_date dd join fact_order_items f on dd.date_key=f.date_key group by dd.month order by total_sales desc limit 1;
 /*OR*/
 select * from(select dd.month,sum(f.item_amount)as total_sales,dense_rank()over(order by sum(f.item_amount)desc)as dk from dim_date dd join fact_order_items f on dd.date_key=f.date_key group by dd.month)t where dk=1;
 
 /*Calculate each customer's percentage contribution to total sales.*/
 
 
 ALTER TABLE dim_customer
ADD COLUMN effective_from DATE,
ADD COLUMN effective_to DATE,
ADD COLUMN is_current BOOLEAN;

UPDATE dim_customer
SET
    effective_from = signup_date,
    effective_to = NULL,
    is_current = 1;
    
    SET SQL_SAFE_UPDATES = 0;
    
    UPDATE dim_customer
SET
    effective_from = signup_date,
    effective_to = NULL,
    is_current = 1;
    
    SELECT *
FROM dim_customer;

UPDATE dim_customer
SET
    effective_to = '2026-09-24',
    is_current = 0
WHERE customer_id = 1
  AND is_current = 1;
  
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

SELECT *
FROM warehouse_orders
ORDER BY order_id;

SELECT
    COUNT(*) AS total_fact_rows,
    COUNT(order_detail_id) AS order_detail_ids,
    COUNT(DISTINCT order_detail_id) AS distinct_order_detail_ids
FROM fact_order_items;

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


SELECT
    COUNT(*) AS expected_order_lines
FROM warehouse_orders w
JOIN order_details od
    ON w.order_id = od.order_id;
    
SELECT
    COUNT(*) AS actual_fact_rows
FROM fact_order_items;

SELECT
    od.order_detail_id
FROM warehouse_orders w
JOIN order_details od
    ON w.order_id = od.order_id
LEFT JOIN fact_order_items f
    ON od.order_detail_id = f.order_detail_id
WHERE f.order_detail_id IS NULL;

SELECT
    order_detail_id,
    COUNT(*) AS row_count
FROM fact_order_items
GROUP BY order_detail_id
HAVING COUNT(*) > 1;


SELECT
    customer_id,
    customer_name,
    city,
    effective_from,
    effective_to,
    is_current
FROM dim_customer
WHERE customer_id = 1
ORDER BY effective_from;

SELECT
    customer_id,
    COUNT(*) AS current_versions
FROM dim_customer
WHERE is_current = 1
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT
    f.order_id,
    f.order_detail_id
FROM fact_order_items f
LEFT JOIN warehouse_orders w
    ON f.order_id = w.order_id
WHERE w.order_id IS NULL;





