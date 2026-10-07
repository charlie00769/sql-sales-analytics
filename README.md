# E-commerce Sales Analytics in SQL

A SQL project that takes a small online store from an empty database to business answers:
revenue, best products, customer segments, and retention.

**Data note:** all data is synthetic (made by `generate_data.py`, fixed seed). The numbers show
that the queries work. They are not real business findings.

## Stack
SQLite (comes with Python, nothing to install) and Python 3.

## Run it (3 steps)
```
python generate_data.py      # builds ecommerce.db  (schema + data)
python run_queries.py        # runs all queries and prints results
python run_queries.py 03     # run only one file, e.g. window functions
```

## Database design
`customers` (500) and `products` (40) are lookup tables.
`orders` (1,103) belong to a customer. `order_items` (1,711) belong to an order and a product.
Constraints: primary keys, foreign keys, CHECK rules (price > 0, valid status). 4 indexes on join and date columns.

## What each file covers
| File | Skills |
|---|---|
| `01_basics.sql` | SELECT, JOIN (3 tables), GROUP BY, ORDER BY |
| `02_intermediate.sql` | LEFT JOIN, HAVING, CASE, CTE, subquery |
| `03_window_functions.sql` | LAG, LEAD, RANK, ROW_NUMBER, running SUM, PARTITION BY |
| `04_advanced.sql` | RFM segments (NTILE), cohort retention, VIEW |
| `05_data_checks.sql` | Orphan rows, bad dates, price mismatches |

## Business rule used everywhere
Revenue counts only `Delivered` orders. Cancelled and Returned orders are excluded.
The rule lives in one VIEW (`v_delivered_sales`) so it is not repeated in every query.
