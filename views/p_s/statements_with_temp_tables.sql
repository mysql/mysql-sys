/*
 * View: statements_with_temp_tables
 *
 * Lists all normalized statements that use temporary tables
 * ordered by number of on disk temporary tables descending first, 
 * then by the number of memory tables
 *
 * mysql> SELECT * FROM statements_with_temp_tables LIMIT 5;
 * +-------------------------------------------------------------------+------------+-------------------+-----------------+--------------------------+------------------------+----------------------------------+
 * | query                                                             | exec_count | memory_tmp_tables | disk_tmp_tables | avg_tmp_tables_per_query | tmp_tables_to_disk_pct | digest                           |
 * +-------------------------------------------------------------------+------------+-------------------+-----------------+--------------------------+------------------------+----------------------------------+
 * | SELECT * FROM `data_size_per_s ... `tables` . `DATA_LENGTH` + ... |          1 |               291 |              47 |                      291 |                     16 | 244fd44a57e27461ec17ca76ca5c2184 |
 * | CREATE SQL SECURITY INVOKER VI ... LIKE ? ORDER BY `timer_start`  |         41 |                41 |              41 |                        1 |                    100 | 1a9ec5a797cd08056fdcf7142e36726b |
 * | CREATE SQL SECURITY INVOKER VI ... SUM ( `sum_timer_wait` ) DESC  |         26 |                26 |              26 |                        1 |                    100 | 2f473ef7b1c25a07f9eb57687e762788 |
 * | CREATE SQL SECURITY INVOKER VI ... LIKE ? ORDER BY `timer_start`  |         23 |                23 |              23 |                        1 |                    100 | 7c70e6abca9191142ce5092449aa9728 |
 * | CREATE SQL SECURITY INVOKER VI ... LIKE ? ORDER BY `timer_start`  |         18 |                18 |              18 |                        1 |                    100 | 50934f96976447cff07a8e43eff0c3f4 |
 * +-------------------------------------------------------------------+------------+-------------------+-----------------+--------------------------+------------------------+----------------------------------+
 * 5 rows in set (0.00 sec)
 *
 * (Example from 5.6.6)
 *
 * Versions: 5.6.5+
 *
 */

DROP VIEW IF EXISTS statements_with_temp_tables;

CREATE SQL SECURITY INVOKER VIEW statements_with_temp_tables AS
SELECT format_statement(DIGEST_TEXT) AS query,
       COUNT_STAR AS exec_count,
       SUM_CREATED_TMP_TABLES AS memory_tmp_tables,
       SUM_CREATED_TMP_DISK_TABLES AS disk_tmp_tables,
       ROUND(SUM_CREATED_TMP_TABLES / COUNT_STAR) AS avg_tmp_tables_per_query,
       ROUND((SUM_CREATED_TMP_DISK_TABLES / SUM_CREATED_TMP_TABLES) * 100) AS tmp_tables_to_disk_pct,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
 WHERE SUM_CREATED_TMP_TABLES > 0
ORDER BY SUM_CREATED_TMP_DISK_TABLES DESC, SUM_CREATED_TMP_TABLES DESC;
