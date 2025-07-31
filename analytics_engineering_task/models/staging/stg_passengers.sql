{{
    config(
        materialized='view'
    )
}}

-- Staging model for passengers

select
    passenger_id,
    booking_id,
    first_name,
    last_name,
    date_of_birth::date as date_of_birth,
    gender,
    nationality,
    passport_number,
    frequent_flyer_number,
    passenger_type,
    created_at::timestamp as created_at,
    -- Calculate age at time of booking
    extract(year from age(current_date, date_of_birth::date)) as age_years
from {{ ref('raw_passengers') }}
