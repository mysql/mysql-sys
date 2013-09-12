/* 
 * View: schema_tables_with_full_table_scans
 *
 * Find tables that are being accessed by full table scans
 * ordering by the number of rows scanned descending
 *
 * mysql> select * from schema_tables_with_full_table_scans limit 5;
 * +------------------+-------------------+-------------------+
 * | object_schema    | object_name       | rows_full_scanned |
 * +------------------+-------------------+-------------------+
 * | mem              | rule_alarms       |              1210 |
 * | mem30__advisors  | advisor_schedules |              1021 |
 * | mem30__inventory | agent             |               498 |
 * | mem              | dc_p_string       |               449 |
 * | mem30__inventory | mysqlserver       |               294 |
 * +------------------+-------------------+-------------------+
 *
 * Versions: 5.6.2+
 *
 */

DROP VIEW IF EXISTS schema_tables_with_full_table_scans;

CREATE SQL SECURITY INVOKER VIEW schema_tables_with_full_table_scans AS
SELECT object_schema, 
       object_name,
       count_read AS rows_full_scanned
  FROM performance_schema.table_io_waits_summary_by_index_usage 
 WHERE index_name IS NULL
   AND count_read > 0
 ORDER BY count_read DESC;
