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
 * View: user_summary
 *
 * Summarizes statement activity and connections by user
 *
 * mysql> select * from user_summary;
 * +------+------------------+---------------+-------------+---------------------+-------------------+--------------+----------------+------------------------+
 * | user | total_statements | total_latency | avg_latency | current_connections | total_connections | unique_hosts | current_memory | total_memory_allocated |
 * +------+------------------+---------------+-------------+---------------------+-------------------+--------------+----------------+------------------------+
 * | root |             5663 | 00:01:47.14   | 18.92 ms    |                   1 |                 1 |            1 | 1.41 MiB       | 543.55 MiB             |
 * | mark |              225 | 14.49 s       | 64.40 ms    |                   1 |                 1 |            1 | 707.60 KiB     | 81.02 MiB              |
 * +------+------------------+---------------+-------------+---------------------+-------------------+--------------+----------------+------------------------+
 * 2 rows in set (0.03 sec)
 * 
 * Versions: 5.6.3+
 */

DROP VIEW IF EXISTS user_summary;

CREATE SQL SECURITY INVOKER VIEW user_summary AS
SELECT accounts.user,
       SUM(essbubem.count_star) AS total_statements,
       sys.format_time(SUM(essbubem.sum_timer_wait)) AS total_latency,
       sys.format_time(SUM(essbubem.sum_timer_wait) / SUM(count_star)) AS avg_latency,
       accounts.current_connections,
       accounts.total_connections,
       COUNT(DISTINCT host) AS unique_hosts,
       mem.current_allocated AS current_memory,
       mem.total_allocated AS total_memory_allocated
  FROM performance_schema.accounts
  JOIN performance_schema.events_statements_summary_by_user_by_event_name essbubem ON accounts.user = essbubem.user
  JOIN sys.memory_by_user_by_current_bytes mem ON accounts.user = mem.user
 WHERE accounts.user IS NOT NULL
 GROUP BY accounts.user
 ORDER BY SUM(sum_timer_wait) DESC;

/*
 * View: user_summary_raw
 *
 * Summarizes statement activity and connections by user
 *
 * mysql> select * from user_summary_raw;
 * +------+------------------+-----------------+------------------+---------------------+-------------------+--------------+----------------+------------------------+
 * | user | total_statements | total_latency   | avg_latency      | current_connections | total_connections | unique_hosts | current_memory | total_memory_allocated |
 * +------+------------------+-----------------+------------------+---------------------+-------------------+--------------+----------------+------------------------+
 * | root |             5685 | 107175100271000 | 18852260381.8821 |                   1 |                 1 |            1 |        1459022 |              572855680 |
 * | mark |              225 |  14489223428000 | 64396548568.8889 |                   1 |                 1 |            1 |         724578 |               84958286 |
 * +------+------------------+-----------------+------------------+---------------------+-------------------+--------------+----------------+------------------------+
 * 2 rows in set (0.05 sec)
 * 
 * Versions: 5.6.3+
 */

DROP VIEW IF EXISTS user_summary_raw;

CREATE SQL SECURITY INVOKER VIEW user_summary_raw AS
SELECT accounts.user,
       SUM(essbubem.count_star) AS total_statements,
       SUM(essbubem.sum_timer_wait) AS total_latency,
       SUM(essbubem.sum_timer_wait) / SUM(count_star) AS avg_latency,
       accounts.current_connections,
       accounts.total_connections,
       COUNT(DISTINCT host) AS unique_hosts,
       mem.current_allocated AS current_memory,
       mem.total_allocated AS total_memory_allocated
  FROM performance_schema.accounts
  JOIN performance_schema.events_statements_summary_by_user_by_event_name essbubem ON accounts.user = essbubem.user
  JOIN sys.memory_by_user_by_current_bytes_raw mem ON accounts.user = mem.user
 WHERE accounts.user IS NOT NULL
 GROUP BY accounts.user
 ORDER BY SUM(sum_timer_wait) DESC;
