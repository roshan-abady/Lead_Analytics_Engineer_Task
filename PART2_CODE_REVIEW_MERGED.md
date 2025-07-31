# Part 2: Code Review - Mentoring a Junior Engineer

## Junior Engineer's Submitted Code

```sql
select bookingid, count(*) as passenger_count, sum(bookingPrice) as revenue
from {{ ref('raw_bookings') }} b
join {{ ref('raw_passengers') }} p on b.bookingid = p.bookingid
join {{ ref('raw_tickets') }} t on b.bookingid = t.bookingid
group by bookingid
```

---

## Code Review Feedback

### **What You Did Well**

1. **Correct dbt Syntax**: Proper use of `{{ ref() }}` for model references - excellent!
2. **Table Aliases**: Good use of short, meaningful aliases (b, p, t)
3. **Basic Structure**: The core logic makes sense for a booking summary

---

## **Technical Issues - dbt Best Practices & Standards**

### 1. **SQL Formatting & Readability**

**Issue**: Poor formatting makes the code hard to read and maintain.

**Current Code:**

```sql
select bookingid, count(*) as passenger_count, sum(bookingPrice) as revenue
from {{ ref('raw_bookings') }} b
join {{ ref('raw_passengers') }} p on b.bookingid = p.bookingid
join {{ ref('raw_tickets') }} t on b.bookingid = t.bookingid
group by bookingid
```

**Improved Code:**

```sql
select
    b.booking_id,
    count(distinct p.passenger_id) as passenger_count,
    sum(t.total_price) as revenue
from {{ ref('raw_bookings') }} as b
inner join {{ ref('raw_passengers') }} as p 
    on b.booking_id = p.booking_id
inner join {{ ref('raw_tickets') }} as t 
    on b.booking_id = t.booking_id
group by b.booking_id
```

### 2. **Column Naming Consistency**

**Issues**:

- Using `bookingid` vs `booking_id` (inconsistent with schema)
- Column `bookingPrice` doesn't exist - should be `total_amount` or `total_price`
- Missing table aliases in SELECT clause

**Fix**: Use consistent column names that match your schema and always prefix with table aliases.

### 3. **Missing JOIN Type Specification**

**Issue**: Implicit JOINs can be confusing and may not reflect business intent.

**Fix**: Always specify JOIN type explicitly (`INNER JOIN`, `LEFT JOIN`, etc.)

### 4. **Missing dbt Configuration**

**Issue**: No model configuration block.

**Addition Needed:**

```sql
{{
    config(
        materialized='view'  -- or 'table' based on usage
    )
}}
```

### 5. **Lack of Documentation**

**Issue**: No comments explaining business logic.

**Improvement**: Add comments explaining the purpose and any business rules.

---

## **Logic Issues - Business Calculations & Data Accuracy**

### 1. **Business Logic Problem - Double Counting**

**Issue**: Your joins create a Cartesian product, inflating passenger and revenue counts.

**Example**: If Booking BK001 has 2 passengers and 2 tickets:

- Your query returns: `passenger_count = 4` (should be 2)
- Your query returns: `revenue = 2500` (should be 1250)

**Solution**: Use `COUNT(DISTINCT)` and consider the correct grain:

```sql
COUNT(DISTINCT p.passenger_id) as unique_passenger_count
```

### 2. **Incorrect Revenue Calculation**

**Issues**:

- Should use ticket-level pricing, not booking-level
- Need to consider ticket status (only sum issued, not refunded/cancelled/pending tickets)

**Improved Logic:**

```sql
sum(case when t.ticket_status = 'issued' then t.total_price else 0 end) as revenue
```

### 3. **Missing Data Quality Considerations**

**Issues**:

- No filtering for cancelled bookings
- No handling of currency differences
- No consideration of refunded tickets
- Missing validation for edge cases

---

## **Recommended Complete Rewrite**

Here's how I would rewrite this model following both technical and logical best practices:

```sql
{{
    config(
        materialized='view'
    )
}}

-- Booking summary model
-- Aggregates passenger count and revenue at booking level
-- Only includes confirmed bookings with issued tickets

with booking_passengers as (
    select 
        booking_id,
        count(distinct passenger_id) as unique_passenger_count
    from {{ ref('stg_ticket_passengers') }} as tp
    inner join {{ ref('stg_passengers') }} as p 
        on tp.passenger_id = p.passenger_id
    group by booking_id
),

booking_revenue as (
    select 
        booking_id,
        sum(case 
            when ticket_status = 'issued' then total_price 
            else 0 
        end) as total_revenue,
        count(distinct ticket_id) as total_tickets,
        count(distinct case 
            when ticket_status = 'issued' 
            then ticket_id 
        end) as issued_tickets
    from {{ ref('stg_tickets') }}
    group by booking_id
)

select
    b.booking_id,
  
    -- Passenger metrics
    bp.unique_passenger_count,
  
    -- Revenue metrics (only from issued tickets)
    br.total_revenue,
  
    -- Additional useful metrics
    br.total_tickets,
    br.issued_tickets,
    br.total_revenue / bp.unique_passenger_count as revenue_per_passenger,
  
    -- Booking details
    b.booking_status,
    b.booking_date,
    b.currency

from {{ ref('stg_bookings') }} as b
inner join booking_passengers as bp 
    on b.booking_id = bp.booking_id
inner join booking_revenue as br 
    on b.booking_id = br.booking_id

-- Only include confirmed bookings
where b.booking_status = 'confirmed'
```

---

## **Learning Points for Junior Developer**

### **Technical Best Practices:**

1. **Formatting**: Always format SQL for readability
2. **Consistency**: Use consistent naming conventions matching your schema
3. **Explicitness**: Be explicit about JOINs and use `as` for aliases
4. **Documentation**: Comment complex business logic
5. **Configuration**: Always include dbt config blocks

### **Business Logic Thinking:**

1. **Data Grain**: Understand the relationship between tables and what each join multiplies
2. **Accuracy**: Think carefully about what you're counting/summing
3. **Edge Cases**: Consider cancelled bookings, refunded tickets, different statuses
4. **Validation**: Test your logic with known data to verify results
5. **Business Questions**: Always think about the business question you're answering

### **Next Steps:**

1. Fix the critical issues first (grain and revenue calculation)
2. Add appropriate tests (uniqueness of booking_id, revenue >= 0)
3. Consider if this should be materialized as a table for performance
4. Think about additional metrics that might be useful for stakeholders

### **Questions for Discussion:**

1. Should we include cancelled bookings in the analysis?
2. How should we handle multi-currency scenarios?
3. What's the business definition of "revenue" - gross or net?
4. Do we need historical snapshots of this data?
