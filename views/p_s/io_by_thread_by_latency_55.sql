/*
 * View: io_by_thread_by_latency
 *
 * Show the top IO consumers by thread, ordered by total latency
 *
 * mysql> select * from io_by_thread_by_latency;
 * +----------------+------------+---------------+-------------+-------------+-------------+-----------+----------------+
 * | user           | count_star | total_latency | min_latency | avg_latency | max_latency | thread_id | processlist_id |
 * +----------------+------------+---------------+-------------+-------------+-------------+-----------+----------------+
 * | root@localhost |       1249 | 1.81 s        | 471.25 ns   | 864.34 us   | 267.19 ms   |        17 |              1 |
 * +----------------+------------+---------------+-------------+-------------+-------------+-----------+----------------+
 * 1 row in set (0.09 sec)
 *
 * (Example taken from 5.6.6)
 *
 * Versions: 5.5+
 */

DROP VIEW IF EXISTS io_by_thread_by_latency;

CREATE VIEW io_by_thread_by_latency AS
SELECT IF(id IS NULL, 
             SUBSTRING_INDEX(name, '/', -1), 
             CONCAT(user, '@', host)
          ) user, 
       SUM(count_star) count_star,
       format_time(SUM(sum_timer_wait)) total_latency,
       format_time(MIN(min_timer_wait)) min_latency,
       format_time(AVG(avg_timer_wait)) avg_latency,
       format_time(MAX(max_timer_wait)) max_latency,
       thread_id,
       id AS processlist_id
  FROM performance_schema.events_waits_summary_by_thread_by_event_name 
  LEFT JOIN performance_schema.threads USING (thread_id) 
  LEFT JOIN information_schema.processlist ON processlist_id = id
 WHERE event_name LIKE 'wait/io/file/%'
   AND sum_timer_wait > 0
 GROUP BY thread_id
 ORDER BY SUM(sum_timer_wait) DESC;

/*
 * View: io_by_thread_by_latency_raw
 *
 * Show the top IO consumers by thread, ordered by total latency
 *
 * Versions: 5.5+
 *
 * mysql> select * from io_by_thread_by_latency_raw;
 * +----------------+------------+---------------+-------------+----------------+--------------+-----------+----------------+
 * | user           | count_star | total_latency | min_latency | avg_latency    | max_latency  | thread_id | processlist_id |
 * +----------------+------------+---------------+-------------+----------------+--------------+-----------+----------------+
 * | root@localhost |       1288 | 1809935846680 |      471250 | 848350349.3333 | 267194403190 |        17 |              1 |
 * +----------------+------------+---------------+-------------+----------------+--------------+-----------+----------------+
 * 1 row in set (0.01 sec)
 *
 * (Example taken from 5.6.6)
 *
 * Versions: 5.5+
 */

DROP VIEW IF EXISTS io_by_thread_by_latency_raw;

CREATE VIEW io_by_thread_by_latency_raw AS
SELECT IF(id IS NULL, 
             SUBSTRING_INDEX(name, '/', -1), 
             CONCAT(user, '@', host)
          ) user, 
       SUM(count_star) count_star,
       SUM(sum_timer_wait) total_latency,
       MIN(min_timer_wait) min_latency,
       AVG(avg_timer_wait) avg_latency,
       MAX(max_timer_wait) max_latency,
       thread_id,
       id AS processlist_id
  FROM performance_schema.events_waits_summary_by_thread_by_event_name 
  LEFT JOIN performance_schema.threads USING (thread_id) 
  LEFT JOIN information_schema.processlist ON processlist_id = id
 WHERE event_name LIKE 'wait/io/file/%'
   AND sum_timer_wait > 0
 GROUP BY thread_id
 ORDER BY SUM(sum_timer_wait) DESC;