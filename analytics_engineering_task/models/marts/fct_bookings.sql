{{
    config(
        materialized='table'
    )
}}

-- Fact table for booking transactions
-- Grain: One row per ticket-segment-passenger combination
-- Contains all measurable/numeric facts for analytics

select
    -- Surrogate key
    {{ dbt_utils.generate_surrogate_key(['t.ticket_id', 's.segment_id', 'p.passenger_id']) }} as booking_fact_key,
    
    -- Foreign keys to dimensions
    b.booking_id,
    t.ticket_id,
    s.segment_id,
    p.passenger_id,
    
    -- Date keys for time-based analysis
    b.booking_date,
    s.departure_date,
    s.arrival_date,
    t.issue_date,
    
    -- Booking attributes
    b.booking_status,
    b.customer_id,
    
    -- Ticket attributes
    t.ticket_status,
    t.fare_class,
    t.fare_basis,
    
    -- Flight attributes
    s.airline,
    s.departure_airport,
    s.arrival_airport,
    
    -- Passenger attributes  
    p.passenger_type,
    p.nationality,
    
    -- Service attributes
    ts.seat_class,
    ts.meal_preference,
    tp.special_assistance,
    
    -- Measurable facts
    t.base_fare,
    t.taxes_fees,
    t.total_price,
    t.currency,
    s.duration_minutes,
    ts.baggage_allowance,
    
    -- Calculated metrics
    case when t.ticket_status = 'issued' then t.total_price else 0 end as revenue,
    case when b.booking_status = 'confirmed' then 1 else 0 end as confirmed_booking_flag,
    case when tp.boarding_pass_issued then 1 else 0 end as boarded_flag,
    
    -- Timestamps
    b.created_at as booking_created_at,
    t.issue_date as ticket_issued_at

from {{ ref('stg_bookings') }} AS b
inner join {{ ref('stg_tickets') }} AS t 
    on b.booking_id = t.booking_id
inner join {{ ref('stg_ticket_segments') }} AS ts 
    on t.ticket_id = ts.ticket_id
inner join {{ ref('stg_segments') }} AS s 
    on ts.segment_id = s.segment_id
inner join {{ ref('stg_ticket_passengers') }} AS tp 
    on t.ticket_id = tp.ticket_id
inner join {{ ref('stg_passengers') }} AS p 
    on tp.passenger_id = p.passenger_id
