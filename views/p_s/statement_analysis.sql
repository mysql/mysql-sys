/*
 * View: statement_analysis
 *
 * Lists a normalized statement view with aggregated statistics,
 * mimics the MySQL Enterprise Monitor Query Analysis view,
 * ordered by the total execution time per normalized statement
 * 
 * mysql> select * from statement_analysis where query IS NOT NULL limit 10;
 * +-------------------------------------------------------------------+-----------+------------+-----------+------------+---------------+-------------+-------------+-----------+---------------+--------------+----------------------------------+
 * | query                                                             | full_scan | exec_count | err_count | warn_count | total_latency | max_latency | avg_latency | rows_sent | rows_sent_avg | rows_scanned | digest                           |
 * +-------------------------------------------------------------------+-----------+------------+-----------+------------+---------------+-------------+-------------+-----------+---------------+--------------+----------------------------------+
 * | COMMIT                                                            |           |      14477 |         0 |          0 | 2.68 s        | 319.99 ms   | 185.07 µs   |         0 |             0 |            0 | 08467ba5a1c5748b32cd7518509ef9a9 |
 * | SELECT `maptimeser0_` . `id` A ...  `maptimeser0_` . `hash` = ?   |           |       2190 |         0 |          0 | 399.22 ms     | 12.85 ms    | 182.09 µs   |      2190 |             1 |         2190 | a39256afecc105bb49acb266134f00be |
 * | SELECT `environmen0_` . `hid`  ... 393_0_` , `environmen0_` . ... |           |        996 |         0 |          0 | 347.44 ms     | 8.91 ms     | 348.61 µs   |       996 |             1 |          996 | ecea708cfd3d0909be4dedf676798e56 |
 * | SELECT `mysqlserve0_` . `hid`  ... , `mysqlserve0_` . `os` AS ... | *         |       1080 |         0 |          0 | 337.56 ms     | 6.49 ms     | 312.53 µs   |      1572 |             1 |         1572 | e9eac5233c5cb73ecb2e336283da0f55 |
 * | SELECT `this_` . `instance_att ... his_` . `attribute_id` = ? )   |           |       1070 |         0 |          0 | 201.62 ms     | 2.01 ms     | 188.38 µs   |         2 |             0 |            2 | 971dc9b0e9a864b40b1218ecf00ec66d |
 * | SELECT `identityna0_` . `id` A ... RE `identityna0_` . `id` = ?   |           |       1074 |         0 |          0 | 158.70 ms     | 7.43 ms     | 147.66 µs   |         0 |             0 |            0 | 0c55d5168c602404fdcd414ced10e2ee |
 * | SELECT `mysqlserve2_` . `hid`  ... ` WHERE `agent0_` . `id` = ?   | *         |        518 |         0 |          0 | 143.75 ms     | 2.65 ms     | 277.43 µs   |      1036 |             2 |         2072 | 3a0b0da99b4faaceb4ce7ecea64cd2ed |
 * | SELECT `agent0_` . `hid` AS `h ... ventory` . `Agent` `agent0_`   | *         |        510 |         0 |          0 | 115.21 ms     | 3.50 ms     | 225.79 µs   |       510 |             1 |          510 | 0d705eeb9f631f35f08bb828a995e0b8 |
 * | SELECT `network_in2_` . `hid`  ... WHERE `network0_` . `id` = ?   |           |        522 |         0 |          0 | 98.86 ms      | 422.11 µs   | 189.37 µs   |       108 |             0 |          216 | dc23c65f7d6201455c9da09214ca8bc9 |
 * | SELECT `network0_` . `hid` AS  ... 21_394_0_` , `network0_` . ... |           |        522 |         0 |          0 | 89.75 ms      | 374.44 µs   | 171.82 µs   |       522 |             1 |          522 | 759bfff4b6c0155fe043a5ad38c4a9f0 |
 * +-------------------------------------------------------------------+-----------+------------+-----------+------------+---------------+-------------+-------------+-----------+---------------+--------------+----------------------------------+
 *
 * (Example from 5.6.6)
 *
 * Versions: 5.6.5+
 */

DROP VIEW IF EXISTS statement_analysis;

CREATE SQL SECURITY INVOKER VIEW statement_analysis AS
SELECT format_statement(DIGEST_TEXT) AS query,
       IF(SUM_NO_GOOD_INDEX_USED > 0 OR SUM_NO_INDEX_USED > 0, '*', '') AS full_scan,
       COUNT_STAR AS exec_count,
       SUM_ERRORS AS err_count,
       SUM_WARNINGS AS warn_count,
       format_time(SUM_TIMER_WAIT) AS total_latency,
       format_time(MAX_TIMER_WAIT) AS max_latency,
       format_time(AVG_TIMER_WAIT) AS avg_latency,
       SUM_ROWS_SENT AS rows_sent,
       ROUND(SUM_ROWS_SENT / COUNT_STAR) AS rows_sent_avg,
       SUM_ROWS_EXAMINED AS rows_scanned,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
ORDER BY SUM_TIMER_WAIT DESC;

/*
 * View: statement_analysis_raw
 *
 * Lists a normalized statement view with aggregated statistics,
 * mimics the MySQL Enterprise Monitor Query Analysis view,
 * ordered by the total execution time per normalized statement
 * 
 * mysql> select * from statement_analysis_raw LIMIT 1\G
 * *************************** 1. row ***************************
 *         query: SELECT * FROM `top_tables_by_latency` SELECT `performance_schema` . `objects_summary_global_by_type` . `OBJECT_SCHEMA` AS `db_name` ...
 *     full_scan: *
 *    exec_count: 2
 *     err_count: 0
 *    warn_count: 0
 * total_latency: 30075208207000
 *   max_latency: 28827579292000
 *   avg_latency: 15037604103000
 *     rows_sent: 220
 * rows_sent_avg: 110
 *  rows_scanned: 440
 *        digest: 44f1f3181975504b160c57b89c9ce23e
 * 1 row in set (0.01 sec) *
 *
 * (Example from 5.6.6)
 *
 * Versions: 5.6.5+
 */

DROP VIEW IF EXISTS statement_analysis_raw;

CREATE SQL SECURITY INVOKER VIEW statement_analysis_raw AS
SELECT DIGEST_TEXT AS query,
       IF(SUM_NO_GOOD_INDEX_USED > 0 OR SUM_NO_INDEX_USED > 0, '*', '') AS full_scan,
       COUNT_STAR AS exec_count,
       SUM_ERRORS AS err_count,
       SUM_WARNINGS AS warn_count,
       SUM_TIMER_WAIT AS total_latency,
       MAX_TIMER_WAIT AS max_latency,
       AVG_TIMER_WAIT AS avg_latency,
       SUM_ROWS_SENT AS rows_sent,
       ROUND(SUM_ROWS_SENT / COUNT_STAR) AS rows_sent_avg,
       SUM_ROWS_EXAMINED AS rows_scanned,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
ORDER BY SUM_TIMER_WAIT DESC;
