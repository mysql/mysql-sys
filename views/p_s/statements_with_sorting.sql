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
 * View: statements_with_sorting
 *
 * List all normalized statements that have done sorts,
 * ordered by sort_merge_passes, sort_scans and sort_rows, all descending
 *
 * mysql> select * from statements_with_sorting limit 5;
 * +-------------------------------------------------------------------+-------+------------+-------------------+-----------------+-------------------+------------------+-------------+-----------------+---------------------+---------------------+----------------------------------+
 * | query                                                             | db    | exec_count | sort_merge_passes | avg_sort_merges | sorts_using_scans | sort_using_range | rows_sorted | avg_rows_sorted | first_seen          | last_seen           | digest                           |
 * +-------------------------------------------------------------------+-------+------------+-------------------+-----------------+-------------------+------------------+-------------+-----------------+---------------------+---------------------+----------------------------------+
 * | SELECT `s` . `identityId` , `s ...  `subject_id` = `s` . `id` ... | mem   |        179 |               179 |               1 |               179 |              179 |        9182 |              51 | 2013-12-04 20:05:16 | 2013-12-14 13:55:55 | e53695702a907c795766dfe4d0142bab |
 * | SELECT `cpuaverage0_` . `os` A ...  `cpuaverage0_` . `timestamp`  | mem   |          2 |                 2 |               1 |                 0 |                2 |          59 |              30 | 2013-12-04 21:08:39 | 2013-12-11 11:34:34 | e44686700b83b5b8f928773a6c4ef994 |
 * | SELECT `connection0_` . `targe ...  `connection0_` . `timestamp`  | mem   |          2 |                 2 |               1 |                 0 |                2 |          58 |              29 | 2013-12-04 21:08:39 | 2013-12-11 11:34:34 | b01a0a611acd1a5d220d7f4b7ac3e709 |
 * | SELECT `mysqlconne0_` . `mysql ...  `mysqlconne0_` . `timestamp`  | mem   |          2 |                 2 |               1 |                 0 |                2 |          58 |              29 | 2013-12-04 21:08:39 | 2013-12-11 11:34:34 | a8fc99f84a78059e8453d681ea7a75fa |
 * | SELECT `plugin_name` FROM `inf ... s` = ? ORDER BY `plugin_name`  | mysql |      24129 |                 0 |               0 |             24129 |                0 |      699741 |              29 | 2013-12-04 20:04:53 | 2013-12-18 19:10:34 | d5163a2f55578fd8e2077b8a3c00b081 |
 * +-------------------------------------------------------------------+-------+------------+-------------------+-----------------+-------------------+------------------+-------------+-----------------+---------------------+---------------------+----------------------------------+
 * 5 rows in set (0.02 sec)
 * 
 * Versions 5.6.9+
 *
 */

DROP VIEW IF EXISTS statements_with_sorting;

CREATE SQL SECURITY INVOKER VIEW statements_with_sorting AS
SELECT sys.format_statement(DIGEST_TEXT) AS query,
       SCHEMA_NAME db,
       COUNT_STAR AS exec_count,
       SUM_SORT_MERGE_PASSES AS sort_merge_passes,
       ROUND(SUM_SORT_MERGE_PASSES / COUNT_STAR) AS avg_sort_merges,
       SUM_SORT_SCAN AS sorts_using_scans,
       SUM_SORT_RANGE AS sort_using_range,
       SUM_SORT_ROWS AS rows_sorted,
       ROUND(SUM_SORT_ROWS / COUNT_STAR) AS avg_rows_sorted,
       FIRST_SEEN as first_seen,
       LAST_SEEN as last_seen,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
 WHERE SUM_SORT_ROWS > 0
 ORDER BY SUM_SORT_MERGE_PASSES DESC, SUM_SORT_SCAN DESC, SUM_SORT_ROWS DESC;
