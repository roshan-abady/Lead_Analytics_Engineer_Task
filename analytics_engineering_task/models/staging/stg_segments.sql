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
    strptime(departure_time, '%H:%M:%S+00:00')::time as departure_time,
    arrival_date::date as arrival_date,
    strptime(arrival_time, '%H:%M:%S+00:00')::time as arrival_time,
    airline,
    flight_number,
    aircraft_type,
    duration_minutes::integer as duration_minutes
from {{ ref('raw_segments') }}
