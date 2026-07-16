-- models/gold/dim_product_cleaned.sql
{{ config(materialized = 'table') }}

with src as (
    select distinct
        category,
        sub_category
    from {{ref('sample_cleaned')}}
)

select
    sha2(concat_ws('||', category, sub_category), 256) as product_id,
    category,
    sub_category
from src