CREATE TABLE stg_brands (
    id TEXT PRIMARY KEY,               -- Assuming _id is a UUID format
    cpg_id TEXT,                       -- Assuming $id is a UUID format
    cpg_ref TEXT,                      -- $ref as a TEXT field
    brand_name TEXT,                   -- Name of the brand
    barcode TEXT,                      -- Barcode as TEXT
    category TEXT,                     -- Category as TEXT
    category_code TEXT,                -- Category code as TEXT
    top_brand BOOLEAN                  -- Boolean to indicate if it's a top brand
);

INSERT INTO stg_brands (
    id,
    cpg_id,
    cpg_ref,
    brand_name,
    barcode,
    category,
    category_code,
    top_brand
)
SELECT
    (data->'_id'->>'$oid')::TEXT AS id,
    (data->'cpg'->'$id'->>'$oid')::TEXT AS cpg_id,
    data->'cpg'->>'$ref' AS cpg_ref,
    data->>'name' AS brand_name,
    data->>'barcode' AS barcode,
    data->>'category' AS category,
    data->>'categoryCode' AS category_code,
    (data->>'topBrand')::BOOLEAN AS top_brand
FROM fetch_challenge.raw_brands; -- Replace raw_data with your source table name