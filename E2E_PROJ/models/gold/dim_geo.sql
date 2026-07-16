-- models/gold/dim_geography_cleaned.sql
{{ config(materialized = 'table') }}

with src as (
    select distinct
        country,
        state,
        city,
        region
    from {{ref('sample_cleaned')}}
)

select
    sha2(concat_ws('||', country, state, city, region), 256) as geo_id,
    country,
    state,
    city,
    region
from src