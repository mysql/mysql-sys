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
 * View: memory_global_total
 * 
 * Shows the total memory usage within the server globally
 *
 * mysql> select * from memory_global_total;
 * +-----------------+
 * | total_allocated |
 * +-----------------+
 * | 1.35 MiB        |
 * +-----------------+
 * 1 row in set (0.18 sec)
 *
 * Versions: 5.7.2+
 */

DROP VIEW IF EXISTS memory_global_total;

CREATE SQL SECURITY INVOKER VIEW memory_global_total AS
SELECT sys.format_bytes(SUM(CURRENT_NUMBER_OF_BYTES_USED)) total_allocated
  FROM performance_schema.memory_summary_global_by_event_name;

/* 
 * View: memory_global_total_raw
 * 
 * Shows the total memory usage within the server globally
 *
 * mysql> select * from memory_global_total_raw;
 * +-----------------+
 * | total_allocated |
 * +-----------------+
 * |         1420023 |
 * +-----------------+
 * 1 row in set (0.01 sec)
 *
 * Versions: 5.7.2+
 */

DROP VIEW IF EXISTS memory_global_total_raw;

CREATE SQL SECURITY INVOKER VIEW memory_global_total_raw AS
SELECT SUM(CURRENT_NUMBER_OF_BYTES_USED) total_allocated
  FROM performance_schema.memory_summary_global_by_event_name;

