/*
 * View: user_summary_by_stages
 *
 * Summarizes stages by user, ordered by user and total latency per stage
 * 
 * mysql> select * from user_summary_by_stages;
 * +------+-------------------------------------+--------+-------------+-----------+
 * | user | event_name                          | count  | wait_sum    | wait_avg  |
 * +------+-------------------------------------+--------+-------------+-----------+
 * | root | stage/sql/System lock               |   9230 | 00:03:11.40 | 20.74 ms  |
 * | root | stage/sql/Opening tables            | 534362 | 00:01:36.18 | 180.00 us |
 * | root | stage/sql/checking permissions      |  22119 | 31.84 s     | 1.44 ms   |
 * | root | stage/sql/Creating sort index       |    307 | 30.26 s     | 98.57 ms  |
 * | root | stage/sql/creating table            |     22 | 3.59 s      | 163.13 ms |
 * ...
 * +------+-------------------------------------+--------+-------------+-----------+
 * 27 rows in set (0.00 sec)
 * 
 * Versions: 5.6.3+
 */

DROP VIEW IF EXISTS user_summary_by_stages;

CREATE SQL SECURITY INVOKER VIEW user_summary_by_stages AS
SELECT user, event_name,
       count_star AS count,
       format_time(sum_timer_wait) AS wait_sum, 
       format_time(avg_timer_wait) AS wait_avg 
  FROM performance_schema.events_stages_summary_by_user_by_event_name
 WHERE user IS NOT NULL 
   AND sum_timer_wait != 0 
 ORDER BY user, sum_timer_wait DESC;

/*
 * View: user_summary_by_stages_raw
 *
 * Summarizes stages by user, ordered by user and total latency per stage
 * 
 * mysql> select * from user_summary_by_stages_raw;
 * +------+-------------------------------------+--------+-----------------+--------------+
 * | user | event_name                          | count  | wait_sum        | wait_avg     |
 * +------+-------------------------------------+--------+-----------------+--------------+
 * | root | stage/sql/System lock               |   9231 | 191395549684000 |  20733999000 |
 * | root | stage/sql/Opening tables            | 534704 |  96185600966000 |    179885000 |
 * | root | stage/sql/checking permissions      |  22123 |  31840645121000 |   1439255000 |
 * | root | stage/sql/Creating sort index       |    308 |  30260103983000 |  98247090000 |
 * | root | stage/sql/creating table            |     22 |   3588876152000 | 163130734000 |
 * ...
 * +------+-------------------------------------+--------+-----------------+--------------+
 * 27 rows in set (0.00 sec)
 * 
 * Versions: 5.6.3+
 */

DROP VIEW IF EXISTS user_summary_by_stages_raw;

CREATE SQL SECURITY INVOKER VIEW user_summary_by_stages_raw AS
SELECT user, event_name,
       count_star AS count,
       sum_timer_wait AS wait_sum, 
       avg_timer_wait AS wait_avg 
  FROM performance_schema.events_stages_summary_by_user_by_event_name
 WHERE user IS NOT NULL 
   AND sum_timer_wait != 0 
 ORDER BY user, sum_timer_wait DESC;
