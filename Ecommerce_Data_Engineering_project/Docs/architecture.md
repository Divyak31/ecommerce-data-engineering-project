# Project Architecture



## Overview



This project implements an ETL-style e-commerce data engineering pipeline using MySQL.



The pipeline processes source order data through staging, simulated CDC, data quality checks, transformations, dimensional modeling, and fact-table loading.



## Pipeline Flow



Source Tables

↓

Simulated CDC

↓

Staging

↓

Data Quality / Quarantine

↓

Transformation

↓

Dimensions

↓

Fact Table

↓

KPIs



## 1. Source Layer



The source layer contains the operational e-commerce tables:



\- customers

\- products

\- orders

\- order\_details



These tables represent the source transactional data.



## 2. Simulated CDC



Changes to orders are represented using a staging table with an operation column.



The project simulates:



\- INSERT — new order 106

\- UPDATE — order 102

\- DELETE — order 104



The simulated CDC changes are then applied to the warehouse layer.



### Important



This project does not use a production CDC tool such as Debezium or AWS DMS.



CDC was simulated using SQL and a staging table containing INSERT, UPDATE, and DELETE operations.



## 3. Staging Layer



The staging layer temporarily holds incoming CDC records before they are processed.



The staging table contains:



\- operation

\- order\_id

\- customer\_id

\- order\_date

\- amount

\- status

\- processed\_at



## 4. Data Quality and Quarantine



Data quality checks are performed to identify invalid or inconsistent data.



The project demonstrates checks for:



\- completeness

\- uniqueness

\- valid quantity

\- valid amount

\- calculation consistency

\- referential integrity



Invalid records can be placed in a quarantine table instead of being processed as valid data.



## 5. Transformation Layer



Source and warehouse data are transformed into order-line level records.



The transformation calculates:



`item\_amount = quantity × product price`



The final transformation maps business identifiers to dimension surrogate keys and prepares the data for the fact table.



## 6. Dimensional Warehouse



The project uses a star-schema design consisting of:



### Dimensions



\- dim\_customer

\- dim\_product

\- dim\_date



### Fact



\- fact\_order\_items



The fact table grain is:



\*\*One row = one product in one order line.\*\*



`order\_detail\_id` uniquely identifies the order line.



## 7. SCD Type 2



Customer history is preserved using Slowly Changing Dimension Type 2.



The customer dimension contains:



\- effective\_from

\- effective\_to

\- is\_current



An example change was simulated where Amit's city changed from Pune to Mumbai.



The previous version is retained as historical data and a new current version is inserted.



## 8. Idempotent Loading



The fact-table load uses a unique constraint on `order\_detail\_id` together with `ON DUPLICATE KEY UPDATE`.



This prevents repeated execution of the same load from creating duplicate fact rows.



## 9. KPI Layer



The final layer contains analytical queries such as:



\- total sales by customer

\- total sales by product category

\- highest-sales customer

\- number of orders per customer

\- average order value

\- repeat customers

\- highest-selling product

\- monthly sales

\- highest-sales month



## 10. Validation



The project includes both data-quality and pipeline-validation checks.



Examples include:



\- fact-row completeness

\- duplicate detection

\- referential integrity

\- calculation consistency

\- source-to-fact reconciliation

\- fact-to-warehouse validation

\- SCD2 current-version validation



## 11. Performance Optimization



Query optimization was practiced using MySQL `EXPLAIN`.



A query filtering `warehouse\_orders` by `customer\_id` initially performed a full table scan.



An index was created on `customer\_id`, after which the execution plan showed that MySQL could use the new index.



This demonstrates the basic optimization process:



\*\*EXPLAIN → identify inefficient operation → optimize → EXPLAIN again\*\*



## 12. Orchestration



Orchestration means coordinating and scheduling multiple pipeline tasks and their dependencies, including retries and failure handling.



Orchestration was \*\*not implemented\*\* in this project.



Airflow is a future learning topic rather than a technology used in this project.



## 13. Production Considerations



This project is a learning/portfolio implementation.



In a production environment, the pipeline could be extended with:



\- real CDC tools

\- workflow orchestration

\- cloud storage

\- distributed processing

\- monitoring and alerting

\- automated data-quality checks

\- scalable incremental processing

