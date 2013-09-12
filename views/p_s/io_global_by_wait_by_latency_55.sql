/*
 * View: io_global_by_wait_by_latency
 *
 * Show the top global IO consumers by latency
 *
 * mysql> select * from io_global_by_wait_by_latency;
 * +--------------------+------------+---------------+-------------+-------------+-------------+------------+------------+-----------+-------------+---------------+-------------+
 * | event_name         | count_star | total_latency | min_latency | avg_latency | max_latency | count_read | total_read | avg_read  | count_write | total_written | avg_written |
 * +--------------------+------------+---------------+-------------+-------------+-------------+------------+------------+-----------+-------------+---------------+-------------+
 * | sql/dbopt          |     328812 | 26.93 s       | 2.06 µs     | 81.90 µs    | 178.71 ms   |          0 | 0 bytes    | 0 bytes   |           9 | 585 bytes     | 65 bytes    |
 * | sql/FRM            |      57837 | 8.39 s        | 19.44 ns    | 145.13 µs   | 336.71 ms   |       8009 | 2.60 MiB   | 341 bytes |       14675 | 2.91 MiB      | 208 bytes   |
 * | sql/binlog         |        190 | 6.79 s        | 1.56 µs     | 35.76 ms    | 4.21 s      |         52 | 60.54 KiB  | 1.16 KiB  |           0 | 0 bytes       | 0 bytes     |
 * | sql/ERRMSG         |          5 | 2.03 s        | 8.61 µs     | 405.40 ms   | 2.03 s      |          3 | 51.82 KiB  | 17.27 KiB |           0 | 0 bytes       | 0 bytes     |
 * | myisam/dfile       |     163681 | 983.13 ms     | 379.08 ns   | 6.01 µs     | 22.06 ms    |      68721 | 127.23 MiB | 1.90 KiB  |     1011613 | 121.45 MiB    | 126 bytes   |
 * | sql/file_parser    |        419 | 601.37 ms     | 1.96 µs     | 1.44 ms     | 37.14 ms    |         66 | 42.01 KiB  | 652 bytes |          64 | 226.98 KiB    | 3.55 KiB    |
 * | myisam/kfile       |       1775 | 375.13 ms     | 1.02 µs     | 211.34 µs   | 35.15 ms    |      54034 | 9.97 MiB   | 193 bytes |      428001 | 12.39 MiB     | 30 bytes    |
 * | sql/global_ddl_log |        164 | 75.96 ms      | 5.72 µs     | 463.19 µs   | 7.43 ms     |         20 | 80.00 KiB  | 4.00 KiB  |          76 | 304.00 KiB    | 4.00 KiB    |
 * | sql/partition      |         81 | 18.87 ms      | 888.08 ns   | 232.92 µs   | 4.67 ms     |         66 | 2.75 KiB   | 43 bytes  |           8 | 288 bytes     | 36 bytes    |
 * | sql/misc           |         23 | 2.73 ms       | 65.14 µs    | 118.50 µs   | 255.31 µs   |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     |
 * | sql/relaylog       |          7 | 1.18 ms       | 838.84 ns   | 168.30 µs   | 892.70 µs   |          0 | 0 bytes    | 0 bytes   |           1 | 120 bytes     | 120 bytes   |
 * | sql/binlog_index   |          5 | 593.47 µs     | 1.07 µs     | 118.69 µs   | 535.90 µs   |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     |
 * | sql/pid            |          3 | 220.55 µs     | 29.29 µs    | 73.52 µs    | 143.11 µs   |          0 | 0 bytes    | 0 bytes   |           1 | 5 bytes       | 5 bytes     |
 * | mysys/charset      |          3 | 196.52 µs     | 17.61 µs    | 65.51 µs    | 137.33 µs   |          1 | 17.83 KiB  | 17.83 KiB |           0 | 0 bytes       | 0 bytes     |
 * | mysys/cnf          |          5 | 171.61 µs     | 303.26 ns   | 34.32 µs    | 115.21 µs   |          3 | 56 bytes   | 19 bytes  |           0 | 0 bytes       | 0 bytes     |
 * | sql/casetest       |          1 | 121.19 µs     | 121.19 µs   | 121.19 µs   | 121.19 µs   |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     |
 * +--------------------+------------+---------------+-------------+-------------+-------------+------------+------------+-----------+-------------+---------------+-------------+
 *
 * (Example from 5.6.6)
 *
 * Versions: 5.5+
 */

DROP VIEW IF EXISTS io_global_by_wait_by_latency;

CREATE SQL SECURITY INVOKER VIEW io_global_by_wait_by_latency AS
SELECT SUBSTRING_INDEX(event_name, '/', -2) event_name,
       ewsgben.count_star,
       format_time(ewsgben.sum_timer_wait) total_latency,
       format_time(ewsgben.min_timer_wait) min_latency,
       format_time(ewsgben.avg_timer_wait) avg_latency,
       format_time(ewsgben.max_timer_wait) max_latency,
       count_read,
       format_bytes(sum_number_of_bytes_read) total_read,
       format_bytes(IFNULL(sum_number_of_bytes_read / count_read, 0)) avg_read,
       count_write,
       format_bytes(sum_number_of_bytes_write) total_written,
       format_bytes(IFNULL(sum_number_of_bytes_write / count_write, 0)) avg_written
  FROM performance_schema.events_waits_summary_global_by_event_name AS ewsgben
  JOIN performance_schema.file_summary_by_event_name AS fsben USING (event_name) 
 WHERE event_name LIKE 'wait/io/file/%'
   AND ewsgben.count_star > 0
 ORDER BY ewsgben.sum_timer_wait DESC;

