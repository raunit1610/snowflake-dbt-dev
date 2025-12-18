{{
    config(
        materialized='incremental',
        incremental_strategy='append',
        tags = ["player"]
    )
}}

WITH source_data AS (
    SELECT
        {{ dbt_utils.star(from=source('t20_database', 'players')) }},
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ AS _inserted_at_,
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ AS _inserted_at_2,
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ AS _inserted_at_3
    FROM {{ source('t20_database', 'players') }}
),

deduped AS (
    SELECT
        PLAYERID,
        ANY_VALUE(PLAYERNAME) AS PLAYERNAME,
        ANY_VALUE(FILENAME) AS FILENAME,
        ANY_VALUE(LOAD_TIMESTAMP) AS LOAD_TIMESTAMP,
        MAX(_inserted_at_) AS _inserted_at_,
        MAX(_inserted_at_2) AS _inserted_at_2,
        MAX(_inserted_at_3) AS _inserted_at_3
    FROM source_data
    GROUP BY PLAYERID
)

SELECT *
FROM deduped