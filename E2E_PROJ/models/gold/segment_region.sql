-- models/gold/mart_segment_region_sales_cleaned.sql
{{ config(materialized = 'table') }}

with base as (
    select
        segment,
        region,
        order_ts::date as order_date,
        sum(sales)    as total_sales,
        sum(profit)   as total_profit,
        sum(quantity) as total_quantity
    from {{ref('sample_cleaned')}}
    group by
        segment,
        region,
        order_date
)

select *
from base