-- Testing to ensure departure date is before arrival date for all segments
select *
from {{ ref('stg_segments') }}
where departure_date > arrival_date
