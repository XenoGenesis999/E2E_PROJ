{% test valid_order_ts(model, column_name) %}

-- Fail if order_ts is outside expected business range
select {{ column_name }}
from {{ model }}
where {{ column_name }} < '2013-01-01'::timestamp
   or {{ column_name }} > '2018-01-01'::timestamp

{% endtest %}