/*
 * View: io_global_by_wait_by_latency_raw
 *
 * Show the top global IO consumers by latency
 *
 * mysql> select * from io_global_by_wait_by_latency_raw;
 * +--------------------+------------+---------------+-------------+-------------+-------------+------------+------------+-----------+-------------+---------------+-------------+
 * | event_name         | count_star | total_latency | min_latency | avg_latency | max_latency | count_read | total_read | avg_read  | count_write | total_written | avg_written |
 * +--------------------+------------+---------------+-------------+-------------+-------------+------------+------------+-----------+-------------+---------------+-------------+
 * | sql/dbopt          |     328812 | 26.93 s       | 2.06 µs     | 81.90 µs    | 178.71 ms   |          0 | 0 bytes    | 0 bytes   |           9 | 585 bytes     | 65 bytes    |
 * | sql/FRM            |      57837 | 8.39 s        | 19.44 ns    | 145.13 µs   | 336.71 ms   |       8009 | 2.60 MiB   | 341 bytes |       14675 | 2.91 MiB      | 208 bytes   |
 * | sql/binlog         |        190 | 6.79 s        | 1.56 µs     | 35.76 ms    | 4.21 s      |         52 | 60.54 KiB  | 1.16 KiB  |           0 | 0 bytes       | 0 bytes     |
 * | sql/ERRMSG         |          5 | 2.03 s        | 8.61 µs     | 405.40 ms   | 2.03 s      |          3 | 51.82 KiB  | 17.27 KiB |           0 | 0 bytes       | 0 bytes     |
 * | myisam/dfile       |     163681 | 983.13 ms     | 379.08 ns   | 6.01 µs     | 22.06 ms    |      68721 | 127.23 MiB | 1.90 KiB  |     1011613 | 121.45 MiB    | 126 bytes   |
 * | sql/file_parser    |        419 | 601.37 ms     | 1.96 µs     | 1.44 ms     | 37.14 ms    |         66 | 42.01 KiB  | 652 bytes |          64 | 226.98 KiB    | 3.55 KiB    |
 * | myisam/kfile       |       1775 | 375.13 ms     | 1.02 µs     | 211.34 µs   | 35.15 ms    |      54034 | 9.97 MiB   | 193 bytes |      428001 | 12.39 MiB     | 30 bytes    |
 * | sql/global_ddl_log |        164 | 75.96 ms      | 5.72 µs     | 463.19 µs   | 7.43 ms     |         20 | 80.00 KiB  | 4.00 KiB  |          76 | 304.00 KiB    | 4.00 KiB    |
 * | sql/partition      |         81 | 18.87 ms      | 888.08 ns   | 232.92 µs   | 4.67 ms     |         66 | 2.75 KiB   | 43 bytes  |           8 | 288 bytes     | 36 bytes    |
 * | sql/misc           |         23 | 2.73 ms       | 65.14 µs    | 118.50 µs   | 255.31 µs   |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     |
 * | sql/relaylog       |          7 | 1.18 ms       | 838.84 ns   | 168.30 µs   | 892.70 µs   |          0 | 0 bytes    | 0 bytes   |           1 | 120 bytes     | 120 bytes   |
 * | sql/binlog_index   |          5 | 593.47 µs     | 1.07 µs     | 118.69 µs   | 535.90 µs   |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     |
 * | sql/pid            |          3 | 220.55 µs     | 29.29 µs    | 73.52 µs    | 143.11 µs   |          0 | 0 bytes    | 0 bytes   |           1 | 5 bytes       | 5 bytes     |
 * | mysys/charset      |          3 | 196.52 µs     | 17.61 µs    | 65.51 µs    | 137.33 µs   |          1 | 17.83 KiB  | 17.83 KiB |           0 | 0 bytes       | 0 bytes     |
 * | mysys/cnf          |          5 | 171.61 µs     | 303.26 ns   | 34.32 µs    | 115.21 µs   |          3 | 56 bytes   | 19 bytes  |           0 | 0 bytes       | 0 bytes     |
 * | sql/casetest       |          1 | 121.19 µs     | 121.19 µs   | 121.19 µs   | 121.19 µs   |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     |
 * +--------------------+------------+---------------+-------------+-------------+-------------+------------+------------+-----------+-------------+---------------+-------------+
 *
 * (Example from 5.6.6)
 *
 * Versions: 5.5+
 */

DROP VIEW IF EXISTS io_global_by_wait_by_latency_raw;

CREATE SQL SECURITY INVOKER VIEW io_global_by_wait_by_latency_raw AS
SELECT SUBSTRING_INDEX(event_name, '/', -2) event_name,
       ewsgben.count_star,
       ewsgben.sum_timer_wait total_latency,
       ewsgben.min_timer_wait min_latency,
       ewsgben.avg_timer_wait avg_latency,
       ewsgben.max_timer_wait max_latency,
       count_read,
       sum_number_of_bytes_read total_read,
       IFNULL(sum_number_of_bytes_read / count_read, 0) avg_read,
       count_write,
       sum_number_of_bytes_write total_written,
       IFNULL(sum_number_of_bytes_write / count_write, 0) avg_written
  FROM performance_schema.events_waits_summary_global_by_event_name AS ewsgben
  JOIN performance_schema.file_summary_by_event_name AS fsben USING (event_name) 
 WHERE event_name LIKE 'wait/io/file/%'
   AND ewsgben.count_star > 0
 ORDER BY ewsgben.sum_timer_wait DESC;