select * from fetch_challenge.stg_receipts r
left join fetch_challenge.stg_users u on r.user_id = u.id

select * from fetch_challenge.stg_receipt_items ri
left join fetch_challenge.stg_receipts r on ri.receipt_id = r.id

select * from fetch_challenge.stg_brands