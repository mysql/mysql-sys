--
-- View: engines_unused
--
-- Storage engines that are installed, but currently not used for any table.
--
-- mysql> SELECT * FROM sys.engines_unused;
--          +------------+
--          | engine     |
--          +------------+
--          | ARCHIVE    |
--          | BLACKHOLE  |
--          | MRG_MYISAM |
--          +------------+
--          3 rows in set (0.01 sec)
--

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER
VIEW engines_unused (
  engine
) AS
  SELECT e.ENGINE
    FROM INFORMATION_SCHEMA.ENGINES e
    LEFT JOIN INFORMATION_SCHEMA.TABLES t
      ON e.ENGINE = t.ENGINE
    WHERE e.SUPPORT IN ('YES', 'DEFAULT')
      AND t.ENGINE IS NULL
    ORDER BY e.ENGINE;
