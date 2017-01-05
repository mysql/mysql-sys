--
-- View: engine_usage_by_schema
--
-- Storage engines usage statistics, grouped by database.
--
-- mysql> SELECT * FROM sys.engine_usage_by_schema;
--          +--------------------+--------------------+--------------+
--          | engine_schema      | engine             | tables_count |
--          +--------------------+--------------------+--------------+
--          | information_schema | InnoDB             |           10 |
--          | information_schema | MEMORY             |           51 |
--          | mysql              | CSV                |            2 |
-- ...
--          +--------------------+--------------------+--------------+
--          10 rows in set (0.01 sec)
--

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER
VIEW engine_usage_by_schema (
  engine_schema,
  engine,
  tables_count
) AS
  SELECT TABLE_SCHEMA AS engine_schema, ENGINE, COUNT(*) AS tables_count
    FROM INFORMATION_SCHEMA.TABLES
    WHERE ENGINE IS NOT NULL
    GROUP BY TABLE_SCHEMA, ENGINE
    ORDER BY TABLE_SCHEMA, ENGINE;
