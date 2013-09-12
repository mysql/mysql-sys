/*
 * View: wait_classes_global_by_avg_latency
 * 
 * Lists the top wait classes by average latency, ignoring idle (this may be very large)
 *
 * mysql> select * from wait_classes_global_by_avg_latency where event_class != 'idle';
 * +-------------------+--------------+---------------+-------------+-------------+-------------+
 * | event_class       | total_events | total_latency | min_latency | avg_latency | max_latency |
 * +-------------------+--------------+---------------+-------------+-------------+-------------+
 * | wait/io/file      |       543123 | 44.60 s       | 19.44 ns    | 82.11 µs    | 4.21 s      |
 * | wait/io/table     |        22002 | 766.60 ms     | 148.72 ns   | 34.84 µs    | 44.97 ms    |
 * | wait/io/socket    |        79613 | 967.17 ms     | 0 ps        | 12.15 µs    | 27.10 ms    |
 * | wait/lock/table   |        35409 | 18.68 ms      | 65.45 ns    | 527.51 ns   | 969.88 µs   |
 * | wait/synch/rwlock |        37935 | 4.61 ms       | 21.38 ns    | 121.61 ns   | 34.65 µs    |
 * | wait/synch/mutex  |       390622 | 18.60 ms      | 19.44 ns    | 47.61 ns    | 10.32 µs    |
 * +-------------------+--------------+---------------+-------------+-------------+-------------+
 *
 * (Example from 5.6.6)
 *
 * Versions: 5.5+
 */

DROP VIEW IF EXISTS wait_classes_global_by_avg_latency;

CREATE SQL SECURITY INVOKER VIEW wait_classes_global_by_avg_latency AS
SELECT SUBSTRING_INDEX(event_name,'/', 3) event_class,
       SUM(COUNT_STAR) total_events,
       format_time(CAST(SUM(sum_timer_wait) AS UNSIGNED)) total_latency,
       format_time(MIN(min_timer_wait)) min_latency,
       format_time(SUM(sum_timer_wait) / SUM(COUNT_STAR)) avg_latency,
       format_time(CAST(MAX(max_timer_wait) AS UNSIGNED)) max_latency
  FROM performance_schema.events_waits_summary_global_by_event_name
 WHERE sum_timer_wait > 0
   AND event_name != 'idle'
 GROUP BY event_class
 ORDER BY SUM(sum_timer_wait) / SUM(COUNT_STAR) DESC;

/*
 * View: wait_classes_global_by_avg_latency_raw
 * 
 * Lists the top wait classes by average latency, ignoring idle (this may be very large)
 *
 * mysql> select * from wait_classes_global_by_avg_latency_raw;
 * +-------------------+--------------+-------------------+-------------+--------------------+------------------+
 * | event_class       | total_events | total_latency     | min_latency | avg_latency        | max_latency      |
 * +-------------------+--------------+-------------------+-------------+--------------------+------------------+
 * | idle              |         4331 | 16044682716000000 |     2000000 | 3704613880397.1369 | 1593550454000000 |
 * | wait/io/file      |        23037 |    20856702551880 |           0 |     905356711.0249 |     350700491310 |
 * | wait/io/table     |       224924 |      719670285750 |      116870 |       3199615.3623 |     208579012460 |
 * | wait/lock/table   |         6972 |        3674766030 |      109330 |        527074.8752 |          8855730 |
 * | wait/synch/rwlock |        11916 |        1273279800 |       37700 |        106854.6324 |          6838780 |
 * | wait/synch/mutex  |      1031881 |       80464286240 |       56550 |         77978.2613 |       2590408470 |
 * +-------------------+--------------+-------------------+-------------+--------------------+------------------+
 * 6 rows in set (0.01 sec)
 *
 * (Example from 5.6.6)
 *
 * Versions: 5.5+
 */

DROP VIEW IF EXISTS wait_classes_global_by_avg_latency_raw;

CREATE SQL SECURITY INVOKER VIEW wait_classes_global_by_avg_latency_raw AS
SELECT SUBSTRING_INDEX(event_name,'/', 3) event_class,
       SUM(COUNT_STAR) total_events,
       SUM(sum_timer_wait) total_latency,
       MIN(min_timer_wait) min_latency,
       SUM(sum_timer_wait) / SUM(COUNT_STAR) avg_latency,
       MAX(max_timer_wait)max_latency
  FROM performance_schema.events_waits_summary_global_by_event_name
 WHERE sum_timer_wait > 0
   AND event_name != 'idle'
 GROUP BY event_class
 ORDER BY SUM(sum_timer_wait) / SUM(COUNT_STAR) DESC;
 