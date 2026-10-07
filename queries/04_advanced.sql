-- LEVEL 4: ADVANCED (RFM segments, cohort retention, view, query plan)

-- Q14. RFM customer segmentation (NTILE)
--   R = how recently they bought, F = how often, M = how much they spent.
--   Score each 1-4 (4 = best). Reference date = 2026-01-01.
WITH customer_stats AS (
    SELECT
        o.customer_id,
        julianday('2026-01-01') - julianday(MAX(o.order_date)) AS days_since_last,
        COUNT(DISTINCT o.order_id)                             AS frequency,
        SUM(oi.quantity * oi.unit_price)                       AS monetary
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY o.customer_id
),
scored AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY days_since_last DESC) AS r_score,  -- recent = high
        NTILE(4) OVER (ORDER BY frequency)            AS f_score,
        NTILE(4) OVER (ORDER BY monetary)             AS m_score
    FROM customer_stats
),
segmented AS (
    SELECT *,
        CASE
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Champions'
            WHEN r_score >= 3 AND f_score <= 2                   THEN 'New / Promising'
            WHEN r_score <= 2 AND f_score >= 3                   THEN 'At Risk'
            WHEN r_score = 1  AND f_score = 1                    THEN 'Lost'
            ELSE 'Regular'
        END AS segment
    FROM scored
)
SELECT
    segment,
    COUNT(*)                     AS customers,
    ROUND(AVG(monetary), 0)      AS avg_spend,
    ROUND(SUM(monetary), 0)      AS total_spend
FROM segmented
GROUP BY segment
ORDER BY total_spend DESC;

-- Q15. Cohort retention: of customers whose FIRST order was in month X,
--      how many ordered again in the next month?
--      Note: Dec 2025 shows 0% only because the data stops at Dec 31.
WITH first_order AS (
    SELECT customer_id, strftime('%Y-%m', MIN(order_date)) AS cohort_month
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY customer_id
),
activity AS (
    SELECT DISTINCT customer_id, strftime('%Y-%m', order_date) AS active_month
    FROM orders
    WHERE status = 'Delivered'
)
SELECT
    f.cohort_month,
    COUNT(DISTINCT f.customer_id) AS cohort_size,
    COUNT(DISTINCT CASE
        WHEN a.active_month = strftime('%Y-%m', date(f.cohort_month || '-01', '+1 month'))
        THEN a.customer_id END)   AS returned_next_month,
    ROUND(100.0 * COUNT(DISTINCT CASE
        WHEN a.active_month = strftime('%Y-%m', date(f.cohort_month || '-01', '+1 month'))
        THEN a.customer_id END) / COUNT(DISTINCT f.customer_id), 1) AS retention_pct
FROM first_order f
LEFT JOIN activity a ON a.customer_id = f.customer_id
GROUP BY f.cohort_month
ORDER BY f.cohort_month;

-- Q16. Create a VIEW so the "Delivered revenue" logic lives in ONE place
DROP VIEW IF EXISTS v_delivered_sales;
CREATE VIEW v_delivered_sales AS
SELECT
    o.order_id,
    o.order_date,
    c.customer_id,
    c.city,
    p.category,
    p.product_name,
    oi.quantity,
    oi.quantity * oi.unit_price AS line_revenue
FROM orders o
JOIN customers   c  ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
JOIN products    p  ON p.product_id  = oi.product_id
WHERE o.status = 'Delivered';

-- Q17. Use the view: best category in each city
WITH city_cat AS (
    SELECT city, category, SUM(line_revenue) AS revenue
    FROM v_delivered_sales
    GROUP BY city, category
),
ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY city ORDER BY revenue DESC) AS rn
    FROM city_cat
)
SELECT city, category AS top_category, ROUND(revenue, 0) AS revenue
FROM ranked
WHERE rn = 1
ORDER BY revenue DESC;
