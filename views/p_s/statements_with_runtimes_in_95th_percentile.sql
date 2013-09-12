/*
 * View: _digest_avg_latency_by_avg_us
 *
 * Helper view for _digest_95th_percentile_by_avg_us
 *
 * Versions: 5.6.5+
 */
DROP VIEW IF EXISTS _digest_avg_latency_by_avg_us;

CREATE SQL SECURITY INVOKER VIEW _digest_avg_latency_by_avg_us AS
SELECT COUNT(*) cnt, 
       ROUND(avg_timer_wait/1000000) AS avg_us
  FROM performance_schema.events_statements_summary_by_digest
 GROUP BY avg_us;

/*
 * View: _digest_95th_percentile_by_avg_us
 *
 * Helper view for statements_with_runtimes_in_95th_percentile.
 * Lists the 95th percentile runtime, for all statements
 *
 * mysql> select * from _digest_95th_percentile_by_avg_us;
 * +--------+------------+
 * | avg_us | percentile |
 * +--------+------------+
 * |    964 |     0.9525 |
 * +--------+------------+
 *
 * Versions: 5.6.5+
 */
DROP VIEW IF EXISTS _digest_95th_percentile_by_avg_us;

CREATE SQL SECURITY INVOKER VIEW _digest_95th_percentile_by_avg_us AS
SELECT s2.avg_us avg_us,
       SUM(s1.cnt)/(SELECT COUNT(*) FROM performance_schema.events_statements_summary_by_digest) percentile
  FROM _digest_avg_latency_by_avg_us AS s1
  JOIN _digest_avg_latency_by_avg_us AS s2
    ON s1.avg_us <= s2.avg_us
 GROUP BY s2.avg_us
HAVING percentile > 0.95
 ORDER BY percentile
 LIMIT 1;

