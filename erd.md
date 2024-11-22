```mermaid
erDiagram
    BRANDS {
        UUID id PK
        TEXT name
        TEXT barcode
        TEXT category
        TEXT category_code
        BOOLEAN top_brand
    }

    USERS {
        UUID id PK
        TEXT role
        TEXT state
        BOOLEAN active
        TIMESTAMP last_login
        TIMESTAMP created_date
        TEXT sign_up_source
    }

    RECEIPTS {
        UUID id PK
        UUID user_id FK --> USERS.id
        TIMESTAMP create_date
        TIMESTAMP modify_date
        NUMERIC total_spent
        TIMESTAMP date_scanned
        TIMESTAMP purchase_date
        INTEGER purchased_item_count
        BOOLEAN active
    }

    RECEIPT_ITEMS {
        SERIAL id PK
        UUID receipt_id FK --> RECEIPTS.id
        TEXT barcode
        NUMERIC item_price
        NUMERIC final_price
        TEXT description
        TEXT rewards_group
        BOOLEAN needs_review
        TEXT points_not_awarded_reason
    }

    BRANDS ||--o{ RECEIPT_ITEMS : "linked to"
    USERS ||--o{ RECEIPTS : "owns"
    RECEIPTS ||--o{ RECEIPT_ITEMS : "contains"
