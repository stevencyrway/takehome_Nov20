-- Table to store main receipt data
CREATE TABLE stg_receipts (
    id TEXT PRIMARY KEY, -- Changed from UUID to TEXT
    user_id TEXT,
    create_date TIMESTAMP,
    modify_date TIMESTAMP,
    total_spent NUMERIC,
    date_scanned TIMESTAMP,
    finished_date TIMESTAMP,
    points_earned NUMERIC,
    purchase_date TIMESTAMP,
    bonus_points_earned INTEGER,
    points_awarded_date TIMESTAMP,
    purchased_item_count INTEGER,
    rewards_receipt_status TEXT,
    bonus_points_earned_reason TEXT
);

-- Table to store nested receipt items
CREATE TABLE stg_receipt_items (
    id SERIAL PRIMARY KEY, -- Unique identifier for each row
    receipt_id TEXT REFERENCES stg_receipts(id), -- Link to stg_receipts table
    barcode TEXT,
    item_price NUMERIC,
    final_price NUMERIC,
    description TEXT,
    partner_item_id TEXT,
    quantity_purchased INTEGER,
    rewards_group TEXT,
    needs_fetch_review BOOLEAN,
    user_flagged_price NUMERIC,
    user_flagged_barcode TEXT,
    user_flagged_new_item BOOLEAN,
    user_flagged_quantity INTEGER,
    needs_fetch_review_reason TEXT,
    points_not_awarded_reason TEXT,
    prevent_target_gap_points BOOLEAN,
    user_flagged_description TEXT,
    rewards_product_partner_id TEXT

);

INSERT INTO stg_receipts (
    id,
    user_id,
    create_date,
    modify_date,
    total_spent,
    date_scanned,
    finished_date,
    points_earned,
    purchase_date,
    bonus_points_earned,
    points_awarded_date,
    purchased_item_count,
    rewards_receipt_status,
    bonus_points_earned_reason
)
SELECT
    (data->'_id'->>'$oid')::TEXT AS id,
    (data->>'userId')::TEXT AS user_id,
    to_timestamp((data->'createDate'->>'$date')::BIGINT / 1000) AS create_date,
    to_timestamp((data->'modifyDate'->>'$date')::BIGINT / 1000) AS modify_date,
    (data->>'totalSpent')::NUMERIC AS total_spent,
    to_timestamp((data->'dateScanned'->>'$date')::BIGINT / 1000) AS date_scanned,
    to_timestamp((data->'finishedDate'->>'$date')::BIGINT / 1000) AS finished_date,
    (data->>'pointsEarned')::NUMERIC AS points_earned,
    to_timestamp((data->'purchaseDate'->>'$date')::BIGINT / 1000) AS purchase_date,
    (data->>'bonusPointsEarned')::INTEGER AS bonus_points_earned,
    to_timestamp((data->'pointsAwardedDate'->>'$date')::BIGINT / 1000) AS points_awarded_date,
    (data->>'purchasedItemCount')::INTEGER AS purchased_item_count,
    data->>'rewardsReceiptStatus' AS rewards_receipt_status,
    data->>'bonusPointsEarnedReason' AS bonus_points_earned_reason
FROM fetch_challenge.raw_receipts; -- Replace 'receipts' with your actual table name


INSERT INTO stg_receipt_items (
    receipt_id,
    barcode,
    item_price,
    final_price,
    description,
    partner_item_id,
    quantity_purchased,
    rewards_group,
    needs_fetch_review,
    user_flagged_price,
    user_flagged_barcode,
    user_flagged_new_item,
    user_flagged_quantity,
    needs_fetch_review_reason,
    points_not_awarded_reason,
    prevent_target_gap_points,
    user_flagged_description,
    rewards_product_partner_id
)
SELECT
    (data->'_id'->>'$oid')::TEXT AS receipt_id,
    item->>'barcode' AS barcode,
    (item->>'itemPrice')::NUMERIC AS item_price,
    (item->>'finalPrice')::NUMERIC AS final_price,
    item->>'description' AS description,
    item->>'partnerItemId' AS partner_item_id,
    (item->>'quantityPurchased')::INTEGER AS quantity_purchased,
    item->>'rewardsGroup' AS rewards_group,
    (item->>'needsFetchReview')::BOOLEAN AS needs_fetch_review,
    (item->>'userFlaggedPrice')::NUMERIC AS user_flagged_price,
    item->>'userFlaggedBarcode' AS user_flagged_barcode,
    (item->>'userFlaggedNewItem')::BOOLEAN AS user_flagged_new_item,
    (item->>'userFlaggedQuantity')::INTEGER AS user_flagged_quantity,
    item->>'needsFetchReviewReason' AS needs_fetch_review_reason,
    item->>'pointsNotAwardedReason' AS points_not_awarded_reason,
    (item->>'preventTargetGapPoints')::BOOLEAN AS prevent_target_gap_points,
    item->>'userFlaggedDescription' AS user_flagged_description,
    (item->>'rewardsProductPartnerId')::TEXT AS rewards_product_partner_id
FROM fetch_challenge.raw_receipts, jsonb_array_elements(data->'rewardsReceiptItemList') AS item;