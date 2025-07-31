{{
    config(
        materialized='table'
    )
}}

-- Dimension table for flights
-- Contains comprehensive flight segment information with route details

select
    s.segment_id,
    s.departure_airport,
    s.arrival_airport,
    s.departure_airport || '-' || s.arrival_airport as route,
    s.departure_date,
    s.departure_time,
    s.arrival_date,
    s.arrival_time,
    s.airline,
    s.flight_number,
    s.aircraft_type,
    s.duration_minutes,
    
    -- Derived attributes
    case 
        when s.duration_minutes < 120 then 'Short Haul'
        when s.duration_minutes < 360 then 'Medium Haul'
        else 'Long Haul'
    end as flight_category,
    
    -- Note: Simplified flight type logic - in production would use airport-to-country mapping
    case 
        when s.departure_airport = s.arrival_airport then 'Domestic'  -- This case would never occur for the current assignment
        else 'International'  -- Treating all as international for mock data
    end as flight_type,
    
    extract(hour from s.departure_time) as departure_hour,
    extract(dow from s.departure_date) as departure_day_of_week,
    
    case 
        when extract(hour from s.departure_time) between 6 and 11 then 'Morning'
        when extract(hour from s.departure_time) between 12 and 17 then 'Afternoon'
        when extract(hour from s.departure_time) between 18 and 21 then 'Evening'
        else 'Night'
    end as departure_time_category,
    
    round(s.duration_minutes / 60.0, 2) as duration_hours

from {{ ref('stg_segments') }} AS s
