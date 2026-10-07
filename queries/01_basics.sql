-- LEVEL 1: BASICS (SELECT, JOIN, GROUP BY, ORDER BY)
-- Rule used everywhere: revenue counts only 'Delivered' orders.

-- Q1. Overall business numbers
SELECT
    COUNT(DISTINCT o.order_id)                          AS total_orders,
    COUNT(DISTINCT o.customer_id)                       AS paying_customers,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)          AS total_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price) * 1.0
          / COUNT(DISTINCT o.order_id), 2)              AS avg_order_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'Delivered';

-- Q2. Revenue and units sold by category
SELECT
    p.category,
    SUM(oi.quantity)                           AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM order_items oi
JOIN orders   o ON o.order_id   = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'Delivered'
GROUP BY p.category
ORDER BY revenue DESC;

-- Q3. Revenue by city (top 6)
SELECT
    c.city,
    COUNT(DISTINCT o.order_id)                 AS orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM customers c
JOIN orders      o  ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
WHERE o.status = 'Delivered'
GROUP BY c.city
ORDER BY revenue DESC;

-- Q4. Cancellation and return rate by status
SELECT
    status,
    COUNT(*)                                             AS orders,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 1) AS pct_of_orders
FROM orders
GROUP BY status
ORDER BY orders DESC;
