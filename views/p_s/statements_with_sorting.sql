/*
 * View: statements_with_sorting
 *
 * List all normalized statements that have done sorts,
 * ordered by sort_merge_passes, sort_scans and sort_rows, all descending
 *
 * mysql> select * from ps_helper.statements_with_sorting;
 * +-------------------------------------------------------------------+------------+-------------------+-----------------+-------------------+------------------+-------------+-----------------+----------------------------------+
 * | query                                                             | exec_count | sort_merge_passes | avg_sort_merges | sorts_using_scans | sort_using_range | rows_sorted | avg_rows_sorted | digest                           |
 * +-------------------------------------------------------------------+------------+-------------------+-----------------+-------------------+------------------+-------------+-----------------+----------------------------------+
 * | SELECT * FROM ps_helper . statements_with_sorting                 |          7 |                 0 |               0 |                 7 |                0 |          31 |               4 | 635d19e3e652972b3267ada0bf9c7b36 |
 * | SELECT * FROM statement_analysis                                  |          4 |                 0 |               0 |                 4 |                0 |          89 |              22 | 10f918a1a410f4fa0fc2602cff02deb7 |
 * | SELECT table_schema , SUM ( da ... tables GROUP BY table_schema   |          2 |                 0 |               0 |                 2 |                0 |          24 |              12 | 27fecd44f0bf5c0fc4e46f547083a09d |
 * | SELECT * FROM statements_with_sorting                             |          2 |                 0 |               0 |                 2 |                0 |           3 |               2 | dc117dd0eb81394322e3d4144a997ffc |
 * +-------------------------------------------------------------------+------------+-------------------+-----------------+-------------------+------------------+-------------+-----------------+----------------------------------+
 * 
 * Versions 5.6.5+
 *
 */

DROP VIEW IF EXISTS statements_with_sorting;

CREATE SQL SECURITY INVOKER VIEW statements_with_sorting AS
SELECT format_statement(DIGEST_TEXT) AS query,
       COUNT_STAR AS exec_count,
       SUM_SORT_MERGE_PASSES AS sort_merge_passes,
       ROUND(SUM_SORT_MERGE_PASSES / COUNT_STAR) AS avg_sort_merges,
       SUM_SORT_SCAN AS sorts_using_scans,
       SUM_SORT_RANGE AS sort_using_range,
       SUM_SORT_ROWS AS rows_sorted,
       ROUND(SUM_SORT_ROWS / COUNT_STAR) AS avg_rows_sorted,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
 WHERE SUM_SORT_ROWS > 0
 ORDER BY SUM_SORT_MERGE_PASSES DESC, SUM_SORT_SCAN DESC, SUM_SORT_ROWS DESC;
