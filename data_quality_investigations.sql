-- Duplicate Keys
-- Check for duplicate _id in users
SELECT id, COUNT(*)
FROM fetch_challenge.stg_users
GROUP BY id
HAVING COUNT(*) > 1;

-- Check for duplicate _id in receipts
SELECT id, COUNT(*)
FROM fetch_challenge.stg_receipts
GROUP BY id
HAVING COUNT(*) > 1;

-- Check for duplicate id in brands
SELECT id, COUNT(*)
FROM fetch_challenge.stg_brands
GROUP BY id
HAVING COUNT(*) > 1;

----------------------------------------------------

-- Null or Missing Values
-- Null values in critical columns for users
SELECT COUNT(*) AS total_users,
       COUNT(id) AS non_null_id,
       COUNT(role) AS non_null_role,
       COUNT(state) AS non_null_state
FROM fetch_challenge.stg_users;

-- Null values in receipts
SELECT COUNT(*) AS total_receipts,
       COUNT(id) AS non_null_id,
       COUNT(user_id) AS non_null_user_id,
       COUNT(total_spent) AS non_null_total_spent
FROM fetch_challenge.stg_receipts;

----------------------------------------------------

-- Referential Integrity
-- Receipts referencing non-existent users
SELECT r.id AS receipt_id, r.user_id
FROM fetch_challenge.stg_receipts r
LEFT JOIN fetch_challenge.stg_users u ON r.user_id = u.id
WHERE u.id IS NULL;

-- Receipt items referencing non-existent receipts
SELECT ri.receipt_id
FROM fetch_challenge.stg_receipt_items ri
LEFT JOIN fetch_challenge.stg_receipts r ON ri.receipt_id = r.id
WHERE r.id IS NULL;

----------------------------------------------------

-- Logical Anomalies
-- Negative or zero total spend in receipts
SELECT *
FROM fetch_challenge.stg_receipts
WHERE total_spent < 0;

-- Items with negative or zero price
SELECT *
FROM fetch_challenge.stg_receipt_items
WHERE item_price < 0;

-- Created dates in the future
SELECT *
FROM fetch_challenge.stg_users
WHERE created_date > CURRENT_DATE;

----------------------------------------------------

-- Outliers in Metrics
-- Outliers in total spend (e.g., greater than 99th percentile)
WITH stats AS (
    SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY total_spent) AS p99
    FROM fetch_challenge.stg_receipts
)
SELECT *
FROM fetch_challenge.stg_receipts r, stats
WHERE r.total_spent > stats.p99;

-- Outliers in item prices
WITH stats AS (
    SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY item_price::NUMERIC) AS p99
    FROM fetch_challenge.stg_receipt_items
)
SELECT *
FROM fetch_challenge.stg_receipt_items ri, stats
WHERE ri.item_price::NUMERIC > stats.p99;
