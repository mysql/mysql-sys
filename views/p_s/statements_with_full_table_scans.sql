/*
 * View: statements_with_full_table_scans
 *
 * Lists all normalized statements that use have done a full table scan
 * ordered by number the percentage of times a full scan was done,
 * then by the number of times the statement executed
 *
 * mysql> select * from statements_with_full_table_scans limit 5;
 * +-------------------------------------------------------------------+------------+---------------------+--------------------------+-------------------+-----------+---------------+----------------------------------+
 * | query                                                             | exec_count | no_index_used_count | no_good_index_used_count | no_index_used_pct | rows_sent | rows_examined | digest                           |
 * +-------------------------------------------------------------------+------------+---------------------+--------------------------+-------------------+-----------+---------------+----------------------------------+
 * | SELECT DISTINCTROW `agent0_` . ... ERE `agent0_` . `id` IN (...)  |       1474 |                1474 |                        0 |               100 |      2948 |          2948 | 4f5d5cc354ebb4746ccb71d9c750e978 |
 * | SELECT COUNT ( * ) FROM `INFOR ... NE = ? AND `SUPPORT` IN (...)  |       1228 |                1228 |                        0 |               100 |      1228 |         11052 | 491ee7143ca1d98f36c24d7eb6d25272 |
 * | SELECT DISTINCTROW `mysqlconne ... conne0_` . `socketPath` AS ... |       1135 |                1132 |                        0 |               100 |         5 |          3393 | 15024988ff6ff3510057b48ca2dfd5d3 |
 * | SELECT `InterfaceAddress4` . ` ... . `hid` WHERE `Os` . `id` = ?  |       1132 |                1132 |                        0 |               100 |      7924 |         82588 | 42d79211cc5e82e32e00340bc6a50b14 |
 * | SELECT COUNT ( * ) FROM `infor ... NAME = ? AND `index_name` = ?  |        772 |                 772 |                        0 |               100 |       772 |          3301 | c8a721d366327a8170d4260fe789941a |
 * +-------------------------------------------------------------------+------------+---------------------+--------------------------+-------------------+-----------+---------------+----------------------------------+
 * 5 rows in set (0.03 sec) *
 * 
 * (Example from 5.6.6)
 *
 * Versions: 5.6.5+
 *
 */

DROP VIEW IF EXISTS statements_with_full_table_scans;

CREATE SQL SECURITY INVOKER VIEW statements_with_full_table_scans AS
SELECT ps_helper.format_statement(DIGEST_TEXT) AS query,
       COUNT_STAR AS exec_count,
       SUM_NO_INDEX_USED AS no_index_used_count,
       SUM_NO_GOOD_INDEX_USED AS no_good_index_used_count,
       ROUND((SUM_NO_INDEX_USED / COUNT_STAR) * 100) AS no_index_used_pct,
       SUM_ROWS_SENT AS rows_sent,
       SUM_ROWS_EXAMINED AS rows_examined,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
 WHERE SUM_NO_INDEX_USED > 0
    OR SUM_NO_GOOD_INDEX_USED > 0
ORDER BY no_index_used_pct DESC, exec_count DESC;
