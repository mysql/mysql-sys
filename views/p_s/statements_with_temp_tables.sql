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
 * View: statements_with_temp_tables
 *
 * Lists all normalized statements that use temporary tables
 * ordered by number of on disk temporary tables descending first, 
 * then by the number of memory tables
 *
 * mysql> select * from statements_with_temp_tables limit 5;
 * +-------------------------------------------------------------------+-------+------------+-------------------+-----------------+--------------------------+------------------------+---------------------+---------------------+----------------------------------+
 * | query                                                             | db    | exec_count | memory_tmp_tables | disk_tmp_tables | avg_tmp_tables_per_query | tmp_tables_to_disk_pct | first_seen          | last_seen           | digest                           |
 * +-------------------------------------------------------------------+-------+------------+-------------------+-----------------+--------------------------+------------------------+---------------------+---------------------+----------------------------------+
 * | SELECT DISTINCTROW `agent0_` . ... gent` `agent0_` INNER JOIN ... | mem   |    1423339 |           1242409 |         1242393 |                        1 |                    100 | 2013-12-04 20:04:48 | 2013-12-18 19:16:48 | fa4b07b4cf70914c1119ec444684dfec |
 * | SELECT DISTINCTROW `mysqlconne ... conne0_` . `socketPath` AS ... | mem   |      67908 |             67898 |           67898 |                        1 |                    100 | 2013-12-04 20:04:54 | 2013-12-18 19:16:34 | fc358ad6384cc77adff425602a0a8fc1 |
 * | SELECT * FROM ( SELECT `digest ... ` , `sum_no_index_used` AS ... | mysql |      20113 |            140791 |           60339 |                        7 |                     43 | 2013-12-04 20:04:54 | 2013-12-18 19:16:34 | 50761c6a1818824328745d8a136b9ed6 |
 * | SELECT COUNT ( * ) FROM `INFOR ... GINS` WHERE `PLUGIN_NAME` = ?  | mysql |      44248 |             44248 |           44248 |                        1 |                    100 | 2013-12-04 20:04:52 | 2013-12-18 19:16:34 | 090f173ed2c6c8c9b8dc60718703ff56 |
 * | SELECT `plugin_name` FROM `inf ... s` = ? ORDER BY `plugin_name`  | mysql |      24136 |             24136 |           24136 |                        1 |                    100 | 2013-12-04 20:04:53 | 2013-12-18 19:16:34 | d5163a2f55578fd8e2077b8a3c00b081 |
 * +-------------------------------------------------------------------+-------+------------+-------------------+-----------------+--------------------------+------------------------+---------------------+---------------------+----------------------------------+
 * 5 rows in set (0.02 sec)
 * 
 * (Example from 5.6.14)
 *
 * Versions: 5.6.9+
 *
 */

DROP VIEW IF EXISTS statements_with_temp_tables;

CREATE SQL SECURITY INVOKER VIEW statements_with_temp_tables AS
SELECT sys.format_statement(DIGEST_TEXT) AS query,
       SCHEMA_NAME as db,
       COUNT_STAR AS exec_count,
       SUM_CREATED_TMP_TABLES AS memory_tmp_tables,
       SUM_CREATED_TMP_DISK_TABLES AS disk_tmp_tables,
       ROUND(SUM_CREATED_TMP_TABLES / COUNT_STAR) AS avg_tmp_tables_per_query,
       ROUND((SUM_CREATED_TMP_DISK_TABLES / SUM_CREATED_TMP_TABLES) * 100) AS tmp_tables_to_disk_pct,
       FIRST_SEEN as first_seen,
       LAST_SEEN as last_seen,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
 WHERE SUM_CREATED_TMP_TABLES > 0
ORDER BY SUM_CREATED_TMP_DISK_TABLES DESC, SUM_CREATED_TMP_TABLES DESC;
