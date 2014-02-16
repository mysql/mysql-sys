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
 * View: statements_with_full_table_scans
 *
 * Lists all normalized statements that use have done a full table scan
 * ordered by number the percentage of times a full scan was done,
 * then by the number of times the statement executed
 *
 * mysql> select * from statements_with_full_table_scans limit 5;
 * +-------------------------------------------------------------------+-------+------------+---------------------+--------------------------+-------------------+-----------+---------------+---------------+-------------------+---------------------+---------------------+----------------------------------+
 * | query                                                             | db    | exec_count | no_index_used_count | no_good_index_used_count | no_index_used_pct | rows_sent | rows_examined | rows_sent_avg | rows_examined_avg | first_seen          | last_seen           | digest                           |
 * +-------------------------------------------------------------------+-------+------------+---------------------+--------------------------+-------------------+-----------+---------------+---------------+-------------------+---------------------+---------------------+----------------------------------+
 * | SELECT `InterfaceAddress4` . ` ... . `hid` WHERE `Os` . `id` = ?  | mem   |     355189 |              355277 |                        0 |               100 |    404862 |       4987778 |             1 |                14 | 2013-12-04 20:04:54 | 2013-12-18 18:54:34 | 42d79211cc5e82e32e00340bc6a50b14 |
 * | SELECT COUNT ( * ) FROM `INFOR ... NE = ? AND `SUPPORT` IN (...)  | mysql |     172765 |              172776 |                        0 |               100 |    172773 |       1554966 |             1 |                 9 | 2013-12-04 20:04:52 | 2013-12-18 18:54:34 | 491ee7143ca1d98f36c24d7eb6d25272 |
 * | SELECT CAST ( `SUM_NUMBER_OF_B ... HERE `EVENT_NAME` = ? LIMIT ?  | mysql |     100455 |              100455 |                        0 |               100 |    100455 |       3094014 |             1 |                31 | 2013-12-04 20:04:52 | 2013-12-18 18:54:34 | b5a370d80095c69a2085547e3a24f552 |
 * | SELECT COUNT ( * ) FROM `INFOR ... CHEMA` = ? AND TABLE_NAME = ?  | mysql |      80360 |               80360 |                        0 |               100 |     80360 |             0 |             1 |                 0 | 2013-12-04 20:05:37 | 2013-12-18 18:54:34 | 6567aa2ac8ad7fe7831b4114dee7c849 |
 * | SELECT DISTINCTROW `mysqlconne ... conne0_` . `socketPath` AS ... | mem   |      67832 |               67821 |                        0 |               100 |        92 |        406943 |             0 |                 6 | 2013-12-04 20:04:54 | 2013-12-18 18:54:34 | fc358ad6384cc77adff425602a0a8fc1 |
 * +-------------------------------------------------------------------+-------+------------+---------------------+--------------------------+-------------------+-----------+---------------+---------------+-------------------+---------------------+---------------------+----------------------------------+
 * 5 rows in set (0.02 sec)
 * 
 * (Example from 5.6.14)
 *
 * Versions: 5.6.9+
 *
 */

DROP VIEW IF EXISTS statements_with_full_table_scans;

CREATE SQL SECURITY INVOKER VIEW statements_with_full_table_scans AS
SELECT sys.format_statement(DIGEST_TEXT) AS query,
       SCHEMA_NAME as db,
       COUNT_STAR AS exec_count,
       SUM_NO_INDEX_USED AS no_index_used_count,
       SUM_NO_GOOD_INDEX_USED AS no_good_index_used_count,
       ROUND((SUM_NO_INDEX_USED / COUNT_STAR) * 100) AS no_index_used_pct,
       SUM_ROWS_SENT AS rows_sent,
       SUM_ROWS_EXAMINED AS rows_examined,
       ROUND(SUM_ROWS_SENT/COUNT_STAR) AS rows_sent_avg,
       ROUND(SUM_ROWS_EXAMINED/COUNT_STAR) AS rows_examined_avg,
       FIRST_SEEN as first_seen,
       LAST_SEEN as last_seen,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
 WHERE SUM_NO_INDEX_USED > 0
    OR SUM_NO_GOOD_INDEX_USED > 0
ORDER BY no_index_used_pct DESC, exec_count DESC;
