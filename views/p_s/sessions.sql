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
-- View: sessions
--
-- Filter sys.processlist to only show user sessions and not background threads.
-- This is a non-blocking closer replacement to
-- [INFORMATION_SCHEMA. | SHOW FULL] PROCESSLIST
-- 
-- Performs less locking than the legacy sources, whilst giving extra information.
--
-- mysql> select * from sys.sessions\G
-- *************************** 1. row ***************************
--                 thd_id: 44524
--                conn_id: 44502
--                   user: msandbox@localhost
--                     db: test
--                command: Query
--                  state: alter table (flush)
--                   time: 18
--      current_statement: alter table t1 add column g int
--      statement_latency: 18.45 s
--               progress: 98.84
--           lock_latency: 265.43 ms
--          rows_examined: 0
--              rows_sent: 0
--          rows_affected: 0
--             tmp_tables: 0
--        tmp_disk_tables: 0
--              full_scan: NO
--         last_statement: NULL
-- last_statement_latency: NULL
--         current_memory: 664.06 KiB
--              last_wait: wait/io/file/innodb/innodb_data_file
--      last_wait_latency: 1.07 us
--                 source: fil0fil.cc:5146
--                    pid: 4212
--           program_name: mysql
--

CREATE OR REPLACE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER 
VIEW sessions
 AS
SELECT * FROM sys.processlist
WHERE conn_id IS NOT NULL AND command != 'Daemon';

