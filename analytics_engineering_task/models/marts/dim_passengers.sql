{{
    config(
        materialized='table'
    )
}}

-- Dimension table for passengers
-- Contains comprehensive passenger information with derived attributes

select
    p.passenger_id,
    p.first_name,
    p.last_name,
    p.first_name || ' ' || p.last_name as full_name,
    p.date_of_birth,
    p.gender,
    p.nationality,
    p.passport_number,
    p.frequent_flyer_number,
    p.passenger_type,
    p.age_years,
    p.created_at,
    
    -- Derived attributes
    case 
        when p.age_years < 2 then 'Infant'
        when p.age_years < 12 then 'Child'
        when p.age_years < 18 then 'Minor'
        when p.age_years < 65 then 'Adult'
        else 'Senior'
    end as age_category,
    
    case 
        when p.frequent_flyer_number is not null then 'Frequent Flyer'
        else 'Regular'
    end as customer_tier,
    
    -- Count of total bookings for this passenger
    count(distinct b.booking_id) as total_bookings

from {{ ref('stg_passengers') }} AS p
left join {{ ref('stg_bookings') }} AS b 
    on p.booking_id = b.booking_id

group by 
    p.passenger_id,
    p.first_name,
    p.last_name,
    p.date_of_birth,
    p.gender,
    p.nationality,
    p.passport_number,
    p.frequent_flyer_number,
    p.passenger_type,
    p.age_years,
    p.created_at
