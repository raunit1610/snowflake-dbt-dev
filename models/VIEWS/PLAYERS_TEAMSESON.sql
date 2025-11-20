{{ config(materialized='view') }}

{{ dbt_utils.union_relations(
    relations=[
        ref('STG_BRONZE_PLAYERSTATS'),
        ref('TeamSeason_9_11_25')
    ],
    source_column_name='source_layer'
) }}
