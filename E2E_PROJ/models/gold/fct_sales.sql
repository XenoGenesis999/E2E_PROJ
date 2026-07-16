-- models/gold/fct_sales_cleaned.sql
{{ config(
    materialized = 'incremental',
    unique_key   = 'row_id',
    incremental_strategy = 'delete+insert'
) }}

with src as (
    select
        row_id,
        order_ts::date as order_date,
        ship_mode,
        segment,
        country,
        state,
        city,
        region,
        category,
        sub_category,
        sales,
        quantity,
        discount,
        profit,
        dirty_category_clean
    from {{ ref('sample_cleaned') }}
    {% if is_incremental() %}
      where order_ts > (select max(order_ts) from {{ this }})
    {% endif %}
)

select *
from src