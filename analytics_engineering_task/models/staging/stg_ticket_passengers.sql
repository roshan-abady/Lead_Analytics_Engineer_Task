{{
    config(
        materialized='view'
    )
}}

-- Staging model for ticket-passenger relationships
-- Includes boarding information

select
    ticket_passenger_id,
    ticket_id,
    passenger_id,
    boarding_pass_issued::boolean as boarding_pass_issued,
    boarding_gate,
    boarding_group::integer as boarding_group,
    special_assistance,
    created_at::timestamp as created_at
from {{ ref('raw_ticket_passengers') }}
