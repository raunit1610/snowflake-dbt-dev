{% macro add_boundries(sixes_col, fours_col) %}
    SUM(COALESCE({{ sixes_col }}, 0) + COALESCE({{ fours_col }}, 0))
{% endmacro %}
