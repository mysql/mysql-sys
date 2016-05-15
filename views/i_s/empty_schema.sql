--
-- View: empty_schema
-- 
-- A list of database that contain nothing (tables, routines, events).
--
-- mysql> SELECT * FROM empty_schema;
-- +-------------+
-- | schema_name |
-- +-------------+
-- | empty_sch   |
-- +-------------+
-- 1 row in set (0.01 sec)
--

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER 
VIEW empty_schema (
  schema_name
) AS
SELECT all_schemas.SCHEMA_NAME
  FROM information_schema.SCHEMATA all_schemas
  LEFT JOIN (
    SELECT DISTINCT ROUTINE_SCHEMA AS object_schema FROM information_schema.ROUTINES
  UNION 
    SELECT DISTINCT TABLE_SCHEMA AS object_schema FROM information_schema.TABLES
  UNION
    SELECT DISTINCT EVENT_SCHEMA AS object_schema FROM information_schema.EVENTS
  ) used_schemas
    ON used_schemas.object_schema = all_schemas.SCHEMA_NAME
    WHERE used_schemas.object_schema IS NULL
  ORDER BY SCHEMA_NAME;
