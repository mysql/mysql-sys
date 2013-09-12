/*
 * View: waits_global_by_latency
 *
 * Lists the top wait events by their total latency, ignoring idle (this may be very large)
 *
 * mysql> select * from waits_global_by_latency limit 5;
 * +--------------------------------------+--------------+---------------+-------------+-------------+
 * | event                                | total_events | total_latency | avg_latency | max_latency |
 * +--------------------------------------+--------------+---------------+-------------+-------------+
 * | wait/io/file/myisam/dfile            |   3623719744 | 00:47:49.09   | 791.70 ns   | 312.96 ms   |
 * | wait/io/table/sql/handler            |     69114944 | 00:44:30.74   | 38.64 us    | 879.49 ms   |
 * | wait/io/file/innodb/innodb_log_file  |     28100261 | 00:37:42.12   | 80.50 us    | 476.00 ms   |
 * | wait/io/socket/sql/client_connection |    200704863 | 00:18:37.81   | 5.57 us     | 1.27 s      |
 * | wait/io/file/innodb/innodb_data_file |      2829403 | 00:08:12.89   | 174.20 us   | 455.22 ms   |
 * +--------------------------------------+--------------+---------------+-------------+-------------+
 * 
 * Versions: 5.5+
 */

DROP VIEW IF EXISTS waits_global_by_latency;

CREATE SQL SECURITY INVOKER VIEW waits_global_by_latency AS
SELECT event_name AS event,
       count_star AS total_events,
       ps_helper.format_time(sum_timer_wait) AS total_latency,
       ps_helper.format_time(avg_timer_wait) AS avg_latency,
       ps_helper.format_time(max_timer_wait) AS max_latency
  FROM performance_schema.events_waits_summary_global_by_event_name
 WHERE event_name != 'idle'
   AND sum_timer_wait > 0
 ORDER BY sum_timer_wait DESC;

/*
 * View: waits_global_by_latency_raw
 *
 * Lists the top wait events by their total latency, ignoring idle (this may be very large)
 *
 * mysql> select * from waits_global_by_latency_raw limit 5;
 * +--------------------------------------+--------------+---------------+-------------+--------------+
 * | event                                | total_events | total_latency | avg_latency | max_latency  |
 * +--------------------------------------+--------------+---------------+-------------+--------------+
 * | wait/io/file/sql/file_parser         |          679 | 3536136351540 |  5207858773 | 129860439800 |
 * | wait/io/file/innodb/innodb_data_file |          195 |  848170566100 |  4349592637 | 350700491310 |
 * | wait/io/file/sql/FRM                 |         1355 |  400428476500 |   295518990 |  44823120940 |
 * | wait/io/file/innodb/innodb_log_file  |           20 |   54298899070 |  2714944765 |  30108124800 |
 * | wait/io/file/mysys/charset           |            3 |   24244722970 |  8081574072 |  24151547420 |
 * +--------------------------------------+--------------+---------------+-------------+--------------+
 * 5 rows in set (0.01 sec)
 * 
 * Versions: 5.5+
 */

DROP VIEW IF EXISTS waits_global_by_latency_raw;

CREATE SQL SECURITY INVOKER VIEW waits_global_by_latency_raw AS
SELECT event_name AS event,
       count_star AS total_events,
       sum_timer_wait AS total_latency,
       avg_timer_wait AS avg_latency,
       max_timer_wait AS max_latency
  FROM performance_schema.events_waits_summary_global_by_event_name
 WHERE event_name != 'idle'
   AND sum_timer_wait > 0
 ORDER BY sum_timer_wait DESC;