/*
 * View: statements_with_runtimes_in_95th_percentile
 *
 * List all statements who's average runtime, in microseconds, is in the top 95th percentile.
 * 
 * mysql> select * from statements_with_runtimes_in_95th_percentile where query not like 'show%';
 * +-------------------------------------------------------------------+-----------+------------+-----------+------------+---------------+-------------+-------------+-----------+---------------+--------------+----------------------------------+
 * | query                                                             | full_scan | exec_count | err_count | warn_count | total_latency | max_latency | avg_latency | rows_sent | rows_sent_avg | rows_scanned | digest                           |
 * +-------------------------------------------------------------------+-----------+------------+-----------+------------+---------------+-------------+-------------+-----------+---------------+--------------+----------------------------------+
 * | SELECT plugin_name FROM inform ... tus = ? ORDER BY plugin_name   | *         |        169 |         0 |          0 | 2.37 s        | 64.45 ms    | 14.03 ms    |      4394 |            26 |        10816 | 23234b56a0b1f1e350bf51bef3050747 |
 * | SELECT `this_` . `target` AS ` ... D `this_` . `timestamp` <= ?   |           |        118 |         0 |          0 | 170.08 ms     | 5.68 ms     | 1.44 ms     |     13582 |           115 |        13582 | 34694223091aee1380c565076b7dfece |
 * | SELECT CAST ( SUM_NUMBER_OF_BY ... WHERE EVENT_NAME = ? LIMIT ?   | *         |        566 |         0 |          0 | 779.56 ms     | 2.93 ms     | 1.38 ms     |       342 |             1 |        17286 | 58d34495d29ad818e68c859e778b0dcb |
 * | SELECT `this_` . `target` AS ` ... D `this_` . `timestamp` <= ?   |           |        118 |         0 |          0 | 153.35 ms     | 3.06 ms     | 1.30 ms     |     13228 |           112 |        13228 | b816579565d5a2882cb8bd496193dc00 |
 * | SELECT `this_` . `target` AS ` ... D `this_` . `timestamp` <= ?   |           |        118 |         0 |          0 | 143.31 ms     | 4.57 ms     | 1.21 ms     |     13646 |           116 |        13646 | 27ff8681eb2c8cf999233e7507b439fe |
 * | SELECT `this_` . `target` AS ` ... D `this_` . `timestamp` <= ?   |           |        118 |         0 |          0 | 143.04 ms     | 7.22 ms     | 1.21 ms     |     13584 |           115 |        13584 | 10b863f20e83dcd9c7782dac249acbb0 |
 * | SELECT `this_` . `target` AS ` ... D `this_` . `timestamp` <= ?   |           |        118 |         0 |          0 | 137.46 ms     | 16.73 ms    | 1.16 ms     |     13922 |           118 |        13922 | 351ebc26af6babb67570843bcc97f6b0 |
 * | UPDATE `mem30__inventory` . `R ... mestamp` = ? WHERE `hid` = ?   |           |        114 |         0 |          0 | 127.64 ms     | 30.33 ms    | 1.12 ms     |         0 |             0 |          114 | f4ecf2aebe212e7ed250a0602d86c389 |
 * | UPDATE `mem30__inventory` . `I ... ` = ? , `hasOldBlocksTime` ... |           |         56 |         0 |          0 | 61.05 ms      | 16.41 ms    | 1.09 ms     |         0 |             0 |           56 | cdc78c70d83c505c5708847ba810d035 |
 * | SELECT `this_` . `target` AS ` ... D `this_` . `timestamp` <= ?   |           |        118 |         0 |          0 | 121.76 ms     | 1.95 ms     | 1.03 ms     |     13936 |           118 |        13936 | 20f97c53c2a59f5eadc06b2fa90fbe75 |
 * | UPDATE `mem30__inventory` . `M ... mpileOs` = ? WHERE `hid` = ?   |           |        114 |         0 |          0 | 114.16 ms     | 22.34 ms    | 1.00 ms     |         0 |             0 |          114 | c5d4a65f3f308f4869807e730739af6d |
 * | CALL `dc_string_insert` (...)                                     |           |         80 |         0 |          0 | 79.89 ms      | 2.62 ms     | 998.50 ┬╡s  |         0 |             0 |          240 | 93eb9cab8ced45cf3b98400e8803f8af |
 * | SELECT `this_` . `target` AS ` ... D `this_` . `timestamp` <= ?   |           |        118 |         0 |          0 | 116.19 ms     | 1.32 ms     | 984.60 ┬╡s  |     13484 |           114 |        13484 | bd23afed9a41367591e2b71dac76f334 |
 * +-------------------------------------------------------------------+-----------+------------+-----------+------------+---------------+-------------+-------------+-----------+---------------+--------------+----------------------------------+
 *
 * (Example from 5.6.6)
 *
 * Versions: 5.6.5+
 *
 */

DROP VIEW IF EXISTS statements_with_runtimes_in_95th_percentile;

CREATE SQL SECURITY INVOKER VIEW statements_with_runtimes_in_95th_percentile AS
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
  FROM performance_schema.events_statements_summary_by_digest stmts
  JOIN _digest_95th_percentile_by_avg_us AS top_percentile
    ON ROUND(stmts.avg_timer_wait/1000000) >= top_percentile.avg_us
 ORDER BY AVG_TIMER_WAIT DESC;

/*
 * View: statements_with_runtimes_in_95th_percentile_raw
 *
 * List all statements who's average runtime, in microseconds, is in the top 95th percentile.
 *
 * mysql> SELECT * FROM statements_with_runtimes_in_95th_percentile_raw LIMIT 1\G
 * *************************** 1. row ***************************
 *         query: SELECT * FROM `top_tables_by_latency` SELECT `performance_schema` . `objects_summary_global_by_type` . `OBJECT_SCHEMA` AS `db_name` , ...
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
 * 1 row in set (0.36 sec)
 *
 * (Example from 5.6.6)
 *
 * Versions: 5.6.5+
 *
 */

DROP VIEW IF EXISTS statements_with_runtimes_in_95th_percentile_raw;

CREATE SQL SECURITY INVOKER VIEW statements_with_runtimes_in_95th_percentile_raw AS
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
  FROM performance_schema.events_statements_summary_by_digest stmts
  JOIN _digest_95th_percentile_by_avg_us AS top_percentile
    ON ROUND(stmts.avg_timer_wait/1000000) >= top_percentile.avg_us
 ORDER BY AVG_TIMER_WAIT DESC;