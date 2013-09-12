/*
 * View: user_summary_by_statement_type
 *
 * Summarizes the types of statements executed by each user
 *
 * mysql> select * from user_summary_by_statement_type;
 * +------+----------------------+--------+---------------+-------------+--------------+-----------+---------------+---------------+------------+
 * | user | statement            | count  | total_latency | max_latency | lock_latency | rows_sent | rows_examined | rows_affected | full_scans |
 * +------+----------------------+--------+---------------+-------------+--------------+-----------+---------------+---------------+------------+
 * | root | create_view          |   2063 | 00:05:04.20   | 463.58 ms   | 1.42 s       |         0 |             0 |             0 |          0 |
 * | root | select               |    174 | 40.87 s       | 28.83 s     | 858.13 ms    |      5212 |        157022 |             0 |         82 |
 * | root | stmt                 |   6645 | 15.31 s       | 491.78 ms   | 0 ps         |         0 |             0 |          7951 |          0 |
 * | root | call_procedure       |     17 | 4.78 s        | 1.02 s      | 37.94 ms     |         0 |             0 |            19 |          0 |
 * | root | create_table         |     19 | 3.04 s        | 431.71 ms   | 0 ps         |         0 |             0 |             0 |          0 |
 * ...
 * +------+----------------------+--------+---------------+-------------+--------------+-----------+---------------+---------------+------------+
 * 41 rows in set (0.24 sec)
 * 
 * Versions: 5.6.3+
 */

DROP VIEW IF EXISTS user_summary_by_statement_type;

CREATE SQL SECURITY INVOKER VIEW user_summary_by_statement_type AS
SELECT user,
       SUBSTRING_INDEX(event_name, '/', -1) AS statement,
       count_star AS count,
       format_time(sum_timer_wait) AS total_latency,
       format_time(max_timer_wait) AS max_latency,
       format_time(sum_lock_time) AS lock_latency,
       sum_rows_sent AS rows_sent,
       sum_rows_examined AS rows_examined,
       sum_rows_affected AS rows_affected,
       sum_no_index_used + sum_no_good_index_used AS full_scans
  FROM performance_schema.events_statements_summary_by_user_by_event_name
 WHERE user IS NOT NULL
   AND sum_timer_wait != 0
 ORDER BY user, sum_timer_wait DESC;

/*
 * View: user_summary_by_statement_type_raw
 *
 * Summarizes the types of statements executed by each user
 *
 * mysql> select * from user_summary_by_statement_type_raw;
 * +------+----------------------+--------+-----------------+----------------+----------------+-----------+---------------+---------------+------------+
 * | user | statement            | count  | total_latency   | max_latency    | lock_latency   | rows_sent | rows_examined | rows_affected | full_scans |
 * +------+----------------------+--------+-----------------+----------------+----------------+-----------+---------------+---------------+------------+
 * | root | create_view          |   2110 | 312717366332000 |   463578029000 |  1432355000000 |         0 |             0 |             0 |          0 |
 * | root | select               |    177 |  41115690428000 | 28827579292000 |   858709000000 |      5254 |        157437 |             0 |         83 |
 * | root | stmt                 |   6645 |  15305389969000 |   491780297000 |              0 |         0 |             0 |          7951 |          0 |
 * | root | call_procedure       |     17 |   4783806053000 |  1016083397000 |    37936000000 |         0 |             0 |            19 |          0 |
 * | root | create_table         |     19 |   3035120946000 |   431706815000 |              0 |         0 |             0 |             0 |          0 |
 * ...
 * +------+----------------------+--------+-----------------+----------------+----------------+-----------+---------------+---------------+------------+
 * 41 rows in set (0.01 sec)
 * 
 * Versions: 5.6.3+
 */

DROP VIEW IF EXISTS user_summary_by_statement_type_raw;

CREATE SQL SECURITY INVOKER VIEW user_summary_by_statement_type_raw AS
SELECT user,
       SUBSTRING_INDEX(event_name, '/', -1) AS statement,
       count_star AS count,
       sum_timer_wait AS total_latency,
       max_timer_wait AS max_latency,
       sum_lock_time AS lock_latency,
       sum_rows_sent AS rows_sent,
       sum_rows_examined AS rows_examined,
       sum_rows_affected AS rows_affected,
       sum_no_index_used + sum_no_good_index_used AS full_scans
  FROM performance_schema.events_statements_summary_by_user_by_event_name
 WHERE user IS NOT NULL
   AND sum_timer_wait != 0
 ORDER BY user, sum_timer_wait DESC;