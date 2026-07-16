{{ config(materialized='view') }}

with dedup as (
    select distinct *
    from {{ source('bronze', 'SAMPLE_DIRTY') }}
),

no_nulls as (
    select *
    from dedup
    where CITY           is not null
      and STATE          is not null
      and POSTAL_CODE    is not null
      and REGION         is not null
      and SALES          is not null
      and QUANTITY       is not null
      and SHIP_MODE      is not null
      and SEGMENT        is not null
      and COUNTRY        is not null
      and CATEGORY       is not null
      and SUB_CATEGORY   is not null
      and DISCOUNT       is not null
      and PROFIT         is not null
      and ORDER_TS       is not null
      and DIRTY_CATEGORY is not null
)

select *
from no_nulls