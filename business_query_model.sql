WITH date_spine AS (
    -- Generate a date spine with monthly intervals
    SELECT
        DATE_TRUNC('month', MIN(r.create_date)) + (INTERVAL '1 month' * generate_series(0,
        (EXTRACT(YEAR FROM MAX(r.create_date)) * 12 + EXTRACT(MONTH FROM MAX(r.create_date)) -
        (EXTRACT(YEAR FROM MIN(r.create_date)) * 12 + EXTRACT(MONTH FROM MIN(r.create_date))))))
        AS month
    FROM fetch_challenge.stg_receipts r
),
recent_users AS (
    -- Get users created within the last 6 months
    SELECT
        id AS user_id
    FROM fetch_challenge.stg_users
    WHERE created_date >= CURRENT_DATE - INTERVAL '6 months'
),
brand_spend AS (
    -- Calculate total spend by brand for users created within the last 6 months
    SELECT
        b.id AS brand_id,
        b.brand_name,
        SUM(r.total_spent) AS total_spend
    FROM fetch_challenge.stg_brands b
    JOIN fetch_challenge.stg_receipt_items ri ON b.barcode = ri.barcode
    JOIN fetch_challenge.stg_receipts r ON ri.receipt_id = r.id
    left JOIN recent_users u ON r.user_id = u.user_id
    GROUP BY b.id, b.brand_name
),

brand_transactions AS (
    -- Calculate total transactions by brand for users created within the last 6 months
    SELECT
        b.id AS brand_id,
        b.brand_name,
        COUNT(DISTINCT r.id) AS transaction_count
    FROM fetch_challenge.stg_brands b
    JOIN fetch_challenge.stg_receipt_items ri ON b.barcode = ri.barcode
    JOIN fetch_challenge.stg_receipts r ON ri.receipt_id = r.id
    left JOIN recent_users u ON r.user_id = u.user_id
    GROUP BY b.id, b.brand_name
),
brand_metrics AS (
    -- Calculate receipts scanned by brand and month
    SELECT
        DATE_TRUNC('month', r.create_date) AS month,
        b.id AS brand_id,
        b.brand_name,
        COUNT(DISTINCT r.id) AS receipts_scanned
    FROM fetch_challenge.stg_brands b
    JOIN fetch_challenge.stg_receipt_items ri ON b.barcode = ri.barcode
    JOIN fetch_challenge.stg_receipts r ON ri.receipt_id = r.id
    GROUP BY DATE_TRUNC('month', r.create_date), b.id, b.brand_name
)
-- Combine all metrics
SELECT
    ds.month,
    bm.brand_name,
    bm.receipts_scanned,
    bs.total_spend,
    bt.transaction_count
FROM date_spine ds
LEFT JOIN brand_metrics bm ON ds.month = bm.month
LEFT JOIN brand_spend bs ON bm.brand_id = bs.brand_id
LEFT JOIN brand_transactions bt ON bm.brand_id = bt.brand_id
where bm.brand_name is not null
and receipts_scanned is not null
and total_spend is not null
and transaction_count is not null
ORDER BY month, receipts_scanned DESC, total_spend DESC, transaction_count DESC;
