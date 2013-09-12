/*
 * View: io_global_by_file_by_latency
 *
 * Show the top global IO consumers by latency by file
 *
 * mysql> select * from io_global_by_file_by_latency limit 5;
 * +-----------------------------------------------------------------+------------+---------------+------------+--------------+-------------+---------------+------------+--------------+
 * | file                                                            | count_star | total_latency | count_read | read_latency | count_write | write_latency | count_misc | misc_latency |
 * +-----------------------------------------------------------------+------------+---------------+------------+--------------+-------------+---------------+------------+--------------+
 * | @@datadir/ps_helper/wait_classes_global_by_avg_latency_raw.frm~ |         24 | 451.99 ms     |          0 | 0 ps         |           4 | 108.07 us     |         20 | 451.88 ms    |
 * | @@datadir/ps_helper/innodb_buffer_stats_by_schema_raw.frm~      |         24 | 379.84 ms     |          0 | 0 ps         |           4 | 108.88 us     |         20 | 379.73 ms    |
 * | @@datadir/ps_helper/io_by_thread_by_latency_raw.frm~            |         24 | 379.46 ms     |          0 | 0 ps         |           4 | 101.37 us     |         20 | 379.36 ms    |
 * | @@datadir/ibtmp1                                                |         53 | 373.45 ms     |          0 | 0 ps         |          48 | 246.08 ms     |          5 | 127.37 ms    |
 * | @@datadir/ps_helper/statement_analysis_raw.frm~                 |         24 | 353.14 ms     |          0 | 0 ps         |           4 | 94.96 us      |         20 | 353.04 ms    |
 * +-----------------------------------------------------------------+------------+---------------+------------+--------------+-------------+---------------+------------+--------------+
 * 5 rows in set (0.00 sec)
 *
 * Versions: 5.6+
 */

DROP VIEW IF EXISTS io_global_by_file_by_latency;

CREATE SQL SECURITY INVOKER VIEW io_global_by_file_by_latency AS
SELECT ps_helper.format_path(file_name) AS file, 
       count_star, 
       ps_helper.format_time(sum_timer_wait) AS total_latency,
       count_read,
       ps_helper.format_time(sum_timer_read) AS read_latency,
       count_write,
       ps_helper.format_time(sum_timer_write) AS write_latency,
       count_misc,
       ps_helper.format_time(sum_timer_misc) AS misc_latency
  FROM performance_schema.file_summary_by_instance
 ORDER BY sum_timer_wait DESC;

/*
 * View: io_global_by_file_by_latency_raw
 *
 * Show the top global IO consumers by latency by file
 *
 * mysql> select * from io_global_by_file_by_latency_raw limit 5;
 * +--------------------------------------------------------------------------------------------+------------+---------------+------------+--------------+-------------+---------------+------------+--------------+
 * | file                                                                                       | count_star | total_latency | count_read | read_latency | count_write | write_latency | count_misc | misc_latency |
 * +--------------------------------------------------------------------------------------------+------------+---------------+------------+--------------+-------------+---------------+------------+--------------+
 * | /Users/mark/sandboxes/msb_5_7_2/data/ps_helper/wait_classes_global_by_avg_latency_raw.frm~ |         30 |  513959738110 |          0 |            0 |           5 |     132130960 |         25 | 513827607150 |
 * | /Users/mark/sandboxes/msb_5_7_2/data/ps_helper/innodb_buffer_stats_by_schema_raw.frm~      |         30 |  490149888410 |          0 |            0 |           5 |     483887040 |         25 | 489666001370 |
 * | /Users/mark/sandboxes/msb_5_7_2/data/ps_helper/io_by_thread_by_latency_raw.frm~            |         30 |  427724241620 |          0 |            0 |           5 |     131399580 |         25 | 427592842040 |
 * | /Users/mark/sandboxes/msb_5_7_2/data/ps_helper/innodb_buffer_stats_by_schema.frm~          |         30 |  406392559950 |          0 |            0 |           5 |     104082160 |         25 | 406288477790 |
 * | /Users/mark/sandboxes/msb_5_7_2/data/ps_helper/statement_analysis_raw.frm~                 |         30 |  395527510430 |          0 |            0 |           5 |     118724840 |         25 | 395408785590 |
 * +--------------------------------------------------------------------------------------------+------------+---------------+------------+--------------+-------------+---------------+------------+--------------+
 * 5 rows in set (0.00 sec)
 *
 * Versions: 5.6+
 */

DROP VIEW IF EXISTS io_global_by_file_by_latency_raw;

CREATE SQL SECURITY INVOKER VIEW io_global_by_file_by_latency_raw AS
SELECT file_name AS file, 
       count_star, 
       sum_timer_wait AS total_latency,
       count_read,
       sum_timer_read AS read_latency,
       count_write,
       sum_timer_write AS write_latency,
       count_misc,
       sum_timer_misc AS misc_latency
  FROM performance_schema.file_summary_by_instance
 ORDER BY sum_timer_wait DESC;