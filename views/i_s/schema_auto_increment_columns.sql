
--
-- View: schema_auto_increment_columns
--
-- Present current auto_increment usage/capacity in all tables.
--
-- Versions: 5.1+
-- 
CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER
VIEW schema_auto_increment_columns AS
  SELECT 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    COLUMN_NAME, 
    DATA_TYPE,
    COLUMN_TYPE,
    (LOCATE('unsigned', COLUMN_TYPE) = 0) AS is_signed,
    (LOCATE('unsigned', COLUMN_TYPE) > 0) AS is_unsigned,
    (
      CASE DATA_TYPE
        WHEN 'tinyint' THEN 255
        WHEN 'smallint' THEN 65535
        WHEN 'mediumint' THEN 16777215
        WHEN 'int' THEN 4294967295
        WHEN 'bigint' THEN 18446744073709551615
      END >> IF(LOCATE('unsigned', COLUMN_TYPE) > 0, 0, 1)
    ) AS max_value,
    AUTO_INCREMENT,
    AUTO_INCREMENT / (
      CASE DATA_TYPE
        WHEN 'tinyint' THEN 255
        WHEN 'smallint' THEN 65535
        WHEN 'mediumint' THEN 16777215
        WHEN 'int' THEN 4294967295
        WHEN 'bigint' THEN 18446744073709551615
      END >> IF(LOCATE('unsigned', COLUMN_TYPE) > 0, 0, 1)
    ) AS auto_increment_ratio
  FROM 
    INFORMATION_SCHEMA.COLUMNS
    INNER JOIN INFORMATION_SCHEMA.TABLES USING (TABLE_SCHEMA, TABLE_NAME)
  WHERE 
    TABLE_SCHEMA NOT IN ('mysql', 'sys', 'INFORMATION_SCHEMA', 'performance_schema')
    AND TABLE_TYPE='BASE TABLE'
    AND EXTRA='auto_increment'
;
