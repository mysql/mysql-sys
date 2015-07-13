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
-- mysql> select * from sessions\G
-- ...
-- *************************** 8. row ***************************
--                 thd_id: 31
--                conn_id: 12
--                   user: root@localhost
--                     db: information_schema
--                command: Query
--                  state: Sending data
--                   time: 0
--      current_statement: select * from processlist limit 5
--           lock_latency: 684.00 us
--          rows_examined: 0
--              rows_sent: 0
--          rows_affected: 0
--             tmp_tables: 2
--        tmp_disk_tables: 0
--              full_scan: YES
--         current_memory: 1.29 MiB
--         last_statement: NULL
-- last_statement_latency: NULL
--              last_wait: wait/synch/mutex/sql/THD::LOCK_query_plan
--      last_wait_latency: 260.13 ns
--                 source: sql_optimizer.cc:1075
--
 
CREATE OR REPLACE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER 
VIEW sessions
 AS
SELECT * FROM sys.processlist
WHERE conn_id IS NOT NULL AND command != 'Daemon';

