-- 01_source_tables.sql
-- Creates and loads the source e-commerce tables.


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