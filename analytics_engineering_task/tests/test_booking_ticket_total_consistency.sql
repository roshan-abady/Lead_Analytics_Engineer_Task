-- Testing to ensure booking total matches sum of ticket prices
with booking_totals as (
    select 
        booking_id,
        total_amount as booking_total
    from {{ ref('stg_bookings') }}
),

ticket_totals as (
    select 
        booking_id,
        sum(total_price) as ticket_total
    from {{ ref('stg_tickets') }}
    where ticket_status = 'issued'
    group by booking_id
)

select 
    b.booking_id,
    b.booking_total,
    coalesce(t.ticket_total, 0) as ticket_total,
    abs(b.booking_total - coalesce(t.ticket_total, 0)) as difference
from booking_totals AS b
left join ticket_totals AS t on b.booking_id = t.booking_id
where abs(b.booking_total - coalesce(t.ticket_total, 0)) > 0.01  -- Allowing for small rounding differences
