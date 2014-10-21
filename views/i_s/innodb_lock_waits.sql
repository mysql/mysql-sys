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
 * View: innodb_lock_waits
 *
 * Give a snapshot of which InnoDB locks transactions are waiting for.
 *
 * Versions: 5.1+ (5.1 required InnoDB Plugin with I_S tables)
 *
 * mysql> SELECT * FROM innodb_lock_waits\G
 * *************************** 1. row ***************************
 *      waiting_trx_id: 805505
 *      waiting_thread: 78
 *       waiting_query: UPDATE t1 SET val = 'c2' WHERE id = 3
 *     waiting_lock_id: 805505:132:3:28
 *   waiting_lock_mode: X
 *   waiting_lock_type: RECORD
 *  waiting_lock_table: `db1`.`t1`
 *  waiting_lock_index: PRIMARY
 *     blocking_trx_id: 805504
 *     blocking_thread: 77
 *      blocking_query: UPDATE t1 SET val = CONCAT('c1', SLEEP(10)) WHERE id = 3
 *    blocking_lock_id: 805504:132:3:28
 *  blocking_lock_mode: X
 *  blocking_lock_type: RECORD
 * blocking_lock_table: `db1`.`t1`
 * blocking_lock_index: PRIMARY
 * 1 row in set (0.00 sec)
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER 
VIEW innodb_lock_waits (
  waiting_trx_id,
  waiting_thread,
  waiting_query,
  waiting_lock_id,
  waiting_lock_mode,
  waiting_lock_type,
  waiting_lock_table,
  waiting_lock_index,
  blocking_trx_id,
  blocking_thread,
  blocking_query,
  blocking_lock_id,
  blocking_lock_mode,
  blocking_lock_type,
  blocking_lock_table,
  blocking_lock_index
) AS
SELECT r.trx_id AS waiting_trx_id,
       r.trx_mysql_thread_id AS waiting_thread,
       sys.format_statement(r.trx_query) AS waiting_query,
       rl.lock_id AS waiting_lock_id,
       rl.lock_mode AS waiting_lock_mode,
       rl.lock_type AS waiting_lock_type,
       rl.lock_table AS waiting_lock_table,
       rl.lock_index AS waiting_lock_index,
       b.trx_id AS blocking_trx_id,
       b.trx_mysql_thread_id AS blocking_thread,
       sys.format_statement(b.trx_query) AS blocking_query,
       bl.lock_id AS blocking_lock_id,
       bl.lock_mode AS blocking_lock_mode,
       bl.lock_type AS blocking_lock_type,
       bl.lock_table AS blocking_lock_table,
       bl.lock_index AS blocking_lock_index
  FROM information_schema.INNODB_LOCK_WAITS w
       INNER JOIN information_schema.INNODB_TRX b    ON b.trx_id = w.blocking_trx_id
       INNER JOIN information_schema.INNODB_TRX r    ON r.trx_id = w.requesting_trx_id
       INNER JOIN information_schema.INNODB_LOCKS bl ON bl.lock_id = w.blocking_lock_id
       INNER JOIN information_schema.INNODB_LOCKS rl ON rl.lock_id = w.requested_lock_id;

/*
 * View: x$innodb_lock_waits
 *
 * Give a snapshot of which InnoDB locks transactions are waiting for.
 *
 * Versions: 5.1+ (5.1 required InnoDB Plugin with I_S tables)
 *
 * mysql> SELECT * FROM x$innodb_lock_waits\G
 * *************************** 1. row ***************************
 *      waiting_trx_id: 805505
 *      waiting_thread: 78
 *       waiting_query: UPDATE t1 SET val = 'c2' WHERE id = 3
 *     waiting_lock_id: 805505:132:3:28
 *   waiting_lock_mode: X
 *   waiting_lock_type: RECORD
 *  waiting_lock_table: `db1`.`t1`
 *  waiting_lock_index: PRIMARY
 *     blocking_trx_id: 805504
 *     blocking_thread: 77
 *      blocking_query: UPDATE t1 SET val = CONCAT('c1', SLEEP(10)) WHERE id = 3
 *    blocking_lock_id: 805504:132:3:28
 *  blocking_lock_mode: X
 *  blocking_lock_type: RECORD
 * blocking_lock_table: `db1`.`t1`
 * blocking_lock_index: PRIMARY
 * 1 row in set (0.00 sec)
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER 
VIEW x$innodb_lock_waits (
  waiting_trx_id,
  waiting_thread,
  waiting_query,
  waiting_lock_id,
  waiting_lock_mode,
  waiting_lock_type,
  waiting_lock_table,
  waiting_lock_index,
  blocking_trx_id,
  blocking_thread,
  blocking_query,
  blocking_lock_id,
  blocking_lock_mode,
  blocking_lock_type,
  blocking_lock_table,
  blocking_lock_index
) AS
SELECT r.trx_id AS waiting_trx_id,
       r.trx_mysql_thread_id AS waiting_thread,
       r.trx_query AS waiting_query,
       rl.lock_id AS waiting_lock_id,
       rl.lock_mode AS waiting_lock_mode,
       rl.lock_type AS waiting_lock_type,
       rl.lock_table AS waiting_lock_table,
       rl.lock_index AS waiting_lock_index,
       b.trx_id AS blocking_trx_id,
       b.trx_mysql_thread_id AS blocking_thread,
       b.trx_query AS blocking_query,
       bl.lock_id AS blocking_lock_id,
       bl.lock_mode AS blocking_lock_mode,
       bl.lock_type AS blocking_lock_type,
       bl.lock_table AS blocking_lock_table,
       bl.lock_index AS blocking_lock_index

  FROM information_schema.INNODB_LOCK_WAITS w
       INNER JOIN information_schema.INNODB_TRX b    ON b.trx_id = w.blocking_trx_id
       INNER JOIN information_schema.INNODB_TRX r    ON r.trx_id = w.requesting_trx_id
       INNER JOIN information_schema.INNODB_LOCKS bl ON bl.lock_id = w.blocking_lock_id
       INNER JOIN information_schema.INNODB_LOCKS rl ON rl.lock_id = w.requested_lock_id;
