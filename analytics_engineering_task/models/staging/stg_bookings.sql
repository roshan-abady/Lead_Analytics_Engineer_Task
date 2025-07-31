{{
    config(
        materialized='view'
    )
}}

-- Staging model for raw bookings data

select
    booking_id,
    customer_id,
    booking_date::date as booking_date,
    booking_status,
    total_amount::decimal(10, 2) as total_amount,
    currency,
    created_at::timestamptz as created_at,
    updated_at::timestamptz as updated_at
from {{ ref('raw_bookings') }}
