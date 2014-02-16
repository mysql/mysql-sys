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
 * View: innodb_buffer_stats_by_schema
 * 
 * Summarizes the output of the INFORMATION_SCHEMA.INNODB_BUFFER_PAGE 
 * table, aggregating by schema
 *
 * mysql> SELECT * FROM innodb_buffer_stats_by_schema;
 * +---------------+------------+------------+-------+--------------+-----------+-------------+
 * | object_schema | allocated  | data       | pages | pages_hashed | pages_old | rows_cached |
 * +---------------+------------+------------+-------+--------------+-----------+-------------+
 * | common_schema | 1.06 MiB   | 529.29 KiB |    68 |           68 |        68 |         697 |
 * | InnoDB System | 144.00 KiB | 15.67 KiB  |     9 |            9 |         9 |          43 |
 * | mysql         | 80.00 KiB  | 9.01 KiB   |     5 |            5 |         5 |          83 |
 * +---------------+------------+------------+-------+--------------+-----------+-------------+
 * 3 rows in set (0.08 sec)
 *
 * Versions: 5.5.28+
 */

/*!50528 DROP VIEW IF EXISTS innodb_buffer_stats_by_schema */;

/*!50528 
CREATE SQL SECURITY INVOKER VIEW innodb_buffer_stats_by_schema AS
SELECT IF(LOCATE('.', ibp.table_name) = 0, 'InnoDB System', REPLACE(SUBSTRING_INDEX(ibp.table_name, '.', 1), '`', '')) AS object_schema,
       sys.format_bytes(SUM(IF(ibp.compressed_size = 0, 16384, compressed_size))) AS allocated,
       sys.format_bytes(SUM(ibp.data_size)) AS data,
       COUNT(ibp.page_number) AS pages,
       COUNT(IF(ibp.is_hashed = 'YES', 1, 0)) AS pages_hashed,
       COUNT(IF(ibp.is_old = 'YES', 1, 0)) AS pages_old,
       ROUND(SUM(ibp.number_records)/COUNT(DISTINCT ibp.index_name)) AS rows_cached 
  FROM information_schema.innodb_buffer_page ibp 
 WHERE table_name IS NOT NULL
 GROUP BY object_schema
 ORDER BY SUM(IF(ibp.compressed_size = 0, 16384, compressed_size)) DESC */;

/* 
 * View: innodb_buffer_stats_by_schema_raw
 * 
 * Summarizes the output of the INFORMATION_SCHEMA.INNODB_BUFFER_PAGE 
 * table, aggregating by schema
 *
 * mysql> SELECT * FROM innodb_buffer_stats_by_schema_raw;
 * +---------------+-----------+--------+-------+--------------+-----------+-------------+
 * | object_schema | allocated | data   | pages | pages_hashed | pages_old | rows_cached |
 * +---------------+-----------+--------+-------+--------------+-----------+-------------+
 * | common_schema |   1114112 | 541996 |    68 |           68 |        68 |         697 |
 * | InnoDB System |    147456 |  16047 |     9 |            9 |         9 |          43 |
 * | mysql         |     81920 |   9224 |     5 |            5 |         5 |          83 |
 * +---------------+-----------+--------+-------+--------------+-----------+-------------+
 * 3 rows in set (0.10 sec)
 *
 * Versions: 5.5.28+
 */

/*!50528 DROP VIEW IF EXISTS innodb_buffer_stats_by_schema_raw */;

/*!50528 
CREATE SQL SECURITY INVOKER VIEW innodb_buffer_stats_by_schema_raw AS
SELECT IF(LOCATE('.', ibp.table_name) = 0, 'InnoDB System', REPLACE(SUBSTRING_INDEX(ibp.table_name, '.', 1), '`', '')) AS object_schema,
       SUM(IF(ibp.compressed_size = 0, 16384, compressed_size)) AS allocated,
       SUM(ibp.data_size) AS data,
       COUNT(ibp.page_number) AS pages,
       COUNT(IF(ibp.is_hashed = 'YES', 1, 0)) AS pages_hashed,
       COUNT(IF(ibp.is_old = 'YES', 1, 0)) AS pages_old,
       ROUND(SUM(ibp.number_records)/COUNT(DISTINCT ibp.index_name)) AS rows_cached 
  FROM information_schema.innodb_buffer_page ibp 
 WHERE table_name IS NOT NULL
 GROUP BY object_schema
 ORDER BY SUM(IF(ibp.compressed_size = 0, 16384, compressed_size)) DESC */;