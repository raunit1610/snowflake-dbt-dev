{{
    config(
        materialized='table',
        tags = ["player","union"]
    )
}}

WITH player_union as(
    {{ dbt_utils.union_relations(
      relations = [ ref('STG_RAW_PLAYER2'), ref('STG_RAW_PLAYER6') ]
  ) }}
)

select * from player_union