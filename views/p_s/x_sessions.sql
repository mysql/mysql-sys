-- Copyright (c) 2014, 2015, Oracle and/or its affiliates. All rights reserved.
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; version 2 of the License.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA

--
-- View: x$session
--
-- Filter sys.processlist to only show user sessions and not background threads.
-- This is a non-blocking closer replacement to
-- [INFORMATION_SCHEMA. | SHOW FULL] PROCESSLIST
-- 
-- Performs less locking than the legacy sources, whilst giving extra information.
--
-- mysql> select * from sys.x$session\G
-- *************************** 1. row ***************************
--                 thd_id: 720
--                conn_id: 698
--                   user: msandbox@localhost
--                     db: test
--                command: Query
--                  state: alter table (read PK and internal sort)
--                   time: 2
--      current_statement: alter table t1 add column l int
--      statement_latency: 2349834276374
--               progress: 60.00
--           lock_latency: 339707000000
--          rows_examined: 0
--              rows_sent: 0
--          rows_affected: 0
--             tmp_tables: 0
--        tmp_disk_tables: 0
--              full_scan: NO
--         last_statement: NULL
-- last_statement_latency: NULL
--         current_memory: 10186821
--              last_wait: wait/io/file/innodb/innodb_data_file
--      last_wait_latency: Still Waiting
--                 source: fil0fil.cc:5351
--                    pid: 5559
--           program_name: mysql
--

CREATE OR REPLACE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER 
VIEW x$session
 AS
SELECT * FROM sys.x$processlist
WHERE conn_id IS NOT NULL AND command != 'Daemon';
