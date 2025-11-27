{{
    config(
        materialized='incremental',
        unique_key=['MATCHID', 'BOWLERID'],
        incremental_strategy='merge',
        tags = ["Bowlingcard"]
    )
}}

WITH source_data AS (
    SELECT 
        {{ dbt_utils.star(from=source('t20_database', 'bowlingcard')) }},
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ AS _inserted_at_
    FROM {{ source('t20_database', 'bowlingcard') }}
)

SELECT *
FROM source_data

{% if is_incremental() %}
  WHERE _inserted_at_ > (SELECT COALESCE(MAX(_inserted_at_), '1900-01-01') FROM {{ this }})
{% endif %}
