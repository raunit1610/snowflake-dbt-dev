{{
    config(
        materialized='table',
        tags = ["player"]
    )
}}

WITH source_data AS (
    SELECT
        {{ dbt_utils.star(from=source('t20_database', 'players')) }},
        CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ AS _inserted_at_
    FROM {{ source('t20_database', 'players') }}
),

deduped AS (
    SELECT
        FILENAME AS FILENAME,
        PLAYERID,
        PLAYERNAME AS PLAYERNAME,
        LOAD_TIMESTAMP AS LOAD_TIMESTAMP,
        _inserted_at_ AS _inserted_at_
    FROM source_data
)

SELECT *
FROM deduped