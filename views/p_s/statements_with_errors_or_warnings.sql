/*
 * View: statements_with_errors_or_warnings
 *
 * List all normalized statements that have raised errors or warnings.
 *
 * mysql> select * from statements_with_errors_or_warnings limit 5;
 * +-------------------------------------------------------------------+-----------+------------+--------+-----------+----------+-------------+---------------------+---------------------+----------------------------------+
 * | query                                                             | db        | exec_count | errors | error_pct | warnings | warning_pct | first_seen          | last_seen           | digest                           |
 * +-------------------------------------------------------------------+-----------+------------+--------+-----------+----------+-------------+---------------------+---------------------+----------------------------------+
 * | INSERT INTO `mem__quan` . `nor ... `lastSeen` ) ) , `lastSeen` )  | mem       |    7619897 |    645 |    0.0085 |        0 |      0.0000 | 2013-12-04 20:05:34 | 2013-12-18 18:48:34 | 6134e9d6f25eb8e6cddf11f6938f202a |
 * | INSERT INTO `mem__inventory` . ... , `Filesystem` ) VALUES (...)  | mem       |         54 |      3 |    5.5556 |        0 |      0.0000 | 2013-12-04 20:10:22 | 2013-12-18 18:48:44 | e225410633e09d7c6288cc390654b361 |
 * | INSERT INTO `mem__events` . `e ...  ?, ... , (_charset) ?, ... )  | mem       |        521 |      3 |    0.5758 |        0 |      0.0000 | 2013-12-04 20:04:53 | 2013-12-18 18:05:34 | 9b9714753319e42ffb3483377c1e596c |
 * | CREATE SQL SECURITY INVOKER VI ... CREATED_T` `SUM_SORT_ROWS` AS  | ps_helper |          2 |      2 |  100.0000 |        0 |      0.0000 | 2013-12-18 17:46:28 | 2013-12-18 17:46:32 | 7131bbf490c4b7bdc93dd76599084996 |
 * | SELECT `mysqlconne0_` . `hid`  ... ` AS `hasProc18_1821_0_` , ... | mem       |     982158 |      1 |    0.0001 |        0 |      0.0000 | 2013-12-04 20:04:48 | 2013-12-18 18:49:04 | 24259bc30a8f8b0b53ba0283d940f938 |
 * +-------------------------------------------------------------------+-----------+------------+--------+-----------+----------+-------------+---------------------+---------------------+----------------------------------+
 * 5 rows in set (0.02 sec)
 *
 * (Example from 5.6.14)
 *
 * Versions 5.6.9+
 *
 */

DROP VIEW IF EXISTS statements_with_errors_or_warnings;

CREATE SQL SECURITY INVOKER VIEW statements_with_errors_or_warnings AS
SELECT format_statement(DIGEST_TEXT) AS query,
       SCHEMA_NAME as db,
       COUNT_STAR AS exec_count,
       SUM_ERRORS AS errors,
       (SUM_ERRORS / COUNT_STAR) * 100 as error_pct,
       SUM_WARNINGS AS warnings,
       (SUM_WARNINGS / COUNT_STAR) * 100 as warning_pct,
       FIRST_SEEN as first_seen,
       LAST_SEEN as last_seen,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
 WHERE SUM_ERRORS > 0
    OR SUM_WARNINGS > 0
ORDER BY SUM_ERRORS DESC, SUM_WARNINGS DESC;
