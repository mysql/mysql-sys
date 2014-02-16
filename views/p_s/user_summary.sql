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
 * +------+------------------+---------------+-------------+---------------------+-------------------+
 * | user | total_statements | total_latency | avg_latency | current_connections | total_connections |
 * +------+------------------+---------------+-------------+---------------------+-------------------+
 * | root |             1967 | 00:03:35.99   | 109.81 ms   |                   2 |                 7 |
 * +------+------------------+---------------+-------------+---------------------+-------------------+
 * 1 row in set (0.00 sec)
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
       COUNT(DISTINCT host) AS unique_hosts
  FROM performance_schema.accounts
  JOIN performance_schema.events_statements_summary_by_user_by_event_name essbubem USING (user)
 WHERE user IS NOT NULL
 GROUP BY user
 ORDER BY SUM(sum_timer_wait) DESC;

/*
 * View: user_summary_raw
 *
 * Summarizes statement activity and connections by user
 *
 * mysql> select * from user_summary_raw;
 * +------+------------------+-----------------+-------------------+---------------------+-------------------+--------------+
 * | user | total_statements | total_latency   | avg_latency       | current_connections | total_connections | unique_hosts |
 * +------+------------------+-----------------+-------------------+---------------------+-------------------+--------------+
 * | root |             2110 | 223924839893000 | 106125516536.9668 |                   2 |                 7 |            1 |
 * +------+------------------+-----------------+-------------------+---------------------+-------------------+--------------+
 * 1 row in set (0.00 sec)
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
       COUNT(DISTINCT host) AS unique_hosts
  FROM performance_schema.accounts
  JOIN performance_schema.events_statements_summary_by_user_by_event_name essbubem USING (user)
 WHERE user IS NOT NULL
 GROUP BY user
 ORDER BY SUM(sum_timer_wait) DESC;
