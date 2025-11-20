{% snapshot raw_player_scd2 %}
  {{
    config(
      target_schema='SNAPSHOTS',   
      unique_key='PLAYERID',             
      strategy='timestamp',        
      updated_at='LOAD_TIMESTAMP',     
      invalidate_hard_deletes=True 
    )
  }}

  SELECT * FROM {{ source('t20_database', 'players') }}

{% endsnapshot %}