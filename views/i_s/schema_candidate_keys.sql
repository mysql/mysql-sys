-- 
-- Candidate keys: listing of prioritized candidate keys: keys which are UNIQUE, by order of best-use. 
-- 

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER
VIEW schema_candidate_keys AS
SELECT
  COLUMNS.TABLE_SCHEMA AS table_schema,
  COLUMNS.TABLE_NAME AS table_name,
  _schema_unique_keys.INDEX_NAME AS index_name,
  _schema_unique_keys.has_nullable AS has_nullable,
  _schema_unique_keys.is_primary AS is_primary,
  _schema_unique_keys.COLUMN_NAMES AS column_names,
  _schema_unique_keys.COUNT_COLUMN_IN_INDEX AS count_column_in_index,
  COLUMNS.DATA_TYPE AS data_type,
  COLUMNS.CHARACTER_SET_NAME AS character_set_name,
  (CASE IFNULL(CHARACTER_SET_NAME, '')
      WHEN '' THEN 0
      ELSE 1
  END << 20
  )
  + (CASE LOWER(DATA_TYPE)
    WHEN 'tinyint' THEN 0
    WHEN 'smallint' THEN 1
    WHEN 'int' THEN 2
    WHEN 'timestamp' THEN 3
    WHEN 'bigint' THEN 4
    WHEN 'datetime' THEN 5
    ELSE 9
  END << 16
  ) + (COUNT_COLUMN_IN_INDEX << 0
  ) AS candidate_key_rank_in_table  
FROM 
  INFORMATION_SCHEMA.COLUMNS 
  INNER JOIN _schema_unique_keys ON (
    COLUMNS.TABLE_SCHEMA = _schema_unique_keys.TABLE_SCHEMA AND
    COLUMNS.TABLE_NAME = _schema_unique_keys.TABLE_NAME AND
    COLUMNS.COLUMN_NAME = _schema_unique_keys.FIRST_COLUMN_NAME
  )
ORDER BY   
  COLUMNS.TABLE_SCHEMA, COLUMNS.TABLE_NAME, candidate_key_rank_in_table
;

