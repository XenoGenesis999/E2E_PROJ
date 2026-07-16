with base as (
    select * from {{ source('bronze', 'SAMPLE_DATA') }}
 ),

duplicated as (
    select * from base
    union all
    select * from base
    union all
    select * from base
    where uniform(0, 1, random()) < 0.2
),

with_nulls as (
    select
        case when uniform(0, 1, random()) < 0.05 then null else City end as city,
        case when uniform(0, 1, random()) < 0.05 then null else State end as state,
        case when uniform(0, 1, random()) < 0.10 then null else PostalCode end as postal_code,
        case when uniform(0, 1, random()) < 0.03 then null else Region end as region,
        case when uniform(0, 1, random()) < 0.05 then null else Sales end as sales,
        case when uniform(0, 1, random()) < 0.05 then null else Quantity end as quantity,

        ShipMode as ship_mode,
        Segment as segment,
        Country as country,
        Category as category,
        SubCategory as sub_category,
        Discount as discount,
        Profit as profit
    from duplicated
),

with_bad_values as (
    select
        city,
        state,
        postal_code,
        region,
        sales,
        quantity,
        ship_mode,
        segment,
        country,
        category,
        sub_category,
        discount,
        profit,

        case
            when uniform(0, 1, random()) < 0.05 then '2020-13-40 25:61:61'
            when uniform(0, 1, random()) < 0.05 then 'not_a_timestamp'
            when uniform(0, 1, random()) < 0.05 then '1970-01-01 00:00:00'
            else to_char(current_timestamp())
        end as order_ts,

        case
            when uniform(0, 1, random()) < 0.05 then 'UNKNOWN_CAT'
            when uniform(0, 1, random()) < 0.05 then '12345'
            else category
        end as dirty_category
    from with_nulls
)

select *
from with_bad_values