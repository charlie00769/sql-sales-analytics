-- LEVEL 3: WINDOW FUNCTIONS (this is what SQL tests ask most)

-- Q10. Monthly revenue + growth vs previous month (LAG)
WITH monthly AS (
    SELECT
        strftime('%Y-%m', o.order_date)            AS month,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY month
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
          / LAG(revenue) OVER (ORDER BY month), 1) AS growth_pct
FROM monthly
ORDER BY month;

-- Q11. Running (cumulative) revenue through the year (SUM OVER)
WITH monthly AS (
    SELECT
        strftime('%Y-%m', o.order_date)            AS month,
        SUM(oi.quantity * oi.unit_price)           AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY month
)
SELECT
    month,
    ROUND(revenue, 2)                                   AS revenue,
    ROUND(SUM(revenue) OVER (ORDER BY month), 2)        AS running_total
FROM monthly
ORDER BY month;

-- Q12. Top 3 products in each category (RANK + PARTITION BY)
WITH product_sales AS (
    SELECT
        p.category,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM order_items oi
    JOIN orders   o ON o.order_id   = oi.order_id
    JOIN products p ON p.product_id = oi.product_id
    WHERE o.status = 'Delivered'
    GROUP BY p.product_id
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rnk
    FROM product_sales
)
SELECT category, rnk, product_name, ROUND(revenue, 2) AS revenue
FROM ranked
WHERE rnk <= 3
ORDER BY category, rnk;

-- Q13. Average days between a customer's 1st and 2nd order
--      (ROW_NUMBER + LEAD)
WITH numbered AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS order_no,
        LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS next_order_date
    FROM orders
    WHERE status = 'Delivered'
)
SELECT
    ROUND(AVG(julianday(next_order_date) - julianday(order_date)), 1) AS avg_days_to_second_order,
    COUNT(*) AS customers_with_second_order
FROM numbered
WHERE order_no = 1 AND next_order_date IS NOT NULL;
