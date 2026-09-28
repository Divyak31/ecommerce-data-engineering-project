\# Data Quality



\## 1. Overview



Data quality checks are used to verify that the data is complete, valid, unique, consistent, and correctly related across tables.



This project demonstrates both data-quality validation and pipeline validation.



\### Data Validation



\*\*Question:\*\* Is the data right?



\### Pipeline Validation



\*\*Question:\*\* Did the pipeline make it right?



\---



\## 2. Quarantine



Invalid records can be separated into a quarantine table instead of being processed as valid warehouse data.



Example invalid record:



\- `amount = -500`

\- `status = 'XYZ'`



The record is stored with an `error\_reason` explaining why it was rejected.



\---



\## 3. Completeness



Completeness checks verify that required fields are populated.



Example:



\- order ID

\- customer key

\- product key

\- date key

\- quantity

\- item amount



`COUNT(column)` can be used to identify populated values because it ignores NULL values.



\---



\## 4. Uniqueness



The project checks for duplicate `order\_detail\_id` values in the fact table.



The expected rule is:



\*\*One order\_detail\_id = one fact row.\*\*



A unique constraint is also applied to `order\_detail\_id` to prevent duplicate order lines from being inserted.



\---



\## 5. Validity



Validity checks verify that values follow expected business rules.



Examples:



\- quantity must be greater than zero

\- item amount must not be NULL

\- item amount must not be negative



\---



\## 6. Calculation Consistency



The project validates that:



\*\*item\_amount = quantity × product price\*\*



This ensures that the calculated fact measure is consistent with the product price and quantity.



\---



\## 7. Referential Integrity



Referential integrity checks verify that fact-table foreign-key-like references have matching dimension records.



The project validates:



\- `customer\_key` → `dim\_customer`

\- `product\_key` → `dim\_product`

\- `date\_key` → `dim\_date`



An orphan record occurs when a fact record points to a missing dimension record.



\---



\## 8. Reconciliation



Reconciliation checks whether expected records reached the next stage.



Example:



\*\*Expected order lines from warehouse + order\_details\*\*



versus



\*\*Actual rows in fact\_order\_items\*\*



This answers:



\*\*Did everything arrive?\*\*



\---



\## 9. Validation vs Reconciliation



These concepts have different purposes:



\*\*Reconciliation → Did everything arrive?\*\*



\*\*Validation → Is what arrived correct?\*\*



For example:



\- row-count comparison checks whether records arrived

\- calculation checks verify whether the arrived records are correct



\---



\## 10. Pre-load vs Post-load Validation



\### Pre-load



\*\*Question:\*\* Can I load it?



Checks are performed before loading data into the target.



\### Post-load



\*\*Question:\*\* Did I load it correctly?



Checks are performed after loading data into the target.



Both types of checks can be used in a production pipeline.



\---



\## 11. Constraints vs Validation Queries



A database constraint helps prevent invalid data.



A validation query helps detect invalid data.



\### Memory Trick



\*\*Constraint = Prevention\*\*



\*\*Validation query = Detection\*\*



For example, the unique constraint on `order\_detail\_id` helps prevent duplicate fact rows, while a duplicate-detection query can identify duplicates that already exist.



\---



\## 12. Idempotency Validation



The fact load uses:



`ON DUPLICATE KEY UPDATE`



together with the unique `order\_detail\_id`.



The same load was executed again and the fact-row count remained unchanged.



This demonstrates idempotent processing.



\### Memory Trick



\*\*Run it again → same correct result → Idempotent\*\*



\---



\## 13. Validation Summary



The project includes checks for:



\- completeness

\- uniqueness

\- validity

\- calculation consistency

\- referential integrity

\- reconciliation

\- idempotency

\- SCD Type 2 current-version validation



The goal is to ensure that the pipeline produces reliable analytical data rather than simply moving records from one table to another.

