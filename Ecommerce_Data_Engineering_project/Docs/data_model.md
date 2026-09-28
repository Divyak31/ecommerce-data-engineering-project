\# Data Model



\## 1. Source Data Model



The source layer contains four transactional tables:



\### customers



Stores customer information.



\- `customer\_id` — business identifier for the customer



\### products



Stores product information.



\- `product\_id` — business identifier for the product



\### orders



Stores order-level information.



\- `order\_id` — business identifier for the order

\- `customer\_id` — identifies the customer who placed the order



\### order\_details



Stores individual products belonging to each order.



\- `order\_detail\_id` — uniquely identifies an order line

\- `order\_id` — identifies the order

\- `product\_id` — identifies the product



Relationship:



customers  

↓  

orders  

↓  

order\_details  

↓  

products



\---



\## 2. Dimensional Model



The warehouse uses a star-schema design.



\### Dimension Tables



\- `dim\_customer`

\- `dim\_product`

\- `dim\_date`



\### Fact Table



\- `fact\_order\_items`



\---



\## 3. Fact Table Grain



The grain of `fact\_order\_items` is:



\*\*One row represents one product in one order line.\*\*



For example, if one order contains three different products, that order produces three fact rows.



The grain definition determines how measures should be aggregated.



\---



\## 4. order\_detail\_id



`order\_detail\_id` uniquely identifies an individual order line in the source data.



It is stored in the fact table and protected by a unique constraint.



\*\*One `order\_detail\_id` = one fact row.\*\*



This also supports idempotent fact loading.



\---



\## 5. Surrogate Keys



The dimension tables use surrogate keys:



\- `customer\_key`

\- `product\_key`

\- `date\_key`



The fact table stores these surrogate keys.



Business identifier to surrogate key mapping:



\- `customer\_id` → `customer\_key`

\- `product\_id` → `product\_key`

\- `full\_date` → `date\_key`



\---



\## 6. Why Surrogate Keys?



Surrogate keys provide stable warehouse identifiers for dimension records.



They are particularly useful for Slowly Changing Dimensions.



For example, when a customer's city changes, the old customer version can remain in the dimension while a new version receives a different `customer\_key`.



\---



\## 7. Slowly Changing Dimension Type 2



`dim\_customer` implements SCD Type 2.



The following columns track customer history:



\- `effective\_from`

\- `effective\_to`

\- `is\_current`



Example:



| customer\_id | city | effective\_from | effective\_to | is\_current |

|---|---|---|---|---|

| 1 | Pune | 2025-01-10 | 2026-09-24 | 0 |

| 1 | Mumbai | 2026-09-24 | NULL | 1 |



The historical Pune version is preserved rather than overwritten.



\---



\## 8. Fact Measures



The fact table contains measures including:



\- `quantity`

\- `item\_amount`



`item\_amount` is calculated as:



\*\*quantity × product price\*\*



These measures can be aggregated for business reporting, such as:



\- total sales

\- sales by customer

\- sales by product

\- sales by category

\- monthly sales



\---



\## 9. Important Aggregation Rule



Because the fact table is at order-line grain:



`COUNT(\*)`



counts fact/order-line rows.



Whereas:



`COUNT(DISTINCT order\_id)`



counts actual orders.



Therefore, when calculating the number of orders, `COUNT(DISTINCT order\_id)` should be used.



\---



\## 10. Average Order Value



Average order value cannot be calculated by simply averaging individual fact rows.



The correct approach is:



Order lines  

↓  

Calculate total for each order  

↓  

Calculate average of order totals



Alternatively:



`SUM(item\_amount) / COUNT(DISTINCT order\_id)`



can be used when the required scope and filters are the same.



\---



\## 11. Data Model Summary



The project follows this general pattern:



Operational Source Data  

↓  

Processed Warehouse Data  

↓  

Dimensional Model  

↓  

Fact + Dimensions  

↓  

Business KPIs



The dimensional model separates descriptive attributes from measurable business events, making the data suitable for analytical queries.

