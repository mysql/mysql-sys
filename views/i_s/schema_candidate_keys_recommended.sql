-- 
-- Candidate keys: listing of prioritized candidate keys: keys which are UNIQUE, by order of best-use. 
-- 

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER
VIEW schema_candidate_keys_recommended AS
SELECT
  table_schema,
  table_name,
  SUBSTRING_INDEX(GROUP_CONCAT(index_name ORDER BY candidate_key_rank_in_table ASC), ',', 1) AS recommended_index_name,
  CAST(SUBSTRING_INDEX(GROUP_CONCAT(has_nullable ORDER BY candidate_key_rank_in_table ASC), ',', 1) AS UNSIGNED INTEGER) AS has_nullable,
  CAST(SUBSTRING_INDEX(GROUP_CONCAT(is_primary ORDER BY candidate_key_rank_in_table ASC), ',', 1) AS UNSIGNED INTEGER) AS is_primary,
  CAST(SUBSTRING_INDEX(GROUP_CONCAT(count_column_in_index ORDER BY candidate_key_rank_in_table ASC), ',', 1) AS UNSIGNED INTEGER) AS count_column_in_index,
  SUBSTRING_INDEX(GROUP_CONCAT(column_names ORDER BY candidate_key_rank_in_table ASC SEPARATOR '\n'), '\n', 1) AS column_names
FROM 
  schema_candidate_keys
GROUP BY
  table_schema, table_name
ORDER BY   
  table_schema, table_name
;
