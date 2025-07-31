{{
    config(
        materialized='view'
    )
}}

-- Staging model for ticket-segment relationships
-- Includes seat/service information

select
    ticket_segment_id,
    ticket_id,
    segment_id,
    seat_number,
    seat_class,
    baggage_allowance::integer as baggage_allowance,
    meal_preference,
    created_at::timestamp as created_at
from {{ ref('raw_ticket_segments') }}
