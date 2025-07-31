{{
    config(
        materialized='view'
    )
}}

-- Staging model for segments (flight legs)

select
    segment_id,
    booking_id,
    departure_airport,
    arrival_airport,
    departure_date::date as departure_date,
    departure_time::timestamptz as departure_time,
    arrival_date::date as arrival_date,
    arrival_time::timestamptz as arrival_time,
    airline,
    flight_number,
    aircraft_type,
    duration_minutes::integer as duration_minutes
from {{ ref('raw_segments') }}
