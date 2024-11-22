CREATE TABLE fetch_challenge.stg_users (
    id TEXT PRIMARY KEY,              -- Assuming _id is a UUID format
    role TEXT,                        -- Role of the user (e.g., consumer)
    state TEXT,                       -- User's state (e.g., WI)
    active BOOLEAN,                   -- Boolean indicating if the user is active
    last_login TIMESTAMP,             -- Last login timestamp
    created_date TIMESTAMP,           -- Created date timestamp
    sign_up_source TEXT               -- Sign up source (e.g., Email)
);

INSERT INTO stg_users (
    id,
    role,
    state,
    active,
    last_login,
    created_date,
    sign_up_source
)
with dedupe_users as (select *, ROW_NUMBER() OVER (PARTITION BY (data->'_id'->>'$oid')::TEXT ORDER BY (data->'_id'->>'$oid')::TEXT) as rn
 from fetch_challenge.raw_users
)
SELECT
    (data->'_id'->>'$oid')::TEXT AS id,
    data->>'role' AS role,
    data->>'state' AS state,
    (data->>'active')::BOOLEAN AS active,
    to_timestamp((data->'lastLogin'->>'$date')::BIGINT / 1000) AS last_login,
    to_timestamp((data->'createdDate'->>'$date')::BIGINT / 1000) AS created_date,
    data->>'signUpSource' AS sign_up_source
    FROM dedupe_users
where rn = 1


