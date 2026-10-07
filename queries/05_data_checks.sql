-- LEVEL 5: DATA QUALITY CHECKS (what data engineers run before trusting data)
-- Every check should return 0. A non-zero number means a problem.

-- Q18. Orders pointing to a customer that does not exist
SELECT COUNT(*) AS orphan_orders
FROM orders o
LEFT JOIN customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

-- Q19. Order items pointing to a missing order or product
SELECT COUNT(*) AS orphan_items
FROM order_items oi
LEFT JOIN orders   o ON o.order_id   = oi.order_id
LEFT JOIN products p ON p.product_id = oi.product_id
WHERE o.order_id IS NULL OR p.product_id IS NULL;

-- Q20. Orders placed BEFORE the customer signed up
SELECT COUNT(*) AS orders_before_signup
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_date < c.signup_date;

-- Q21. Orders with no items
SELECT COUNT(*) AS orders_without_items
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
WHERE oi.item_id IS NULL;

-- Q22. Item price differs from the product's list price
SELECT COUNT(*) AS price_mismatches
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
WHERE oi.unit_price <> p.price;
