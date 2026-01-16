{{ config(materialized='table') }}

  with source_dataa as (
      select 1 as id
      union all
      select null as id
  )

  select *
  from source_dataa