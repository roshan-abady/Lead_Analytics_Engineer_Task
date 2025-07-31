# Travel Booking Analytics Pipeline

dbt project transforming raw booking data into dimensional models for analytics. Built for Rome2Rio Lead Analytics Engineer assessment.

## Architecture

### Data Flow

```
Raw Data (Seeds) → Staging Models → Mart Models
                                   ↙        ↓        ↘
                          fct_bookings  dim_passengers  dim_flights
                        (Fact Table)   (Dimension)     (Dimension)
```

### Model Structure

#### Staging Layer (`models/staging/`)

- **`stg_bookings`**: Clean booking data with type casting and standardisation
- **`stg_passengers`**: Passenger information with calculated age
- **`stg_tickets`**: Ticket pricing data with proper decimal formatting
- **`stg_segments`**: Flight segment details with time parsing
- **`stg_ticket_segments`**: Ticket-segment relationship data
- **`stg_ticket_passengers`**: Ticket-passenger relationship data

#### Mart Layer (`models/marts/`)

- **`fct_bookings`**: Central fact table at ticket-segment-passenger grain
- **`dim_passengers`**: Passenger dimension with derived attributes
- **`dim_flights`**: Flight dimension with route and timing categorisations

## Data Quality

**46+ tests** covering uniqueness, referential integrity, business logic, and data ranges
**3 custom tests** for departure/arrival logic, booking consistency, and completeness
**Expected failures** demonstrate data quality controls with mock data

## Orchestration

**Airflow DAG** - Daily at 6 AM with `dbt build` command
**Features** - Retry logic, email notifications, streamlined 75-line structure

## Configuration

**Database**: DuckDB local development
**Profile**: analytics_engineering_task
**Tests**: 46+ comprehensive validations

## Usage

### Quick Start

```bash
# Complete pipeline build and test
dbt build

# Individual steps (if needed)
dbt deps                    # Install dependencies
dbt seed                    # Load seed data
dbt run                     # Build all models
dbt test                    # Run all tests
dbt docs generate           # Generate documentation
```

### Testing the Pipeline

```bash
# Test specific layers
dbt build --select staging
dbt build --select marts

# Skip problematic tests during development
dbt build --exclude test_booking_ticket_total_consistency

# Store failed test results for debugging
dbt build --store-failures
```

## Sample Data

**Volumes**: 10 bookings, 16 tickets, 14 passengers, 15 segments → 28 fact records
**Results**: Top routes JFK-LHR/LHR-JFK ($2,750 each), 13 adults/1 child, mixed flight categories

## Project Structure

```
analytics_engineering_task/
├── models/
│   ├── staging/           # Staging layer models (6 models)
│   └── marts/            # Fact and dimension tables (3 models)
├── tests/                # Custom data quality tests (3 tests)
├── seeds/                # Raw data files (6 CSV files)
├── dags/                 # Airflow orchestration
└── README.md            # This file
```

---

*Rome2Rio Lead Analytics Engineer Assessment - Roshan Abady - July 2025*
