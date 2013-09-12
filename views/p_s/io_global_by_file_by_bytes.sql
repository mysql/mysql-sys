/*
 * View: io_global_by_file_by_bytes
 *
 * Show the top global IO consumers by bytes usage by file
 *
 * mysql> SELECT * FROM io_global_by_file_by_bytes LIMIT 5;
 * +--------------------------------------------+------------+------------+-----------+-------------+---------------+-----------+------------+-----------+
 * | file                                       | count_read | total_read | avg_read  | count_write | total_written | avg_write | total      | write_pct |
 * +--------------------------------------------+------------+------------+-----------+-------------+---------------+-----------+------------+-----------+
 * | @@datadir/ibdata1                          |        147 | 4.27 MiB   | 29.71 KiB |           3 | 48.00 KiB     | 16.00 KiB | 4.31 MiB   |      1.09 |
 * | @@datadir/mysql/proc.MYD                   |        347 | 85.35 KiB  | 252 bytes |         111 | 19.08 KiB     | 176 bytes | 104.43 KiB |     18.27 |
 * | @@datadir/ib_logfile0                      |          6 | 68.00 KiB  | 11.33 KiB |           8 | 4.00 KiB      | 512 bytes | 72.00 KiB  |      5.56 |
 * | /opt/mysql/5.5.33/share/english/errmsg.sys |          3 | 43.68 KiB  | 14.56 KiB |           0 | 0 bytes       | 0 bytes   | 43.68 KiB  |      0.00 |
 * | /opt/mysql/5.5.33/share/charsets/Index.xml |          1 | 17.89 KiB  | 17.89 KiB |           0 | 0 bytes       | 0 bytes   | 17.89 KiB  |      0.00 |
 * +--------------------------------------------+------------+------------+-----------+-------------+---------------+-----------+------------+-----------+
 * 5 rows in set (0.01 sec) *
 *
 * Versions: 5.5+
 */

DROP VIEW IF EXISTS io_global_by_file_by_bytes;

CREATE SQL SECURITY INVOKER VIEW io_global_by_file_by_bytes AS
SELECT format_path(file_name) AS file, 
       count_read, 
       format_bytes(sum_number_of_bytes_read) AS total_read,
       format_bytes(IFNULL(sum_number_of_bytes_read / count_read, 0)) AS avg_read,
       count_write, 
       format_bytes(sum_number_of_bytes_write) AS total_written,
       format_bytes(IFNULL(sum_number_of_bytes_write / count_write, 0.00)) AS avg_write,
       format_bytes(sum_number_of_bytes_read + sum_number_of_bytes_write) AS total, 
       IFNULL(ROUND(100-((sum_number_of_bytes_read/(sum_number_of_bytes_read+sum_number_of_bytes_write))*100), 2), 0.00) AS write_pct 
  FROM performance_schema.file_summary_by_instance
 ORDER BY sum_number_of_bytes_read + sum_number_of_bytes_write DESC;

/*
 * View: io_global_by_file_by_bytes_raw
 *
 * Show the top global IO consumers by bytes usage by file
 *
 * mysql> SELECT * FROM io_global_by_file_by_bytes_raw LIMIT 5;
 * +------------------------------------------------------+------------+------------+------------+-------------+---------------+------------+---------+-----------+
 * | file                                                 | count_read | total_read | avg_read   | count_write | total_written | avg_write  | total   | write_pct |
 * +------------------------------------------------------+------------+------------+------------+-------------+---------------+------------+---------+-----------+
 * | /Users/mark/sandboxes/msb_5_5_33/data/ibdata1        |        147 |    4472832 | 30427.4286 |           3 |         49152 | 16384.0000 | 4521984 |      1.09 |
 * | /Users/mark/sandboxes/msb_5_5_33/data/mysql/proc.MYD |        347 |      87397 |   251.8646 |         111 |         19536 |   176.0000 |  106933 |     18.27 |
 * | /Users/mark/sandboxes/msb_5_5_33/data/ib_logfile0    |          6 |      69632 | 11605.3333 |           8 |          4096 |   512.0000 |   73728 |      5.56 |
 * | /opt/mysql/5.5.33/share/english/errmsg.sys           |          3 |      44724 | 14908.0000 |           0 |             0 |     0.0000 |   44724 |      0.00 |
 * | /opt/mysql/5.5.33/share/charsets/Index.xml           |          1 |      18317 | 18317.0000 |           0 |             0 |     0.0000 |   18317 |      0.00 |
 * +------------------------------------------------------+------------+------------+------------+-------------+---------------+------------+---------+-----------+
 * 5 rows in set (0.00 sec)
 *
 * Versions: 5.5+
 */

DROP VIEW IF EXISTS io_global_by_file_by_bytes_raw;

CREATE SQL SECURITY INVOKER VIEW io_global_by_file_by_bytes_raw AS
SELECT file_name AS file, 
       count_read, 
       sum_number_of_bytes_read AS total_read,
       IFNULL(sum_number_of_bytes_read / count_read, 0) AS avg_read,
       count_write, 
       sum_number_of_bytes_write AS total_written,
       IFNULL(sum_number_of_bytes_write / count_write, 0.00) AS avg_write,
       sum_number_of_bytes_read + sum_number_of_bytes_write AS total, 
       IFNULL(ROUND(100-((sum_number_of_bytes_read/(sum_number_of_bytes_read+sum_number_of_bytes_write))*100), 2), 0.00) AS write_pct 
  FROM performance_schema.file_summary_by_instance
 ORDER BY sum_number_of_bytes_read + sum_number_of_bytes_write DESC;