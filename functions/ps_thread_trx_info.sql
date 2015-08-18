-- Copyright (c) 2015, Oracle and/or its affiliates. All rights reserved.
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

DROP FUNCTION IF EXISTS ps_thread_trx_info;

DELIMITER $$

CREATE DEFINER='root'@'localhost' FUNCTION ps_thread_trx_info (
        in_thread_id BIGINT UNSIGNED
    ) RETURNS LONGTEXT
    COMMENT '
             Description
             -----------

             Returns a JSON object with info on the given threads current transaction, 
             and the statements it has already exected, derived from the
             performance_schema.events_transactions_current and
             performance_schema.events_statements_history tables (so the consumers 
             for these also have to be enabled within Performance Schema to get full
             data in the object).

             Parameters
             -----------

             in_thread_id (BIGINT UNSIGNED):
               The id of the thread to return the transaction info for.

             Example
             -----------

             SELECT sys.ps_thread_trx_info(48)\G
             *************************** 1. row ***************************
             sys.ps_thread_trx_info(48): [
               {
                 "time": "790.70 us",
                 "state": "COMMITTED",
                 "mode": "READ WRITE",
                 "autocommitted": "NO",
                 "gtid": "AUTOMATIC",
                 "isolation": "REPEATABLE READ",
                 "statements_executed": [
                   {
                     "sql_text": "INSERT INTO info VALUES (1, \'foo\')",
                     "time": "471.02 us",
                     "schema": "trx",
                     "rows_examined": 0,
                     "rows_affected": 1,
                     "rows_sent": 0,
                     "tmp_tables": 0,
                     "tmp_disk_tables": 0,
                     "sort_rows": 0,
                     "sort_merge_passes": 0
                   },
                   {
                     "sql_text": "COMMIT",
                     "time": "254.42 us",
                     "schema": "trx",
                     "rows_examined": 0,
                     "rows_affected": 0,
                     "rows_sent": 0,
                     "tmp_tables": 0,
                     "tmp_disk_tables": 0,
                     "sort_rows": 0,
                     "sort_merge_passes": 0
                   }
                 ]
               },
               {
                 "time": "426.20 us",
                 "state": "COMMITTED",
                 "mode": "READ WRITE",
                 "autocommitted": "NO",
                 "gtid": "AUTOMATIC",
                 "isolation": "REPEATABLE READ",
                 "statements_executed": [
                   {
                     "sql_text": "INSERT INTO info VALUES (2, \'bar\')",
                     "time": "107.33 us",
                     "schema": "trx",
                     "rows_examined": 0,
                     "rows_affected": 1,
                     "rows_sent": 0,
                     "tmp_tables": 0,
                     "tmp_disk_tables": 0,
                     "sort_rows": 0,
                     "sort_merge_passes": 0
                   },
                   {
                     "sql_text": "COMMIT",
                     "time": "213.23 us",
                     "schema": "trx",
                     "rows_examined": 0,
                     "rows_affected": 0,
                     "rows_sent": 0,
                     "tmp_tables": 0,
                     "tmp_disk_tables": 0,
                     "sort_rows": 0,
                     "sort_merge_passes": 0
                   }
                 ]
               }
             ]
             1 row in set (0.03 sec)
            '

    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    READS SQL DATA
BEGIN
    DECLARE v_output TEXT;

    SET @old_ground_concat_max_len = @@session.group_concat_max_len;
    SET SESSION group_concat_max_len = 1000000000;

    SET v_output = (
        SELECT CONCAT('[', IFNULL(GROUP_CONCAT(trx_info ORDER BY event_id), ''), '\n]') AS trx_info
          FROM (SELECT trxi.thread_id, 
                       trxi.event_id,
                       GROUP_CONCAT(
                         IFNULL(
                           CONCAT('\n  {\n',
                                  '    "time": "', IFNULL(sys.format_time(trxi.timer_wait), ''), '",\n',
                                  '    "state": "', IFNULL(trxi.state, ''), '",\n',
                                  '    "mode": "', IFNULL(trxi.access_mode, ''), '",\n',
                                  '    "autocommitted": "', IFNULL(trxi.autocommit, ''), '",\n',
                                  '    "gtid": "', IFNULL(trxi.gtid, ''), '",\n',
                                  '    "isolation": "', IFNULL(trxi.isolation_level, ''), '",\n',
                                  '    "statements_executed": [', IFNULL(s.stmts, ''), IF(s.stmts IS NULL, ' ]\n', '\n    ]\n'),
                                  '  }'
                           ), 
                           '') 
                         ORDER BY event_id) AS trx_info

                  FROM (
                        (SELECT thread_id, event_id, timer_wait, state,access_mode, autocommit, gtid, isolation_level
                           FROM performance_schema.events_transactions_current
                          WHERE thread_id = in_thread_id
                            AND end_event_id IS NULL)
                        UNION
                        (SELECT thread_id, event_id, timer_wait, state,access_mode, autocommit, gtid, isolation_level
                           FROM performance_schema.events_transactions_history
                          WHERE thread_id = in_thread_id)
                       ) AS trxi
                  LEFT JOIN (SELECT thread_id,
                                    nesting_event_id,
                                    GROUP_CONCAT(
                                      IFNULL(
                                        CONCAT('\n      {\n',
                                               '        "sql_text": "', IFNULL(REPLACE(sql_text, '\\', '\\\\'), ''), '",\n',
                                               '        "time": "', IFNULL(sys.format_time(timer_wait), ''), '",\n',
                                               '        "schema": "', IFNULL(current_schema, ''), '",\n',
                                               '        "rows_examined": ', IFNULL(rows_examined, ''), ',\n',
                                               '        "rows_affected": ', IFNULL(rows_affected, ''), ',\n',
                                               '        "rows_sent": ', IFNULL(rows_sent, ''), ',\n',
                                               '        "tmp_tables": ', IFNULL(created_tmp_tables, ''), ',\n',
                                               '        "tmp_disk_tables": ', IFNULL(created_tmp_disk_tables, ''), ',\n',
                                               '        "sort_rows": ', IFNULL(sort_rows, ''), ',\n',
                                               '        "sort_merge_passes": ', IFNULL(sort_merge_passes, ''), '\n',
                                               '      }'), '') ORDER BY event_id) AS stmts
                               FROM performance_schema.events_statements_history
                              WHERE sql_text IS NOT NULL
                                AND thread_id = in_thread_id
                              GROUP BY thread_id, nesting_event_id
                            ) AS s 
                    ON trxi.thread_id = s.thread_id 
                   AND trxi.event_id = s.nesting_event_id
                 WHERE trxi.thread_id = in_thread_id
                 GROUP BY trxi.thread_id, trxi.event_id
                ) trxs
          GROUP BY thread_id
    );

    SET @old_ground_concat_max_len = @@session.group_concat_max_len;
    SET SESSION group_concat_max_len = 1000000000;

    RETURN v_output;
END$$

DELIMITER ;
