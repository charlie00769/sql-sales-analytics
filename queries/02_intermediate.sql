-- LEVEL 2: INTERMEDIATE (HAVING, CASE, LEFT JOIN, subqueries, CTE)

-- Q5. Customers who signed up but NEVER ordered (LEFT JOIN + IS NULL)
SELECT COUNT(*) AS customers_never_ordered
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- Q6. Repeat vs one-time customers (CTE + CASE)
WITH orders_per_customer AS (
    SELECT customer_id, COUNT(*) AS n_orders
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY customer_id
)
SELECT
    CASE WHEN n_orders = 1 THEN 'One-time' ELSE 'Repeat (2+)' END AS customer_type,
    COUNT(*) AS customers
FROM orders_per_customer
GROUP BY customer_type;

-- Q7. Products that sold well: more than 40 units (HAVING)
SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN orders   o ON o.order_id   = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'Delivered'
GROUP BY p.product_id
HAVING SUM(oi.quantity) > 40
ORDER BY units_sold DESC;

-- Q8. Products never sold (LEFT JOIN)
SELECT p.product_name, p.category
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.item_id IS NULL;

-- Q9. Orders bigger than the average order (subquery)
SELECT o.order_id, ROUND(SUM(oi.quantity * oi.unit_price), 2) AS order_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY o.order_id
HAVING order_value > (
    SELECT AVG(v) FROM (
        SELECT SUM(oi2.quantity * oi2.unit_price) AS v
        FROM orders o2
        JOIN order_items oi2 ON oi2.order_id = o2.order_id
        WHERE o2.status = 'Delivered'
        GROUP BY o2.order_id
    )
)
ORDER BY order_value DESC
LIMIT 10;
