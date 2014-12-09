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
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA */

/* 
 * View: metrics
 * 
 * Creates a union of the two Information Schema views GLOBAL_STATUS and INNODB_METRICS
 *
 * 
 * mysql> SELECT * FROM sys.metrics WHERE Enabled;
 * SELECT * FROM sys.metrics WHERE Enabled;
 * +-----------------------------------------------+-------------------------+--------------------------------------+---------+
 * | Variable_name                                 | Variable_value          | Type                                 | Enabled |
 * +-----------------------------------------------+-------------------------+--------------------------------------+---------+
 * | Aborted_clients                               | 0                       | Global Status                        |       1 |
 * | Aborted_connects                              | 0                       | Global Status                        |       1 |
 * | Binlog_cache_disk_use                         | 0                       | Global Status                        |       1 |
 * | Binlog_cache_use                              | 1                       | Global Status                        |       1 |
 * | Binlog_stmt_cache_disk_use                    | 0                       | Global Status                        |       1 |
 * | Binlog_stmt_cache_use                         | 17                      | Global Status                        |       1 |
 * | Bytes_received                                | 2303731                 | Global Status                        |       1 |
 * | Bytes_sent                                    | 371026                  | Global Status                        |       1 |
 * ...
 * | Innodb_rwlock_x_os_waits                      | 0                       | InnoDB Metrics - server              |       1 |
 * | Innodb_rwlock_x_spin_rounds                   | 34247                   | InnoDB Metrics - server              |       1 |
 * | Innodb_rwlock_x_spin_waits                    | 0                       | InnoDB Metrics - server              |       1 |
 * | Trx_rseg_history_len                          | 2535                    | InnoDB Metrics - transaction         |       1 |
 * | NOW()                                         | 2014-12-09 11:23:06.838 | System Time                          |       1 |
 * | UNIX_TIMESTAMP()                              | 1418084586.838          | System Time                          |       1 |
 * +-----------------------------------------------+-------------------------+--------------------------------------+---------+
 * 420 rows in set (0.05 sec)
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER 
VIEW metrics (
  Variable_name,
  Variable_value,
  Type,
  Enabled
) AS
(
SELECT sys.ucfirst(VARIABLE_NAME) AS Variable_name, VARIABLE_VALUE AS Variable_value, 'Global Status' AS Type, TRUE AS Enabled
  FROM information_schema.GLOBAL_STATUS
) UNION ALL (
SELECT sys.ucfirst(NAME) AS Variable_name, COUNT AS Variable_value,
       CONCAT('InnoDB Metrics - ', SUBSYSTEM) AS Type,
       IF(TIME_ENABLED > TIME_DISABLED OR (TIME_ENABLED IS NOT NULL AND TIME_DISABLED IS NULL), TRUE, FALSE) AS Enabled
  FROM information_schema.INNODB_METRICS
) UNION ALL (
SELECT 'NOW()' AS Variable_name, NOW(3) AS Variable_value, 'System Time' AS Type, TRUE AS Enabled
) UNION ALL (
SELECT 'UNIX_TIMESTAMP()' AS Variable_name, ROUND(UNIX_TIMESTAMP(NOW(3)), 3) AS Variable_value, 'System Time' AS Type, TRUE AS Enabled
)
 ORDER BY Type, Variable_name;
