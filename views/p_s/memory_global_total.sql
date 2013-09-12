/* 
 * View: memory_global_total
 * 
 * Shows the total memory usage within the server globally
 *
 * mysql> select * from memory_global_total;
 * +-----------------+
 * | total_allocated |
 * +-----------------+
 * | 1.35 MiB        |
 * +-----------------+
 * 1 row in set (0.18 sec)
 *
 * Versions: 5.7.2+
 */

DROP VIEW IF EXISTS memory_global_total;

CREATE SQL SECURITY INVOKER VIEW memory_global_total AS
SELECT ps_helper.format_bytes(SUM(CURRENT_NUMBER_OF_BYTES_USED)) total_allocated
  FROM performance_schema.memory_summary_global_by_event_name;

/* 
 * View: memory_global_total_raw
 * 
 * Shows the total memory usage within the server globally
 *
 * mysql> select * from memory_global_total_raw;
 * +-----------------+
 * | total_allocated |
 * +-----------------+
 * |         1420023 |
 * +-----------------+
 * 1 row in set (0.01 sec)
 *
 * Versions: 5.7.2+
 */

DROP VIEW IF EXISTS memory_global_total_raw;

CREATE SQL SECURITY INVOKER VIEW memory_global_total_raw AS
SELECT SUM(CURRENT_NUMBER_OF_BYTES_USED) total_allocated
  FROM performance_schema.memory_summary_global_by_event_name;

