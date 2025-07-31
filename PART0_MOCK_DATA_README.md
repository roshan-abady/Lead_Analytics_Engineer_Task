# Mock Data Overview for Travel Booking Platform

## Data Structure Summary

I've created mock data for 6 interrelated tables representing a travel booking platform:

### Core Tables

#### 1. **raw_bookings.csv** (10 records)

- Primary table containing booking-level information
- Key fields: `booking_id`, `customer_id`, `booking_date`, `booking_status`, `total_amount`, `currency`
- Statuses: confirmed, cancelled, pending
- Currencies: USD, EUR, GBP

#### 2. **raw_segments.csv** (15 records)

- Travel legs/flights within bookings
- Key fields: `segment_id`, `booking_id`, departure/arrival airports, flight details
- Covers domestic US, European, and international routes
- Includes realistic flight durations and aircraft types

#### 3. **raw_passengers.csv** (14 records)

- Traveler information
- Key fields: `passenger_id`, `booking_id`, personal details, `passenger_type`
- Mix of adults and children
- Some have frequent flyer numbers

#### 4. **raw_tickets.csv** (16 records)

- Ticket pricing and fare information
- Key fields: `ticket_id`, `booking_id`, fare details, pricing breakdown
- Fare classes: Y (economy), W (premium economy), J (business), F (first)
- Various ticket statuses: issued, cancelled, refunded, pending

### Linking Tables

#### 5. **raw_ticket_segments.csv** (28 records)

- Links tickets to flight segments
- Key fields: `ticket_id`, `segment_id`, seat assignments, service preferences
- Includes seat numbers, meal preferences, baggage allowances

#### 6. **raw_ticket_passengers.csv** (16 records)

- Links tickets to passengers
- Key fields: `ticket_id`, `passenger_id`, boarding information
- Includes boarding passes, gates, special assistance needs

## Relationships

```
Booking (1) -> (M) Segment
Booking (1) -> (M) Passenger  
Booking (1) -> (M) Ticket

Ticket (M) -> (M) Segment (via ticket_segments)
Ticket (M) -> (M) Passenger (via ticket_passengers)
```

## Key Business Scenarios Covered

- **Multi-passenger bookings**: Families traveling together
- **Multi-segment trips**: Round trips and connecting flights
- **Different fare classes**: Economy to First class
- **Various booking statuses**: Active, cancelled, pending bookings
- **International travel**: Multiple currencies and countries
- **Special services**: Meal preferences, assistance needs
- **Refunds/Changes**: Cancelled and refunded tickets
