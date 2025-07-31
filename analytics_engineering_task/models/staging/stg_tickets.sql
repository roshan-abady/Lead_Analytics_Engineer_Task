{{
    config(
        materialized='view'
    )
}}

-- Staging model for tickets
-- Clean and standardize ticket pricing information

select
    ticket_id,
    booking_id,
    ticket_number,
    fare_class,
    fare_basis,
    base_fare::decimal(10, 2) as base_fare,
    taxes_fees::decimal(10, 2) as taxes_fees,
    total_price::decimal(10, 2) as total_price,
    currency,
    ticket_status,
    issue_date::date as issue_date,
    valid_until::date as valid_until
from {{ ref('raw_tickets') }}
