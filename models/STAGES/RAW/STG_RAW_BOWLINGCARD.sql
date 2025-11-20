{{
    config(
        materialized='table'
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
