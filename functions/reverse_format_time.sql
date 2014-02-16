/* Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; version 2 of the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA */

/*
 * Function: reverse_format_time()
 * 
 * Takes a value from the format_time() function, and reverses it 
 * to raw values. 
 *
 * This is useful for cases where you want to use a view that exposes
 * formatted values, but would like to ORDER BY some other column within
 * the result set. 
 * 
 * NOTE: However, this does mean that some precision may be lost from 
 *       the original values, as when we convert using format_time we
 *       ROUND to two decimal places
 *
 * Parameters
 *   time_string: The value that is formatted by the format_time() function
 *
 * Example to show precision lost:
 * 
 * mysql> SELECT event_name AS event,
 *     ->        format_time(sum_timer_wait) AS total_latency,
 *     ->        reverse_format_time(format_time(sum_timer_wait)) AS reverse_format,
 *     ->        sum_timer_wait
 *     ->   FROM performance_schema.events_waits_summary_global_by_event_name
 *     ->  WHERE event_name != 'idle'
 *     ->  ORDER BY sum_timer_wait DESC LIMIT 5;
 * +--------------------------------------+---------------+----------------+----------------+
 * | event                                | total_latency | reverse_format | sum_timer_wait |
 * +--------------------------------------+---------------+----------------+----------------+
 * | wait/io/file/sql/file_parser         | 7.97 s        |  8000000000000 |  7974907810740 |
 * | wait/io/file/innodb/innodb_data_file | 848.17 ms     |   848000000000 |   848170566100 |
 * | wait/io/file/sql/FRM                 | 501.60 ms     |   502000000000 |   501604256790 |
 * | wait/io/file/innodb/innodb_log_file  | 54.30 ms      |    54000000000 |    54298899070 |
 * | wait/io/file/myisam/kfile            | 32.51 ms      |    33000000000 |    32512834380 |
 * +--------------------------------------+---------------+----------------+----------------+
 * 5 rows in set (0.01 sec)
 *
 * Example to show use against a sys view:
 *
 * mysql> SELECT event_name, total_latency, avg_latency FROM top_global_io_consumers_by_latency;
 * +-------------------------+---------------+-------------+
 * | event_name              | total_latency | avg_latency |
 * +-------------------------+---------------+-------------+
 * | sql/file_parser         | 7.97 s        | 5.70 ms     |
 * | innodb/innodb_data_file | 848.17 ms     | 4.35 ms     |
 * | sql/FRM                 | 502.21 ms     | 275.49 us   |
 * | innodb/innodb_log_file  | 54.30 ms      | 2.71 ms     |
 * ...
 * | archive/data            | 9.73 us       | 9.73 us     |
 * +-------------------------+---------------+-------------+
 * 15 rows in set (0.01 sec)
 * 
 * mysql> SELECT event_name, total_latency, avg_latency FROM top_global_io_consumers_by_latency
 *     ->  ORDER BY reverse_format_time(avg_latency) DESC;
 * +-------------------------+---------------+-------------+
 * | event_name              | total_latency | avg_latency |
 * +-------------------------+---------------+-------------+
 * | mysys/charset           | 24.24 ms      | 8.08 ms     |
 * | sql/file_parser         | 7.97 s        | 5.70 ms     |
 * | innodb/innodb_data_file | 848.17 ms     | 4.35 ms     |
 * | sql/ERRMSG              | 20.43 ms      | 4.09 ms     |
 * ...
 * | sql/global_ddl_log      | 14.60 us      | 7.30 us     |
 * +-------------------------+---------------+-------------+
 * 15 rows in set (0.01 sec)
 */

DROP FUNCTION IF EXISTS reverse_format_time;

DELIMITER $$

CREATE FUNCTION reverse_format_time(time_string VARCHAR(32))
  RETURNS BIGINT
  DETERMINISTIC
BEGIN
  IF time_string IS NULL THEN RETURN NULL;
  ELSEIF time_string LIKE '% ps' THEN RETURN CAST(LEFT(time_string, LENGTH(time_string) - 3) AS DECIMAL);
  ELSEIF time_string LIKE '% ns' THEN RETURN CAST(LEFT(time_string, LENGTH(time_string) - 3) AS DECIMAL) * 1000;
  ELSEIF time_string LIKE '% us' THEN RETURN CAST(LEFT(time_string, LENGTH(time_string) - 3) AS DECIMAL) * 1000000;
  ELSEIF time_string LIKE '% ms' THEN RETURN CAST(LEFT(time_string, LENGTH(time_string) - 3) AS DECIMAL) * 1000000000;
  ELSEIF time_string LIKE '% s' THEN RETURN CAST(LEFT(time_string, LENGTH(time_string) - 2) AS DECIMAL) * 1000000000000;
  ELSEIF time_string LIKE '% h' THEN RETURN CAST(LEFT(time_string, LENGTH(time_string) - 2) AS DECIMAL) * 3600000000000000;
  ELSE RETURN TIME_TO_SEC(time_string) * 1000000000000;
  END IF;
END $$

DELIMITER ;
