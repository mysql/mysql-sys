/*
 * View: statements_with_full_table_scans
 *
 * Lists all normalized statements that use have done a full table scan
 * ordered by number the percentage of times a full scan was done,
 * then by the number of times the statement executed
 *
 * mysql> select * from statements_with_full_table_scans limit 5;
 * +-------------------------------------------------------------------+------------+-------------------+-----------------+--------------------------+------------------------+----------------------------------+
 * | query                                                             | exec_count | memory_tmp_tables | disk_tmp_tables | avg_tmp_tables_per_query | tmp_tables_to_disk_pct | digest                           |
 * +-------------------------------------------------------------------+------------+-------------------+-----------------+--------------------------+------------------------+----------------------------------+
 * | SELECT DISTINCTROW `hibalarm0_ ... testeval2_` . `alarm_id` = ... |          5 |                15 |               5 |                        3 |                     33 | ad6024cfc2db562ae268b25e65ef27c0 |
 * | SELECT DISTINCTROW `hibalarm0_ ... testeval2_` . `alarm_id` = ... |          2 |                 6 |               2 |                        3 |                     33 | 4aac3ab9521a432ff03313a69cfcc58f |
 * | SELECT SQL_CALC_FOUND_ROWS `st ...  , MIN ( `min_exec_time` ) ... |          1 |                 3 |               1 |                        3 |                     33 | c6df6711da3d1a26bc136dc8b354f6eb |
 * | SELECT COUNT ( DISTINCTROW `hi ... `hibevalres4_` . `time` DESC   |          5 |                15 |               0 |                        3 |                      0 | 12e0392402780424c736c9555bcc9703 |
 * | SELECT `hibrulesch1_` . `insta ... ` , `hibevalres2_` . `level`   |          5 |                 5 |               0 |                        1 |                      0 | a12cabd32d1507c758c71478075f5290 |
 * +-------------------------------------------------------------------+------------+-------------------+-----------------+--------------------------+------------------------+----------------------------------+
 *
 * (Example from 5.6.6)
 *
 * Versions: 5.6.5+
 *
 */

DROP VIEW IF EXISTS statements_with_full_table_scans;

CREATE SQL SECURITY INVOKER VIEW statements_with_full_table_scans AS
SELECT format_statement(DIGEST_TEXT) AS query,
       COUNT_STAR AS exec_count,
       SUM_NO_INDEX_USED AS no_index_used_count,
       SUM_NO_GOOD_INDEX_USED AS no_good_index_used_count,
       ROUND((SUM_NO_INDEX_USED / COUNT_STAR) * 100) no_index_used_pct,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
 WHERE SUM_NO_INDEX_USED > 0
    OR SUM_NO_GOOD_INDEX_USED > 0
ORDER BY no_index_used_pct DESC, exec_count DESC;
