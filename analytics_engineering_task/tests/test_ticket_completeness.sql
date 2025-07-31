-- Testing to ensure all ticket-passenger combinations have corresponding ticket-segment records
with ticket_passengers as (
    select distinct ticket_id
    from {{ ref('stg_ticket_passengers') }}
),

ticket_segments as (
    select distinct ticket_id  
    from {{ ref('stg_ticket_segments') }}
)

select tp.ticket_id
from ticket_passengers AS tp
left join ticket_segments AS ts
    on tp.ticket_id = ts.ticket_id
where ts.ticket_id is null
