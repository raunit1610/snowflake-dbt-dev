{{
    config(
        materialized='incremental',
        unique_key='TEAMID',
        incremental_strategy='merge',
        tags=["inactive"]
    )
}}

WITH source_data AS (
    SELECT 
        {{ dbt_utils.star(from=source('t20_database', 'teams')) }},
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ AS _inserted_at_
    FROM {{ source('t20_database', 'teams') }}
),

deduped AS (
    SELECT
        TEAMID,
        ANY_VALUE(TEAMNAME) AS TEAMNAME,
        ANY_VALUE(FILENAME) AS FILENAME,
        ANY_VALUE(LOAD_TIMESTAMP) AS LOAD_TIMESTAMP,
        MAX(_inserted_at_) AS _inserted_at_
    FROM source_data
    GROUP BY TEAMID
)

SELECT *
FROM deduped

{% if is_incremental() %}
  WHERE _inserted_at_ > (SELECT MAX(_inserted_at_) FROM {{ this }})
{% endif %}
