{{ config(materialized='view') }}

with src as (
    select *
    from {{ source('bronze', 'SAMPLE_DIRTY') }}
), 


hashed as (
    select
        src.*,

        sha2(
            concat_ws(
                '||',
                ship_mode,
                segment,
                country,
                city,
                state,
                postal_code,
                region,
                category,
                sub_category,
                sales,
                quantity,
                discount,
                profit,
                order_ts,
                dirty_category
            ), 256
        ) as row_hash
    from src
),


deduped as (
    select
        *
    from (
        select
            *,
            row_number() over (
                partition by row_hash
                order by order_ts desc
            ) as row_rank
        from hashed
    )
    where row_rank = 1
), 



standardized as (
    select
        -- synthetic primary key
        row_hash as row_id,

        -- text fields: trimmed and uppercased
        upper(trim(ship_mode))     as ship_mode,
        upper(trim(segment))       as segment,
        upper(trim(country))       as country,
        upper(trim(state))         as state,
        upper(trim(city))          as city,
        upper(trim(region))        as region,
        upper(trim(category))      as category,
        upper(trim(sub_category))  as sub_category,

        -- numeric fields (already numeric from source)
        sales,
        quantity,
        discount,
        profit,

        -- timestamps: parse and drop invalids
        try_to_timestamp(order_ts, 'YYYY-MM-DD HH24:MI:SS') as order_ts,

        -- cleaned version of dirty_category for analysis
        upper(trim(dirty_category)) as dirty_category_clean
    from deduped
    where
        -- drop rows where critical fields are missing or invalid
        ship_mode is not null
        and segment is not null
        and country is not null
        and region is not null
        and try_to_timestamp(order_ts, 'YYYY-MM-DD HH24:MI:SS') is not null
)

select *
from standardized