"""
Simplified Airflow DAG for dbt Travel Booking Analytics Pipeline
Uses dbt build command for efficient execution of models and tests

Author: Roshan Abady
Created: 2024-07-23
"""

from datetime import datetime, timedelta
import pytz
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator

# DAG configuration
default_args = {
    'owner': 'analytics_team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1, tzinfo=pytz.UTC),
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    'email': ['analytics-team@company.com']
}

# Define the DAG
dag = DAG(
    'travel_booking_analytics',
    default_args=default_args,
    description='Travel booking platform analytics pipeline using dbt build',
    schedule='0 6 * * *',  # Daily at 6 AM
    catchup=False,
    max_active_runs=1,
    tags=['analytics', 'dbt', 'travel', 'booking']
)

# dbt project path (adjustable for your environment)
DBT_PROJECT_DIR = '/opt/airflow/dbt/analytics_engineering_task'
DBT_PROFILES_DIR = '/opt/airflow/.dbt'

# Start task
start_task = EmptyOperator(
    task_id='start_pipeline',
    dag=dag
)

# Install dbt dependencies
dbt_deps = BashOperator(
    task_id='dbt_deps',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt deps --profiles-dir {DBT_PROFILES_DIR}',
    dag=dag
)

# Build all: seeds, models, and tests (replaces separate seed/run/test tasks)
dbt_build = BashOperator(
    task_id='dbt_build',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt build --profiles-dir {DBT_PROFILES_DIR}',
    dag=dag
)

# Generate documentation
dbt_docs_generate = BashOperator(
    task_id='dbt_docs_generate',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt docs generate --profiles-dir {DBT_PROFILES_DIR}',
    dag=dag
)

# End task
end_task = EmptyOperator(
    task_id='end_pipeline',
    dag=dag
)

# Define simplified task dependencies
start_task >> dbt_deps >> dbt_build >> dbt_docs_generate >> end_task