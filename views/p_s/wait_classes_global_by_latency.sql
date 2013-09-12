/*
 * View: wait_classes_global_by_latency
 * 
 * Lists the top wait classes by total latency, ignoring idle (this may be very large)
 *
 * mysql> select * from wait_classes_global_by_latency;
 * +-------------------+--------------+---------------+-------------+-------------+-------------+
 * | event_class       | total_events | total_latency | min_latency | avg_latency | max_latency |
 * +-------------------+--------------+---------------+-------------+-------------+-------------+
 * | wait/io/file      |       550470 | 46.01 s       | 19.44 ns    | 83.58 µs    | 4.21 s      |
 * | wait/io/socket    |       228833 | 2.71 s        | 0 ps        | 11.86 µs    | 29.93 ms    |
 * | wait/io/table     |        64063 | 1.89 s        | 99.79 ns    | 29.43 µs    | 68.07 ms    |
 * | wait/lock/table   |        76029 | 47.19 ms      | 65.45 ns    | 620.74 ns   | 969.88 µs   |
 * | wait/synch/mutex  |       635925 | 34.93 ms      | 19.44 ns    | 54.93 ns    | 107.70 µs   |
 * | wait/synch/rwlock |        61287 | 7.62 ms       | 21.38 ns    | 124.37 ns   | 34.65 µs    |
 * +-------------------+--------------+---------------+-------------+-------------+-------------+
 *
 * (Example from 5.6.6)
 *
 * Versions: 5.5+
 */

DROP VIEW IF EXISTS wait_classes_global_by_latency;

CREATE SQL SECURITY INVOKER VIEW wait_classes_global_by_latency AS
SELECT SUBSTRING_INDEX(event_name,'/', 3) event_class, 
       SUM(COUNT_STAR) total_events,
       format_time(SUM(sum_timer_wait)) total_latency,
       format_time(MIN(min_timer_wait)) min_latency,
       format_time(SUM(sum_timer_wait) / SUM(COUNT_STAR)) avg_latency,
       format_time(MAX(max_timer_wait)) max_latency
  FROM performance_schema.events_waits_summary_global_by_event_name
 WHERE sum_timer_wait > 0
   AND event_name != 'idle'
 GROUP BY SUBSTRING_INDEX(event_name,'/', 3) 
 ORDER BY SUM(sum_timer_wait) DESC;

/*
 * View: wait_classes_global_by_latency_raw
 * 
 * Lists the top wait classes by total latency, ignoring idle (this may be very large)
 *
 * mysql> SELECT * FROM wait_classes_global_by_latency_raw;
 * +-------------------+--------------+----------------+-------------+----------------+--------------+
 * | event_class       | total_events | total_latency  | min_latency | avg_latency    | max_latency  |
 * +-------------------+--------------+----------------+-------------+----------------+--------------+
 * | wait/io/file      |        29468 | 27100905420290 |           0 | 919672370.7170 | 350700491310 |
 * | wait/io/table     |       224924 |   719670285750 |      116870 |   3199615.3623 | 208579012460 |
 * | wait/synch/mutex  |      1532036 |   118515948070 |       56550 |     77358.4616 |   2590408470 |
 * | wait/io/socket    |         1193 |    10677541030 |           0 |   8950160.1257 |    287760330 |
 * | wait/lock/table   |         6972 |     3674766030 |      109330 |    527074.8752 |      8855730 |
 * | wait/synch/rwlock |        13646 |     1579833580 |       37700 |    115772.6499 |     28293850 |
 * +-------------------+--------------+----------------+-------------+----------------+--------------+
 * 6 rows in set (0.01 sec)
 *
 * (Example from 5.6.6)
 *
 * Versions: 5.5+
 */

DROP VIEW IF EXISTS wait_classes_global_by_latency_raw;

CREATE SQL SECURITY INVOKER VIEW wait_classes_global_by_latency_raw AS
SELECT SUBSTRING_INDEX(event_name,'/', 3) event_class, 
       SUM(COUNT_STAR) total_events,
       SUM(sum_timer_wait) total_latency,
       MIN(min_timer_wait) min_latency,
       SUM(sum_timer_wait) / SUM(COUNT_STAR) avg_latency,
       MAX(max_timer_wait) max_latency
  FROM performance_schema.events_waits_summary_global_by_event_name
 WHERE sum_timer_wait > 0
   AND event_name != 'idle'
 GROUP BY SUBSTRING_INDEX(event_name,'/', 3) 
 ORDER BY SUM(sum_timer_wait) DESC;
