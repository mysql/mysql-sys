/* 
 * View: schema_object_overview
 * 
 * Shows an overview of the types of objects within each schema
 *
 * Note: On instances with a large number of objects, this could take
 *       some time to execute, and is not recommended.
 *
 * mysql> select * from schema_object_overview;
 * +--------------------+---------------+-------+
 * | db                 | object_type   | count |
 * +--------------------+---------------+-------+
 * | information_schema | SYSTEM VIEW   |    59 |
 * | mysql              | BASE TABLE    |    28 |
 * | mysql              | INDEX (BTREE) |    63 |
 * | performance_schema | BASE TABLE    |    52 |
 * | ps_helper          | FUNCTION      |     8 |
 * | ps_helper          | PROCEDURE     |    12 |
 * | ps_helper          | VIEW          |    49 |
 * | test               | BASE TABLE    |     2 |
 * | test               | INDEX (BTREE) |     2 |
 * +--------------------+---------------+-------+
 * 9 rows in set (0.08 sec)
 *
 * Versions: 5.1+
 */

DROP VIEW IF EXISTS schema_object_overview;

CREATE SQL SECURITY INVOKER VIEW schema_object_overview AS
SELECT ROUTINE_SCHEMA AS db, ROUTINE_TYPE AS object_type, COUNT(*) AS count FROM INFORMATION_SCHEMA.ROUTINES GROUP BY ROUTINE_SCHEMA, ROUTINE_TYPE
 UNION 
SELECT TABLE_SCHEMA, TABLE_TYPE, COUNT(*) FROM INFORMATION_SCHEMA.TABLES GROUP BY TABLE_SCHEMA, TABLE_TYPE
 UNION
SELECT TABLE_SCHEMA, CONCAT('INDEX (', INDEX_TYPE, ')'), COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS GROUP BY TABLE_SCHEMA, INDEX_TYPE
 UNION
SELECT TRIGGER_SCHEMA, 'TRIGGER', COUNT(*) FROM INFORMATION_SCHEMA.TRIGGERS GROUP BY TRIGGER_SCHEMA
 UNION
SELECT EVENT_SCHEMA, 'EVENT', COUNT(*) FROM INFORMATION_SCHEMA.EVENTS GROUP BY EVENT_SCHEMA
ORDER BY DB, OBJECT_TYPE;