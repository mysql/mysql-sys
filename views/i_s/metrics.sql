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
 * +--------------------------------------+-----------------------------------------------+---------+-------------------------+
 * | Type                                 | Variable_name                                 | Enabled | Variable_value          |
 * +--------------------------------------+-----------------------------------------------+---------+-------------------------+
 * | Global Status                        | Aborted_clients                               |       1 | 0                       |
 * | Global Status                        | Aborted_connects                              |       1 | 0                       |
 * | Global Status                        | Binlog_cache_disk_use                         |       1 | 0                       |
 * | Global Status                        | Binlog_cache_use                              |       1 | 0                       |
 * | Global Status                        | Binlog_stmt_cache_disk_use                    |       1 | 0                       |
 * | Global Status                        | Binlog_stmt_cache_use                         |       1 | 2                       |
 * | Global Status                        | Bytes_received                                |       1 | 9350                    |
 * | Global Status                        | Bytes_sent                                    |       1 | 320264                  |
 * ...
 * | InnoDB Metrics - server              | Innodb_rwlock_x_os_waits                      |       1 | 0                       |
 * | InnoDB Metrics - server              | Innodb_rwlock_x_spin_rounds                   |       1 | 18511                   |
 * | InnoDB Metrics - server              | Innodb_rwlock_x_spin_waits                    |       1 | 0                       |
 * | InnoDB Metrics - transaction         | Trx_rseg_history_len                          |       1 | 8                       |
 * | System Time                          | NOW()                                         |       1 | 2014-12-08 15:17:34.482 |
 * | System Time                          | UNIX_TIMESTAMP()                              |       1 | 1418012254.482          |
 * +--------------------------------------+-----------------------------------------------+---------+-------------------------+
 * 420 rows in set (0.05 sec)
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER 
VIEW metrics (
  Type,
  Variable_name,
  Enabled,
  Variable_value
) AS
(
SELECT 'Global Status' AS Type, sys.ucfirst(VARIABLE_NAME) AS Variable_name, TRUE AS Enabled, VARIABLE_VALUE AS Variable_value
  FROM information_schema.GLOBAL_STATUS
) UNION ALL (
SELECT CONCAT('InnoDB Metrics - ', SUBSYSTEM) AS Type, sys.ucfirst(NAME) AS Variable_name,
       IF(TIME_ENABLED > TIME_DISABLED OR (TIME_ENABLED IS NOT NULL AND TIME_DISABLED IS NULL), TRUE, FALSE) AS Enabled, COUNT AS Variable_value
  FROM information_schema.INNODB_METRICS
) UNION ALL (
SELECT 'System Time' AS Type, 'NOW()' AS Variable_name, TRUE AS Enabled, NOW(3) AS Variable_value
) UNION ALL (
SELECT 'System Time' AS Type, 'UNIX_TIMESTAMP()' AS Variable_name, TRUE AS Enabled, ROUND(UNIX_TIMESTAMP(NOW(3)), 3) AS Variable_value
)
 ORDER BY Type, Variable_name;
