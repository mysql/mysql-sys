--
-- View: engine_usage_by_schema
--
-- Storage engines usage statistics, grouped by database.
--
-- mysql> SELECT * FROM sys.engine_usage_by_schema;
--          +---------------+--------+--------------+
--          | engine_schema | engine | tables_count |
--          +---------------+--------+--------------+
--          | sys           | VIEW   |          103 |
--          | sys           | InnoDB |            1 |
-- ...
--          +---------------+--------+--------------+
--          5 rows in set (0.00 sec)
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
