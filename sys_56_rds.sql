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

SET NAMES utf8;

CREATE DATABASE IF NOT EXISTS sys DEFAULT CHARACTER SET utf8;

USE sys;

CREATE OR REPLACE VIEW version AS SELECT '1.0.1' AS sys_version, version() AS mysql_version;
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

DROP FUNCTION IF EXISTS extract_schema_from_file_name;

DELIMITER $$

CREATE DEFINER=CURRENT_USER FUNCTION extract_schema_from_file_name (
        path VARCHAR(512)
    )
    RETURNS VARCHAR(512) 
    COMMENT '
             Description
             -----------

             Takes a raw file path, and attempts to extract the schema name from it.

             Useful for when interacting with Performance Schema data 
             concerning IO statistics, for example.

             Currently relies on the fact that a table data file will be within a 
             specified database directory (will not work with partitions or tables
             that specify an individual DATA_DIRECTORY).

             Parameters
             -----------

             path (VARCHAR(512)):
               The full file path to a data file to extract the schema name from.

             Returns
             -----------

             VARCHAR(512)

             Example
             -----------

             mysql> SELECT sys.extract_schema_from_file_name(\'/var/lib/mysql/employees/employee.ibd\');
             +----------------------------------------------------------------------------+
             | sys.extract_schema_from_file_name(\'/var/lib/mysql/employees/employee.ibd\') |
             +----------------------------------------------------------------------------+
             | employees                                                                  |
             +----------------------------------------------------------------------------+
             1 row in set (0.00 sec)
            '
    SQL SECURITY INVOKER
    DETERMINISTIC
    NO SQL
    RETURN SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(path, '\\', '/'), '/', -2), '/', 1)
$$

DELIMITER ;
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

DROP FUNCTION IF EXISTS extract_table_from_file_name;

DELIMITER $$

CREATE DEFINER=CURRENT_USER FUNCTION extract_table_from_file_name (
        path VARCHAR(512)
    )
    RETURNS VARCHAR(512) 
    COMMENT '
             Description
             -----------

             Takes a raw file path, and extracts the table name from it.

             Useful for when interacting with Performance Schema data 
             concerning IO statistics, for example.

             Parameters
             -----------

             path (VARCHAR(512)):
               The full file path to a data file to extract the table name from.

             Returns
             -----------

             VARCHAR(512)

             Example
             -----------

             mysql> SELECT sys.extract_table_from_file_name(\'/var/lib/mysql/employees/employee.ibd\');
             +---------------------------------------------------------------------------+
             | sys.extract_table_from_file_name(\'/var/lib/mysql/employees/employee.ibd\') |
             +---------------------------------------------------------------------------+
             | employee                                                                  |
             +---------------------------------------------------------------------------+
             1 row in set (0.02 sec)
            '
    SQL SECURITY INVOKER
    DETERMINISTIC
    NO SQL
    RETURN SUBSTRING_INDEX(REPLACE(SUBSTRING_INDEX(REPLACE(path, '\\', '/'), '/', -1), '@0024', '$'), '.', 1);
$$

DELIMITER ;
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

DROP FUNCTION IF EXISTS format_bytes;

DELIMITER $$

CREATE DEFINER=CURRENT_USER FUNCTION format_bytes (
        bytes BIGINT
    )
    RETURNS VARCHAR(16)
    COMMENT '
             Description
             -----------

             Takes a raw bytes value, and converts it to a human readable format.

             Parameters
             -----------

             bytes (BIGINT):
               A raw bytes value.

             Returns
             -----------

             VARCHAR(16)

             Example
             -----------

             mysql> SELECT sys.format_bytes(2348723492723746) AS size;
             +----------+
             | size     |
             +----------+
             | 2.09 PiB |
             +----------+
             1 row in set (0.00 sec)

             mysql> SELECT sys.format_bytes(2348723492723) AS size;
             +----------+
             | size     |
             +----------+
             | 2.14 TiB |
             +----------+
             1 row in set (0.00 sec)

             mysql> SELECT sys.format_bytes(23487234) AS size;
             +-----------+
             | size      |
             +-----------+
             | 22.40 MiB |
             +-----------+
             1 row in set (0.00 sec)
            '
    SQL SECURITY INVOKER
    DETERMINISTIC
    NO SQL
BEGIN
  IF bytes IS NULL THEN RETURN NULL;
  ELSEIF bytes >= 1125899906842624 THEN RETURN CONCAT(ROUND(bytes / 1125899906842624, 2), ' PiB');
  ELSEIF bytes >= 1099511627776 THEN RETURN CONCAT(ROUND(bytes / 1099511627776, 2), ' TiB');
  ELSEIF bytes >= 1073741824 THEN RETURN CONCAT(ROUND(bytes / 1073741824, 2), ' GiB');
  ELSEIF bytes >= 1048576 THEN RETURN CONCAT(ROUND(bytes / 1048576, 2), ' MiB');
  ELSEIF bytes >= 1024 THEN RETURN CONCAT(ROUND(bytes / 1024, 2), ' KiB');
  ELSE RETURN CONCAT(bytes, ' bytes');
  END IF;
END $$

DELIMITER ;
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

DROP FUNCTION IF EXISTS format_path;

DELIMITER $$

CREATE DEFINER=CURRENT_USER FUNCTION format_path (
        path VARCHAR(260)
    )
    RETURNS VARCHAR(260) CHARSET UTF8
    COMMENT '
             Description
             -----------

             Takes a raw path value, and strips out the datadir or tmpdir
             replacing with @@datadir and @@tmpdir respectively. 

             Also normalizes the paths across operating systems, so backslashes
             on Windows are converted to forward slashes

             Parameters
             -----------

             path (VARCHAR(260)): 
               The raw file path value to format.

             Returns
             -----------

             VARCHAR(260) CHARSET UTF8

             Example
             -----------

             mysql> select @@datadir;
             +-----------------------------------------------+
             | @@datadir                                     |
             +-----------------------------------------------+
             | /Users/mark/sandboxes/SmallTree/AMaster/data/ |
             +-----------------------------------------------+
             1 row in set (0.06 sec)

             mysql> select format_path(\'/Users/mark/sandboxes/SmallTree/AMaster/data/mysql/proc.MYD\') AS path;
             +--------------------------+
             | path                     |
             +--------------------------+
             | @@datadir/mysql/proc.MYD |
             +--------------------------+
             1 row in set (0.03 sec)
            '
    SQL SECURITY INVOKER
    DETERMINISTIC
    NO SQL
BEGIN
  DECLARE v_path VARCHAR(260);

  /* OSX hides /private/ in variables, but Performance Schema does not */
  IF path LIKE '/private/%' 
    THEN SET v_path = REPLACE(path, '/private', '');
    ELSE SET v_path = path;
  END IF;

  IF v_path IS NULL THEN RETURN NULL;
  ELSEIF v_path LIKE CONCAT(@@global.datadir, '%') ESCAPE '|' THEN 
    RETURN REPLACE(REPLACE(REPLACE(v_path, @@global.datadir, '@@datadir/'), '\\\\', ''), '\\', '/');
  ELSEIF v_path LIKE CONCAT(@@global.tmpdir, '%') ESCAPE '|' THEN 
    RETURN REPLACE(REPLACE(REPLACE(v_path, @@global.tmpdir, '@@tmpdir/'), '\\\\', ''), '\\', '/');
  ELSE RETURN v_path;
  END IF;
END$$

DELIMITER ;
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

DROP FUNCTION IF EXISTS format_statement;

DELIMITER $$

CREATE DEFINER=CURRENT_USER FUNCTION format_statement (
        statement LONGTEXT
    )
    RETURNS VARCHAR(65)
    COMMENT '
             Description
             -----------

             Formats a normalized statement, truncating it if it\'s > 64 characters long.

             Useful for printing statement related data from Performance Schema from 
             the command line.

             Parameters
             -----------

             statement (LONGTEXT): 
               The statement to format.

             Returns
             -----------

             VARCHAR(65)

             Example
             -----------

             mysql> SELECT sys.format_statement(digest_text)
                 ->   FROM performance_schema.events_statements_summary_by_digest
                 ->  ORDER by sum_timer_wait DESC limit 5;
             +-------------------------------------------------------------------+
             | sys.format_statement(digest_text)                                 |
             +-------------------------------------------------------------------+
             | CREATE SQL SECURITY INVOKER VI ... KE ? AND `variable_value` > ?  |
             | CREATE SQL SECURITY INVOKER VI ... ait` IS NOT NULL , `esc` . ... |
             | CREATE SQL SECURITY INVOKER VI ... ait` IS NOT NULL , `sys` . ... |
             | CREATE SQL SECURITY INVOKER VI ...  , `compressed_size` ) ) DESC  |
             | CREATE SQL SECURITY INVOKER VI ... LIKE ? ORDER BY `timer_start`  |
             +-------------------------------------------------------------------+
             5 rows in set (0.00 sec)
            '
    SQL SECURITY INVOKER
    DETERMINISTIC
    NO SQL
BEGIN
  IF LENGTH(statement) > 64 THEN 
      RETURN REPLACE(CONCAT(LEFT(statement, 30), ' ... ', RIGHT(statement, 30)), '\n', ' ');
  ELSE 
      RETURN REPLACE(statement, '\n', ' ');
  END IF;
END $$

DELIMITER ;
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

DROP FUNCTION IF EXISTS format_time;

DELIMITER $$

CREATE DEFINER=CURRENT_USER FUNCTION format_time (
        picoseconds BIGINT UNSIGNED
    )
    RETURNS VARCHAR(16) CHARSET UTF8
    COMMENT '
             Description
             -----------

             Takes a raw picoseconds value, and converts it to a human readable form.
             
             Picoseconds are the precision that all latency values are printed in 
             within Performance Schema, however are not user friendly when wanting
             to scan output from the command line.

             Parameters
             -----------

             picoseconds (BIGINT UNSIGNED): 
               The raw picoseconds value to convert.

             Returns
             -----------

             VARCHAR(16) CHARSET UTF8

             Example
             -----------

             mysql> select format_time(342342342342345);
             +------------------------------+
             | format_time(342342342342345) |
             +------------------------------+
             | 00:05:42                     |
             +------------------------------+
             1 row in set (0.00 sec)

             mysql> select format_time(342342342);
             +------------------------+
             | format_time(342342342) |
             +------------------------+
             | 342.34 µs              |
             +------------------------+
             1 row in set (0.00 sec)

             mysql> select format_time(34234);
              +--------------------+
             | format_time(34234) |
             +--------------------+
             | 34.23 ns           |
             +--------------------+
             1 row in set (0.00 sec)
            '
    SQL SECURITY INVOKER
    DETERMINISTIC
    NO SQL
BEGIN
  IF picoseconds IS NULL THEN RETURN NULL;
  ELSEIF picoseconds >= 3600000000000000 THEN RETURN CONCAT(ROUND(picoseconds / 3600000000000000, 2), 'h');
  ELSEIF picoseconds >= 60000000000000 THEN RETURN SEC_TO_TIME(ROUND(picoseconds / 1000000000000, 2));
  ELSEIF picoseconds >= 1000000000000 THEN RETURN CONCAT(ROUND(picoseconds / 1000000000000, 2), ' s');
  ELSEIF picoseconds >= 1000000000 THEN RETURN CONCAT(ROUND(picoseconds / 1000000000, 2), ' ms');
  ELSEIF picoseconds >= 1000000 THEN RETURN CONCAT(ROUND(picoseconds / 1000000, 2), ' us');
  ELSEIF picoseconds >= 1000 THEN RETURN CONCAT(ROUND(picoseconds / 1000, 2), ' ns');
  ELSE RETURN CONCAT(picoseconds, ' ps');
  END IF;
END $$

DELIMITER ;
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

DROP FUNCTION IF EXISTS ps_is_account_enabled;

DELIMITER $$

CREATE DEFINER=CURRENT_USER FUNCTION ps_is_account_enabled (
        in_host VARCHAR(60), 
        in_user VARCHAR(16)
    ) 
    RETURNS ENUM('YES', 'NO', 'PARTIAL')
    COMMENT '
             Description
             -----------

             Determines whether instrumentation of an account is enabled 
             within Performance Schema.

             Parameters
             -----------

             in_host VARCHAR(60): 
               The hostname of the account to check.
             in_user (VARCHAR(16)):
               The username of the account to check.

             Returns
             -----------

             ENUM(\'YES\', \'NO\', \'PARTIAL\')

             Example
             -----------

             mysql> SELECT sys.ps_is_account_enabled(\'localhost\', \'root\');
             +------------------------------------------------+
             | sys.ps_is_account_enabled(\'localhost\', \'root\') |
             +------------------------------------------------+
             | YES                                            |
             +------------------------------------------------+
             1 row in set (0.01 sec)
            '
    SQL SECURITY INVOKER
    DETERMINISTIC 
    READS SQL DATA 
BEGIN
    RETURN IF(EXISTS(SELECT 1
                       FROM performance_schema.setup_actors
                      WHERE (`HOST` = '%' OR in_host LIKE `HOST`)
                        AND (`USER` = '%' OR `USER` = in_user)
                    ),
              'YES', 'NO'
           );
END $$

DELIMITER ;
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

DROP FUNCTION IF EXISTS ps_thread_stack;

DELIMITER $$

CREATE DEFINER=CURRENT_USER FUNCTION ps_thread_stack (
        thd_id INT,
        debug BOOLEAN
    )
RETURNS LONGTEXT CHARSET latin1
    COMMENT '
             Description
             -----------

             Outputs a JSON formatted stack of all statements, stages and events
             within Performance Schema for the specified thread.

             Parameters
             -----------

             thd_id (BIGINT):
               The id of the thread to trace. This should match the thread_id
               column from the performance_schema.threads table.
             in_verbose (BOOLEAN):
               Include file:lineno information in the events.

             Example
             -----------

             (line separation added for output)

             mysql> SELECT sys.ps_thread_stack(37, FALSE) AS thread_stack\\G
             *************************** 1. row ***************************
             thread_stack: {"rankdir": "LR","nodesep": "0.10","stack_created": "2014-02-19 13:39:03",
             "mysql_version": "5.7.3-m13","mysql_user": "root@localhost","events": 
             [{"nesting_event_id": "0", "event_id": "10", "timer_wait": 256.35, "event_info": 
             "sql/select", "wait_info": "select @@version_comment limit 1\\nerrors: 0\\nwarnings: 0\\nlock time:
             ...
            '
SQL SECURITY INVOKER
NOT DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE json_objects LONGTEXT;

    /*!50602
    /* Do not track the current thread, it will kill the stack */
    UPDATE performance_schema.threads
       SET instrumented = 'NO'
     WHERE processlist_id = CONNECTION_ID();
    */

    SET SESSION group_concat_max_len=@@global.max_allowed_packet;

    /* Select the entire stack of events */
    SELECT GROUP_CONCAT(CONCAT( '{'
              , CONCAT_WS( ', '
              , CONCAT('"nesting_event_id": "', IF(nesting_event_id IS NULL, '0', nesting_event_id), '"')
              , CONCAT('"event_id": "', event_id, '"')
              /* Convert from picoseconds to microseconds */
              , CONCAT( '"timer_wait": ', ROUND(timer_wait/1000000, 2))  
              , CONCAT( '"event_info": "'
                  , CASE 
                        WHEN event_name NOT LIKE 'wait/io%' THEN SUBSTRING_INDEX(event_name, '/', -2)
                        WHEN event_name NOT LIKE 'wait/io/file%' OR event_name NOT LIKE 'wait/io/socket%' THEN SUBSTRING_INDEX(event_name, '/', -4)
                        ELSE event_name
                    END
                  , '"'
              )
              /* Always dump the extra wait information gathered for statements */
              , CONCAT( '"wait_info": "', IFNULL(wait_info, ''), '"')
              /* If debug is enabled, add the file:lineno information for waits */
              , CONCAT( '"source": "', IF(true AND event_name LIKE 'wait%', IFNULL(wait_info, ''), ''), '"')
              /* Depending on the type of event, name it appropriately */
              , CASE 
                     WHEN event_name LIKE 'wait/io/file%'      THEN '"event_type": "io/file"'
                     WHEN event_name LIKE 'wait/io/table%'     THEN '"event_type": "io/table"'
                     WHEN event_name LIKE 'wait/io/socket%'    THEN '"event_type": "io/socket"'
                     WHEN event_name LIKE 'wait/synch/mutex%'  THEN '"event_type": "synch/mutex"'
                     WHEN event_name LIKE 'wait/synch/cond%'   THEN '"event_type": "synch/cond"'
                     WHEN event_name LIKE 'wait/synch/rwlock%' THEN '"event_type": "synch/rwlock"'
                     WHEN event_name LIKE 'wait/lock%'         THEN '"event_type": "lock"'
                     WHEN event_name LIKE 'statement/%'        THEN '"event_type": "stmt"'
                     WHEN event_name LIKE 'stage/%'            THEN '"event_type": "stage"'
                     WHEN event_name LIKE '%idle%'             THEN '"event_type": "idle"'
                     ELSE '' 
                END                   
            )
            , '}'
          )
          ORDER BY event_id ASC SEPARATOR ',') event
    INTO json_objects
    FROM (
          /*!50600
          /* Select all statements, with the extra tracing information available */
          (SELECT thread_id, event_id, event_name, timer_wait, timer_start, nesting_event_id, 
                  CONCAT(sql_text, '\\n',
                         'errors: ', errors, '\\n',
                         'warnings: ', warnings, '\\n',
                         'lock time: ', ROUND(lock_time/1000000, 2),'us\\n',
                         'rows affected: ', rows_affected, '\\n',
                         'rows sent: ', rows_sent, '\\n',
                         'rows examined: ', rows_examined, '\\n',
                         'tmp tables: ', created_tmp_tables, '\\n',
                         'tmp disk tables: ', created_tmp_disk_tables, '\\n',
                         'select scan: ', select_scan, '\\n',
                         'select full join: ', select_full_join, '\\n',
                         'select full range join: ', select_full_range_join, '\\n',
                         'select range: ', select_range, '\\n',
                         'select range check: ', select_range_check, '\\n', 
                         'sort merge passes: ', sort_merge_passes, '\\n',
                         'sort rows: ', sort_rows, '\\n',
                         'sort range: ', sort_range, '\\n',
                         'sort scan: ', sort_scan, '\\n',
                         'no index used: ', IF(no_index_used, 'TRUE', 'FALSE'), '\\n',
                         'no good index used: ', IF(no_good_index_used, 'TRUE', 'FALSE'), '\\n'
                         ) AS wait_info
             FROM performance_schema.events_statements_history_long WHERE thread_id = thd_id)
          UNION 
          /* Select all stages */
          (SELECT thread_id, event_id, event_name, timer_wait, timer_start, nesting_event_id, null AS wait_info
             FROM performance_schema.events_stages_history_long WHERE thread_id = thd_id) 
          UNION*/
          /* Select all events, adding information appropriate to the event */
          (SELECT thread_id, event_id, 
                  CONCAT(event_name , 
                         IF(event_name NOT LIKE 'wait/synch/mutex%', IFNULL(CONCAT(' - ', operation), ''), ''), 
                         IF(number_of_bytes IS NOT NULL, CONCAT(' ', number_of_bytes, ' bytes'), ''),
                         IF(event_name LIKE 'wait/io/file%', '\\n', ''),
                         IF(object_schema IS NOT NULL, CONCAT('\\nObject: ', object_schema, '.'), ''), 
                         IF(object_name IS NOT NULL, 
                            IF (event_name LIKE 'wait/io/socket%',
                                /* Print the socket if used, else the IP:port as reported */
                                CONCAT(IF (object_name LIKE ':0%', @@socket, object_name)),
                                object_name),
                            ''),
                         /*!50600 IF(index_name IS NOT NULL, CONCAT(' Index: ', index_name), ''),*/'\\n'
                         ) AS event_name,
                  timer_wait, timer_start, nesting_event_id, source AS wait_info
             FROM performance_schema.events_waits_history_long WHERE thread_id = thd_id)) events 
    ORDER BY event_id;

    RETURN CONCAT('{', 
                  CONCAT_WS(',', 
                            '"rankdir": "LR"',
                            '"nodesep": "0.10"',
                            CONCAT('"stack_created": "', NOW(), '"'),
                            CONCAT('"mysql_version": "', VERSION(), '"'),
                            CONCAT('"mysql_user": "', CURRENT_USER(), '"'),
                            CONCAT('"events": [', IFNULL(json_objects,''), ']')
                           ),
                  '}');

END$$

DELIMITER ;
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

DROP PROCEDURE IF EXISTS create_synonym_db;

DELIMITER $$

CREATE DEFINER=CURRENT_USER PROCEDURE create_synonym_db (
        IN in_db_name VARCHAR(64), 
        IN in_synonym VARCHAR(64)
    )
    COMMENT '
             Description
             -----------

             Takes a source database name and synonym name, and then creates the 
             synonym database with views that point to all of the tables within
             the source database.

             Useful for creating a "ps" synonym for "performance_schema",
             or "is" instead of "information_schema", for example.

             Parameters
             -----------

             in_db_name (VARCHAR(64)):
               The database name that you would like to create a synonym for.
             in_synonym (VARCHAR(64)):
               The database synonym name.

             Example
             -----------

             mysql> SHOW DATABASES;
             +--------------------+
             | Database           |
             +--------------------+
             | information_schema |
             | mysql              |
             | performance_schema |
             | sys                |
             | test               |
             +--------------------+
             5 rows in set (0.00 sec)

             mysql> CALL sys.create_synonym_db(\'performance_schema\', \'ps\');
             +-------------------------------------+
             | summary                             |
             +-------------------------------------+
             | Created 74 views in the ps database |
             +-------------------------------------+
             1 row in set (8.57 sec)

             Query OK, 0 rows affected (8.57 sec)

             mysql> SHOW DATABASES;
             +--------------------+
             | Database           |
             +--------------------+
             | information_schema |
             | mysql              |
             | performance_schema |
             | ps                 |
             | sys                |
             | test               |
             +--------------------+
             6 rows in set (0.00 sec)

             mysql> SHOW FULL TABLES FROM ps;
             +------------------------------------------------------+------------+
             | Tables_in_ps                                         | Table_type |
             +------------------------------------------------------+------------+
             | accounts                                             | VIEW       |
             | cond_instances                                       | VIEW       |
             | events_stages_current                                | VIEW       |
             | events_stages_history                                | VIEW       |
             ...
            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    MODIFIES SQL DATA
BEGIN
    DECLARE v_done bool DEFAULT FALSE;
    DECLARE v_db_name_check VARCHAR(64);
    DECLARE v_db_err_msg TEXT;
    DECLARE v_table VARCHAR(64);
    DECLARE v_views_created INT DEFAULT 0;

    DECLARE db_doesnt_exist CONDITION FOR SQLSTATE '42000';
    DECLARE db_name_exists CONDITION FOR SQLSTATE 'HY000';

    DECLARE c_table_names CURSOR FOR 
        SELECT TABLE_NAME 
          FROM INFORMATION_SCHEMA.TABLES 
         WHERE TABLE_SCHEMA = in_db_name;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    /* Check if the source database exists */
    SELECT SCHEMA_NAME INTO v_db_name_check
      FROM INFORMATION_SCHEMA.SCHEMATA
     WHERE SCHEMA_NAME = in_db_name;

    IF v_db_name_check IS NULL THEN
        SET v_db_err_msg = CONCAT('Unknown database ', in_db_name);
        SIGNAL SQLSTATE 'HY000'
            SET MESSAGE_TEXT = v_db_err_msg;
    END IF;

    /* Check if a database of the synonym name already exists */
    SELECT SCHEMA_NAME INTO v_db_name_check
      FROM INFORMATION_SCHEMA.SCHEMATA
     WHERE SCHEMA_NAME = in_synonym;

    IF v_db_name_check = in_synonym THEN
        SET v_db_err_msg = CONCAT('Can\'t create database ', in_synonym, '; database exists');
        SIGNAL SQLSTATE 'HY000'
            SET MESSAGE_TEXT = v_db_err_msg;
    END IF;

    /* All good, create the database and views */
    SET @create_db_stmt := CONCAT('CREATE DATABASE ', in_synonym);
    PREPARE create_db_stmt FROM @create_db_stmt;
    EXECUTE create_db_stmt;
    DEALLOCATE PREPARE create_db_stmt;

    SET v_done = FALSE;
    OPEN c_table_names;
    c_table_names: LOOP
        FETCH c_table_names INTO v_table;
        IF v_done THEN
            LEAVE c_table_names;
        END IF;

        SET @create_view_stmt = CONCAT('CREATE SQL SECURITY INVOKER VIEW ', in_synonym, '.', v_table, ' AS SELECT * FROM ', in_db_name, '.', v_table);
        PREPARE create_view_stmt FROM @create_view_stmt;
        EXECUTE create_view_stmt;
        DEALLOCATE PREPARE create_view_stmt;

        SET v_views_created = v_views_created + 1;
    END LOOP;
    CLOSE c_table_names;

    SELECT CONCAT('Created ', v_views_created, ' view', IF(v_views_created != 1, 's', ''), ' in the ', in_synonym, ' database') AS summary;

END$$

DELIMITER ;
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

DROP PROCEDURE IF EXISTS ps_setup_disable_background_threads;

DELIMITER $$

CREATE DEFINER=CURRENT_USER PROCEDURE ps_setup_disable_background_threads ()
    COMMENT '
             Description
             -----------

             Disable all background thread instrumentation within Performance Schema.


             Parameters
             -----------

             None.

             Example
             -----------

             mysql> CALL sys.ps_setup_disable_background_threads();
             +--------------------------------+
             | summary                        |
             +--------------------------------+
             | Disabled 18 background threads |
             +--------------------------------+
             1 row in set (0.00 sec)
            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    MODIFIES SQL DATA
BEGIN

    UPDATE performance_schema.threads
       SET instrumented = 'NO'
     WHERE type = 'BACKGROUND';

    SELECT CONCAT('Disabled ', @rows := ROW_COUNT(), ' background thread', IF(@rows != 1, 's', '')) AS summary;

END$$

DELIMITER ;
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

DROP PROCEDURE IF EXISTS ps_setup_disable_instrument;

DELIMITER $$

CREATE DEFINER=CURRENT_USER PROCEDURE ps_setup_disable_instrument (
        IN in_pattern VARCHAR(128)
    )
    COMMENT '
             Description
             -----------

             Disables instruments within Performance Schema 
             matching the input pattern.


             Parameters
             -----------

             in_pattern (VARCHAR(128)):
               A LIKE pattern match (using "%in_pattern%") of events to disable

             Example
             -----------

             To disable all mutex instruments:

             mysql> CALL sys.ps_setup_disable_instrument(\'wait/synch/mutex\');
             +--------------------------+
             | summary                  |
             +--------------------------+
             | Disabled 155 instruments |
             +--------------------------+
             1 row in set (0.02 sec)

             To disable just a the scpecific TCP/IP based network IO instrument:

             mysql> CALL sys.ps_setup_disable_instrument(\'wait/io/socket/sql/server_tcpip_socket\');
             +------------------------+
             | summary                |
             +------------------------+
             | Disabled 1 instruments |
             +------------------------+
             1 row in set (0.00 sec)

             To enable all instruments:

             mysql> CALL sys.ps_setup_disable_instrument(\'\');
             +--------------------------+
             | summary                  |
             +--------------------------+
             | Disabled 547 instruments |
             +--------------------------+
             1 row in set (0.01 sec)
            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    MODIFIES SQL DATA
BEGIN

    UPDATE performance_schema.setup_instruments
       SET enabled = 'NO', timed = 'NO'
     WHERE name LIKE CONCAT('%', in_pattern, '%');

    SELECT CONCAT('Disabled ', @rows := ROW_COUNT(), ' instrument', IF(@rows != 1, 's', '')) AS summary;

END$$

DELIMITER ;
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

DROP PROCEDURE IF EXISTS ps_setup_disable_thread;

DELIMITER $$

CREATE DEFINER=CURRENT_USER PROCEDURE ps_setup_disable_thread (
        IN in_connection_id BIGINT
    )
    COMMENT '
             Description
             -----------

             Disable the given connection/thread in Performance Schema.


             Parameters
             -----------

             in_connection_id (BIGINT):
               The connection ID (PROCESSLIST_ID from performance_schema.threads
               or the ID shown within SHOW PROCESSLIST)

             Example
             -----------

             mysql> CALL sys.ps_setup_disable_thread(3);
             +-------------------+
             | summary           |
             +-------------------+
             | Disabled 1 thread |
             +-------------------+
             1 row in set (0.01 sec)

             To disable the current connection:

             mysql> CALL sys.ps_setup_disable_thread(CONNECTION_ID());
             +-------------------+
             | summary           |
             +-------------------+
             | Disabled 1 thread |
             +-------------------+
             1 row in set (0.00 sec)
            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    MODIFIES SQL DATA
BEGIN

    UPDATE performance_schema.threads
       SET instrumented = 'NO'
     WHERE processlist_id = CONNECTION_ID();

    SELECT CONCAT('Disabled ', @rows := ROW_COUNT(), ' thread', IF(@rows != 1, 's', '')) AS summary;

END$$

DELIMITER ;
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

DROP PROCEDURE IF EXISTS ps_setup_enable_background_threads;

DELIMITER $$

CREATE DEFINER=CURRENT_USER PROCEDURE ps_setup_enable_background_threads ()
    COMMENT '
             Description
             -----------

             Enable all background thread instrumentation within Performance Schema.


             Parameters
             -----------

             None.

             Example
             -----------

             mysql> CALL sys.ps_setup_enable_background_threads();
             +-------------------------------+
             | summary                       |
             +-------------------------------+
             | Enabled 18 background threads |
             +-------------------------------+
             1 row in set (0.00 sec)
            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    MODIFIES SQL DATA
BEGIN

    UPDATE performance_schema.threads
       SET instrumented = 'YES'
     WHERE type = 'BACKGROUND';

    SELECT CONCAT('Enabled ', @rows := ROW_COUNT(), ' background thread', IF(@rows != 1, 's', '')) AS summary;

END$$

DELIMITER ;
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

DROP PROCEDURE IF EXISTS ps_setup_enable_instrument;

DELIMITER $$

CREATE DEFINER=CURRENT_USER PROCEDURE ps_setup_enable_instrument (
        IN in_pattern VARCHAR(128)
    )
    COMMENT '
             Description
             -----------

             Enables instruments within Performance Schema 
             matching the input pattern.


             Parameters
             -----------

             in_pattern (VARCHAR(128)):
               A LIKE pattern match (using "%in_pattern%") of events to enable

             Example
             -----------

             To enable all mutex instruments:

             mysql> CALL sys.ps_setup_enable_instrument(\'wait/synch/mutex\');
             +-------------------------+
             | summary                 |
             +-------------------------+
             | Enabled 155 instruments |
             +-------------------------+
             1 row in set (0.02 sec)

             Query OK, 0 rows affected (0.02 sec)

             To enable just a the scpecific TCP/IP based network IO instrument:

             mysql> CALL sys.ps_setup_enable_instrument(\'wait/io/socket/sql/server_tcpip_socket\');
             +-----------------------+
             | summary               |
             +-----------------------+
             | Enabled 1 instruments |
             +-----------------------+
             1 row in set (0.00 sec)

             Query OK, 0 rows affected (0.00 sec)

             To enable all instruments:

             mysql> CALL sys.ps_setup_enable_instrument(\'\');
             +-------------------------+
             | summary                 |
             +-------------------------+
             | Enabled 547 instruments |
             +-------------------------+
             1 row in set (0.01 sec)

             Query OK, 0 rows affected (0.01 sec)
            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    MODIFIES SQL DATA
BEGIN

    UPDATE performance_schema.setup_instruments
       SET enabled = 'YES', timed = 'YES'
     WHERE name LIKE CONCAT('%', in_pattern, '%');

    SELECT CONCAT('Enabled ', @rows := ROW_COUNT(), ' instrument', IF(@rows != 1, 's', '')) AS summary;

END$$

DELIMITER ;
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

DROP PROCEDURE IF EXISTS ps_setup_enable_thread;

DELIMITER $$

CREATE DEFINER=CURRENT_USER PROCEDURE ps_setup_enable_thread (
        IN in_connection_id BIGINT
    )
    COMMENT '
             Description
             -----------

             Enable the given connection/thread in Performance Schema.


             Parameters
             -----------

             in_connection_id (BIGINT):
               The connection ID (PROCESSLIST_ID from performance_schema.threads
               or the ID shown within SHOW PROCESSLIST)

             Example
             -----------

             mysql> CALL sys.ps_setup_enable_thread(3);
             +------------------+
             | summary          |
             +------------------+
             | Enabled 1 thread |
             +------------------+
             1 row in set (0.01 sec)

             To enable the current connection:

             mysql> CALL sys.ps_setup_enable_thread(CONNECTION_ID());
             +------------------+
             | summary          |
             +------------------+
             | Enabled 1 thread |
             +------------------+
             1 row in set (0.00 sec)
            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    MODIFIES SQL DATA
BEGIN

    UPDATE performance_schema.threads
       SET instrumented = 'YES'
     WHERE processlist_id = in_connection_id;

    SELECT CONCAT('Enabled ', @rows := ROW_COUNT(), ' thread', IF(@rows != 1, 's', '')) AS summary;

END$$

DELIMITER ;
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

DROP PROCEDURE IF EXISTS ps_setup_reload_saved;

DELIMITER $$

CREATE DEFINER=CURRENT_USER PROCEDURE ps_setup_reload_saved ()
    COMMENT '
             Description
             -----------

             Reloads a saved Performance Schema configuration,
             so that you can alter the setup for debugging purposes, 
             but restore it to a previous state.
             
             Use the companion procedure - ps_setup_save(), to 
             save a configuration.


             Parameters
             -----------

             None.

             Example
             -----------

             mysql> CALL sys.ps_setup_save();
             Query OK, 0 rows affected (0.08 sec)

             mysql> UPDATE performance_schema.setup_instruments SET enabled = \'YES\', timed = \'YES\';
             Query OK, 547 rows affected (0.40 sec)
             Rows matched: 784  Changed: 547  Warnings: 0

             /* Run some tests that need more detailed instrumentation here */

             mysql> CALL sys.ps_setup_reload_saved();
             Query OK, 0 rows affected (0.32 sec)
            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    MODIFIES SQL DATA
BEGIN
    DECLARE v_done bool DEFAULT FALSE;
    DECLARE v_lock_result INT;
    DECLARE v_lock_used_by BIGINT;
    DECLARE v_signal_message TEXT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SIGNAL SQLSTATE VALUE '90001'
           SET MESSAGE_TEXT = 'An error occurred, was sys.ps_setup_save() run before this procedure?';
    END;


    SELECT IS_USED_LOCK('sys.ps_setup_save') INTO v_lock_used_by;

    IF (v_lock_used_by != CONNECTION_ID()) THEN
        SET v_signal_message = CONCAT('The sys.ps_setup_save lock is currently owned by ', v_lock_used_by);
        SIGNAL SQLSTATE VALUE '90002'
           SET MESSAGE_TEXT = v_signal_message;
    END IF;

    DELETE FROM performance_schema.setup_actors;
    INSERT INTO performance_schema.setup_actors SELECT * FROM tmp_setup_actors;

    BEGIN
        /* Workaround for http://bugs.mysql.com/bug.php?id=70025 */
        DECLARE v_name varchar(64);
        DECLARE v_enabled enum('YES', 'NO');
        DECLARE c_consumers CURSOR FOR SELECT NAME, ENABLED FROM tmp_setup_consumers;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

        SET v_done = FALSE;
        OPEN c_consumers;
        c_consumers_loop: LOOP
            FETCH c_consumers INTO v_name, v_enabled;
            IF v_done THEN
               LEAVE c_consumers_loop;
            END IF;

            UPDATE performance_schema.setup_consumers
               SET ENABLED = v_enabled
             WHERE NAME = v_name;
         END LOOP;
         CLOSE c_consumers;
    END;

    UPDATE performance_schema.setup_instruments
     INNER JOIN tmp_setup_instruments USING (NAME)
       SET performance_schema.setup_instruments.ENABLED = tmp_setup_instruments.ENABLED,
           performance_schema.setup_instruments.TIMED   = tmp_setup_instruments.TIMED;
    BEGIN
        /* Workaround for http://bugs.mysql.com/bug.php?id=70025 */
        DECLARE v_thread_id bigint unsigned;
        DECLARE v_instrumented enum('YES', 'NO');
        DECLARE c_threads CURSOR FOR SELECT THREAD_ID, INSTRUMENTED FROM tmp_threads;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

        SET v_done = FALSE;
        OPEN c_threads;
        c_threads_loop: LOOP
            FETCH c_threads INTO v_thread_id, v_instrumented;
            IF v_done THEN
               LEAVE c_threads_loop;
            END IF;

            UPDATE performance_schema.threads
               SET INSTRUMENTED = v_instrumented
             WHERE THREAD_ID = v_thread_id;
        END LOOP;
        CLOSE c_threads;
    END;

    UPDATE performance_schema.threads
       SET INSTRUMENTED = IF(PROCESSLIST_USER IS NOT NULL,
                             sys.ps_is_account_enabled(PROCESSLIST_HOST, PROCESSLIST_USER),
                             'YES')
     WHERE THREAD_ID NOT IN (SELECT THREAD_ID FROM tmp_threads);

    DROP TEMPORARY TABLE tmp_setup_actors;
    DROP TEMPORARY TABLE tmp_setup_consumers;
    DROP TEMPORARY TABLE tmp_setup_instruments;
    DROP TEMPORARY TABLE tmp_threads;

    SELECT RELEASE_LOCK('sys.ps_setup_save') INTO v_lock_result;

END$$

DELIMITER ;
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

DROP PROCEDURE IF EXISTS ps_setup_reset_to_default;

DELIMITER $$

CREATE DEFINER=CURRENT_USER PROCEDURE ps_setup_reset_to_default (
       IN in_verbose BOOLEAN
    )
    COMMENT '
             Description
             -----------

             Resets the Performance Schema setup to the default settings.

             Parameters
             -----------

             in_verbose (BOOLEAN):
               Whether to print each setup stage (including the SQL) whilst running.

             Example
             -----------

             mysql> CALL sys.ps_setup_reset_to_default(true)\\G
             *************************** 1. row ***************************
             status: Resetting: setup_actors
             DELETE
             FROM performance_schema.setup_actors
              WHERE NOT (HOST = \'%\' AND USER = \'%\' AND ROLE = \'%\')
             1 row in set (0.00 sec)

             *************************** 1. row ***************************
             status: Resetting: setup_actors
             INSERT IGNORE INTO performance_schema.setup_actors
             VALUES (\'%\', \'%\', \'%\')
             1 row in set (0.00 sec)
             ...

             mysql> CALL sys.ps_setup_reset_to_default(false)\G
             Query OK, 0 rows affected (0.00 sec)
            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    MODIFIES SQL DATA
BEGIN

    SET @query = 'DELETE
                    FROM performance_schema.setup_actors
                   WHERE NOT (HOST = ''%'' AND USER = ''%'' AND ROLE = ''%'')';

    IF (in_verbose) THEN
        SELECT CONCAT('Resetting: setup_actors\n', REPLACE(@query, '  ', '')) AS status;
    END IF;

    PREPARE reset_stmt FROM @query;
    EXECUTE reset_stmt;
    DEALLOCATE PREPARE reset_stmt;

    SET @query = 'INSERT IGNORE INTO performance_schema.setup_actors
                  VALUES (''%'', ''%'', ''%'')';

    IF (in_verbose) THEN
        SELECT CONCAT('Resetting: setup_actors\n', REPLACE(@query, '  ', '')) AS status;
    END IF;

    PREPARE reset_stmt FROM @query;
    EXECUTE reset_stmt;
    DEALLOCATE PREPARE reset_stmt;

    SET @query = 'UPDATE performance_schema.setup_instruments
                     SET ENABLED = ''NO'', TIMED = ''NO''
                   WHERE NAME NOT LIKE ''wait/io/file/%''
                     AND NAME NOT LIKE ''wait/io/table/%''
                     AND NAME NOT LIKE ''statement/%''
                     AND NAME NOT IN (''wait/lock/table/sql/handler'', ''idle'')';

    IF (in_verbose) THEN
        SELECT CONCAT('Resetting: setup_instruments\n', REPLACE(@query, '  ', '')) AS status;
    END IF;

    PREPARE reset_stmt FROM @query;
    EXECUTE reset_stmt;
    DEALLOCATE PREPARE reset_stmt;
         
    SET @query = 'UPDATE performance_schema.setup_consumers
                     SET ENABLED = IF(NAME IN (''events_statements_current'', ''global_instrumentation'', ''thread_instrumentation'', ''statements_digest''), ''YES'', ''NO'')';

    IF (in_verbose) THEN
        SELECT CONCAT('Resetting: setup_consumers\n', REPLACE(@query, '  ', '')) AS status;
    END IF;

    PREPARE reset_stmt FROM @query;
    EXECUTE reset_stmt;
    DEALLOCATE PREPARE reset_stmt;

    SET @query = 'DELETE
                    FROM performance_schema.setup_objects
                   WHERE NOT (OBJECT_TYPE = ''TABLE'' AND OBJECT_NAME = ''%''
                     AND (OBJECT_SCHEMA = ''mysql''              AND ENABLED = ''NO''  AND TIMED = ''NO'' )
                      OR (OBJECT_SCHEMA = ''performance_schema'' AND ENABLED = ''NO''  AND TIMED = ''NO'' )
                      OR (OBJECT_SCHEMA = ''information_schema'' AND ENABLED = ''NO''  AND TIMED = ''NO'' )
                      OR (OBJECT_SCHEMA = ''%''                  AND ENABLED = ''YES'' AND TIMED = ''YES''))';

    IF (in_verbose) THEN
        SELECT CONCAT('Resetting: setup_objects\n', REPLACE(@query, '  ', '')) AS status;
    END IF;

    PREPARE reset_stmt FROM @query;
    EXECUTE reset_stmt;
    DEALLOCATE PREPARE reset_stmt;

    SET @query = 'INSERT IGNORE INTO performance_schema.setup_objects
                  VALUES (''TABLE'', ''mysql''             , ''%'', ''NO'' , ''NO'' ),
                         (''TABLE'', ''performance_schema'', ''%'', ''NO'' , ''NO'' ),
                         (''TABLE'', ''information_schema'', ''%'', ''NO'' , ''NO'' ),
                         (''TABLE'', ''%''                 , ''%'', ''YES'', ''YES'')';

    IF (in_verbose) THEN
        SELECT CONCAT('Resetting: setup_objects\n', REPLACE(@query, '  ', '')) AS status;
    END IF;

    PREPARE reset_stmt FROM @query;
    EXECUTE reset_stmt;
    DEALLOCATE PREPARE reset_stmt;

    SET @query = 'UPDATE performance_schema.threads
                     SET INSTRUMENTED = ''YES''';

    IF (in_verbose) THEN
        SELECT CONCAT('Resetting: threads\n', REPLACE(@query, '  ', '')) AS status;
    END IF;

    PREPARE reset_stmt FROM @query;
    EXECUTE reset_stmt;
    DEALLOCATE PREPARE reset_stmt;

END$$

DELIMITER ;
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

DROP PROCEDURE IF EXISTS ps_setup_save;

DELIMITER $$

CREATE DEFINER=CURRENT_USER PROCEDURE ps_setup_save (
        IN in_timeout INT
    )
    COMMENT '
             Description
             -----------

             Saves the current configuration of Performance Schema, 
             so that you can alter the setup for debugging purposes, 
             but restore it to a previous state.

             Use the companion procedure - ps_setup_reload_saved(), to 
             restore the saved config.


             Parameters
             -----------

             None.

             Example
             -----------

             mysql> CALL sys.ps_setup_save();
             Query OK, 0 rows affected (0.08 sec)

             mysql> UPDATE performance_schema.setup_instruments 
                 ->    SET enabled = \'YES\', timed = \'YES\';
             Query OK, 547 rows affected (0.40 sec)
             Rows matched: 784  Changed: 547  Warnings: 0

             /* Run some tests that need more detailed instrumentation here */

             mysql> CALL sys.ps_setup_reload_saved();
             Query OK, 0 rows affected (0.32 sec)
            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    MODIFIES SQL DATA
BEGIN
    DECLARE v_lock_result INT;


    SELECT GET_LOCK('sys.ps_setup_save', in_timeout) INTO v_lock_result;

    IF v_lock_result THEN
        DROP TEMPORARY TABLE IF EXISTS tmp_setup_actors;
        DROP TEMPORARY TABLE IF EXISTS tmp_setup_consumers;
        DROP TEMPORARY TABLE IF EXISTS tmp_setup_instruments;
        DROP TEMPORARY TABLE IF EXISTS tmp_threads;

        CREATE TEMPORARY TABLE tmp_setup_actors LIKE performance_schema.setup_actors;
        CREATE TEMPORARY TABLE tmp_setup_consumers LIKE performance_schema.setup_consumers;
        CREATE TEMPORARY TABLE tmp_setup_instruments LIKE performance_schema.setup_instruments;
        CREATE TEMPORARY TABLE tmp_threads (THREAD_ID bigint unsigned NOT NULL PRIMARY KEY, INSTRUMENTED enum('YES','NO') NOT NULL);

        INSERT INTO tmp_setup_actors SELECT * FROM performance_schema.setup_actors;
        INSERT INTO tmp_setup_consumers SELECT * FROM performance_schema.setup_consumers;
        INSERT INTO tmp_setup_instruments SELECT * FROM performance_schema.setup_instruments;
        INSERT INTO tmp_threads SELECT THREAD_ID, INSTRUMENTED FROM performance_schema.threads;
    ELSE
        SIGNAL SQLSTATE VALUE '90000'
           SET MESSAGE_TEXT = 'Could not lock the sys.ps_setup_save user lock, another thread has a saved configuration';
    END IF;

END$$

DELIMITER ;
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

DROP PROCEDURE IF EXISTS ps_setup_show_disabled;

DELIMITER $$

CREATE DEFINER=CURRENT_USER PROCEDURE ps_setup_show_disabled (
        IN in_show_instruments BOOLEAN,
        IN in_show_threads BOOLEAN
    )
    COMMENT '
             Description
             -----------

             Shows all currently disable Performance Schema configuration.

             Parameters
             -----------

             in_in_show_instruments (BOOLEAN):
               Whether to print disabled instruments (can print many items)

             in_in_show_threads (BOOLEAN):
               Whether to print disabled threads

             Example
             -----------

             mysql> CALL sys.ps_setup_show_disabled(TRUE, TRUE);
             +----------------------------+
             | performance_schema_enabled |
             +----------------------------+
             |                          1 |
             +----------------------------+
             1 row in set (0.00 sec)

             +--------------------+
             | enabled_users      |
             +--------------------+
             | \'mark\'@\'localhost\' |
             +--------------------+
             1 row in set (0.00 sec)

             +-------------+----------------------+---------+-------+
             | object_type | objects              | enabled | timed |
             +-------------+----------------------+---------+-------+
             | EVENT       | mysql.%              | NO      | NO    |
             | EVENT       | performance_schema.% | NO      | NO    |
             | EVENT       | information_schema.% | NO      | NO    |
             | FUNCTION    | mysql.%              | NO      | NO    |
             | FUNCTION    | performance_schema.% | NO      | NO    |
             | FUNCTION    | information_schema.% | NO      | NO    |
             | PROCEDURE   | mysql.%              | NO      | NO    |
             | PROCEDURE   | performance_schema.% | NO      | NO    |
             | PROCEDURE   | information_schema.% | NO      | NO    |
             | TABLE       | mysql.%              | NO      | NO    |
             | TABLE       | performance_schema.% | NO      | NO    |
             | TABLE       | information_schema.% | NO      | NO    |
             | TRIGGER     | mysql.%              | NO      | NO    |
             | TRIGGER     | performance_schema.% | NO      | NO    |
             | TRIGGER     | information_schema.% | NO      | NO    |
             +-------------+----------------------+---------+-------+
             15 rows in set (0.00 sec)

             +----------------------------------+
             | disabled_consumers               |
             +----------------------------------+
             | events_stages_current            |
             | events_stages_history            |
             | events_stages_history_long       |
             | events_statements_history        |
             | events_statements_history_long   |
             | events_transactions_history      |
             | events_transactions_history_long |
             | events_waits_current             |
             | events_waits_history             |
             | events_waits_history_long        |
             +----------------------------------+
             10 rows in set (0.00 sec)

             Empty set (0.00 sec)
             
             +---------------------------------------------------------------------------------------+-------+
             | disabled_instruments                                                                  | timed |
             +---------------------------------------------------------------------------------------+-------+
             | wait/synch/mutex/sql/TC_LOG_MMAP::LOCK_tc                                             | NO    |
             | wait/synch/mutex/sql/LOCK_des_key_file                                                | NO    |
             | wait/synch/mutex/sql/MYSQL_BIN_LOG::LOCK_commit                                       | NO    |
             ...
             | memory/sql/servers_cache                                                              | NO    |
             | memory/sql/udf_mem                                                                    | NO    |
             | wait/lock/metadata/sql/mdl                                                            | NO    |
             +---------------------------------------------------------------------------------------+-------+
             547 rows in set (0.00 sec)

             Query OK, 0 rows affected (0.01 sec)
            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    READS SQL DATA
BEGIN
    SELECT @@performance_schema AS performance_schema_enabled;

    SELECT CONCAT('\'', host, '\'@\'', user, '\'') AS enabled_users
      FROM performance_schema.setup_actors;

    SELECT object_type,
           CONCAT(object_schema, '.', object_name) AS objects,
           enabled,
           timed
      FROM performance_schema.setup_objects
     WHERE enabled = 'NO';

    SELECT name AS disabled_consumers
      FROM performance_schema.setup_consumers
     WHERE enabled = 'NO';

    IF (in_show_threads) THEN
        SELECT IF(name = 'thread/sql/one_connection', 
                  CONCAT(processlist_user, '@', processlist_host), 
                  REPLACE(name, 'thread/', '')) AS enabled_threads,
        TYPE AS thread_type
          FROM performance_schema.threads
         WHERE INSTRUMENTED = 'NO';
    END IF;

    IF (in_show_instruments) THEN
        SELECT name AS disabled_instruments,
               timed
          FROM performance_schema.setup_instruments
         WHERE enabled = 'NO';
    END IF;
END$$

DELIMITER ;
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

DROP PROCEDURE IF EXISTS ps_setup_show_enabled;

DELIMITER $$

CREATE DEFINER=CURRENT_USER PROCEDURE ps_setup_show_enabled (
        IN in_show_instruments BOOLEAN,
        IN in_show_threads BOOLEAN
    )
    COMMENT '
             Description
             -----------

             Shows all currently enabled Performance Schema configuration.

             Parameters
             -----------

             in_show_instruments (BOOLEAN):
               Whether to print enabled instruments (can print many items)

             in_show_threads (BOOLEAN):
               Whether to print enabled threads

             Example
             -----------

             mysql> CALL sys.ps_setup_show_enabled(TRUE, TRUE);
             +----------------------------+
             | performance_schema_enabled |
             +----------------------------+
             |                          1 |
             +----------------------------+
             1 row in set (0.00 sec)

             +---------------+
             | enabled_users |
             +---------------+
             | \'%\'@\'%\'       |
             +---------------+
             1 row in set (0.01 sec)

             +----------------------+---------+-------+
             | objects              | enabled | timed |
             +----------------------+---------+-------+
             | mysql.%              | NO      | NO    |
             | performance_schema.% | NO      | NO    |
             | information_schema.% | NO      | NO    |
             | %.%                  | YES     | YES   |
             +----------------------+---------+-------+
             4 rows in set (0.01 sec)

             +---------------------------+
             | enabled_consumers         |
             +---------------------------+
             | events_statements_current |
             | global_instrumentation    |
             | thread_instrumentation    |
             | statements_digest         |
             +---------------------------+
             4 rows in set (0.05 sec)

             +--------------------------+-------------+
             | enabled_threads          | thread_type |
             +--------------------------+-------------+
             | innodb/srv_master_thread | BACKGROUND  |
             | root@localhost           | FOREGROUND  |
             | root@localhost           | FOREGROUND  |
             | root@localhost           | FOREGROUND  |
             | root@localhost           | FOREGROUND  |
             +--------------------------+-------------+
             5 rows in set (0.03 sec)

             +-------------------------------------+-------+
             | enabled_instruments                 | timed |
             +-------------------------------------+-------+
             | wait/io/file/sql/map                | YES   |
             | wait/io/file/sql/binlog             | YES   |
             ...
             | statement/com/Error                 | YES   |
             | statement/com/                      | YES   |
             | idle                                | YES   |
             +-------------------------------------+-------+
             210 rows in set (0.08 sec)

             Query OK, 0 rows affected (0.89 sec)
            '
    SQL SECURITY INVOKER
    DETERMINISTIC
    READS SQL DATA
BEGIN
    SELECT @@performance_schema AS performance_schema_enabled;

    SELECT CONCAT('\'', host, '\'@\'', user, '\'') AS enabled_users
      FROM performance_schema.setup_actors;

    SELECT object_type,
           CONCAT(object_schema, '.', object_name) AS objects,
           enabled,
           timed
      FROM performance_schema.setup_objects;

    SELECT name AS enabled_consumers
      FROM performance_schema.setup_consumers
     WHERE enabled = 'YES';

    IF (in_show_threads) THEN
        SELECT IF(name = 'thread/sql/one_connection', 
                  CONCAT(processlist_user, '@', processlist_host), 
                  REPLACE(name, 'thread/', '')) AS enabled_threads,
        TYPE AS thread_type
          FROM performance_schema.threads
         WHERE INSTRUMENTED = 'YES';
    END IF;

    IF (in_show_instruments) THEN
        SELECT name AS enabled_instruments,
               timed
          FROM performance_schema.setup_instruments
         WHERE enabled = 'YES';
    END IF;
END$$

DELIMITER ;
/* Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; version 2 of the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA */

DROP PROCEDURE IF EXISTS ps_statement_avg_latency_histogram;

DELIMITER $$

CREATE DEFINER=CURRENT_USER PROCEDURE ps_statement_avg_latency_histogram ()
    COMMENT '
             Description
             -----------

             Outputs a textual histogram graph of the average latency values
             across all normalized queries tracked within the Performance Schema
             events_statements_summary_by_digest table.

             Can be used to show a very high level picture of what kind of 
             latency distribution statements running within this instance have.

             Parameters
             -----------

             None.

             Example
             -----------

             mysql> CALL sys.ps_statement_avg_latency_histogram()\G
             *************************** 1. row ***************************
             Performance Schema Statement Digest Average Latency Histogram:

               . = 1 unit
               * = 2 units
               # = 3 units

             (0 - 38ms)     240 | ################################################################################
             (38 - 77ms)    38  | ......................................
             (77 - 115ms)   3   | ...
             (115 - 154ms)  62  | *******************************
             (154 - 192ms)  3   | ...
             (192 - 231ms)  0   |
             (231 - 269ms)  0   |
             (269 - 307ms)  0   |
             (307 - 346ms)  0   |
             (346 - 384ms)  1   | .
             (384 - 423ms)  1   | .
             (423 - 461ms)  0   |
             (461 - 499ms)  0   |
             (499 - 538ms)  0   |
             (538 - 576ms)  0   |
             (576 - 615ms)  1   | .

               Total Statements: 350; Buckets: 16; Bucket Size: 38 ms;
            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    READS SQL DATA
BEGIN
SELECT CONCAT('\n',
       '\n  . = 1 unit',
       '\n  * = 2 units',
       '\n  # = 3 units\n',
       @label := CONCAT(@label_inner := CONCAT('\n(0 - ',
                                               ROUND((@bucket_size := (SELECT ROUND((MAX(avg_us) - MIN(avg_us)) / (@buckets := 16)) AS size
                                                                         FROM sys.x$ps_digest_avg_latency_distribution)) / (@unit_div := 1000)),
                                                (@unit := 'ms'), ')'),
                        REPEAT(' ', (@max_label_size := ((1 + LENGTH(ROUND((@bucket_size * 15) / @unit_div)) + 3 + LENGTH(ROUND(@bucket_size * 16) / @unit_div)) + 1)) - LENGTH(@label_inner)),
                        @count_in_bucket := IFNULL((SELECT SUM(cnt)
                                                      FROM sys.x$ps_digest_avg_latency_distribution AS b1 
                                                     WHERE b1.avg_us <= @bucket_size), 0)),
       REPEAT(' ', (@max_label_len := (@max_label_size + LENGTH((@total_queries := (SELECT SUM(cnt) FROM sys.x$ps_digest_avg_latency_distribution)))) + 1) - LENGTH(@label)), '| ',
       IFNULL(REPEAT(IF(@count_in_bucket < (@one_unit := 40), '.', IF(@count_in_bucket < (@two_unit := 80), '*', '#')), 
       	             IF(@count_in_bucket < @one_unit, @count_in_bucket,
       	             	IF(@count_in_bucket < @two_unit, @count_in_bucket / 2, @count_in_bucket / 3))), ''),

       @label := CONCAT(@label_inner := CONCAT('\n(', ROUND(@bucket_size / @unit_div), ' - ', ROUND((@bucket_size * 2) / @unit_div), @unit, ')'),
                        REPEAT(' ', @max_label_size - LENGTH(@label_inner)),
                        @count_in_bucket := IFNULL((SELECT SUM(cnt)
                                                      FROM sys.x$ps_digest_avg_latency_distribution AS b1 
                                                     WHERE b1.avg_us > @bucket_size AND b1.avg_us <= @bucket_size * 2), 0)),
       REPEAT(' ', @max_label_len - LENGTH(@label)), '| ',
       IFNULL(REPEAT(IF(@count_in_bucket < @one_unit, '.', IF(@count_in_bucket < @two_unit, '*', '#')), 
       	             IF(@count_in_bucket < @one_unit, @count_in_bucket,
       	             	IF(@count_in_bucket < @two_unit, @count_in_bucket / 2, @count_in_bucket / 3))), ''),
       @label := CONCAT(@label_inner := CONCAT('\n(', ROUND((@bucket_size * 2) / @unit_div), ' - ', ROUND((@bucket_size * 3) / @unit_div), @unit, ')'),
                        REPEAT(' ', @max_label_size - LENGTH(@label_inner)),
                        @count_in_bucket := IFNULL((SELECT SUM(cnt)
                                                      FROM sys.x$ps_digest_avg_latency_distribution AS b1 
                                                     WHERE b1.avg_us > @bucket_size * 2 AND b1.avg_us <= @bucket_size * 3), 0)),
       REPEAT(' ', @max_label_len - LENGTH(@label)), '| ',
       IFNULL(REPEAT(IF(@count_in_bucket < @one_unit, '.', IF(@count_in_bucket < @two_unit, '*', '#')), 
       	             IF(@count_in_bucket < @one_unit, @count_in_bucket,
       	             	IF(@count_in_bucket < @two_unit, @count_in_bucket / 2, @count_in_bucket / 3))), ''),
       @label := CONCAT(@label_inner := CONCAT('\n(', ROUND((@bucket_size * 3) / @unit_div), ' - ', ROUND((@bucket_size * 4) / @unit_div), @unit, ')'),
                        REPEAT(' ', @max_label_size - LENGTH(@label_inner)),
                        @count_in_bucket := IFNULL((SELECT SUM(cnt)
                                                      FROM sys.x$ps_digest_avg_latency_distribution AS b1 
                                                     WHERE b1.avg_us > @bucket_size * 3 AND b1.avg_us <= @bucket_size * 4), 0)),
       REPEAT(' ', @max_label_len - LENGTH(@label)), '| ',
       IFNULL(REPEAT(IF(@count_in_bucket < @one_unit, '.', IF(@count_in_bucket < @two_unit, '*', '#')), 
       	             IF(@count_in_bucket < @one_unit, @count_in_bucket,
       	             	IF(@count_in_bucket < @two_unit, @count_in_bucket / 2, @count_in_bucket / 3))), ''),
       @label := CONCAT(@label_inner := CONCAT('\n(', ROUND((@bucket_size * 4) / @unit_div), ' - ', ROUND((@bucket_size * 5) / @unit_div), @unit, ')'),
                        REPEAT(' ', @max_label_size - LENGTH(@label_inner)),
                        @count_in_bucket := IFNULL((SELECT SUM(cnt)
                                                      FROM sys.x$ps_digest_avg_latency_distribution AS b1 
                                                     WHERE b1.avg_us > @bucket_size * 4 AND b1.avg_us <= @bucket_size * 5), 0)),
       REPEAT(' ', @max_label_len - LENGTH(@label)), '| ',
       IFNULL(REPEAT(IF(@count_in_bucket < @one_unit, '.', IF(@count_in_bucket < @two_unit, '*', '#')), 
       	             IF(@count_in_bucket < @one_unit, @count_in_bucket,
       	             	IF(@count_in_bucket < @two_unit, @count_in_bucket / 2, @count_in_bucket / 3))), ''),
       @label := CONCAT(@label_inner := CONCAT('\n(', ROUND((@bucket_size * 5) / @unit_div), ' - ', ROUND((@bucket_size * 6) / @unit_div), @unit, ')'),
                        REPEAT(' ', @max_label_size - LENGTH(@label_inner)),
                        @count_in_bucket := IFNULL((SELECT SUM(cnt)
                                                      FROM sys.x$ps_digest_avg_latency_distribution AS b1 
                                                     WHERE b1.avg_us > @bucket_size * 5 AND b1.avg_us <= @bucket_size * 6), 0)),
       REPEAT(' ', @max_label_len - LENGTH(@label)), '| ',
       IFNULL(REPEAT(IF(@count_in_bucket < @one_unit, '.', IF(@count_in_bucket < @two_unit, '*', '#')), 
       	             IF(@count_in_bucket < @one_unit, @count_in_bucket,
       	             	IF(@count_in_bucket < @two_unit, @count_in_bucket / 2, @count_in_bucket / 3))), ''),
       @label := CONCAT(@label_inner := CONCAT('\n(', ROUND((@bucket_size * 6) / @unit_div), ' - ', ROUND((@bucket_size * 7) / @unit_div), @unit, ')'),
                        REPEAT(' ', @max_label_size - LENGTH(@label_inner)),
                        @count_in_bucket := IFNULL((SELECT SUM(cnt)
                                                      FROM sys.x$ps_digest_avg_latency_distribution AS b1 
                                                     WHERE b1.avg_us > @bucket_size * 6 AND b1.avg_us <= @bucket_size * 7), 0)),
       REPEAT(' ', @max_label_len - LENGTH(@label)), '| ',
       IFNULL(REPEAT(IF(@count_in_bucket < @one_unit, '.', IF(@count_in_bucket < @two_unit, '*', '#')), 
       	             IF(@count_in_bucket < @one_unit, @count_in_bucket,
       	             	IF(@count_in_bucket < @two_unit, @count_in_bucket / 2, @count_in_bucket / 3))), ''),
       @label := CONCAT(@label_inner := CONCAT('\n(', ROUND((@bucket_size * 7) / @unit_div), ' - ', ROUND((@bucket_size * 8) / @unit_div), @unit, ')'),
                        REPEAT(' ', @max_label_size - LENGTH(@label_inner)),
                        @count_in_bucket := IFNULL((SELECT SUM(cnt)
                                                      FROM sys.x$ps_digest_avg_latency_distribution AS b1 
                                                     WHERE b1.avg_us > @bucket_size * 7 AND b1.avg_us <= @bucket_size * 8), 0)),
       REPEAT(' ', @max_label_len - LENGTH(@label)), '| ',
       IFNULL(REPEAT(IF(@count_in_bucket < @one_unit, '.', IF(@count_in_bucket < @two_unit, '*', '#')), 
       	             IF(@count_in_bucket < @one_unit, @count_in_bucket,
       	             	IF(@count_in_bucket < @two_unit, @count_in_bucket / 2, @count_in_bucket / 3))), ''),
       @label := CONCAT(@label_inner := CONCAT('\n(', ROUND((@bucket_size * 8) / @unit_div), ' - ', ROUND((@bucket_size * 9) / @unit_div), @unit, ')'),
                        REPEAT(' ', @max_label_size - LENGTH(@label_inner)),
                        @count_in_bucket := IFNULL((SELECT SUM(cnt)
                                                      FROM sys.x$ps_digest_avg_latency_distribution AS b1 
                                                     WHERE b1.avg_us > @bucket_size * 8 AND b1.avg_us <= @bucket_size * 9), 0)),
       REPEAT(' ', @max_label_len - LENGTH(@label)), '| ',
       IFNULL(REPEAT(IF(@count_in_bucket < @one_unit, '.', IF(@count_in_bucket < @two_unit, '*', '#')), 
       	             IF(@count_in_bucket < @one_unit, @count_in_bucket,
       	             	IF(@count_in_bucket < @two_unit, @count_in_bucket / 2, @count_in_bucket / 3))), ''),
       @label := CONCAT(@label_inner := CONCAT('\n(', ROUND((@bucket_size * 9) / @unit_div), ' - ', ROUND((@bucket_size * 10) / @unit_div), @unit, ')'),
                         REPEAT(' ', @max_label_size - LENGTH(@label_inner)),
                         @count_in_bucket := IFNULL((SELECT SUM(cnt)
                                                       FROM sys.x$ps_digest_avg_latency_distribution AS b1 
                                                      WHERE b1.avg_us > @bucket_size * 9 AND b1.avg_us <= @bucket_size * 10), 0)),
       REPEAT(' ', @max_label_len - LENGTH(@label)), '| ',
       IFNULL(REPEAT(IF(@count_in_bucket < @one_unit, '.', IF(@count_in_bucket < @two_unit, '*', '#')), 
       	             IF(@count_in_bucket < @one_unit, @count_in_bucket,
       	             	IF(@count_in_bucket < @two_unit, @count_in_bucket / 2, @count_in_bucket / 3))), ''),
       @label := CONCAT(@label_inner := CONCAT('\n(', ROUND((@bucket_size * 10) / @unit_div), ' - ', ROUND((@bucket_size * 11) / @unit_div), @unit, ')'),
                        REPEAT(' ', @max_label_size - LENGTH(@label_inner)),
                        @count_in_bucket := IFNULL((SELECT SUM(cnt)
                                                      FROM sys.x$ps_digest_avg_latency_distribution AS b1 
                                                     WHERE b1.avg_us > @bucket_size * 10 AND b1.avg_us <= @bucket_size * 11), 0)),
       REPEAT(' ', @max_label_len - LENGTH(@label)), '| ',
       IFNULL(REPEAT(IF(@count_in_bucket < @one_unit, '.', IF(@count_in_bucket < @two_unit, '*', '#')), 
       	             IF(@count_in_bucket < @one_unit, @count_in_bucket,
       	             	IF(@count_in_bucket < @two_unit, @count_in_bucket / 2, @count_in_bucket / 3))), ''),
       @label := CONCAT(@label_inner := CONCAT('\n(', ROUND((@bucket_size * 11) / @unit_div), ' - ', ROUND((@bucket_size * 12) / @unit_div), @unit, ')'),
                        REPEAT(' ', @max_label_size - LENGTH(@label_inner)),
                        @count_in_bucket := IFNULL((SELECT SUM(cnt)
                                                      FROM sys.x$ps_digest_avg_latency_distribution AS b1 
                                                     WHERE b1.avg_us > @bucket_size * 11 AND b1.avg_us <= @bucket_size * 12), 0)),
       REPEAT(' ', @max_label_len - LENGTH(@label)), '| ',
       IFNULL(REPEAT(IF(@count_in_bucket < @one_unit, '.', IF(@count_in_bucket < @two_unit, '*', '#')), 
       	             IF(@count_in_bucket < @one_unit, @count_in_bucket,
       	             	IF(@count_in_bucket < @two_unit, @count_in_bucket / 2, @count_in_bucket / 3))), ''),
       @label := CONCAT(@label_inner := CONCAT('\n(', ROUND((@bucket_size * 12) / @unit_div), ' - ', ROUND((@bucket_size * 13) / @unit_div), @unit, ')'),
                        REPEAT(' ', @max_label_size - LENGTH(@label_inner)),
                        @count_in_bucket := IFNULL((SELECT SUM(cnt)
                                                      FROM sys.x$ps_digest_avg_latency_distribution AS b1 
                                                     WHERE b1.avg_us > @bucket_size * 12 AND b1.avg_us <= @bucket_size * 13), 0)),
       REPEAT(' ', @max_label_len - LENGTH(@label)), '| ',
       IFNULL(REPEAT(IF(@count_in_bucket < @one_unit, '.', IF(@count_in_bucket < @two_unit, '*', '#')), 
       	             IF(@count_in_bucket < @one_unit, @count_in_bucket,
       	             	IF(@count_in_bucket < @two_unit, @count_in_bucket / 2, @count_in_bucket / 3))), ''),
       @label := CONCAT(@label_inner := CONCAT('\n(', ROUND((@bucket_size * 13) / @unit_div), ' - ', ROUND((@bucket_size * 14) / @unit_div), @unit, ')'),
                        REPEAT(' ', @max_label_size - LENGTH(@label_inner)),
                        @count_in_bucket := IFNULL((SELECT SUM(cnt)
                                                      FROM sys.x$ps_digest_avg_latency_distribution AS b1 
                                                     WHERE b1.avg_us > @bucket_size * 13 AND b1.avg_us <= @bucket_size * 14), 0)),
       REPEAT(' ', @max_label_len - LENGTH(@label)), '| ',
       IFNULL(REPEAT(IF(@count_in_bucket < @one_unit, '.', IF(@count_in_bucket < @two_unit, '*', '#')), 
       	             IF(@count_in_bucket < @one_unit, @count_in_bucket,
       	             	IF(@count_in_bucket < @two_unit, @count_in_bucket / 2, @count_in_bucket / 3))), ''),
       @label := CONCAT(@label_inner := CONCAT('\n(', ROUND((@bucket_size * 14) / @unit_div), ' - ', ROUND((@bucket_size * 15) / @unit_div), @unit, ')'),
                        REPEAT(' ', @max_label_size - LENGTH(@label_inner)),
                        @count_in_bucket := IFNULL((SELECT SUM(cnt)
                                                      FROM sys.x$ps_digest_avg_latency_distribution AS b1 
                                                     WHERE b1.avg_us > @bucket_size * 14 AND b1.avg_us <= @bucket_size * 15), 0)),
       REPEAT(' ', @max_label_len - LENGTH(@label)), '| ',
       IFNULL(REPEAT(IF(@count_in_bucket < @one_unit, '.', IF(@count_in_bucket < @two_unit, '*', '#')), 
       	             IF(@count_in_bucket < @one_unit, @count_in_bucket,
       	             	IF(@count_in_bucket < @two_unit, @count_in_bucket / 2, @count_in_bucket / 3))), ''),
       @label := CONCAT(@label_inner := CONCAT('\n(', ROUND((@bucket_size * 15) / @unit_div), ' - ', ROUND((@bucket_size * 16) / @unit_div), @unit, ')'),
                        REPEAT(' ', @max_label_size - LENGTH(@label_inner)),
                        @count_in_bucket := IFNULL((SELECT SUM(cnt)
                                                      FROM sys.x$ps_digest_avg_latency_distribution AS b1 
                                                     WHERE b1.avg_us > @bucket_size * 15 AND b1.avg_us <= @bucket_size * 16), 0)),
       REPEAT(' ', @max_label_len - LENGTH(@label)), '| ',
       IFNULL(REPEAT(IF(@count_in_bucket < @one_unit, '.', IF(@count_in_bucket < @two_unit, '*', '#')), 
       	             IF(@count_in_bucket < @one_unit, @count_in_bucket,
       	             	IF(@count_in_bucket < @two_unit, @count_in_bucket / 2, @count_in_bucket / 3))), ''),

       '\n\n  Total Statements: ', @total_queries, '; Buckets: ', @buckets , '; Bucket Size: ', ROUND(@bucket_size / @unit_div) , ' ', @unit, ';\n'

      ) AS `Performance Schema Statement Digest Average Latency Histogram`;

END $$

DELIMITER ;
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

DROP PROCEDURE IF EXISTS ps_trace_statement_digest;

DELIMITER $$

CREATE DEFINER=CURRENT_USER PROCEDURE ps_trace_statement_digest (
        IN in_digest VARCHAR(32),
        IN in_runtime INT, 
        IN in_interval DECIMAL(2,2),
        IN in_start_fresh BOOLEAN,
        IN in_auto_enable BOOLEAN
    )
    COMMENT '
             Description
             -----------

             Traces all instrumentation within Performance Schema for a specific
             Statement Digest. 

             When finding a statement of interest within the 
             performance_schema.events_statements_summary_by_digest table, feed
             the DIGEST MD5 value in to this procedure, set how long to poll for, 
             and at what interval to poll, and it will generate a report of all 
             statistics tracked within Performance Schema for that digest for the
             interval.

             It will also attempt to generate an EXPLAIN for the longest running 
             example of the digest during the interval. Note this may fail, as
             Performance Schema truncates long SQL_TEXT values (and hence the 
             EXPLAIN will fail due to parse errors).

             Parameters
             -----------

             in_digest (VARCHAR(32)):
               The statement digest identifier you would like to analyze
             in_runtime (INT):
               The number of seconds to run analysis for (defaults to a minute)
             in_interval (DECIMAL(2,2)):
               The interval (in seconds, may be fractional) at which to try
               and take snapshots (defaults to a second)
             in_start_fresh (BOOLEAN):
               Whether to TRUNCATE the events_statements_history_long and
               events_stages_history_long tables before starting (default false)
             in_auto_enable (BOOLEAN):
               Whether to automatically turn on required consumers (default false)

             Example
             -----------

             mysql> call ps_analyze_statement_digest(\'891ec6860f98ba46d89dd20b0c03652c\', 10, 0.1, true, true);
             +--------------------+
             | SUMMARY STATISTICS |
             +--------------------+
             | SUMMARY STATISTICS |
             +--------------------+
             1 row in set (9.11 sec)

             +------------+-----------+-----------+-----------+---------------+------------+------------+
             | executions | exec_time | lock_time | rows_sent | rows_examined | tmp_tables | full_scans |
             +------------+-----------+-----------+-----------+---------------+------------+------------+
             |         21 | 4.11 ms   | 2.00 ms   |         0 |            21 |          0 |          0 |
             +------------+-----------+-----------+-----------+---------------+------------+------------+
             1 row in set (9.11 sec)

             +------------------------------------------+-------+-----------+
             | event_name                               | count | latency   |
             +------------------------------------------+-------+-----------+
             | stage/sql/checking query cache for query |    16 | 724.37 µs |
             | stage/sql/statistics                     |    16 | 546.92 µs |
             | stage/sql/freeing items                  |    18 | 520.11 µs |
             | stage/sql/init                           |    51 | 466.80 µs |
             ...
             | stage/sql/cleaning up                    |    18 | 11.92 µs  |
             | stage/sql/executing                      |    16 | 6.95 µs   |
             +------------------------------------------+-------+-----------+
             17 rows in set (9.12 sec)

             +---------------------------+
             | LONGEST RUNNING STATEMENT |
             +---------------------------+
             | LONGEST RUNNING STATEMENT |
             +---------------------------+
             1 row in set (9.16 sec)
             
             +-----------+-----------+-----------+-----------+---------------+------------+-----------+
             | thread_id | exec_time | lock_time | rows_sent | rows_examined | tmp_tables | full_scan |
             +-----------+-----------+-----------+-----------+---------------+------------+-----------+
             |    166646 | 618.43 µs | 1.00 ms   |         0 |             1 |          0 |         0 |
             +-----------+-----------+-----------+-----------+---------------+------------+-----------+
             1 row in set (9.16 sec)

             // Truncated for clarity...
             +-----------------------------------------------------------------+
             | sql_text                                                        |
             +-----------------------------------------------------------------+
             | select hibeventhe0_.id as id1382_, hibeventhe0_.createdTime ... |
             +-----------------------------------------------------------------+
             1 row in set (9.17 sec)

             +------------------------------------------+-----------+
             | event_name                               | latency   |
             +------------------------------------------+-----------+
             | stage/sql/init                           | 8.61 µs   |
             | stage/sql/Waiting for query cache lock   | 453.23 µs |
             | stage/sql/init                           | 331.07 ns |
             | stage/sql/checking query cache for query | 43.04 µs  |
             ...
             | stage/sql/freeing items                  | 30.46 µs  |
             | stage/sql/cleaning up                    | 662.13 ns |
             +------------------------------------------+-----------+
             18 rows in set (9.23 sec)

             +----+-------------+--------------+-------+---------------+-----------+---------+-------------+------+-------+
             | id | select_type | table        | type  | possible_keys | key       | key_len | ref         | rows | Extra |
             +----+-------------+--------------+-------+---------------+-----------+---------+-------------+------+-------+
             |  1 | SIMPLE      | hibeventhe0_ | const | fixedTime     | fixedTime | 775     | const,const |    1 | NULL  |
             +----+-------------+--------------+-------+---------------+-----------+---------+-------------+------+-------+
             1 row in set (9.27 sec)

             Query OK, 0 rows affected (9.28 sec)
            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    MODIFIES SQL DATA
BEGIN

    DECLARE v_start_fresh BOOLEAN DEFAULT false;
    DECLARE v_auto_enable BOOLEAN DEFAULT false;
    DECLARE v_runtime INT DEFAULT 0;
    DECLARE v_start INT DEFAULT 0;
    DECLARE v_found_stmts INT;

    /* Do not track the current thread, it will kill the stack */
    CALL sys.ps_setup_disable_thread(CONNECTION_ID());

    DROP TEMPORARY TABLE IF EXISTS stmt_trace;
    CREATE TEMPORARY TABLE stmt_trace (
        thread_id BIGINT,
        timer_start BIGINT,
        event_id BIGINT,
        sql_text longtext,
        timer_wait BIGINT,
        lock_time BIGINT,
        errors BIGINT,
        mysql_errno BIGINT,
        rows_sent BIGINT,
        rows_affected BIGINT,
        rows_examined BIGINT,
        created_tmp_tables BIGINT,
        created_tmp_disk_tables BIGINT,
        no_index_used BIGINT,
        PRIMARY KEY (thread_id, timer_start)
    );

    DROP TEMPORARY TABLE IF EXISTS stmt_stages;
    CREATE TEMPORARY TABLE stmt_stages (
       event_id BIGINT,
       stmt_id BIGINT,
       event_name VARCHAR(128),
       timer_wait BIGINT,
       PRIMARY KEY (event_id)
    );

    SET v_start_fresh = in_start_fresh;
    IF v_start_fresh THEN
        TRUNCATE TABLE performance_schema.events_statements_history_long;
        TRUNCATE TABLE performance_schema.events_stages_history_long;
    END IF;

    SET v_auto_enable = in_auto_enable;
    IF v_auto_enable THEN
        CALL sys.ps_setup_save(0);
    END IF;

    WHILE v_runtime < in_runtime DO
        SELECT UNIX_TIMESTAMP() INTO v_start;

        INSERT IGNORE INTO stmt_trace
        SELECT thread_id, timer_start, event_id, sql_text, timer_wait, lock_time, errors, mysql_errno, 
               rows_sent, rows_affected, rows_examined, created_tmp_tables, created_tmp_disk_tables, no_index_used
          FROM performance_schema.events_statements_history_long
        WHERE digest = in_digest;

        INSERT IGNORE INTO stmt_stages
        SELECT stages.event_id, stmt_trace.event_id,
               stages.event_name, stages.timer_wait
          FROM performance_schema.events_stages_history_long AS stages
          JOIN stmt_trace ON stages.nesting_event_id = stmt_trace.event_id;

        SELECT SLEEP(in_interval) INTO @sleep;
        SET v_runtime = v_runtime + (UNIX_TIMESTAMP() - v_start);
    END WHILE;

    SELECT "SUMMARY STATISTICS";

    SELECT COUNT(*) executions,
           sys.format_time(SUM(timer_wait)) AS exec_time,
           sys.format_time(SUM(lock_time)) AS lock_time,
           SUM(rows_sent) AS rows_sent,
           SUM(rows_affected) AS rows_affected,
           SUM(rows_examined) AS rows_examined,
           SUM(created_tmp_tables) AS tmp_tables,
           SUM(no_index_used) AS full_scans
      FROM stmt_trace;

    SELECT event_name,
           COUNT(*) as count,
           sys.format_time(SUM(timer_wait)) as latency
      FROM stmt_stages
     GROUP BY event_name
     ORDER BY SUM(timer_wait) DESC;

    SELECT "LONGEST RUNNING STATEMENT";

    SELECT thread_id,
           sys.format_time(timer_wait) AS exec_time,
           sys.format_time(lock_time) AS lock_time,
           rows_sent,
           rows_affected,
           rows_examined,
           created_tmp_tables AS tmp_tables,
           no_index_used AS full_scan
      FROM stmt_trace
     ORDER BY timer_wait DESC LIMIT 1;

    SELECT sql_text
      FROM stmt_trace
     ORDER BY timer_wait DESC LIMIT 1;

    SELECT sql_text, event_id INTO @sql, @sql_id
      FROM stmt_trace
    ORDER BY timer_wait DESC LIMIT 1;

    SELECT event_name,
           sys.format_time(timer_wait) as latency
      FROM stmt_stages
     WHERE stmt_id = @sql_id
     ORDER BY event_id;

    DROP TEMPORARY TABLE stmt_trace;
    DROP TEMPORARY TABLE stmt_stages;

    SET @stmt := CONCAT("EXPLAIN FORMAT=JSON", @sql);
    PREPARE explain_stmt FROM @stmt;
    EXECUTE explain_stmt;
    DEALLOCATE PREPARE explain_stmt;

    IF v_auto_enable THEN
        CALL sys.ps_reload_saved();
        CALL sys.ps_setup_enable_thread(CONNECTION_ID());
    END IF;

END$$

DELIMITER ;
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

DROP PROCEDURE IF EXISTS ps_trace_thread;

DELIMITER $$
CREATE DEFINER=CURRENT_USER PROCEDURE ps_trace_thread (
        IN in_thread_id INT,
        IN in_outfile VARCHAR(255),
        IN in_max_runtime DECIMAL(20,2),
        IN in_interval DECIMAL(20,2),
        IN in_start_fresh BOOLEAN,
        IN in_auto_setup BOOLEAN,
        IN in_debug BOOLEAN
    )
    COMMENT '
             Description
             -----------

             Dumps all data within Performance Schema for an instrumented thread,
             to create a DOT formatted graph file. 

             Each resultset returned from the procedure should be used for a complete graph

             Parameters
             -----------

             in_thread_id (INT): 
               The thread that you would like a stack trace for
             in_outfile  (VARCHAR(255)):
               The filename the dot file will be written to
             in_max_runtime (DECIMAL(20,2)):
               The maximum time to keep collecting data.
               Use NULL to get the default which is 60 seconds.
             in_interval (DECIMAL(20,2)): 
               How long to sleep between data collections. 
               Use NULL to get the default which is 1 second.
             in_start_fresh (BOOLEAN):
               Whether to reset all Performance Schema data before tracing.
             in_auto_setup (BOOLEAN):
               Whether to disable all other threads and enable all consumers/instruments. 
               This will also reset the settings at the end of the run.
             in_debug (BOOLEAN):
               Whether you would like to include file:lineno in the graph

             Example
             -----------

             mysql> CALL sys.ps_dump_thread_stack(25, CONCAT(\'/tmp/stack-\', REPLACE(NOW(), \' \', \'-\'), \'.dot\'), NULL, NULL, TRUE, TRUE, TRUE);
             +-------------------+
             | summary           |
             +-------------------+
             | Disabled 1 thread |
             +-------------------+
             1 row in set (0.00 sec)

             +---------------------------------------------+
             | Info                                        |
             +---------------------------------------------+
             | Data collection starting for THREAD_ID = 25 |
             +---------------------------------------------+
             1 row in set (0.03 sec)

             +-----------------------------------------------------------+
             | Info                                                      |
             +-----------------------------------------------------------+
             | Stack trace written to /tmp/stack-2014-02-16-21:18:41.dot |
             +-----------------------------------------------------------+
             1 row in set (60.07 sec)

             +-------------------------------------------------------------------+
             | Convert to PDF                                                    |
             +-------------------------------------------------------------------+
             | dot -Tpdf -o /tmp/stack_25.pdf /tmp/stack-2014-02-16-21:18:41.dot |
             +-------------------------------------------------------------------+
             1 row in set (60.07 sec)

             +-------------------------------------------------------------------+
             | Convert to PNG                                                    |
             +-------------------------------------------------------------------+
             | dot -Tpng -o /tmp/stack_25.png /tmp/stack-2014-02-16-21:18:41.dot |
             +-------------------------------------------------------------------+
             1 row in set (60.07 sec)

             +------------------+
             | summary          |
             +------------------+
             | Enabled 1 thread |
             +------------------+
             1 row in set (60.32 sec)
            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    MODIFIES SQL DATA
BEGIN
    DECLARE v_done bool DEFAULT FALSE;
    DECLARE v_start, v_runtime DECIMAL(20,2) DEFAULT 0.0;
    DECLARE v_min_event_id bigint unsigned DEFAULT 0;
    DECLARE v_event longtext;
    DECLARE c_stack CURSOR FOR
        SELECT CONCAT(IF(nesting_event_id IS NOT NULL, CONCAT(nesting_event_id, ' -> '), ''), 
                    event_id, '; ', event_id, ' [label="',
                    /* Convert from picoseconds to microseconds */
                    '(', sys.format_time(timer_wait), ') ',
                    IF (event_name NOT LIKE 'wait/io%', 
                        SUBSTRING_INDEX(event_name, '/', -2), 
                        IF (event_name NOT LIKE 'wait/io/file%' OR event_name NOT LIKE 'wait/io/socket%',
                            SUBSTRING_INDEX(event_name, '/', -4),
                            event_name)
                        ),
                    /* Always dump the extra wait information gathered for statements */
                    IF (event_name LIKE 'statement/%', IFNULL(CONCAT('\\n', wait_info), ''), ''),
                    /* If debug is enabled, add the file:lineno information for waits */
                    IF (in_debug AND event_name LIKE 'wait%', wait_info, ''),
                    '", ', 
                    /* Depending on the type of event, style appropriately */
                    CASE WHEN event_name LIKE 'wait/io/file%' THEN 
                           'shape=box, style=filled, color=red'
                         WHEN event_name LIKE 'wait/io/table%' THEN 
                           'shape=box, style=filled, color=green'
                         WHEN event_name LIKE 'wait/io/socket%' THEN
                           'shape=box, style=filled, color=yellow'
                         WHEN event_name LIKE 'wait/synch/mutex%' THEN
                           'style=filled, color=lightskyblue'
                         WHEN event_name LIKE 'wait/synch/cond%' THEN
                           'style=filled, color=darkseagreen3'
                         WHEN event_name LIKE 'wait/synch/rwlock%' THEN
                           'style=filled, color=orchid'
                         WHEN event_name LIKE 'wait/lock%' THEN
                           'shape=box, style=filled, color=tan'
                         WHEN event_name LIKE 'statement/%' THEN
                           CONCAT('shape=box, style=bold',
                                  /* Style statements depending on COM vs SQL */
                                  CASE WHEN event_name LIKE 'statement/com/%' THEN
                                         ' style=filled, color=darkseagreen'
                                       ELSE
                                         /* Use long query time from the server to
                                            flag long running statements in red */
                                         IF((timer_wait/1000000000000) > @@long_query_time, 
                                            ' style=filled, color=red', 
                                            ' style=filled, color=lightblue')
                                  END
                           )
                         WHEN event_name LIKE 'stage/%' THEN
                           'style=filled, color=slategray3'
                         /* IDLE events are on their own, call attention to them */
                         WHEN event_name LIKE '%idle%' THEN
                           'shape=box, style=filled, color=firebrick3'
                         ELSE '' END,
                     '];\n'
                   ) event, event_id
        FROM (
             /* Select all statements, with the extra tracing information available */
             (SELECT thread_id, event_id, event_name, timer_wait, timer_start, nesting_event_id, 
                     CONCAT(sql_text, '\\n',
                            'errors: ', errors, '\\n',
                            'warnings: ', warnings, '\\n',
                            'lock time: ', sys.format_time(lock_time),'\\n',
                            'rows affected: ', rows_affected, '\\n',
                            'rows sent: ', rows_sent, '\\n',
                            'rows examined: ', rows_examined, '\\n',
                            'tmp tables: ', created_tmp_tables, '\\n',
                            'tmp disk tables: ', created_tmp_disk_tables, '\\n'
                            'select scan: ', select_scan, '\\n',
                            'select full join: ', select_full_join, '\\n',
                            'select full range join: ', select_full_range_join, '\\n',
                            'select range: ', select_range, '\\n',
                            'select range check: ', select_range_check, '\\n', 
                            'sort merge passes: ', sort_merge_passes, '\\n',
                            'sort rows: ', sort_rows, '\\n',
                            'sort range: ', sort_range, '\\n',
                            'sort scan: ', sort_scan, '\\n',
                            'no index used: ', IF(no_index_used, 'TRUE', 'FALSE'), '\\n',
                            'no good index used: ', IF(no_good_index_used, 'TRUE', 'FALSE'), '\\n'
                     ) AS wait_info
                FROM performance_schema.events_statements_history_long
               WHERE thread_id = in_thread_id AND event_id > v_min_event_id)
             UNION
             /* Select all stages */
             (SELECT thread_id, event_id, event_name, timer_wait, timer_start, nesting_event_id, null AS wait_info
                FROM performance_schema.events_stages_history_long 
               WHERE thread_id = in_thread_id AND event_id > v_min_event_id)
             UNION 
             /* Select all events, adding information appropriate to the event */
             (SELECT thread_id, event_id, 
                     CONCAT(event_name, 
                            IF(event_name NOT LIKE 'wait/synch/mutex%', IFNULL(CONCAT(' - ', operation), ''), ''), 
                            IF(number_of_bytes IS NOT NULL, CONCAT(' ', number_of_bytes, ' bytes'), ''),
                            IF(event_name LIKE 'wait/io/file%', '\\n', ''),
                            IF(object_schema IS NOT NULL, CONCAT('\\nObject: ', object_schema, '.'), ''), 
                            IF(object_name IS NOT NULL, 
                               IF (event_name LIKE 'wait/io/socket%',
                                   /* Print the socket if used, else the IP:port as reported */
                                   CONCAT('\\n', IF (object_name LIKE ':0%', @@socket, object_name)),
                                   object_name),
                               ''
                            ),
                            IF(index_name IS NOT NULL, CONCAT(' Index: ', index_name), ''), '\\n'
                     ) AS event_name,
                     timer_wait, timer_start, nesting_event_id, source AS wait_info
                FROM performance_schema.events_waits_history_long
               WHERE thread_id = in_thread_id AND event_id > v_min_event_id)
           ) events 
       ORDER BY event_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    /* Do not track the current thread, it will kill the stack */
    CALL sys.ps_setup_disable_thread(CONNECTION_ID());

    IF (in_auto_setup) THEN
        CALL sys.ps_setup_save(0);
        
        /* Ensure only the thread to create the stack trace for is instrumented and that we instrument
           everything. */
        DELETE FROM performance_schema.setup_actors;

        UPDATE performance_schema.threads
           SET INSTRUMENTED = IF(THREAD_ID = in_thread_id, 'YES', 'NO');

        UPDATE performance_schema.setup_consumers
           SET ENABLED = 'YES'
         WHERE NAME NOT LIKE '%\_history'; -- only the %_history_long tables and it ancestors are needed

        UPDATE performance_schema.setup_instruments
           SET ENABLED = 'YES',
               TIMED   = 'YES';
    END IF;

    IF (in_start_fresh) THEN
        TRUNCATE performance_schema.events_statements_history_long;
        TRUNCATE performance_schema.events_stages_history_long;
        TRUNCATE performance_schema.events_waits_history_long;
    END IF;

    DROP TEMPORARY TABLE IF EXISTS tmp_events;
    CREATE TEMPORARY TABLE tmp_events (
      event_id bigint unsigned NOT NULL,
      event longblob,
      PRIMARY KEY (event_id)
    );

    /* Print headers for a .dot file */
    INSERT INTO tmp_events VALUES (0, CONCAT('digraph events { rankdir=LR; nodesep=0.10;\n',
                                             '// Stack created .....: ', NOW(), '\n',
                                             '// MySQL version .....: ', VERSION(), '\n',
                                             '// MySQL hostname ....: ', @@hostname, '\n',
                                             '// MySQL port ........: ', @@port, '\n',
                                             '// MySQL socket ......: ', @@socket, '\n',
                                             '// MySQL user ........: ', CURRENT_USER(), '\n'));

    SELECT CONCAT('Data collection starting for THREAD_ID = ', in_thread_id) AS 'Info';

    SET v_min_event_id = 0,
        v_start        = UNIX_TIMESTAMP(),
        in_interval    = IFNULL(in_interval, 1.00),
        in_max_runtime = IFNULL(in_max_runtime, 60.00);

    WHILE (v_runtime < in_max_runtime
           AND (SELECT INSTRUMENTED FROM performance_schema.threads WHERE THREAD_ID = in_thread_id) = 'YES') DO
        SET v_done = FALSE;
        OPEN c_stack;
        c_stack_loop: LOOP
            FETCH c_stack INTO v_event, v_min_event_id;
            IF v_done THEN
                LEAVE c_stack_loop;
            END IF;

            IF (LENGTH(v_event) > 0) THEN
                INSERT INTO tmp_events VALUES (v_min_event_id, v_event);
            END IF;
        END LOOP;
        CLOSE c_stack;

        SELECT SLEEP(in_interval) INTO @sleep;
        SET v_runtime = v_runtime + (UNIX_TIMESTAMP() - v_start);
    END WHILE;

    INSERT INTO tmp_events VALUES (v_min_event_id+1, '}');
   
    SET @query = CONCAT('SELECT event FROM tmp_events ORDER BY event_id INTO OUTFILE ''', in_outfile, ''' FIELDS ESCAPED BY '''' LINES TERMINATED BY ''''');
    PREPARE stmt_output FROM @query;
    EXECUTE stmt_output;
    DEALLOCATE PREPARE stmt_output;
   
    SELECT CONCAT('Stack trace written to ', in_outfile) AS 'Info';
    SELECT CONCAT('dot -Tpdf -o /tmp/stack_', in_thread_id, '.pdf ', in_outfile) AS 'Convert to PDF';
    SELECT CONCAT('dot -Tpng -o /tmp/stack_', in_thread_id, '.png ', in_outfile) AS 'Convert to PNG';
    DROP TEMPORARY TABLE tmp_events;

    /* Reset the settings for the performance schema */
    IF (in_auto_setup) THEN
        CALL sys.ps_setup_reload_saved();
        CALL sys.ps_setup_enable_thread(CONNECTION_ID());
    END IF;
END$$

DELIMITER ;
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

DROP PROCEDURE IF EXISTS ps_truncate_all_tables;

DELIMITER $$

CREATE DEFINER=CURRENT_USER PROCEDURE ps_truncate_all_tables (
        IN in_verbose BOOLEAN
    )
    COMMENT '
             Description
             -----------

             Truncates all summary tables within Performance Schema, 
             resetting all aggregated instrumentation as a snapshot.


             Parameters
             -----------

             in_verbose (BOOLEAN):
               Whether to print each TRUNCATE statement before running

             Example
             -----------

             mysql> CALL sys.ps_truncate_all_tables(false);
             +---------------------+
             | summary             |
             +---------------------+
             | Truncated 44 tables |
             +---------------------+
             1 row in set (0.10 sec)

             Query OK, 0 rows affected (0.10 sec)
            '
    SQL SECURITY INVOKER
    DETERMINISTIC
    MODIFIES SQL DATA
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_total_tables INT DEFAULT 0;
    DECLARE v_ps_table VARCHAR(64);
    DECLARE ps_tables CURSOR FOR
        SELECT table_name 
          FROM INFORMATION_SCHEMA.TABLES 
         WHERE table_schema = 'performance_schema' 
           AND (table_name LIKE '%summary%' 
            OR table_name LIKE '%history%');
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;


    OPEN ps_tables;

    ps_tables_loop: LOOP
        FETCH ps_tables INTO v_ps_table;
        IF v_done THEN
          LEAVE ps_tables_loop;
        END IF;

        SET @truncate_stmt := CONCAT('TRUNCATE TABLE performance_schema.', v_ps_table);
        IF in_verbose THEN
            SELECT CONCAT('Running: ', @truncate_stmt) AS status;
        END IF;

        PREPARE truncate_stmt FROM @truncate_stmt;
        EXECUTE truncate_stmt;
        DEALLOCATE PREPARE truncate_stmt;

        SET v_total_tables = v_total_tables + 1;
    END LOOP;

    CLOSE ps_tables;


    SELECT CONCAT('Truncated ', v_total_tables, ' tables') AS summary;

END$$

DELIMITER ;
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
 * View: innodb_buffer_stats_by_schema
 * 
 * Summarizes the output of the INFORMATION_SCHEMA.INNODB_BUFFER_PAGE 
 * table, aggregating by schema
 *
 * 
 * mysql> select * from innodb_buffer_stats_by_schema;
 * +--------------------------+------------+------------+-------+--------------+-----------+-------------+
 * | object_schema            | allocated  | data       | pages | pages_hashed | pages_old | rows_cached |
 * +--------------------------+------------+------------+-------+--------------+-----------+-------------+
 * | mem30_trunk__instruments | 1.69 MiB   | 510.03 KiB |   108 |          108 |       108 |        3885 |
 * | InnoDB System            | 688.00 KiB | 351.62 KiB |    43 |           43 |        43 |         862 |
 * | mem30_trunk__events      | 80.00 KiB  | 21.61 KiB  |     5 |            5 |         5 |         229 |
 * +--------------------------+------------+------------+-------+--------------+-----------+-------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW innodb_buffer_stats_by_schema (
  object_schema,
  allocated,
  data,
  pages,
  pages_hashed,
  pages_old,
  rows_cached
) AS
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
 ORDER BY SUM(IF(ibp.compressed_size = 0, 16384, compressed_size)) DESC;

/* 
 * View: x$innodb_buffer_stats_by_schema
 * 
 * Summarizes the output of the INFORMATION_SCHEMA.INNODB_BUFFER_PAGE 
 * table, aggregating by schema
 *
 * mysql> select * from x$innodb_buffer_stats_by_schema;
 * +--------------------------+-----------+--------+-------+--------------+-----------+-------------+
 * | object_schema            | allocated | data   | pages | pages_hashed | pages_old | rows_cached |
 * +--------------------------+-----------+--------+-------+--------------+-----------+-------------+
 * | mem30_trunk__instruments |   1769472 | 522272 |   108 |          108 |       108 |        3885 |
 * | InnoDB System            |    704512 | 360054 |    43 |           43 |        43 |         862 |
 * | mem30_trunk__events      |     81920 |  22125 |     5 |            5 |         5 |         229 |
 * +--------------------------+-----------+--------+-------+--------------+-----------+-------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$innodb_buffer_stats_by_schema (
  object_schema,
  allocated,
  data,
  pages,
  pages_hashed,
  pages_old,
  rows_cached
) AS
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
 ORDER BY SUM(IF(ibp.compressed_size = 0, 16384, compressed_size)) DESC;
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
 * View: innodb_buffer_stats_by_table
 * 
 * Summarizes the output of the INFORMATION_SCHEMA.INNODB_BUFFER_PAGE 
 * table, aggregating by schema and table name
 *
 * mysql> select * from innodb_buffer_stats_by_table;
 * +--------------------------+------------------------------------+------------+-----------+-------+--------------+-----------+-------------+
 * | object_schema            | object_name                        | allocated  | data      | pages | pages_hashed | pages_old | rows_cached |
 * +--------------------------+------------------------------------+------------+-----------+-------+--------------+-----------+-------------+
 * | InnoDB System            | SYS_COLUMNS                        | 128.00 KiB | 98.97 KiB |     8 |            8 |         8 |        1532 |
 * | InnoDB System            | SYS_FOREIGN                        | 128.00 KiB | 55.48 KiB |     8 |            8 |         8 |         172 |
 * | InnoDB System            | SYS_TABLES                         | 128.00 KiB | 56.18 KiB |     8 |            8 |         8 |         365 |
 * | InnoDB System            | SYS_INDEXES                        | 112.00 KiB | 76.16 KiB |     7 |            7 |         7 |        1046 |
 * | mem30_trunk__instruments | agentlatencytime                   | 96.00 KiB  | 28.83 KiB |     6 |            6 |         6 |         252 |
 * | mem30_trunk__instruments | binlogspaceusagedata               | 96.00 KiB  | 22.54 KiB |     6 |            6 |         6 |         196 |
 * | mem30_trunk__instruments | connectionsdata                    | 96.00 KiB  | 36.68 KiB |     6 |            6 |         6 |         276 |
 * ...
 * +--------------------------+------------------------------------+------------+-----------+-------+--------------+-----------+-------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW innodb_buffer_stats_by_table (
  object_schema,
  object_name,
  allocated,
  data,
  pages,
  pages_hashed,
  pages_old,
  rows_cached
) AS
SELECT IF(LOCATE('.', ibp.table_name) = 0, 'InnoDB System', REPLACE(SUBSTRING_INDEX(ibp.table_name, '.', 1), '`', '')) AS object_schema,
       REPLACE(SUBSTRING_INDEX(ibp.table_name, '.', -1), '`', '') AS object_name,
       sys.format_bytes(SUM(IF(ibp.compressed_size = 0, 16384, compressed_size))) AS allocated,
       sys.format_bytes(SUM(ibp.data_size)) AS data,
       COUNT(ibp.page_number) AS pages,
       COUNT(IF(ibp.is_hashed = 'YES', 1, 0)) AS pages_hashed,
       COUNT(IF(ibp.is_old = 'YES', 1, 0)) AS pages_old,
       ROUND(SUM(ibp.number_records)/COUNT(DISTINCT ibp.index_name)) AS rows_cached 
  FROM information_schema.innodb_buffer_page ibp 
 WHERE table_name IS NOT NULL
 GROUP BY object_schema, object_name
 ORDER BY SUM(IF(ibp.compressed_size = 0, 16384, compressed_size)) DESC;

/* View: x$innodb_buffer_stats_by_table
 * 
 * Summarizes the output of the INFORMATION_SCHEMA.INNODB_BUFFER_PAGE 
 * table, aggregating by schema and table name
 *
 * mysql> select * from x$innodb_buffer_stats_by_table;
 * +--------------------------+------------------------------------+-----------+--------+-------+--------------+-----------+-------------+
 * | object_schema            | object_name                        | allocated | data   | pages | pages_hashed | pages_old | rows_cached |
 * +--------------------------+------------------------------------+-----------+--------+-------+--------------+-----------+-------------+
 * | InnoDB System            | SYS_COLUMNS                        |    131072 | 101350 |     8 |            8 |         8 |        1532 |
 * | InnoDB System            | SYS_FOREIGN                        |    131072 |  56808 |     8 |            8 |         8 |         172 |
 * | InnoDB System            | SYS_TABLES                         |    131072 |  57529 |     8 |            8 |         8 |         365 |
 * | InnoDB System            | SYS_INDEXES                        |    114688 |  77984 |     7 |            7 |         7 |        1046 |
 * | mem30_trunk__instruments | agentlatencytime                   |     98304 |  29517 |     6 |            6 |         6 |         252 |
 * | mem30_trunk__instruments | binlogspaceusagedata               |     98304 |  23076 |     6 |            6 |         6 |         196 |
 * | mem30_trunk__instruments | connectionsdata                    |     98304 |  37563 |     6 |            6 |         6 |         276 |
 * ...
 * +--------------------------+------------------------------------+-----------+--------+-------+--------------+-----------+-------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$innodb_buffer_stats_by_table (
  object_schema,
  object_name,
  allocated,
  data,
  pages,
  pages_hashed,
  pages_old,
  rows_cached
) AS
SELECT IF(LOCATE('.', ibp.table_name) = 0, 'InnoDB System', REPLACE(SUBSTRING_INDEX(ibp.table_name, '.', 1), '`', '')) AS object_schema,
       REPLACE(SUBSTRING_INDEX(ibp.table_name, '.', -1), '`', '') AS object_name,
       SUM(IF(ibp.compressed_size = 0, 16384, compressed_size)) AS allocated,
       SUM(ibp.data_size) AS data,
       COUNT(ibp.page_number) AS pages,
       COUNT(IF(ibp.is_hashed = 'YES', 1, 0)) AS pages_hashed,
       COUNT(IF(ibp.is_old = 'YES', 1, 0)) AS pages_old,
       ROUND(SUM(ibp.number_records)/COUNT(DISTINCT ibp.index_name)) AS rows_cached 
  FROM information_schema.innodb_buffer_page ibp 
 WHERE table_name IS NOT NULL
 GROUP BY object_schema, object_name
 ORDER BY SUM(IF(ibp.compressed_size = 0, 16384, compressed_size)) DESC;
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
 * View: schema_object_overview
 * 
 * Shows an overview of the types of objects within each schema
 *
 * Note: On instances with a large number of objects, this could take
 *       some time to execute, and is not recommended.
 *
 * mysql> select * from schema_object_overview;
 * +---------------------------------+---------------+-------+
 * | db                              | object_type   | count |
 * +---------------------------------+---------------+-------+
 * | information_schema              | SYSTEM VIEW   |    59 |
 * | mem30_test__instruments         | BASE TABLE    |     1 |
 * | mem30_test__instruments         | INDEX (BTREE) |     2 |
 * | mem30_test__test                | BASE TABLE    |     9 |
 * | mem30_test__test                | INDEX (BTREE) |    19 |
 * ...
 * | sys                             | FUNCTION      |     8 |
 * | sys                             | PROCEDURE     |    16 |
 * | sys                             | VIEW          |    59 |
 * +---------------------------------+---------------+-------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW schema_object_overview (
  db,
  object_type,
  count
) AS
SELECT ROUTINE_SCHEMA AS db, ROUTINE_TYPE AS object_type, COUNT(*) AS count FROM INFORMATION_SCHEMA.ROUTINES GROUP BY ROUTINE_SCHEMA, ROUTINE_TYPE
 UNION 
SELECT TABLE_SCHEMA, TABLE_TYPE, COUNT(*) FROM INFORMATION_SCHEMA.TABLES GROUP BY TABLE_SCHEMA, TABLE_TYPE
 UNION
SELECT TABLE_SCHEMA, CONCAT('INDEX (', INDEX_TYPE, ')'), COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS GROUP BY TABLE_SCHEMA, INDEX_TYPE
 UNION
SELECT TRIGGER_SCHEMA, 'TRIGGER', COUNT(*) FROM INFORMATION_SCHEMA.TRIGGERS GROUP BY TRIGGER_SCHEMA
 UNION
SELECT EVENT_SCHEMA, 'EVENT', COUNT(*) FROM INFORMATION_SCHEMA.EVENTS GROUP BY EVENT_SCHEMA
ORDER BY DB, OBJECT_TYPE;
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
 * View: io_by_thread_by_latency
 *
 * Show the top IO consumers by thread, ordered by total latency
 *
 * mysql> select * from io_by_thread_by_latency;
 * +---------------------+-------+---------------+-------------+-------------+-------------+-----------+----------------+
 * | user                | total | total_latency | min_latency | avg_latency | max_latency | thread_id | processlist_id |
 * +---------------------+-------+---------------+-------------+-------------+-------------+-----------+----------------+
 * | root@localhost      | 11580 | 18.01 s       | 429.78 ns   | 1.12 ms     | 181.07 ms   |        25 |              6 |
 * | main                |  1358 | 1.31 s        | 475.02 ns   | 2.27 ms     | 350.70 ms   |         1 |           NULL |
 * | page_cleaner_thread |   654 | 147.44 ms     | 588.12 ns   | 225.44 us   | 46.41 ms    |        18 |           NULL |
 * | io_write_thread     |   131 | 107.75 ms     | 8.60 us     | 822.55 us   | 27.69 ms    |         8 |           NULL |
 * | io_write_thread     |    46 | 47.07 ms      | 10.64 us    | 1.02 ms     | 16.90 ms    |         9 |           NULL |
 * | io_write_thread     |    71 | 46.99 ms      | 9.11 us     | 661.81 us   | 17.04 ms    |        11 |           NULL |
 * | io_log_thread       |    20 | 21.01 ms      | 14.25 us    | 1.05 ms     | 7.08 ms     |         3 |           NULL |
 * | srv_master_thread   |    13 | 17.60 ms      | 8.49 us     | 1.35 ms     | 9.99 ms     |        16 |           NULL |
 * | srv_purge_thread    |     4 | 1.81 ms       | 34.31 us    | 452.45 us   | 1.02 ms     |        17 |           NULL |
 * | io_write_thread     |    19 | 951.39 us     | 9.75 us     | 50.07 us    | 297.47 us   |        10 |           NULL |
 * | signal_handler      |     3 | 218.03 us     | 21.64 us    | 72.68 us    | 154.84 us   |        19 |           NULL |
 * +---------------------+-------+---------------+-------------+-------------+-------------+-----------+----------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW io_by_thread_by_latency (
  user,
  total,
  total_latency,
  min_latency,
  avg_latency,
  max_latency,
  thread_id,
  processlist_id
)
AS
SELECT IF(processlist_id IS NULL, 
             SUBSTRING_INDEX(name, '/', -1), 
             CONCAT(processlist_user, '@', processlist_host)
          ) user, 
       SUM(count_star) total,
       sys.format_time(SUM(sum_timer_wait)) total_latency,
       sys.format_time(MIN(min_timer_wait)) min_latency,
       sys.format_time(AVG(avg_timer_wait)) avg_latency,
       sys.format_time(MAX(max_timer_wait)) max_latency,
       thread_id,
       processlist_id
  FROM performance_schema.events_waits_summary_by_thread_by_event_name 
  LEFT JOIN performance_schema.threads USING (thread_id)
 WHERE event_name LIKE 'wait/io/file/%'
   AND sum_timer_wait > 0
 GROUP BY thread_id
 ORDER BY SUM(sum_timer_wait) DESC;

/*
 * View: x$io_by_thread_by_latency
 *
 * Show the top IO consumers by thread, ordered by total latency
 *
 * mysql> select * from x$io_by_thread_by_latency;
 * +---------------------+-------+----------------+-------------+-----------------+--------------+-----------+----------------+
 * | user                | total | total_latency  | min_latency | avg_latency     | max_latency  | thread_id | processlist_id |
 * +---------------------+-------+----------------+-------------+-----------------+--------------+-----------+----------------+
 * | root@localhost      | 11587 | 18007539905680 |      429780 | 1120831681.6667 | 181065665560 |        25 |              6 |
 * | main                |  1358 |  1309001741320 |      475020 | 2269581997.8000 | 350700491310 |         1 |           NULL |
 * | page_cleaner_thread |   654 |   147435455960 |      588120 |  225436198.0000 |  46412043990 |        18 |           NULL |
 * | io_write_thread     |   131 |   107754483070 |     8603140 |  822553303.0000 |  27691592500 |         8 |           NULL |
 * | io_write_thread     |    46 |    47074926860 |    10642710 | 1023367631.0000 |  16899745070 |         9 |           NULL |
 * | io_write_thread     |    71 |    46988801210 |     9108320 |  661814075.0000 |  17042760020 |        11 |           NULL |
 * | io_log_thread       |    20 |    21007710490 |    14250600 | 1050385336.0000 |   7081255090 |         3 |           NULL |
 * | srv_master_thread   |    13 |    17601511720 |     8486270 | 1353962324.0000 |   9990100380 |        16 |           NULL |
 * | srv_purge_thread    |     4 |     1809792270 |    34307000 |  452447879.0000 |   1018887740 |        17 |           NULL |
 * | io_write_thread     |    19 |      951385890 |     9745450 |   50072763.0000 |    297468080 |        10 |           NULL |
 * | signal_handler      |     3 |      218026640 |    21639800 |   72675421.0000 |    154841440 |        19 |           NULL |
 * +---------------------+-------+----------------+-------------+-----------------+--------------+-----------+----------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$io_by_thread_by_latency (
  user,
  total,
  total_latency,
  min_latency,
  avg_latency,
  max_latency,
  thread_id,
  processlist_id
)
AS
SELECT IF(processlist_id IS NULL, 
             SUBSTRING_INDEX(name, '/', -1), 
             CONCAT(processlist_user, '@', processlist_host)
          ) user, 
       SUM(count_star) total,
       SUM(sum_timer_wait) total_latency,
       MIN(min_timer_wait) min_latency,
       AVG(avg_timer_wait) avg_latency,
       MAX(max_timer_wait) max_latency,
       thread_id,
       processlist_id
  FROM performance_schema.events_waits_summary_by_thread_by_event_name 
  LEFT JOIN performance_schema.threads USING (thread_id)
 WHERE event_name LIKE 'wait/io/file/%'
   AND sum_timer_wait > 0
 GROUP BY thread_id
 ORDER BY SUM(sum_timer_wait) DESC;
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
 * View: io_global_by_file_by_bytes
 *
 * Shows the top global IO consumers by bytes usage by file.
 *
 * mysql> SELECT * FROM io_global_by_file_by_bytes LIMIT 5;
 * +--------------------------------------------+------------+------------+-----------+-------------+---------------+-----------+------------+-----------+
 * | file                                       | count_read | total_read | avg_read  | count_write | total_written | avg_write | total      | write_pct |
 * +--------------------------------------------+------------+------------+-----------+-------------+---------------+-----------+------------+-----------+
 * | @@datadir/ibdata1                          |        147 | 4.27 MiB   | 29.71 KiB |           3 | 48.00 KiB     | 16.00 KiB | 4.31 MiB   |      1.09 |
 * | @@datadir/mysql/proc.MYD                   |        347 | 85.35 KiB  | 252 bytes |         111 | 19.08 KiB     | 176 bytes | 104.43 KiB |     18.27 |
 * | @@datadir/ib_logfile0                      |          6 | 68.00 KiB  | 11.33 KiB |           8 | 4.00 KiB      | 512 bytes | 72.00 KiB  |      5.56 |
 * | /opt/mysql/5.5.33/share/english/errmsg.sys |          3 | 43.68 KiB  | 14.56 KiB |           0 | 0 bytes       | 0 bytes   | 43.68 KiB  |      0.00 |
 * | /opt/mysql/5.5.33/share/charsets/Index.xml |          1 | 17.89 KiB  | 17.89 KiB |           0 | 0 bytes       | 0 bytes   | 17.89 KiB  |      0.00 |
 * +--------------------------------------------+------------+------------+-----------+-------------+---------------+-----------+------------+-----------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW io_global_by_file_by_bytes (
  file,
  count_read,
  total_read,
  avg_read,
  count_write,
  total_written,
  avg_write,
  total,
  write_pct
) AS
SELECT sys.format_path(file_name) AS file, 
       count_read, 
       sys.format_bytes(sum_number_of_bytes_read) AS total_read,
       sys.format_bytes(IFNULL(sum_number_of_bytes_read / count_read, 0)) AS avg_read,
       count_write, 
       sys.format_bytes(sum_number_of_bytes_write) AS total_written,
       sys.format_bytes(IFNULL(sum_number_of_bytes_write / count_write, 0.00)) AS avg_write,
       sys.format_bytes(sum_number_of_bytes_read + sum_number_of_bytes_write) AS total, 
       IFNULL(ROUND(100-((sum_number_of_bytes_read/(sum_number_of_bytes_read+sum_number_of_bytes_write))*100), 2), 0.00) AS write_pct 
  FROM performance_schema.file_summary_by_instance
 ORDER BY sum_number_of_bytes_read + sum_number_of_bytes_write DESC;

/*
 * View: x$io_global_by_file_by_bytes
 *
 * Shows the top global IO consumers by bytes usage by file.
 *
 * mysql> SELECT * FROM x$io_global_by_file_by_bytes LIMIT 5;
 * +------------------------------------------------------+------------+------------+------------+-------------+---------------+------------+---------+-----------+
 * | file                                                 | count_read | total_read | avg_read   | count_write | total_written | avg_write  | total   | write_pct |
 * +------------------------------------------------------+------------+------------+------------+-------------+---------------+------------+---------+-----------+
 * | /Users/mark/sandboxes/msb_5_5_33/data/ibdata1        |        147 |    4472832 | 30427.4286 |           3 |         49152 | 16384.0000 | 4521984 |      1.09 |
 * | /Users/mark/sandboxes/msb_5_5_33/data/mysql/proc.MYD |        347 |      87397 |   251.8646 |         111 |         19536 |   176.0000 |  106933 |     18.27 |
 * | /Users/mark/sandboxes/msb_5_5_33/data/ib_logfile0    |          6 |      69632 | 11605.3333 |           8 |          4096 |   512.0000 |   73728 |      5.56 |
 * | /opt/mysql/5.5.33/share/english/errmsg.sys           |          3 |      44724 | 14908.0000 |           0 |             0 |     0.0000 |   44724 |      0.00 |
 * | /opt/mysql/5.5.33/share/charsets/Index.xml           |          1 |      18317 | 18317.0000 |           0 |             0 |     0.0000 |   18317 |      0.00 |
 * +------------------------------------------------------+------------+------------+------------+-------------+---------------+------------+---------+-----------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$io_global_by_file_by_bytes (
  file,
  count_read,
  total_read,
  avg_read,
  count_write,
  total_written,
  avg_write,
  total,
  write_pct
) AS
SELECT file_name AS file, 
       count_read, 
       sum_number_of_bytes_read AS total_read,
       IFNULL(sum_number_of_bytes_read / count_read, 0) AS avg_read,
       count_write, 
       sum_number_of_bytes_write AS total_written,
       IFNULL(sum_number_of_bytes_write / count_write, 0.00) AS avg_write,
       sum_number_of_bytes_read + sum_number_of_bytes_write AS total, 
       IFNULL(ROUND(100-((sum_number_of_bytes_read/(sum_number_of_bytes_read+sum_number_of_bytes_write))*100), 2), 0.00) AS write_pct 
  FROM performance_schema.file_summary_by_instance
 ORDER BY sum_number_of_bytes_read + sum_number_of_bytes_write DESC;
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
 * View: io_global_by_file_by_latency
 *
 * Shows the top global IO consumers by latency by file.
 *
 * mysql> select * from io_global_by_file_by_latency limit 5;
 * +-----------------------------------------------------------+-------+---------------+------------+--------------+-------------+---------------+------------+--------------+
 * | file                                                      | total | total_latency | count_read | read_latency | count_write | write_latency | count_misc | misc_latency |
 * +-----------------------------------------------------------+-------+---------------+------------+--------------+-------------+---------------+------------+--------------+
 * | @@datadir/sys/wait_classes_global_by_avg_latency_raw.frm~ |    24 | 451.99 ms     |          0 | 0 ps         |           4 | 108.07 us     |         20 | 451.88 ms    |
 * | @@datadir/sys/innodb_buffer_stats_by_schema_raw.frm~      |    24 | 379.84 ms     |          0 | 0 ps         |           4 | 108.88 us     |         20 | 379.73 ms    |
 * | @@datadir/sys/io_by_thread_by_latency_raw.frm~            |    24 | 379.46 ms     |          0 | 0 ps         |           4 | 101.37 us     |         20 | 379.36 ms    |
 * | @@datadir/ibtmp1                                          |    53 | 373.45 ms     |          0 | 0 ps         |          48 | 246.08 ms     |          5 | 127.37 ms    |
 * | @@datadir/sys/statement_analysis_raw.frm~                 |    24 | 353.14 ms     |          0 | 0 ps         |           4 | 94.96 us      |         20 | 353.04 ms    |
 * +-----------------------------------------------------------+-------+---------------+------------+--------------+-------------+---------------+------------+--------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW io_global_by_file_by_latency (
  file,
  total,
  total_latency,
  count_read,
  read_latency,
  count_write,
  write_latency,
  count_misc,
  misc_latency
) AS
SELECT sys.format_path(file_name) AS file, 
       count_star AS total, 
       sys.format_time(sum_timer_wait) AS total_latency,
       count_read,
       sys.format_time(sum_timer_read) AS read_latency,
       count_write,
       sys.format_time(sum_timer_write) AS write_latency,
       count_misc,
       sys.format_time(sum_timer_misc) AS misc_latency
  FROM performance_schema.file_summary_by_instance
 ORDER BY sum_timer_wait DESC;

/*
 * View: x$io_global_by_file_by_latency
 *
 * Shows the top global IO consumers by latency by file.
 *
 * mysql> select * from x$io_global_by_file_by_latency limit 5;
 * +--------------------------------------------------------------------------------------+-------+---------------+------------+--------------+-------------+---------------+------------+--------------+
 * | file                                                                                 | total | total_latency | count_read | read_latency | count_write | write_latency | count_misc | misc_latency |
 * +--------------------------------------------------------------------------------------+-------+---------------+------------+--------------+-------------+---------------+------------+--------------+
 * | /Users/mark/sandboxes/msb_5_7_2/data/sys/wait_classes_global_by_avg_latency_raw.frm~ |    30 |  513959738110 |          0 |            0 |           5 |     132130960 |         25 | 513827607150 |
 * | /Users/mark/sandboxes/msb_5_7_2/data/sys/innodb_buffer_stats_by_schema_raw.frm~      |    30 |  490149888410 |          0 |            0 |           5 |     483887040 |         25 | 489666001370 |
 * | /Users/mark/sandboxes/msb_5_7_2/data/sys/io_by_thread_by_latency_raw.frm~            |    30 |  427724241620 |          0 |            0 |           5 |     131399580 |         25 | 427592842040 |
 * | /Users/mark/sandboxes/msb_5_7_2/data/sys/innodb_buffer_stats_by_schema.frm~          |    30 |  406392559950 |          0 |            0 |           5 |     104082160 |         25 | 406288477790 |
 * | /Users/mark/sandboxes/msb_5_7_2/data/sys/statement_analysis_raw.frm~                 |    30 |  395527510430 |          0 |            0 |           5 |     118724840 |         25 | 395408785590 |
 * +--------------------------------------------------------------------------------------+-------+---------------+------------+--------------+-------------+---------------+------------+--------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$io_global_by_file_by_latency (
  file,
  total,
  total_latency,
  count_read,
  read_latency,
  count_write,
  write_latency,
  count_misc,
  misc_latency
) AS
SELECT file_name AS file, 
       count_star AS total, 
       sum_timer_wait AS total_latency,
       count_read,
       sum_timer_read AS read_latency,
       count_write,
       sum_timer_write AS write_latency,
       count_misc,
       sum_timer_misc AS misc_latency
  FROM performance_schema.file_summary_by_instance
 ORDER BY sum_timer_wait DESC;
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
 * View: io_global_by_wait_by_bytes
 *
 * Shows the top global IO consumer classes by bytes usage.
 *
 * mysql> select * from io_global_by_wait_by_bytes;
 * +--------------------+--------+---------------+-------------+-------------+-------------+------------+------------+-----------+-------------+---------------+-------------+-----------------+
 * | event_name         | total  | total_latency | min_latency | avg_latency | max_latency | count_read | total_read | avg_read  | count_write | total_written | avg_written | total_requested |
 * +--------------------+--------+---------------+-------------+-------------+-------------+------------+------------+-----------+-------------+---------------+-------------+-----------------+
 * | myisam/dfile       | 163681 | 983.13 ms     | 379.08 ns   | 6.01 µs     | 22.06 ms    |      68737 | 127.31 MiB | 1.90 KiB  |     1012221 | 121.52 MiB    | 126 bytes   | 248.83 MiB      |
 * | myisam/kfile       |   1775 | 375.13 ms     | 1.02 µs     | 211.34 µs   | 35.15 ms    |      54066 | 9.97 MiB   | 193 bytes |      428257 | 12.40 MiB     | 30 bytes    | 22.37 MiB       |
 * | sql/FRM            |  57889 | 8.40 s        | 19.44 ns    | 145.05 µs   | 336.71 ms   |       8009 | 2.60 MiB   | 341 bytes |       14675 | 2.91 MiB      | 208 bytes   | 5.51 MiB        |
 * | sql/global_ddl_log |    164 | 75.96 ms      | 5.72 µs     | 463.19 µs   | 7.43 ms     |         20 | 80.00 KiB  | 4.00 KiB  |          76 | 304.00 KiB    | 4.00 KiB    | 384.00 KiB      |
 * | sql/file_parser    |    419 | 601.37 ms     | 1.96 µs     | 1.44 ms     | 37.14 ms    |         66 | 42.01 KiB  | 652 bytes |          64 | 226.98 KiB    | 3.55 KiB    | 268.99 KiB      |
 * | sql/binlog         |    190 | 6.79 s        | 1.56 µs     | 35.76 ms    | 4.21 s      |         52 | 60.54 KiB  | 1.16 KiB  |           0 | 0 bytes       | 0 bytes     | 60.54 KiB       |
 * | sql/ERRMSG         |      5 | 2.03 s        | 8.61 µs     | 405.40 ms   | 2.03 s      |          3 | 51.82 KiB  | 17.27 KiB |           0 | 0 bytes       | 0 bytes     | 51.82 KiB       |
 * | mysys/charset      |      3 | 196.52 µs     | 17.61 µs    | 65.51 µs    | 137.33 µs   |          1 | 17.83 KiB  | 17.83 KiB |           0 | 0 bytes       | 0 bytes     | 17.83 KiB       |
 * | sql/partition      |     81 | 18.87 ms      | 888.08 ns   | 232.92 µs   | 4.67 ms     |         66 | 2.75 KiB   | 43 bytes  |           8 | 288 bytes     | 36 bytes    | 3.04 KiB        |
 * | sql/dbopt          | 329166 | 26.95 s       | 2.06 µs     | 81.89 µs    | 178.71 ms   |          0 | 0 bytes    | 0 bytes   |           9 | 585 bytes     | 65 bytes    | 585 bytes       |
 * | sql/relaylog       |      7 | 1.18 ms       | 838.84 ns   | 168.30 µs   | 892.70 µs   |          0 | 0 bytes    | 0 bytes   |           1 | 120 bytes     | 120 bytes   | 120 bytes       |
 * | mysys/cnf          |      5 | 171.61 µs     | 303.26 ns   | 34.32 µs    | 115.21 µs   |          3 | 56 bytes   | 19 bytes  |           0 | 0 bytes       | 0 bytes     | 56 bytes        |
 * | sql/pid            |      3 | 220.55 µs     | 29.29 µs    | 73.52 µs    | 143.11 µs   |          0 | 0 bytes    | 0 bytes   |           1 | 5 bytes       | 5 bytes     | 5 bytes         |
 * | sql/casetest       |      1 | 121.19 µs     | 121.19 µs   | 121.19 µs   | 121.19 µs   |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     | 0 bytes         |
 * | sql/binlog_index   |      5 | 593.47 µs     | 1.07 µs     | 118.69 µs   | 535.90 µs   |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     | 0 bytes         |
 * | sql/misc           |     23 | 2.73 ms       | 65.14 µs    | 118.50 µs   | 255.31 µs   |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     | 0 bytes         |
 * +--------------------+--------+---------------+-------------+-------------+-------------+------------+------------+-----------+-------------+---------------+-------------+-----------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW io_global_by_wait_by_bytes (
  event_name,
  total,
  total_latency,
  min_latency,
  avg_latency,
  max_latency,
  count_read,
  total_read,
  avg_read,
  count_write,
  total_written,
  avg_written,
  total_requested
) AS
SELECT SUBSTRING_INDEX(event_name, '/', -2) event_name,
       count_star AS total,
       sys.format_time(sum_timer_wait) AS total_latency,
       sys.format_time(min_timer_wait) AS min_latency,
       sys.format_time(avg_timer_wait) AS avg_latency,
       sys.format_time(max_timer_wait) AS max_latency,
       count_read,
       sys.format_bytes(sum_number_of_bytes_read) AS total_read,
       sys.format_bytes(IFNULL(sum_number_of_bytes_read / count_read, 0)) AS avg_read,
       count_write,
       sys.format_bytes(sum_number_of_bytes_write) AS total_written,
       sys.format_bytes(IFNULL(sum_number_of_bytes_write / count_write, 0)) AS avg_written,
       sys.format_bytes(sum_number_of_bytes_write + sum_number_of_bytes_read) AS total_requested
  FROM performance_schema.file_summary_by_event_name
 WHERE event_name LIKE 'wait/io/file/%' 
   AND count_star > 0
 ORDER BY sum_number_of_bytes_write + sum_number_of_bytes_read DESC;

/*
 * View: x$io_global_by_wait_by_bytes
 *
 * Shows the top global IO consumer classes by bytes usage.
 *
 * mysql> select * from x$io_global_by_wait_by_bytes;
 * +-------------------------+-------+---------------+-------------+-------------+--------------+------------+------------+------------+-------------+---------------+-------------+-----------------+
 * | event_name              | total | total_latency | min_latency | avg_latency | max_latency  | count_read | total_read | avg_read   | count_write | total_written | avg_written | total_requested |
 * +-------------------------+-------+---------------+-------------+-------------+--------------+------------+------------+------------+-------------+---------------+-------------+-----------------+
 * | innodb/innodb_data_file |   151 |  334405721910 |     8399560 |  2214607429 | 107444600380 |        147 |    4472832 | 30427.4286 |           0 |             0 |      0.0000 |         4472832 |
 * | sql/FRM                 |   555 |  147752034170 |      674830 |   266219881 |  57705900850 |        270 |     112174 |   415.4593 |           0 |             0 |      0.0000 |          112174 |
 * | innodb/innodb_log_file  |    22 |   56776429970 |     2476890 |  2580746816 |  18883021430 |          6 |      69632 | 11605.3333 |           5 |          2560 |    512.0000 |           72192 |
 * | sql/ERRMSG              |     5 |   11862056180 |    14883960 |  2372411236 |  11109473700 |          3 |      44724 | 14908.0000 |           0 |             0 |      0.0000 |           44724 |
 * | mysys/charset           |     3 |    7256869230 |    19796270 |  2418956410 |   7198498320 |          1 |      18317 | 18317.0000 |           0 |             0 |      0.0000 |           18317 |
 * | myisam/kfile            |   135 |   10194698280 |      784160 |    75516283 |   2593514950 |         40 |       9216 |   230.4000 |          33 |          1017 |     30.8182 |           10233 |
 * | myisam/dfile            |    68 |   10527909730 |      772850 |   154822201 |   7600014630 |          9 |       6667 |   740.7778 |           0 |             0 |      0.0000 |            6667 |
 * | sql/pid                 |     3 |     216507330 |    41296580 |    72169110 |    100617530 |          0 |          0 |     0.0000 |           1 |             6 |      6.0000 |               6 |
 * | sql/casetest            |     5 |     185261570 |     4105530 |    37052314 |    113488310 |          0 |          0 |     0.0000 |           0 |             0 |      0.0000 |               0 |
 * | sql/global_ddl_log      |     2 |      21538010 |     3121560 |    10769005 |     18416450 |          0 |          0 |     0.0000 |           0 |             0 |      0.0000 |               0 |
 * | sql/dbopt               |    10 |    1004267680 |     1164930 |   100426768 |    939894930 |          0 |          0 |     0.0000 |           0 |             0 |      0.0000 |               0 |
 * +-------------------------+-------+---------------+-------------+-------------+--------------+------------+------------+------------+-------------+---------------+-------------+-----------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$io_global_by_wait_by_bytes (
  event_name,
  total,
  total_latency,
  min_latency,
  avg_latency,
  max_latency,
  count_read,
  total_read,
  avg_read,
  count_write,
  total_written,
  avg_written,
  total_requested
) AS
SELECT SUBSTRING_INDEX(event_name, '/', -2) AS event_name,
       count_star AS total,
       sum_timer_wait AS total_latency,
       min_timer_wait AS min_latency,
       avg_timer_wait AS avg_latency,
       max_timer_wait AS max_latency,
       count_read,
       sum_number_of_bytes_read AS total_read,
       IFNULL(sum_number_of_bytes_read / count_read, 0) AS avg_read,
       count_write,
       sum_number_of_bytes_write AS total_written,
       IFNULL(sum_number_of_bytes_write / count_write, 0) AS avg_written,
       sum_number_of_bytes_write + sum_number_of_bytes_read AS total_requested
  FROM performance_schema.file_summary_by_event_name
 WHERE event_name LIKE 'wait/io/file/%' 
   AND count_star > 0
 ORDER BY sum_number_of_bytes_write + sum_number_of_bytes_read DESC;
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
 * View: io_global_by_wait_by_latency
 *
 * Shows the top global IO consumers by latency.
 *
 * mysql> SELECT * FROM io_global_by_wait_by_latency;
 * +-------------------------+-------+---------------+-------------+-------------+--------------+---------------+--------------+------------+------------+-----------+-------------+---------------+-------------+
 * | event_name              | total | total_latency | avg_latency | max_latency | read_latency | write_latency | misc_latency | count_read | total_read | avg_read  | count_write | total_written | avg_written |
 * +-------------------------+-------+---------------+-------------+-------------+--------------+---------------+--------------+------------+------------+-----------+-------------+---------------+-------------+
 * | sql/file_parser         |  5433 | 30.20 s       | 5.56 ms     | 203.65 ms   | 22.08 ms     | 24.89 ms      | 30.16 s      |         24 | 6.18 KiB   | 264 bytes |         737 | 2.15 MiB      | 2.99 KiB    |
 * | innodb/innodb_data_file |  1344 | 1.52 s        | 1.13 ms     | 350.70 ms   | 203.82 ms    | 450.96 ms     | 868.21 ms    |        147 | 2.30 MiB   | 16.00 KiB |        1001 | 53.61 MiB     | 54.84 KiB   |
 * | innodb/innodb_log_file  |   828 | 893.48 ms     | 1.08 ms     | 30.11 ms    | 16.32 ms     | 705.89 ms     | 171.27 ms    |          6 | 68.00 KiB  | 11.33 KiB |         413 | 2.19 MiB      | 5.42 KiB    |
 * | myisam/kfile            |  7642 | 242.34 ms     | 31.71 us    | 19.27 ms    | 73.60 ms     | 23.48 ms      | 145.26 ms    |        758 | 135.63 KiB | 183 bytes |        4386 | 232.52 KiB    | 54 bytes    |
 * | myisam/dfile            | 12540 | 223.47 ms     | 17.82 us    | 32.50 ms    | 87.76 ms     | 16.97 ms      | 118.74 ms    |       5390 | 4.49 MiB   | 873 bytes |        1448 | 2.65 MiB      | 1.88 KiB    |
 * | csv/metadata            |     8 | 28.98 ms      | 3.62 ms     | 20.15 ms    | 399.27 us    | 0 ps          | 28.58 ms     |          2 | 70 bytes   | 35 bytes  |           0 | 0 bytes       | 0 bytes     |
 * | mysys/charset           |     3 | 24.24 ms      | 8.08 ms     | 24.15 ms    | 24.15 ms     | 0 ps          | 93.18 us     |          1 | 17.31 KiB  | 17.31 KiB |           0 | 0 bytes       | 0 bytes     |
 * | sql/ERRMSG              |     5 | 20.43 ms      | 4.09 ms     | 19.31 ms    | 20.32 ms     | 0 ps          | 103.20 us    |          3 | 58.97 KiB  | 19.66 KiB |           0 | 0 bytes       | 0 bytes     |
 * | mysys/cnf               |     5 | 11.37 ms      | 2.27 ms     | 11.28 ms    | 11.29 ms     | 0 ps          | 78.22 us     |          3 | 56 bytes   | 19 bytes  |           0 | 0 bytes       | 0 bytes     |
 * | sql/dbopt               |    57 | 4.04 ms       | 70.92 us    | 843.70 us   | 0 ps         | 186.43 us     | 3.86 ms      |          0 | 0 bytes    | 0 bytes   |           7 | 431 bytes     | 62 bytes    |
 * | csv/data                |     4 | 411.55 us     | 102.89 us   | 234.89 us   | 0 ps         | 0 ps          | 411.55 us    |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     |
 * | sql/misc                |    22 | 340.38 us     | 15.47 us    | 33.77 us    | 0 ps         | 0 ps          | 340.38 us    |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     |
 * | archive/data            |    39 | 277.86 us     | 7.12 us     | 16.18 us    | 0 ps         | 0 ps          | 277.86 us    |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     |
 * | sql/pid                 |     3 | 218.03 us     | 72.68 us    | 154.84 us   | 0 ps         | 21.64 us      | 196.39 us    |          0 | 0 bytes    | 0 bytes   |           1 | 6 bytes       | 6 bytes     |
 * | sql/casetest            |     5 | 197.15 us     | 39.43 us    | 126.31 us   | 0 ps         | 0 ps          | 197.15 us    |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     |
 * | sql/global_ddl_log      |     2 | 14.60 us      | 7.30 us     | 12.12 us    | 0 ps         | 0 ps          | 14.60 us     |          0 | 0 bytes    | 0 bytes   |           0 | 0 bytes       | 0 bytes     |
 * +-------------------------+-------+---------------+-------------+-------------+--------------+---------------+--------------+------------+------------+-----------+-------------+---------------+-------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW io_global_by_wait_by_latency (
  event_name,
  total,
  total_latency,
  avg_latency,
  max_latency,
  read_latency,
  write_latency,
  misc_latency,
  count_read,
  total_read,
  avg_read,
  count_write,
  total_written,
  avg_written
) AS
SELECT SUBSTRING_INDEX(event_name, '/', -2) AS event_name,
       count_star AS total,
       sys.format_time(sum_timer_wait) AS total_latency,
       sys.format_time(avg_timer_wait) AS avg_latency,
       sys.format_time(max_timer_wait) AS max_latency,
       sys.format_time(sum_timer_read) AS read_latency,
       sys.format_time(sum_timer_write) AS write_latency,
       sys.format_time(sum_timer_misc) AS misc_latency,
       count_read,
       sys.format_bytes(sum_number_of_bytes_read) AS total_read,
       sys.format_bytes(IFNULL(sum_number_of_bytes_read / count_read, 0)) AS avg_read,
       count_write,
       sys.format_bytes(sum_number_of_bytes_write) AS total_written,
       sys.format_bytes(IFNULL(sum_number_of_bytes_write / count_write, 0)) AS avg_written
  FROM performance_schema.file_summary_by_event_name 
 WHERE event_name LIKE 'wait/io/file/%'
   AND count_star > 0
 ORDER BY sum_timer_wait DESC;

/*
 * View: x$io_global_by_wait_by_latency
 *
 * Shows the top global IO consumers by latency.
 *
 * mysql> select * from x$io_global_by_wait_by_latency;
 * +-------------------------+-------+----------------+-------------+--------------+--------------+---------------+----------------+------------+------------+------------+-------------+---------------+-------------+
 * | event_name              | total | total_latency  | avg_latency | max_latency  | read_latency | write_latency | misc_latency   | count_read | total_read | avg_read   | count_write | total_written | avg_written |
 * +-------------------------+-------+----------------+-------------+--------------+--------------+---------------+----------------+------------+------------+------------+-------------+---------------+-------------+
 * | sql/file_parser         |  5945 | 33615441247050 |  5654405471 | 203652881640 |  22093704230 |   27389668280 | 33565957874540 |         26 |       7008 |   269.5385 |         808 |       2479209 |   3068.3280 |
 * | sql/FRM                 |  6332 |  1755386796800 |   277224688 | 145624702340 | 519139578620 |    1677016640 |  1234570201540 |       2040 |     865905 |   424.4632 |         439 |        103445 |    235.6378 |
 * | innodb/innodb_data_file |  1344 |  1522989889460 |  1133176798 | 350700491310 | 203817502460 |  450959403830 |   868212983170 |        147 |    2408448 | 16384.0000 |        1001 |      56213504 |  56157.3467 |
 * | innodb/innodb_log_file  |   828 |   893475794640 |  1079076921 |  30108124800 |  16315236730 |  705886928240 |   171273629670 |          6 |      69632 | 11605.3333 |         413 |       2294272 |   5555.1380 |
 * | myisam/kfile            |  7826 |   246001992860 |    31433883 |  19265276810 |  74419162870 |   23923730090 |   147659099900 |        770 |     141058 |   183.1922 |        4516 |        249602 |     55.2706 |
 * | myisam/dfile            | 13431 |   228191713620 |    16989882 |  32500163410 |  89162969350 |   17341973610 |   121686770660 |       5819 |    4873176 |   837.4594 |        1577 |       2853444 |   1809.4128 |
 * | csv/metadata            |     8 |    28975194560 |  3621899320 |  20148109020 |    399265620 |             0 |    28575928940 |          2 |         70 |    35.0000 |           0 |             0 |      0.0000 |
 * | mysys/charset           |     3 |    24244722970 |  8081574072 |  24151547420 |  24151547420 |             0 |       93175550 |          1 |      17722 | 17722.0000 |           0 |             0 |      0.0000 |
 * | sql/ERRMSG              |     5 |    20427386850 |  4085477370 |  19312386730 |  20324183100 |             0 |      103203750 |          3 |      60390 | 20130.0000 |           0 |             0 |      0.0000 |
 * | mysys/cnf               |     5 |    11366169230 |  2273233846 |  11283602460 |  11287953040 |             0 |       78216190 |          3 |         56 |    18.6667 |           0 |             0 |      0.0000 |
 * | sql/dbopt               |    57 |     4042348570 |    70918224 |    843703380 |            0 |     186430270 |     3855918300 |          0 |          0 |     0.0000 |           7 |           431 |     61.5714 |
 * | csv/data                |     4 |      411548280 |   102887070 |    234886080 |            0 |             0 |      411548280 |          0 |          0 |     0.0000 |           0 |             0 |      0.0000 |
 * | sql/misc                |    24 |      369128240 |    15380092 |     33771660 |            0 |             0 |      369128240 |          0 |          0 |     0.0000 |           0 |             0 |      0.0000 |
 * | archive/data            |    39 |      277856540 |     7124169 |     16180840 |            0 |             0 |      277856540 |          0 |          0 |     0.0000 |           0 |             0 |      0.0000 |
 * | sql/pid                 |     3 |      218026640 |    72675421 |    154841440 |            0 |      21639800 |      196386840 |          0 |          0 |     0.0000 |           1 |             6 |      6.0000 |
 * | sql/casetest            |     5 |      197152150 |    39430430 |    126310080 |            0 |             0 |      197152150 |          0 |          0 |     0.0000 |           0 |             0 |      0.0000 |
 * | sql/global_ddl_log      |     2 |       14604980 |     7302490 |     12120550 |            0 |             0 |       14604980 |          0 |          0 |     0.0000 |           0 |             0 |      0.0000 |
 * +-------------------------+-------+----------------+-------------+--------------+--------------+---------------+----------------+------------+------------+------------+-------------+---------------+-------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$io_global_by_wait_by_latency (
  event_name,
  total,
  total_latency,
  avg_latency,
  max_latency,
  read_latency,
  write_latency,
  misc_latency,
  count_read,
  total_read,
  avg_read,
  count_write,
  total_written,
  avg_written
) AS
SELECT SUBSTRING_INDEX(event_name, '/', -2) AS event_name,
       count_star AS total,
       sum_timer_wait AS total_latency,
       avg_timer_wait AS avg_latency,
       max_timer_wait AS max_latency,
       sum_timer_read AS read_latency,
       sum_timer_write AS write_latency,
       sum_timer_misc AS misc_latency,
       count_read,
       sum_number_of_bytes_read AS total_read,
       IFNULL(sum_number_of_bytes_read / count_read, 0) AS avg_read,
       count_write,
       sum_number_of_bytes_write AS total_written,
       IFNULL(sum_number_of_bytes_write / count_write, 0) AS avg_written
  FROM performance_schema.file_summary_by_event_name 
 WHERE event_name LIKE 'wait/io/file/%'
   AND count_star > 0
 ORDER BY sum_timer_wait DESC;
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
 * View: latest_file_io
 *
 * Shows the latest file IO, by file / thread.
 *
 * mysql> select * from latest_file_io limit 5;
 * +----------------------+----------------------------------------+------------+-----------+-----------+
 * | thread               | file                                   | latency    | operation | requested |
 * +----------------------+----------------------------------------+------------+-----------+-----------+
 * | msandbox@localhost:1 | @@tmpdir/#sqlcf28_1_4e.MYI             | 9.26 µs    | write     | 124 bytes |
 * | msandbox@localhost:1 | @@tmpdir/#sqlcf28_1_4e.MYI             | 4.00 µs    | write     | 2 bytes   |
 * | msandbox@localhost:1 | @@tmpdir/#sqlcf28_1_4e.MYI             | 56.34 µs   | close     | NULL      |
 * | msandbox@localhost:1 | @@tmpdir/#sqlcf28_1_4e.MYD             | 53.93 µs   | close     | NULL      |
 * | msandbox@localhost:1 | @@tmpdir/#sqlcf28_1_4e.MYI             | 104.05 ms  | delete    | NULL      |
 * +----------------------+----------------------------------------+------------+-----------+-----------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW latest_file_io (
  thread,
  file,
  latency,
  operation,
  requested
) AS
SELECT IF(id IS NULL, 
             CONCAT(SUBSTRING_INDEX(name, '/', -1), ':', thread_id), 
             CONCAT(user, '@', host, ':', id)
          ) thread, 
       sys.format_path(object_name) file, 
       sys.format_time(timer_wait) AS latency, 
       operation, 
       sys.format_bytes(number_of_bytes) AS requested
  FROM performance_schema.events_waits_history_long 
  JOIN performance_schema.threads USING (thread_id)
  LEFT JOIN information_schema.processlist ON processlist_id = id
 WHERE object_name IS NOT NULL
   AND event_name LIKE 'wait/io/file/%'
 ORDER BY timer_start;

/*
 * View: x$latest_file_io
 *
 * Shows the latest file IO, by file / thread.
 *
 * mysql> SELECT * FROM x$latest_file_io LIMIT 5;
 * +------------------+------------------------------------------------------------------------------------+-------------+-----------+-----------+
 * | thread           | file                                                                               | latency     | operation | requested |
 * +------------------+------------------------------------------------------------------------------------+-------------+-----------+-----------+
 * | root@localhost:6 | /Users/mark/sandboxes/msb_5_7_2/data/ps_helper/user_summary_by_statement_type.frm~ |    26152490 | write     |      4210 |
 * | root@localhost:6 | /Users/mark/sandboxes/msb_5_7_2/data/ps_helper/user_summary_by_statement_type.frm~ | 30062722690 | sync      |      NULL |
 * | root@localhost:6 | /Users/mark/sandboxes/msb_5_7_2/data/ps_helper/user_summary_by_statement_type.frm~ |    34144890 | close     |      NULL |
 * | root@localhost:6 | /Users/mark/sandboxes/msb_5_7_2/data/ps_helper/check_lost_instrumentation.frm      |   113001980 | open      |      NULL |
 * | root@localhost:6 | /Users/mark/sandboxes/msb_5_7_2/data/ps_helper/check_lost_instrumentation.frm      |     9553180 | read      |        10 |
 * +------------------+------------------------------------------------------------------------------------+-------------+-----------+-----------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$latest_file_io (
  thread,
  file,
  latency,
  operation,
  requested
) AS
SELECT IF(id IS NULL, 
             CONCAT(SUBSTRING_INDEX(name, '/', -1), ':', thread_id), 
             CONCAT(user, '@', host, ':', id)
          ) thread, 
       object_name file, 
       timer_wait AS latency, 
       operation, 
       number_of_bytes AS requested
  FROM performance_schema.events_waits_history_long 
  JOIN performance_schema.threads USING (thread_id)
  LEFT JOIN information_schema.processlist ON processlist_id = id
 WHERE object_name IS NOT NULL
   AND event_name LIKE 'wait/io/file/%'
 ORDER BY timer_start;
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
 * View: memory_by_user_by_current_bytes
 *
 * Summarizes memory use by user using the 5.7 Performance Schema instrumentation.
 *
 * mysql> select * from memory_by_user_by_current_bytes WHERE user IS NOT NULL;
 * +------+--------------------+-------------------+-------------------+-------------------+-----------------+
 * | user | current_count_used | current_allocated | current_avg_alloc | current_max_alloc | total_allocated |
 * +------+--------------------+-------------------+-------------------+-------------------+-----------------+
 * | root |               1401 | 1.09 MiB          | 815 bytes         | 334.97 KiB        | 42.73 MiB       |
 * | mark |                201 | 496.08 KiB        | 2.47 KiB          | 334.97 KiB        | 5.50 MiB        |
 * +------+--------------------+-------------------+-------------------+-------------------+-----------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW memory_by_user_by_current_bytes (
  user,
  current_count_used,
  current_allocated,
  current_avg_alloc,
  current_max_alloc,
  total_allocated
) AS
SELECT user,
       SUM(current_count_used) AS current_count_used,
       sys.format_bytes(SUM(current_number_of_bytes_used)) AS current_allocated,
       sys.format_bytes(SUM(current_number_of_bytes_used) / SUM(current_count_used)) AS current_avg_alloc,
       sys.format_bytes(MAX(current_number_of_bytes_used)) AS current_max_alloc,
       sys.format_bytes(SUM(sum_number_of_bytes_alloc)) AS total_allocated
  FROM performance_schema.memory_summary_by_user_by_event_name
 GROUP BY user
 ORDER BY SUM(current_number_of_bytes_used) DESC;

/*
 * View: x$memory_by_user_by_current_bytes
 *
 * Summarizes memory use by user
 *
 * mysql> select * from x$memory_by_user_by_current_bytes WHERE user IS NOT NULL;
 * +------+--------------------+-------------------+-------------------+-------------------+-----------------+
 * | user | current_count_used | current_allocated | current_avg_alloc | current_max_alloc | total_allocated |
 * +------+--------------------+-------------------+-------------------+-------------------+-----------------+
 * | root |               1399 |           1124553 |          803.8263 |            343008 |        45426133 |
 * | mark |                201 |            507990 |         2527.3134 |            343008 |         5769804 |
 * +------+--------------------+-------------------+-------------------+-------------------+-----------------+
 * 
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$memory_by_user_by_current_bytes (
  user,
  current_count_used,
  current_allocated,
  current_avg_alloc,
  current_max_alloc,
  total_allocated
) AS
SELECT user,
       SUM(current_count_used) AS current_count_used,
       SUM(current_number_of_bytes_used) AS current_allocated,
       SUM(current_number_of_bytes_used) / SUM(current_count_used) AS current_avg_alloc,
       MAX(current_number_of_bytes_used) AS current_max_alloc,
       SUM(sum_number_of_bytes_alloc) AS total_allocated
  FROM performance_schema.memory_summary_by_user_by_event_name
 GROUP BY user
 ORDER BY SUM(current_number_of_bytes_used) DESC;
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
 * View: memory_global_by_current_allocated
 * 
 * Shows the current memory usage within the server globally broken down by allocation type.
 *
 * mysql> select * from memory_global_by_current_allocated;
 * +----------------------------------------+---------------+---------------+-------------------+------------+------------+----------------+
 * | event_name                             | current_count | current_alloc | current_avg_alloc | high_count | high_alloc | high_avg_alloc |
 * +----------------------------------------+---------------+---------------+-------------------+------------+------------+----------------+
 * | memory/sql/TABLE_SHARE::mem_root       |           269 | 568.21 KiB    | 2.11 KiB          |        339 | 706.04 KiB | 2.08 KiB       |
 * | memory/sql/TABLE                       |           214 | 366.56 KiB    | 1.71 KiB          |        245 | 481.13 KiB | 1.96 KiB       |
 * | memory/sql/sp_head::main_mem_root      |            32 | 334.97 KiB    | 10.47 KiB         |        421 | 9.73 MiB   | 23.66 KiB      |
 * | memory/sql/Filesort_buffer::sort_keys  |             1 | 255.89 KiB    | 255.89 KiB        |          1 | 256.00 KiB | 256.00 KiB     |
 * | memory/mysys/array_buffer              |            82 | 121.66 KiB    | 1.48 KiB          |       1124 | 852.55 KiB | 777 bytes      |
 * ...
 * +----------------------------------------+---------------+---------------+-------------------+------------+------------+----------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW memory_global_by_current_allocated (
  event_name,
  current_count,
  current_alloc,
  current_avg_alloc,
  high_count,
  high_alloc,
  high_avg_alloc
) AS
SELECT event_name,
       current_count_used AS current_count,
       sys.format_bytes(current_number_of_bytes_used) AS current_alloc,
       sys.format_bytes(current_number_of_bytes_used / current_count_used) AS current_avg_alloc,
       high_count_used AS high_count,
       sys.format_bytes(high_number_of_bytes_used) AS high_alloc,
       sys.format_bytes(high_number_of_bytes_used / high_count_used) AS high_avg_alloc
  FROM performance_schema.memory_summary_global_by_event_name
 WHERE current_number_of_bytes_used > 0
 ORDER BY current_number_of_bytes_used DESC;

/* 
 * View: x$memory_global_by_current_allocated
 * 
 * Shows the current memory usage within the server globally broken down by allocation type.
 *
 * mysql> select * from x$memory_global_by_current_allocated;
 * +----------------------------------------+---------------+---------------+-------------------+------------+------------+----------------+
 * | event_name                             | current_count | current_alloc | current_avg_alloc | high_count | high_alloc | high_avg_alloc |
 * +----------------------------------------+---------------+---------------+-------------------+------------+------------+----------------+
 * | memory/sql/TABLE_SHARE::mem_root       |           270 |        582656 |         2157.9852 |        339 |     722984 |      2132.6962 |
 * | memory/sql/TABLE                       |           214 |        375353 |         1753.9860 |        245 |     492672 |      2010.9061 |
 * | memory/sql/sp_head::main_mem_root      |            32 |        343008 |        10719.0000 |        421 |   10200008 |     24228.0475 |
 * | memory/sql/Filesort_buffer::sort_keys  |             1 |        262036 |       262036.0000 |          1 |     262140 |    262140.0000 |
 * | memory/mysys/array_buffer              |            82 |        124576 |         1519.2195 |       1124 |     873008 |       776.6975 |
 * ...
 * +----------------------------------------+---------------+---------------+-------------------+------------+------------+----------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$memory_global_by_current_allocated (
  event_name,
  current_count,
  current_alloc,
  current_avg_alloc,
  high_count,
  high_alloc,
  high_avg_alloc
) AS
SELECT event_name,
       current_count_used AS current_count,
       current_number_of_bytes_used AS current_alloc,
       current_number_of_bytes_used / current_count_used AS current_avg_alloc,
       high_count_used AS high_count,
       high_number_of_bytes_used AS high_alloc,
       high_number_of_bytes_used / high_count_used AS high_avg_alloc
  FROM performance_schema.memory_summary_global_by_event_name
 WHERE current_number_of_bytes_used > 0
 ORDER BY current_number_of_bytes_used DESC;
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
 * View: memory_global_total
 * 
 * Shows the total memory usage within the server globally.
 *
 * mysql> select * from memory_global_total;
 * +-----------------+
 * | total_allocated |
 * +-----------------+
 * | 123.35 MiB      |
 * +-----------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW memory_global_total (
  total_allocated
) AS
SELECT sys.format_bytes(SUM(CURRENT_NUMBER_OF_BYTES_USED)) total_allocated
  FROM performance_schema.memory_summary_global_by_event_name;

/* 
 * View: memory_global_total_raw
 * 
 * Shows the total memory usage within the server globally
 *
 * mysql> select * from x$memory_global_total;
 * +-----------------+
 * | total_allocated |
 * +-----------------+
 * |         1420023 |
 * +-----------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$memory_global_total (
  total_allocated
) AS
SELECT SUM(CURRENT_NUMBER_OF_BYTES_USED) total_allocated
  FROM performance_schema.memory_summary_global_by_event_name;
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
 * View: processlist
 *
 * A detailed non-blocking processlist view to replace 
 * [INFORMATION_SCHEMA. | SHOW FULL] PROCESSLIST
 *
 * mysql> select * from processlist where conn_id is not null\G
 * ...
 * *************************** 8. row ***************************
 *                 thd_id: 12400
 *                conn_id: 12379
 *                   user: root@localhost
 *                     db: ps_helper
 *                command: Query
 *                  state: Copying to tmp table
 *                   time: 0
 *      current_statement: select * from processlist_full where conn_id is not null
 *         last_statement: NULL
 * last_statement_latency: NULL
 *           lock_latency: 1.00 ms
 *          rows_examined: 0
 *              rows_sent: 0
 *          rows_affected: 0
 *             tmp_tables: 1
 *        tmp_disk_tables: 0
 *              full_scan: YES
 *              last_wait: wait/synch/mutex/sql/THD::LOCK_thd_data
 *      last_wait_latency: 62.53 ns
 *                 source: sql_class.h:3843
 *
 */
 
CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW processlist (
  thd_id,
  conn_id,
  user,
  db,
  command,
  state,
  time,
  current_statement,
  lock_latency,
  rows_examined,
  rows_sent,
  rows_affected,
  tmp_tables,
  tmp_disk_tables,
  full_scan,
  last_statement,
  last_statement_latency,
  last_wait,
  last_wait_latency,
  source
) AS
SELECT pps.thread_id AS thd_id,
       pps.processlist_id AS conn_id,
       IF(pps.name = 'thread/sql/one_connection', 
          CONCAT(pps.processlist_user, '@', pps.processlist_host), 
          REPLACE(pps.name, 'thread/', '')) user,
       pps.processlist_db AS db,
       pps.processlist_command AS command,
       pps.processlist_state AS state,
       pps.processlist_time AS time,
       sys.format_statement(pps.processlist_info) AS current_statement,
       sys.format_time(esc.lock_time) AS lock_latency,
       esc.rows_examined,
       esc.rows_sent,
       esc.rows_affected,
       esc.created_tmp_tables AS tmp_tables,
       esc.created_tmp_disk_tables AS tmp_disk_tables,
       IF(esc.no_good_index_used > 0 OR esc.no_index_used > 0, 
          'YES', 'NO') AS full_scan,
       IF(esc.timer_wait IS NOT NULL,
          sys.format_statement(esc.sql_text),
          NULL) AS last_statement,
       IF(esc.timer_wait IS NOT NULL,
          sys.format_time(esc.timer_wait),
          NULL) as last_statement_latency,
       ewc.event_name AS last_wait,
       IF(ewc.timer_wait IS NULL AND ewc.event_name IS NOT NULL, 
          'Still Waiting', 
          sys.format_time(ewc.timer_wait)) last_wait_latency,
       ewc.source
  FROM performance_schema.threads AS pps
  LEFT JOIN performance_schema.events_waits_current AS ewc USING (thread_id)
  LEFT JOIN performance_schema.events_statements_current as esc USING (thread_id)
 GROUP BY thread_id
 ORDER BY pps.processlist_time DESC, last_wait_latency DESC;

/*
 * View: processlist_raw
 *
 * A detailed non-blocking processlist view to replace 
 * [INFORMATION_SCHEMA. | SHOW FULL] PROCESSLIST
 * 
 * mysql> select * from processlist_full where conn_id is not null\G
 * *************************** 1. row ***************************
 *                 thd_id: 25
 *                conn_id: 6
 *                   user: root@localhost
 *                     db: ps_helper
 *                command: Query
 *                  state: Sending data
 *                   time: 0
 *      current_statement: select * from processlist_full where conn_id is not null
 *         last_statement: NULL
 * last_statement_latency: NULL
 *           lock_latency: 741.00 us
 *          rows_examined: 0
 *              rows_sent: 0
 *          rows_affected: 0
 *             tmp_tables: 1
 *        tmp_disk_tables: 0
 *              full_scan: YES
 *              last_wait: wait/synch/mutex/sql/THD::LOCK_query_plan
 *      last_wait_latency: 196.04 ns
 *                 source: sql_optimizer.cc:1075
 * 1 row in set (0.00 sec)
 *
 * Versions: 5.6.2+
 *
 */
 
CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$processlist (
  thd_id,
  conn_id,
  user,
  db,
  command,
  state,
  time,
  current_statement,
  lock_latency,
  rows_examined,
  rows_sent,
  rows_affected,
  tmp_tables,
  tmp_disk_tables,
  full_scan,
  last_statement,
  last_statement_latency,
  last_wait,
  last_wait_latency,
  source
) AS
SELECT pps.thread_id AS thd_id,
       pps.processlist_id AS conn_id,
       IF(pps.name = 'thread/sql/one_connection', 
          CONCAT(pps.processlist_user, '@', pps.processlist_host), 
          REPLACE(pps.name, 'thread/', '')) user,
       pps.processlist_db AS db,
       pps.processlist_command AS command,
       pps.processlist_state AS state,
       pps.processlist_time AS time,
       pps.processlist_info AS current_statement,
       esc.lock_time AS lock_latency,
       esc.rows_examined,
       esc.rows_sent,
       esc.rows_affected,
       esc.created_tmp_tables AS tmp_tables,
       esc.created_tmp_disk_tables AS tmp_disk_tables,
       IF(esc.no_good_index_used > 0 OR esc.no_index_used > 0, 
          'YES', 'NO') AS full_scan,
       IF(esc.timer_wait IS NOT NULL,
          esc.sql_text,
          NULL) AS last_statement,
       IF(esc.timer_wait IS NOT NULL,
          esc.timer_wait,
          NULL) as last_statement_latency,
       ewc.event_name AS last_wait,
       IF(ewc.timer_wait IS NULL AND ewc.event_name IS NOT NULL, 
          'Still Waiting', 
          ewc.timer_wait) last_wait_latency,
       ewc.source
  FROM performance_schema.threads AS pps
  LEFT JOIN performance_schema.events_waits_current AS ewc USING (thread_id)
  LEFT JOIN performance_schema.events_statements_current as esc USING (thread_id)
 GROUP BY thread_id
 ORDER BY pps.processlist_time DESC, last_wait_latency DESC;
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
 * View: ps_check_lost_instrumentation
 * 
 * Used to check whether Performance Schema is not able to monitor
 * all runtime data - only returns variables that have lost instruments
 *
 * mysql> select * from ps_check_lost_instrumentation;
 * +----------------------------------------+----------------+
 * | variable_name                          | variable_value |
 * +----------------------------------------+----------------+
 * | Performance_schema_file_handles_lost   | 101223         |
 * | Performance_schema_file_instances_lost | 1231           |
 * +----------------------------------------+----------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW ps_check_lost_instrumentation (
  variable_name,
  variable_value
)
AS
SELECT variable_name, variable_value
  FROM information_schema.global_status
 WHERE variable_name LIKE 'perf%lost'
   AND variable_value > 0;
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
 * View: schema_index_statistics
 *
 * Statistics around indexes.
 *
 * Ordered by the total wait time descending - top indexes are most contended.
 *
 * mysql> select * from schema_index_statistics limit 5;
 * +------------------+-------------+------------+---------------+----------------+---------------+----------------+--------------+----------------+--------------+----------------+
 * | table_schema     | table_name  | index_name | rows_selected | select_latency | rows_inserted | insert_latency | rows_updated | update_latency | rows_deleted | delete_latency |
 * +------------------+-------------+------------+---------------+----------------+---------------+----------------+--------------+----------------+--------------+----------------+
 * | mem              | mysqlserver | PRIMARY    |          6208 | 108.27 ms      |             0 | 0 ps           |         5470 | 1.47 s         |            0 | 0 ps           |
 * | mem              | innodb      | PRIMARY    |          4666 | 76.27 ms       |             0 | 0 ps           |         4454 | 571.47 ms      |            0 | 0 ps           |
 * | mem              | connection  | PRIMARY    |          1064 | 20.98 ms       |             0 | 0 ps           |         1064 | 457.30 ms      |            0 | 0 ps           |
 * | mem              | environment | PRIMARY    |          5566 | 151.17 ms      |             0 | 0 ps           |          694 | 252.57 ms      |            0 | 0 ps           |
 * | mem              | querycache  | PRIMARY    |          1698 | 27.99 ms       |             0 | 0 ps           |         1698 | 371.72 ms      |            0 | 0 ps           |
 * +------------------+-------------+------------+---------------+----------------+---------------+----------------+--------------+----------------+--------------+----------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW schema_index_statistics (
  table_schema,
  table_name,
  index_name,
  rows_selected,
  select_latency,
  rows_inserted,
  insert_latency,
  rows_updated,
  update_latency,
  rows_deleted,
  delete_latency
) AS
SELECT OBJECT_SCHEMA AS table_schema,
       OBJECT_NAME AS table_name,
       INDEX_NAME as index_name,
       COUNT_FETCH AS rows_selected,
       sys.format_time(SUM_TIMER_FETCH) AS select_latency,
       COUNT_INSERT AS rows_inserted,
       sys.format_time(SUM_TIMER_INSERT) AS insert_latency,
       COUNT_UPDATE AS rows_updated,
       sys.format_time(SUM_TIMER_UPDATE) AS update_latency,
       COUNT_DELETE AS rows_deleted,
       sys.format_time(SUM_TIMER_INSERT) AS delete_latency
  FROM performance_schema.table_io_waits_summary_by_index_usage
 WHERE index_name IS NOT NULL
 ORDER BY sum_timer_wait DESC;

/*
 * View: x$schema_index_statistics
 *
 * Statistics around indexes.
 *
 * Ordered by the total wait time descending - top indexes are most contended.
 *
 * mysql> SELECT * FROM x$schema_index_statistics LIMIT 5;
 * +---------------+----------------------+-------------------+---------------+----------------+---------------+----------------+--------------+----------------+--------------+----------------+
 * | table_schema  | table_name           | index_name        | rows_selected | select_latency | rows_inserted | insert_latency | rows_updated | update_latency | rows_deleted | delete_latency |
 * +---------------+----------------------+-------------------+---------------+----------------+---------------+----------------+--------------+----------------+--------------+----------------+
 * | common_schema | _global_sql_tokens   | PRIMARY           |          1886 |     1129676730 |             0 |              0 |            0 |              0 |         1878 |              0 |
 * | common_schema | _script_statements   | PRIMARY           |          4606 |     4212160680 |             0 |              0 |            0 |              0 |            0 |              0 |
 * | common_schema | _global_qs_variables | declaration_depth |           256 |     1650193090 |             0 |              0 |           32 |     1372148050 |            0 |              0 |
 * | common_schema | _global_qs_variables | PRIMARY           |             0 |              0 |             0 |              0 |            0 |              0 |           16 |              0 |
 * | common_schema | metadata             | PRIMARY           |             5 |       76730810 |             0 |              0 |            4 |      114310170 |            0 |              0 |
 * +---------------+----------------------+-------------------+---------------+----------------+---------------+----------------+--------------+----------------+--------------+----------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$schema_index_statistics (
  table_schema,
  table_name,
  index_name,
  rows_selected,
  select_latency,
  rows_inserted,
  insert_latency,
  rows_updated,
  update_latency,
  rows_deleted,
  delete_latency
) AS
SELECT OBJECT_SCHEMA AS table_schema,
       OBJECT_NAME AS table_name,
       INDEX_NAME as index_name,
       COUNT_FETCH AS rows_selected,
       SUM_TIMER_FETCH AS select_latency,
       COUNT_INSERT AS rows_inserted,
       SUM_TIMER_INSERT AS insert_latency,
       COUNT_UPDATE AS rows_updated,
       SUM_TIMER_UPDATE AS update_latency,
       COUNT_DELETE AS rows_deleted,
       SUM_TIMER_INSERT AS delete_latency
  FROM performance_schema.table_io_waits_summary_by_index_usage
 WHERE index_name IS NOT NULL
 ORDER BY sum_timer_wait DESC;
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
 * View: schema_table_statistics
 *
 * Statistics around tables.
 *
 * Ordered by the total wait time descending - top tables are most contended.
 * 
 * mysql> select * from schema_table_statistics limit 1\G
 * *************************** 1. row ***************************
 *                  table_schema: mem
 *                    table_name: mysqlserver
 *                  rows_fetched: 27087
 *                 fetch_latency: 442.72 ms
 *                 rows_inserted: 2
 *                insert_latency: 185.04 µs 
 *                  rows_updated: 5096
 *                update_latency: 1.39 s
 *                  rows_deleted: 0
 *                delete_latency: 0 ps
 *              io_read_requests: 2565
 *                 io_read_bytes: 1121627
 *               io_read_latency: 10.07 ms
 *             io_write_requests: 1691
 *                io_write_bytes: 128383
 *              io_write_latency: 14.17 ms
 *              io_misc_requests: 2698
 *               io_misc_latency: 433.66 ms
 *
 */ 

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW schema_table_statistics (
  table_schema,
  table_name,
  total_latency,
  rows_fetched,
  fetch_latency,
  rows_inserted,
  insert_latency,
  rows_updated,
  update_latency,
  rows_deleted,
  delete_latency,
  io_read_requests,
  io_read,
  io_read_latency,
  io_write_requests,
  io_write,
  io_write_latency,
  io_misc_requests,
  io_misc_latency
) AS
SELECT pst.object_schema AS table_schema,
       pst.object_name AS table_name,
       sys.format_time(pst.sum_timer_wait) AS total_latency,
       pst.count_fetch AS rows_fetched,
       sys.format_time(pst.sum_timer_fetch) AS fetch_latency,
       pst.count_insert AS rows_inserted,
       sys.format_time(pst.sum_timer_insert) AS insert_latency,
       pst.count_update AS rows_updated,
       sys.format_time(pst.sum_timer_update) AS update_latency,
       pst.count_delete AS rows_deleted,
       sys.format_time(pst.sum_timer_delete) AS delete_latency,
       SUM(fsbi.count_read) AS io_read_requests,
       sys.format_bytes(SUM(fsbi.sum_number_of_bytes_read)) AS io_read,
       sys.format_time(SUM(fsbi.sum_timer_read)) AS io_read_latency,
       SUM(fsbi.count_write) AS io_write_requests,
       sys.format_bytes(SUM(fsbi.sum_number_of_bytes_write)) AS io_write,
       sys.format_time(SUM(fsbi.sum_timer_write)) AS io_write_latency,
       SUM(fsbi.count_misc) AS io_misc_requests,
       sys.format_time(SUM(fsbi.sum_timer_misc)) AS io_misc_latency
  FROM performance_schema.table_io_waits_summary_by_table AS pst
  LEFT JOIN performance_schema.file_summary_by_instance AS fsbi
    ON pst.object_schema = extract_schema_from_file_name(fsbi.file_name)
   AND pst.object_name = extract_table_from_file_name(fsbi.file_name)
 GROUP BY pst.object_schema, pst.object_name
 ORDER BY pst.sum_timer_wait DESC;

/* 
 * View: x$schema_table_statistics
 *
 * Statistics around tables.
 *
 * Ordered by the total wait time descending - top tables are most contended.
 * 
 * mysql> SELECT * FROM x$schema_table_statistics LIMIT 1\G
 * *************************** 1. row ***************************
 *      table_schema: common_schema
 *        table_name: help_content
 *      rows_fetched: 0
 *     fetch_latency: 0
 *     rows_inserted: 169
 *    insert_latency: 409815527680
 *      rows_updated: 0
 *    update_latency: 0
 *      rows_deleted: 0
 *    delete_latency: 0
 *  io_read_requests: 14
 *           io_read: 1180
 *   io_read_latency: 52406770
 * io_write_requests: 131
 *          io_write: 11719246
 *  io_write_latency: 133726902790
 *  io_misc_requests: 61
 *   io_misc_latency: 209081089750
 *
 */ 
 
CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$schema_table_statistics (
  table_schema,
  table_name,
  total_latency,
  rows_fetched,
  fetch_latency,
  rows_inserted,
  insert_latency,
  rows_updated,
  update_latency,
  rows_deleted,
  delete_latency,
  io_read_requests,
  io_read,
  io_read_latency,
  io_write_requests,
  io_write,
  io_write_latency,
  io_misc_requests,
  io_misc_latency
) AS
SELECT pst.object_schema AS table_schema,
       pst.object_name AS table_name,
       pst.sum_timer_wait AS total_latency,
       pst.count_fetch AS rows_fetched,
       pst.sum_timer_fetch AS fetch_latency,
       pst.count_insert AS rows_inserted,
       pst.sum_timer_insert AS insert_latency,
       pst.count_update AS rows_updated,
       pst.sum_timer_update AS update_latency,
       pst.count_delete AS rows_deleted,
       pst.sum_timer_delete AS delete_latency,
       SUM(fsbi.count_read) AS io_read_requests,
       SUM(fsbi.sum_number_of_bytes_read) AS io_read,
       SUM(fsbi.sum_timer_read) AS io_read_latency,
       SUM(fsbi.count_write) AS io_write_requests,
       SUM(fsbi.sum_number_of_bytes_write) AS io_write,
       SUM(fsbi.sum_timer_write) AS io_write_latency,
       SUM(fsbi.count_misc) AS io_misc_requests,
       SUM(fsbi.sum_timer_misc) AS io_misc_latency
  FROM performance_schema.table_io_waits_summary_by_table AS pst
  LEFT JOIN performance_schema.file_summary_by_instance AS fsbi
    ON pst.object_schema = extract_schema_from_file_name(fsbi.file_name)
   AND pst.object_name = extract_table_from_file_name(fsbi.file_name)
 GROUP BY pst.object_schema, pst.object_name
 ORDER BY pst.sum_timer_wait DESC;
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
 * View: schema_table_statistics_with_buffer
 *
 * Statistics around tables.
 *
 * Ordered by the total wait time descending - top tables are most contended.
 *
 * More statistics such as caching stats for the InnoDB buffer pool with InnoDB tables
 *
 * mysql> select * from schema_table_statistics_with_buffer limit 1\G
 * *************************** 1. row ***************************
 *                  table_schema: mem
 *                    table_name: mysqlserver
 *                  rows_fetched: 27087
 *                 fetch_latency: 442.72 ms
 *                 rows_inserted: 2
 *                insert_latency: 185.04 µs 
 *                  rows_updated: 5096
 *                update_latency: 1.39 s
 *                  rows_deleted: 0
 *                delete_latency: 0 ps
 *              io_read_requests: 2565
 *                 io_read_bytes: 1121627
 *               io_read_latency: 10.07 ms
 *             io_write_requests: 1691
 *                io_write_bytes: 128383
 *              io_write_latency: 14.17 ms
 *              io_misc_requests: 2698
 *               io_misc_latency: 433.66 ms
 *           innodb_buffer_pages: 19
 *    innodb_buffer_pages_hashed: 19
 *       innodb_buffer_pages_old: 19
 * innodb_buffer_bytes_allocated: 311296
 *      innodb_buffer_bytes_data: 1924
 *     innodb_buffer_rows_cached: 2
 *
 */ 
 
CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW schema_table_statistics_with_buffer (
  table_schema,
  table_name,
  rows_fetched,
  fetch_latency,
  rows_inserted,
  insert_latency,
  rows_updated,
  update_latency,
  rows_deleted,
  delete_latency,
  io_read_requests,
  io_read,
  io_read_latency,
  io_write_requests,
  io_write,
  io_write_latency,
  io_misc_requests,
  io_misc_latency,
  innodb_buffer_allocated,
  innodb_buffer_data,
  innodb_buffer_pages,
  innodb_buffer_pages_hashed,
  innodb_buffer_pages_old,
  innodb_buffer_rows_cached
) AS
SELECT pst.object_schema AS table_schema,
       pst.object_name AS table_name,
       SUM(pst.count_fetch) AS rows_fetched,
       sys.format_time(SUM(pst.sum_timer_fetch)) AS fetch_latency,
       SUM(pst.count_fetch) AS rows_fetched,
       sys.format_time(SUM(pst.sum_timer_insert)) AS insert_latency,
       SUM(pst.count_update) AS rows_updated,
       sys.format_time(SUM(pst.sum_timer_update)) AS update_latency,
       SUM(pst.count_delete) AS rows_deleted,
       sys.format_time(SUM(pst.sum_timer_delete)) AS delete_latency,
       SUM(fsbi.count_read) AS io_read_requests,
       sys.format_bytes(SUM(fsbi.sum_number_of_bytes_read)) AS io_read,
       sys.format_time(SUM(fsbi.sum_timer_read)) AS io_read_latency,
       SUM(fsbi.count_write) AS io_write_requests,
       sys.format_bytes(SUM(fsbi.sum_number_of_bytes_write)) AS io_write,
       sys.format_time(SUM(fsbi.sum_timer_write)) AS io_write_latency,
       SUM(fsbi.count_misc) AS io_misc_requests,
       sys.format_time(SUM(fsbi.sum_timer_misc)) AS io_misc_latency,
       SUM(ibp.allocated) AS innodb_buffer_allocated,
       SUM(ibp.data) AS innodb_buffer_data,
       SUM(ibp.pages) AS innodb_buffer_pages,
       SUM(ibp.pages_hashed) AS innodb_buffer_pages_hashed,
       SUM(ibp.pages_old) AS innodb_buffer_pages_old,
       SUM(ibp.rows_cached) AS innodb_buffer_rows_cached
  FROM performance_schema.table_io_waits_summary_by_table AS pst
  LEFT JOIN performance_schema.file_summary_by_instance AS fsbi
    ON pst.object_schema = extract_schema_from_file_name(fsbi.file_name)
   AND pst.object_name = extract_table_from_file_name(fsbi.file_name)
  LEFT JOIN sys.x$innodb_buffer_stats_by_table AS ibp
    ON pst.object_schema = ibp.object_schema
   AND pst.object_name = ibp.object_name
 GROUP BY pst.object_schema, pst.object_name
 ORDER BY SUM(pst.sum_timer_wait) DESC;

/* 
 * View: x$schema_table_statistics_with_buffer
 *
 * Statistics around tables.
 *
 * Ordered by the total wait time descending - top tables are most contended.
 *
 * More statistics such as caching stats for the InnoDB buffer pool with InnoDB tables
 *
 * mysql> SELECT * FROM x$schema_table_statistics_with_buffer LIMIT 1\G
 * *************************** 1. row ***************************
 *               table_schema: common_schema
 *                 table_name: help_content
 *               rows_fetched: 0
 *              fetch_latency: 0
 *              rows_inserted: 169
 *             insert_latency: 409815527680
 *               rows_updated: 0
 *             update_latency: 0
 *               rows_deleted: 0
 *             delete_latency: 0
 *           io_read_requests: 14
 *                    io_read: 1180
 *            io_read_latency: 52406770
 *          io_write_requests: 131
 *                   io_write: 11719246
 *           io_write_latency: 133726902790
 *           io_misc_requests: 61
 *            io_misc_latency: 209081089750
 *    innodb_buffer_allocated: 688128
 *         innodb_buffer_data: 423667
 *        innodb_buffer_pages: 42
 * innodb_buffer_pages_hashed: 42
 *    innodb_buffer_pages_old: 42
 *  innodb_buffer_rows_cached: 210
 *
 */ 
 
CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$schema_table_statistics_with_buffer (
  table_schema,
  table_name,
  rows_fetched,
  fetch_latency,
  rows_inserted,
  insert_latency,
  rows_updated,
  update_latency,
  rows_deleted,
  delete_latency,
  io_read_requests,
  io_read,
  io_read_latency,
  io_write_requests,
  io_write,
  io_write_latency,
  io_misc_requests,
  io_misc_latency,
  innodb_buffer_allocated,
  innodb_buffer_data,
  innodb_buffer_pages,
  innodb_buffer_pages_hashed,
  innodb_buffer_pages_old,
  innodb_buffer_rows_cached
) AS
SELECT pst.object_schema AS table_schema,
       pst.object_name AS table_name,
       SUM(pst.count_fetch) AS rows_fetched,
       SUM(pst.sum_timer_fetch) AS fetch_latency,
       SUM(pst.count_insert) AS rows_inserted,
       SUM(pst.sum_timer_insert) AS insert_latency,
       SUM(pst.count_update) AS rows_updated,
       SUM(pst.sum_timer_update) AS update_latency,
       SUM(pst.count_delete) AS rows_deleted,
       SUM(pst.sum_timer_delete) AS delete_latency,
       SUM(fsbi.count_read) AS io_read_requests,
       SUM(fsbi.sum_number_of_bytes_read) AS io_read,
       SUM(fsbi.sum_timer_read) AS io_read_latency,
       SUM(fsbi.count_write) AS io_write_requests,
       SUM(fsbi.sum_number_of_bytes_write) AS io_write,
       SUM(fsbi.sum_timer_write) AS io_write_latency,
       SUM(fsbi.count_misc) AS io_misc_requests,
       SUM(fsbi.sum_timer_misc) AS io_misc_latency,
       SUM(ibp.allocated) AS innodb_buffer_allocated,
       SUM(ibp.data) AS innodb_buffer_data,
       SUM(ibp.pages) AS innodb_buffer_pages,
       SUM(ibp.pages_hashed) AS innodb_buffer_pages_hashed,
       SUM(ibp.pages_old) AS innodb_buffer_pages_old,
       SUM(ibp.rows_cached) AS innodb_buffer_rows_cached
  FROM performance_schema.table_io_waits_summary_by_table AS pst
  LEFT JOIN performance_schema.file_summary_by_instance AS fsbi
    ON pst.object_schema = extract_schema_from_file_name(fsbi.file_name)
   AND pst.object_name = extract_table_from_file_name(fsbi.file_name)
  LEFT JOIN sys.x$innodb_buffer_stats_by_table AS ibp
    ON pst.object_schema = ibp.object_schema
   AND pst.object_name = ibp.object_name
 GROUP BY pst.object_schema, pst.object_name
 ORDER BY SUM(pst.sum_timer_wait) DESC;
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
 * View: schema_tables_with_full_table_scans
 *
 * Find tables that are being accessed by full table scans
 * ordering by the number of rows scanned descending.
 *
 * mysql> select * from schema_tables_with_full_table_scans limit 5;
 * +------------------+-------------------+-------------------+
 * | object_schema    | object_name       | rows_full_scanned |
 * +------------------+-------------------+-------------------+
 * | mem              | rule_alarms       |              1210 |
 * | mem30__advisors  | advisor_schedules |              1021 |
 * | mem30__inventory | agent             |               498 |
 * | mem              | dc_p_string       |               449 |
 * | mem30__inventory | mysqlserver       |               294 |
 * +------------------+-------------------+-------------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW schema_tables_with_full_table_scans (
  object_schema,
  object_name,
  rows_full_scanned
) AS
SELECT object_schema, 
       object_name,
       count_read AS rows_full_scanned
  FROM performance_schema.table_io_waits_summary_by_index_usage 
 WHERE index_name IS NULL
   AND count_read > 0
 ORDER BY count_read DESC;
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
 * View: schema_unused_indexes
 * 
 * Finds indexes that have had no events against them (and hence, no usage).
 *
 * To trust whether the data from this view is representative of your workload,
 * you should ensure that the server has been up for a representative amount of
 * time before using it.
 *
 * mysql> select * from schema_unused_indexes limit 5;
 * +-------------------------+----------------------------------------+------------+
 * | object_schema           | object_name                            | index_name |
 * +-------------------------+----------------------------------------+------------+
 * | mem30_test__instruments | mysqlavailabilityadvisor$observedstate | PRIMARY    |
 * | mem30_test__test        | compressme                             | PRIMARY    |
 * | mem30_test__test        | compressmekeyblocksize                 | PRIMARY    |
 * | mem30_test__test        | dontcompressme                         | PRIMARY    |
 * | mem30_test__test        | round_robin_test                       | PRIMARY    |
 * +-------------------------+----------------------------------------+------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW schema_unused_indexes (
  object_schema,
  object_name,
  index_name
) AS
SELECT object_schema,
       object_name,
       index_name
  FROM performance_schema.table_io_waits_summary_by_index_usage 
 WHERE index_name IS NOT NULL
   AND count_star = 0
   AND object_schema != 'mysql'
 ORDER BY object_schema, object_name;
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
 * View: statement_analysis
 *
 * Lists a normalized statement view with aggregated statistics,
 * mimics the MySQL Enterprise Monitor Query Analysis view,
 * ordered by the total execution time per normalized statement
 * 
 * mysql> select * from statement_analysis limit 1\G
 * *************************** 1. row ***************************
 *             query: SELECT * FROM `schema_object_o ... MA` , `information_schema` ...
 *                db: sys
 *         full_scan: *
 *        exec_count: 2
 *         err_count: 0
 *        warn_count: 0
 *     total_latency: 16.75 s
 *       max_latency: 16.57 s
 *       avg_latency: 8.38 s
 *      lock_latency: 16.69 s
 *         rows_sent: 84
 *     rows_sent_avg: 42
 *     rows_examined: 20012
 * rows_examined_avg: 10006
 *        tmp_tables: 378
 *   tmp_disk_tables: 66
 *       rows_sorted: 168
 * sort_merge_passes: 0
 *            digest: 54f9bd520f0bbf15db0c2ed93386bec9
 *        first_seen: 2014-03-07 13:13:41
 *         last_seen: 2014-03-07 13:13:48 *
 * 
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW statement_analysis (
  query,
  db,
  full_scan,
  exec_count,
  err_count,
  warn_count,
  total_latency,
  max_latency,
  avg_latency,
  lock_latency,
  rows_sent,
  rows_sent_avg,
  rows_examined,
  rows_examined_avg,
  tmp_tables,
  tmp_disk_tables,
  rows_sorted,
  sort_merge_passes,
  digest,
  first_seen,
  last_seen
) AS
SELECT sys.format_statement(DIGEST_TEXT) AS query,
       SCHEMA_NAME AS db,
       IF(SUM_NO_GOOD_INDEX_USED > 0 OR SUM_NO_INDEX_USED > 0, '*', '') AS full_scan,
       COUNT_STAR AS exec_count,
       SUM_ERRORS AS err_count,
       SUM_WARNINGS AS warn_count,
       sys.format_time(SUM_TIMER_WAIT) AS total_latency,
       sys.format_time(MAX_TIMER_WAIT) AS max_latency,
       sys.format_time(AVG_TIMER_WAIT) AS avg_latency,
       sys.format_time(SUM_LOCK_TIME) AS lock_latency,
       SUM_ROWS_SENT AS rows_sent,
       ROUND(SUM_ROWS_SENT / COUNT_STAR) AS rows_sent_avg,
       SUM_ROWS_EXAMINED AS rows_examined,
       ROUND(SUM_ROWS_EXAMINED / COUNT_STAR)  AS rows_examined_avg,
       SUM_CREATED_TMP_TABLES AS tmp_tables,
       SUM_CREATED_TMP_DISK_TABLES AS tmp_disk_tables,
       SUM_SORT_ROWS AS rows_sorted,
       SUM_SORT_MERGE_PASSES AS sort_merge_passes,
       DIGEST AS digest,
       FIRST_SEEN AS first_seen,
       LAST_SEEN as last_seen
  FROM performance_schema.events_statements_summary_by_digest
ORDER BY SUM_TIMER_WAIT DESC;

/*
 * View: x$statement_analysis
 *
 * Lists a normalized statement view with aggregated statistics,
 * mimics the MySQL Enterprise Monitor Query Analysis view,
 * ordered by the total execution time per normalized statement
 * 
 * mysql> select * from x$statement_analysis limit 1\G
 * *************************** 1. row ***************************
 *             query: SELECT * FROM `schema_object_overview` SELECT `information_schema` . `routines`  -- truncated
 *                db: sys
 *         full_scan: *
 *        exec_count: 2
 *         err_count: 0
 *        warn_count: 0
 *     total_latency: 16751388791000
 *       max_latency: 16566171163000
 *       avg_latency: 8375694395000
 *      lock_latency: 16686483000000
 *         rows_sent: 84
 *     rows_sent_avg: 42
 *     rows_examined: 20012
 * rows_examined_avg: 10006
 *        tmp_tables: 378
 *   tmp_disk_tables: 66
 *       rows_sorted: 168
 * sort_merge_passes: 0
 *            digest: 54f9bd520f0bbf15db0c2ed93386bec9
 *        first_seen: 2014-03-07 13:13:41
 *         last_seen: 2014-03-07 13:13:48
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$statement_analysis (
  query,
  db,
  full_scan,
  exec_count,
  err_count,
  warn_count,
  total_latency,
  max_latency,
  avg_latency,
  lock_latency,
  rows_sent,
  rows_sent_avg,
  rows_examined,
  rows_examined_avg,
  tmp_tables,
  tmp_disk_tables,
  rows_sorted,
  sort_merge_passes,
  digest,
  first_seen,
  last_seen
) AS
SELECT DIGEST_TEXT AS query,
       SCHEMA_NAME AS db,
       IF(SUM_NO_GOOD_INDEX_USED > 0 OR SUM_NO_INDEX_USED > 0, '*', '') AS full_scan,
       COUNT_STAR AS exec_count,
       SUM_ERRORS AS err_count,
       SUM_WARNINGS AS warn_count,
       SUM_TIMER_WAIT AS total_latency,
       MAX_TIMER_WAIT AS max_latency,
       AVG_TIMER_WAIT AS avg_latency,
       SUM_LOCK_TIME AS lock_latency,
       SUM_ROWS_SENT AS rows_sent,
       ROUND(SUM_ROWS_SENT / COUNT_STAR) AS rows_sent_avg,
       SUM_ROWS_EXAMINED AS rows_examined,
       ROUND(SUM_ROWS_EXAMINED / COUNT_STAR)  AS rows_examined_avg,
       SUM_CREATED_TMP_TABLES AS tmp_tables,
       SUM_CREATED_TMP_DISK_TABLES AS tmp_disk_tables,
       SUM_SORT_ROWS AS rows_sorted,
       SUM_SORT_MERGE_PASSES AS sort_merge_passes,
       DIGEST AS digest,
       FIRST_SEEN AS first_seen,
       LAST_SEEN as last_seen
  FROM performance_schema.events_statements_summary_by_digest
ORDER BY SUM_TIMER_WAIT DESC;
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
 * View: statements_with_errors_or_warnings
 *
 * Lists all normalized statements that have raised errors or warnings.
 *
 * mysql> select * from x$statements_with_errors_or_warnings LIMIT 1\G
 * *************************** 1. row ***************************
 *       query: CREATE OR REPLACE ALGORITHM =  ... _delete` AS `rows_deleted` ...
 *          db: sys
 *  exec_count: 2
 *      errors: 1
 *   error_pct: 50.0000
 *    warnings: 0
 * warning_pct: 0.0000
 *  first_seen: 2014-03-07 12:56:54
 *   last_seen: 2014-03-07 13:01:01
 *      digest: 943a788859e623d5f7798ba0ae0fd8a9
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW statements_with_errors_or_warnings (
  query,
  db,
  exec_count,
  errors,
  error_pct,
  warnings,
  warning_pct,
  first_seen,
  last_seen,
  digest
) AS
SELECT sys.format_statement(DIGEST_TEXT) AS query,
       SCHEMA_NAME as db,
       COUNT_STAR AS exec_count,
       SUM_ERRORS AS errors,
       (SUM_ERRORS / COUNT_STAR) * 100 as error_pct,
       SUM_WARNINGS AS warnings,
       (SUM_WARNINGS / COUNT_STAR) * 100 as warning_pct,
       FIRST_SEEN as first_seen,
       LAST_SEEN as last_seen,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
 WHERE SUM_ERRORS > 0
    OR SUM_WARNINGS > 0
ORDER BY SUM_ERRORS DESC, SUM_WARNINGS DESC;

/*
 * View: x$statements_with_errors_or_warnings
 *
 * Lists all normalized statements that have raised errors or warnings.
 *
 * mysql> select * from x$statements_with_errors_or_warnings LIMIT 1\G
 * *************************** 1. row ***************************
 *       query: CREATE OR REPLACE ALGORITHM = TEMPTABLE DEFINER = ? @ ? SQL SECURITY INVOKER VIEW ... truncated
 *          db: sys
 *  exec_count: 2
 *      errors: 1
 *   error_pct: 50.0000
 *    warnings: 0
 * warning_pct: 0.0000
 *  first_seen: 2014-03-07 12:56:54
 *   last_seen: 2014-03-07 13:01:01
 *      digest: 943a788859e623d5f7798ba0ae0fd8a9
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$statements_with_errors_or_warnings (
  query,
  db,
  exec_count,
  errors,
  error_pct,
  warnings,
  warning_pct,
  first_seen,
  last_seen,
  digest
) AS
SELECT DIGEST_TEXT AS query,
       SCHEMA_NAME as db,
       COUNT_STAR AS exec_count,
       SUM_ERRORS AS errors,
       (SUM_ERRORS / COUNT_STAR) * 100 as error_pct,
       SUM_WARNINGS AS warnings,
       (SUM_WARNINGS / COUNT_STAR) * 100 as warning_pct,
       FIRST_SEEN as first_seen,
       LAST_SEEN as last_seen,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
 WHERE SUM_ERRORS > 0
    OR SUM_WARNINGS > 0
ORDER BY SUM_ERRORS DESC, SUM_WARNINGS DESC;
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
 * View: statements_with_full_table_scans
 *
 * Lists all normalized statements that use have done a full table scan
 * ordered by number the percentage of times a full scan was done,
 * then by the statement latency.
 *
 * mysql> select * from statements_with_full_table_scans limit 1\G
 * *************************** 1. row ***************************
 *                    query: SELECT * FROM `schema_tables_w ... ex_usage` . `COUNT_READ` DESC
 *                       db: sys
 *               exec_count: 1
 *            total_latency: 88.20 ms
 *      no_index_used_count: 1
 * no_good_index_used_count: 0
 *        no_index_used_pct: 100
 *                rows_sent: 0
 *            rows_examined: 1501
 *            rows_sent_avg: 0
 *        rows_examined_avg: 1501
 *               first_seen: 2014-03-07 13:58:20
 *                last_seen: 2014-03-07 13:58:20
 *                   digest: 64baecd5c1e1e1651a6b92e55442a288
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW statements_with_full_table_scans (
  query,
  db,
  exec_count,
  total_latency,
  no_index_used_count,
  no_good_index_used_count,
  no_index_used_pct,
  rows_sent,
  rows_examined,
  rows_sent_avg,
  rows_examined_avg,
  first_seen,
  last_seen,
  digest
) AS
SELECT sys.format_statement(DIGEST_TEXT) AS query,
       SCHEMA_NAME as db,
       COUNT_STAR AS exec_count,
       sys.format_time(SUM_TIMER_WAIT) AS total_latency,
       SUM_NO_INDEX_USED AS no_index_used_count,
       SUM_NO_GOOD_INDEX_USED AS no_good_index_used_count,
       ROUND((SUM_NO_INDEX_USED / COUNT_STAR) * 100) AS no_index_used_pct,
       SUM_ROWS_SENT AS rows_sent,
       SUM_ROWS_EXAMINED AS rows_examined,
       ROUND(SUM_ROWS_SENT/COUNT_STAR) AS rows_sent_avg,
       ROUND(SUM_ROWS_EXAMINED/COUNT_STAR) AS rows_examined_avg,
       FIRST_SEEN as first_seen,
       LAST_SEEN as last_seen,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
 WHERE SUM_NO_INDEX_USED > 0
    OR SUM_NO_GOOD_INDEX_USED > 0
 ORDER BY no_index_used_pct DESC, total_latency DESC;

/*
 * View: x$statements_with_full_table_scans
 *
 * Lists all normalized statements that use have done a full table scan
 * ordered by number the percentage of times a full scan was done,
 * then by the statement latency.
 *
 * mysql> select * from x$statements_with_full_table_scans limit 1\G
 * *************************** 1. row ***************************
 *                    query: SELECT * FROM `schema_object_overview` SELECT `information_schema` . `routines` . `ROUTINE_SCHEMA` // truncated
 *                       db: sys
 *               exec_count: 2
 *            total_latency: 16751388791000
 *      no_index_used_count: 2
 * no_good_index_used_count: 0
 *        no_index_used_pct: 100
 *                rows_sent: 84
 *            rows_examined: 20012
 *            rows_sent_avg: 42
 *        rows_examined_avg: 10006
 *               first_seen: 2014-03-07 13:13:41
 *                last_seen: 2014-03-07 13:13:48
 *                   digest: 54f9bd520f0bbf15db0c2ed93386bec9
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$statements_with_full_table_scans (
  query,
  db,
  exec_count,
  total_latency,
  no_index_used_count,
  no_good_index_used_count,
  no_index_used_pct,
  rows_sent,
  rows_examined,
  rows_sent_avg,
  rows_examined_avg,
  first_seen,
  last_seen,
  digest
) AS
SELECT DIGEST_TEXT AS query,
       SCHEMA_NAME as db,
       COUNT_STAR AS exec_count,
       SUM_TIMER_WAIT AS total_latency,
       SUM_NO_INDEX_USED AS no_index_used_count,
       SUM_NO_GOOD_INDEX_USED AS no_good_index_used_count,
       ROUND((SUM_NO_INDEX_USED / COUNT_STAR) * 100) AS no_index_used_pct,
       SUM_ROWS_SENT AS rows_sent,
       SUM_ROWS_EXAMINED AS rows_examined,
       ROUND(SUM_ROWS_SENT/COUNT_STAR) AS rows_sent_avg,
       ROUND(SUM_ROWS_EXAMINED/COUNT_STAR) AS rows_examined_avg,
       FIRST_SEEN as first_seen,
       LAST_SEEN as last_seen,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
 WHERE SUM_NO_INDEX_USED > 0
    OR SUM_NO_GOOD_INDEX_USED > 0
 ORDER BY no_index_used_pct DESC, total_latency DESC;
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
 * View: x$ps_digest_avg_latency_distribution
 *
 * Helper view for x$ps_digest_95th_percentile_by_avg_us
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$ps_digest_avg_latency_distribution (
  cnt,
  avg_us
) AS
SELECT COUNT(*) cnt, 
       ROUND(avg_timer_wait/1000000) AS avg_us
  FROM performance_schema.events_statements_summary_by_digest
 GROUP BY avg_us;

/*
 * View: x$ps_digest_95th_percentile_by_avg_us
 *
 * Helper view for statements_with_runtimes_in_95th_percentile.
 * Lists the 95th percentile runtime, for all statements
 *
 * mysql> select * from x$ps_digest_95th_percentile_by_avg_us;
 * +--------+------------+
 * | avg_us | percentile |
 * +--------+------------+
 * |    964 |     0.9525 |
 * +--------+------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$ps_digest_95th_percentile_by_avg_us (
  avg_us,
  percentile
) AS
SELECT s2.avg_us avg_us,
       SUM(s1.cnt)/(SELECT COUNT(*) FROM performance_schema.events_statements_summary_by_digest) percentile
  FROM sys.x$ps_digest_avg_latency_distribution AS s1
  JOIN sys.x$ps_digest_avg_latency_distribution AS s2
    ON s1.avg_us <= s2.avg_us
 GROUP BY s2.avg_us
HAVING percentile > 0.95
 ORDER BY percentile
 LIMIT 1;

/*
 * View: statements_with_runtimes_in_95th_percentile
 *
 * List all statements who's average runtime, in microseconds, is in the top 95th percentile.
 * 
 * mysql> select * from statements_with_runtimes_in_95th_percentile limit 5;
 * +-------------------------------------------------------------------+------+-----------+------------+-----------+------------+---------------+-------------+-------------+-----------+---------------+---------------+-------------------+---------------------+---------------------+----------------------------------+
 * | query                                                             | db   | full_scan | exec_count | err_count | warn_count | total_latency | max_latency | avg_latency | rows_sent | rows_sent_avg | rows_examined | rows_examined_avg | FIRST_SEEN          | LAST_SEEN           | digest                           |
 * +-------------------------------------------------------------------+------+-----------+------------+-----------+------------+---------------+-------------+-------------+-----------+---------------+---------------+-------------------+---------------------+---------------------+----------------------------------+
 * | SELECT `e` . `round_robin_bin` ...  `timestamp` = `maxes` . `ts`  | mem  | *         |         14 |         0 |          0 | 43.96 s       | 6.69 s      | 3.14 s      |        11 |             1 |        253170 |             18084 | 2013-12-04 20:05:01 | 2013-12-04 20:06:34 | 29ba002bf039bb6439357a10134407de |
 * | SELECT `e` . `round_robin_bin` ...  `timestamp` = `maxes` . `ts`  | mem  | *         |          8 |         0 |          0 | 17.89 s       | 4.12 s      | 2.24 s      |         7 |             1 |        169534 |             21192 | 2013-12-04 20:04:54 | 2013-12-04 20:05:05 | 0b1c1f91e7e9e0ff91aa49d15f540793 |
 * | SELECT `e` . `round_robin_bin` ...  `timestamp` = `maxes` . `ts`  | mem  | *         |          1 |         0 |          0 | 2.22 s        | 2.22 s      | 2.22 s      |         1 |             1 |         40322 |             40322 | 2013-12-04 20:05:39 | 2013-12-04 20:05:39 | 07b27145c8f8a3779737df5032374833 |
 * | SELECT `e` . `round_robin_bin` ...  `timestamp` = `maxes` . `ts`  | mem  | *         |          1 |         0 |          0 | 1.97 s        | 1.97 s      | 1.97 s      |         1 |             1 |         40322 |             40322 | 2013-12-04 20:05:39 | 2013-12-04 20:05:39 | a07488137ea5c1bccf3e291c50bfd21f |
 * | SELECT `e` . `round_robin_bin` ...  `timestamp` = `maxes` . `ts`  | mem  | *         |          2 |         0 |          0 | 3.91 s        | 3.91 s      | 1.96 s      |         1 |             1 |         13126 |              6563 | 2013-12-04 20:05:04 | 2013-12-04 20:06:34 | b8bddc6566366dafc7e474f67096a93b |
 * +-------------------------------------------------------------------+------+-----------+------------+-----------+------------+---------------+-------------+-------------+-----------+---------------+---------------+-------------------+---------------------+---------------------+----------------------------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW statements_with_runtimes_in_95th_percentile (
  query,
  db,
  full_scan,
  exec_count,
  err_count,
  warn_count,
  total_latency,
  max_latency,
  avg_latency,
  rows_sent,
  rows_sent_avg,
  rows_examined,
  rows_examined_avg,
  first_seen,
  last_seen,
  digest
) AS
SELECT sys.format_statement(DIGEST_TEXT) AS query,
       SCHEMA_NAME as db,
       IF(SUM_NO_GOOD_INDEX_USED > 0 OR SUM_NO_INDEX_USED > 0, '*', '') AS full_scan,
       COUNT_STAR AS exec_count,
       SUM_ERRORS AS err_count,
       SUM_WARNINGS AS warn_count,
       sys.format_time(SUM_TIMER_WAIT) AS total_latency,
       sys.format_time(MAX_TIMER_WAIT) AS max_latency,
       sys.format_time(AVG_TIMER_WAIT) AS avg_latency,
       SUM_ROWS_SENT AS rows_sent,
       ROUND(SUM_ROWS_SENT / COUNT_STAR) AS rows_sent_avg,
       SUM_ROWS_EXAMINED AS rows_examined,
       ROUND(SUM_ROWS_EXAMINED / COUNT_STAR) AS rows_examined_avg,
       FIRST_SEEN AS first_seen,
       LAST_SEEN AS last_seen,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest stmts
  JOIN sys.x$ps_digest_95th_percentile_by_avg_us AS top_percentile
    ON ROUND(stmts.avg_timer_wait/1000000) >= top_percentile.avg_us
 ORDER BY AVG_TIMER_WAIT DESC;

/*
 * View: x$statements_with_runtimes_in_95th_percentile
 *
 * List all statements who's average runtime, in microseconds, is in the top 95th percentile.
 * 
 * mysql> SELECT * FROM x$statements_with_runtimes_in_95th_percentile LIMIT 1\G
 * *************************** 1. row ***************************
 *             query: SELECT `e` . `round_robin_bin` AS `round1_1706_0_` , `e` . `id` AS `id1706_0_` , `e` . `timestamp` AS `timestamp1706_0_` , `e` . `rxBytes` AS `rxBytes1706_0_` , `e` . `rxPackets` AS `rxPackets1706_0_` , `e` . `rxErrors` AS `rxErrors1706_0_` , `e` . `txBytes` AS `txBytes1706_0_` , `e` . `txPackets` AS `txPackets1706_0_` , `e` . `txErrors` AS `txErrors1706_0_` , `e` . `txCollisions` AS `txColli10_1706_0_` FROM `mem__instruments` . `NetworkTrafficAdvisor_NetworkTraffic` AS `e` JOIN ( SELECT `id` AS `t` , MAX ( TIMESTAMP ) AS `ts` FROM `mem__instruments` . `NetworkTrafficAdvisor_NetworkTraffic` WHERE `id` IN (?) GROUP BY `id` ORDER BY NULL ) `maxes` ON `e` . `id` = `maxes` . `t` AND `e` . `timestamp` = `maxes` . `ts`
 *                db: mem
 *         full_scan: *
 *        exec_count: 14
 *         err_count: 0
 *        warn_count: 0
 *     total_latency: 43961670267000
 *       max_latency: 6686877140000
 *       avg_latency: 3140119304000
 *         rows_sent: 11
 *     rows_sent_avg: 1
 *     rows_examined: 253170
 * rows_examined_avg: 18084
 *        first_seen: 2013-12-04 20:05:01
 *         last_seen: 2013-12-04 20:06:34
 *            digest: 29ba002bf039bb6439357a10134407de
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$statements_with_runtimes_in_95th_percentile (
  query,
  db,
  full_scan,
  exec_count,
  err_count,
  warn_count,
  total_latency,
  max_latency,
  avg_latency,
  rows_sent,
  rows_sent_avg,
  rows_examined,
  rows_examined_avg,
  first_seen,
  last_seen,
  digest
) AS
SELECT DIGEST_TEXT AS query,
       SCHEMA_NAME AS db,
       IF(SUM_NO_GOOD_INDEX_USED > 0 OR SUM_NO_INDEX_USED > 0, '*', '') AS full_scan,
       COUNT_STAR AS exec_count,
       SUM_ERRORS AS err_count,
       SUM_WARNINGS AS warn_count,
       SUM_TIMER_WAIT AS total_latency,
       MAX_TIMER_WAIT AS max_latency,
       AVG_TIMER_WAIT AS avg_latency,
       SUM_ROWS_SENT AS rows_sent,
       ROUND(SUM_ROWS_SENT / COUNT_STAR) AS rows_sent_avg,
       SUM_ROWS_EXAMINED AS rows_examined,
       ROUND(SUM_ROWS_EXAMINED / COUNT_STAR) AS rows_examined_avg,
       FIRST_SEEN as first_seen,
       LAST_SEEN as last_seen,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest stmts
  JOIN sys.x$ps_digest_95th_percentile_by_avg_us AS top_percentile
    ON ROUND(stmts.avg_timer_wait/1000000) >= top_percentile.avg_us
 ORDER BY AVG_TIMER_WAIT DESC;
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
 * View: statements_with_sorting
 *
 * Lists all normalized statements that have done sorts,
 * ordered by total_latency descending.
 *
 * mysql> select * from statements_with_sorting limit 1\G
 * *************************** 1. row ***************************
 *             query: SELECT * FROM `schema_object_o ... MA` , `information_schema` ...
 *                db: sys
 *        exec_count: 2
 *     total_latency: 16.75 s
 * sort_merge_passes: 0
 *   avg_sort_merges: 0
 * sorts_using_scans: 12
 *  sort_using_range: 0
 *       rows_sorted: 168
 *   avg_rows_sorted: 84
 *        first_seen: 2014-03-07 13:13:41
 *         last_seen: 2014-03-07 13:13:48
 *            digest: 54f9bd520f0bbf15db0c2ed93386bec9
 * 
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW statements_with_sorting (
  query,
  db,
  exec_count,
  total_latency,
  sort_merge_passes,
  avg_sort_merges,
  sorts_using_scans,
  sort_using_range,
  rows_sorted,
  avg_rows_sorted,
  first_seen,
  last_seen,
  digest
) AS
SELECT sys.format_statement(DIGEST_TEXT) AS query,
       SCHEMA_NAME db,
       COUNT_STAR AS exec_count,
       sys.format_time(SUM_TIMER_WAIT) AS total_latency,
       SUM_SORT_MERGE_PASSES AS sort_merge_passes,
       ROUND(SUM_SORT_MERGE_PASSES / COUNT_STAR) AS avg_sort_merges,
       SUM_SORT_SCAN AS sorts_using_scans,
       SUM_SORT_RANGE AS sort_using_range,
       SUM_SORT_ROWS AS rows_sorted,
       ROUND(SUM_SORT_ROWS / COUNT_STAR) AS avg_rows_sorted,
       FIRST_SEEN as first_seen,
       LAST_SEEN as last_seen,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
 WHERE SUM_SORT_ROWS > 0
 ORDER BY SUM_TIMER_WAIT DESC;

/*
 * View: x$statements_with_sorting
 *
 * Lists all normalized statements that have done sorts,
 * ordered by total_latency descending.
 *
 * mysql> select * from x$statements_with_sorting\G
 * *************************** 1. row ***************************
 *             query: SELECT * FROM `schema_object_overview` SELECT `information_schema` . `routines` . `ROUTINE_SCHEMA` AS // truncated
 *                db: sys
 *        exec_count: 2
 *     total_latency: 16751388791000
 * sort_merge_passes: 0
 *   avg_sort_merges: 0
 * sorts_using_scans: 12
 *  sort_using_range: 0
 *       rows_sorted: 168
 *   avg_rows_sorted: 84
 *        first_seen: 2014-03-07 13:13:41
 *         last_seen: 2014-03-07 13:13:48
 *            digest: 54f9bd520f0bbf15db0c2ed93386bec9 *
 * 
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$statements_with_sorting (
  query,
  db,
  exec_count,
  total_latency,
  sort_merge_passes,
  avg_sort_merges,
  sorts_using_scans,
  sort_using_range,
  rows_sorted,
  avg_rows_sorted,
  first_seen,
  last_seen,
  digest
) AS
SELECT DIGEST_TEXT AS query,
       SCHEMA_NAME db,
       COUNT_STAR AS exec_count,
       SUM_TIMER_WAIT AS total_latency,
       SUM_SORT_MERGE_PASSES AS sort_merge_passes,
       ROUND(SUM_SORT_MERGE_PASSES / COUNT_STAR) AS avg_sort_merges,
       SUM_SORT_SCAN AS sorts_using_scans,
       SUM_SORT_RANGE AS sort_using_range,
       SUM_SORT_ROWS AS rows_sorted,
       ROUND(SUM_SORT_ROWS / COUNT_STAR) AS avg_rows_sorted,
       FIRST_SEEN as first_seen,
       LAST_SEEN as last_seen,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
 WHERE SUM_SORT_ROWS > 0
 ORDER BY SUM_TIMER_WAIT DESC;
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
 * View: statements_with_temp_tables
 *
 * Lists all normalized statements that use temporary tables
 * ordered by number of on disk temporary tables descending first, 
 * then by the number of memory tables.
 *
 * mysql> select * from statements_with_temp_tables limit 1\G
 * *************************** 1. row ***************************
 *                    query: SELECT * FROM `schema_object_o ... MA` , `information_schema` ...
 *                       db: sys
 *               exec_count: 2
 *            total_latency: 16.75 s
 *        memory_tmp_tables: 378
 *          disk_tmp_tables: 66
 * avg_tmp_tables_per_query: 189
 *  tmp_tables_to_disk_pct: 17
 *               first_seen: 2014-03-07 13:13:41
 *                last_seen: 2014-03-07 13:13:48
 *                   digest: 54f9bd520f0bbf15db0c2ed93386bec9
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW statements_with_temp_tables (
  query,
  db,
  exec_count,
  total_latency,
  memory_tmp_tables,
  disk_tmp_tables,
  avg_tmp_tables_per_query,
  tmp_tables_to_disk_pct,
  first_seen,
  last_seen,
  digest
) AS
SELECT sys.format_statement(DIGEST_TEXT) AS query,
       SCHEMA_NAME as db,
       COUNT_STAR AS exec_count,
       sys.format_time(SUM_TIMER_WAIT) as total_latency,
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

/*
 * View: x$statements_with_temp_tables
 *
 * Lists all normalized statements that use temporary tables
 * ordered by number of on disk temporary tables descending first, 
 * then by the number of memory tables.
 *
 * mysql> select * from x$statements_with_temp_tables limit 1\G
 * *************************** 1. row ***************************
 *                    query: SELECT * FROM `schema_object_overview` SELECT `information_schema` . `routines` . `ROUTINE_SCHEMA` AS `db` ,  // truncated
 *                       db: sys
 *               exec_count: 2
 *            total_latency: 16751388791000
 *        memory_tmp_tables: 378
 *          disk_tmp_tables: 66
 * avg_tmp_tables_per_query: 189
 *   tmp_tables_to_disk_pct: 17
 *               first_seen: 2014-03-07 13:13:41
 *                last_seen: 2014-03-07 13:13:48
 *                   digest: 54f9bd520f0bbf15db0c2ed93386bec9
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$statements_with_temp_tables (
  query,
  db,
  exec_count,
  total_latency,
  memory_tmp_tables,
  disk_tmp_tables,
  avg_tmp_tables_per_query,
  tmp_tables_to_disk_pct,
  first_seen,
  last_seen,
  digest
) AS
SELECT DIGEST_TEXT AS query,
       SCHEMA_NAME as db,
       COUNT_STAR AS exec_count,
       SUM_TIMER_WAIT as total_latency,
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
 * View: user_summary
 *
 * Summarizes statement activity, file IO and connections by user.
 *
 * mysql> select * from user_summary;
 * +------+------------+-------------------+-----------------------+-------------+----------+-----------------+---------------------+-------------------+--------------+
 * | user | statements | statement_latency | statement_avg_latency | table_scans | file_ios | file_io_latency | current_connections | total_connections | unique_hosts |
 * +------+------------+-------------------+-----------------------+-------------+----------+-----------------+---------------------+-------------------+--------------+
 * | root |       2924 | 00:03:59.53       | 81.92 ms              |          82 |    54702 | 55.61 s         |                   1 |                 1 |            1 |
 * +------+------------+-------------------+-----------------------+-------------+----------+-----------------+---------------------+-------------------+--------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW user_summary (
  user,
  statements,
  statement_latency,
  statement_avg_latency,
  table_scans,
  file_ios,
  file_io_latency,
  current_connections,
  total_connections,
  unique_hosts
) AS
SELECT accounts.user,
       SUM(stmt.total) AS statements,
       sys.format_time(SUM(stmt.total_latency)) AS statement_latency,
       sys.format_time(SUM(stmt.total_latency) / SUM(stmt.total)) AS statement_avg_latency,
       SUM(stmt.full_scans) AS table_scans,
       SUM(io.ios) AS file_ios,
       sys.format_time(SUM(io.io_latency)) AS file_io_latency,
       SUM(accounts.current_connections) AS current_connections,
       SUM(accounts.total_connections) AS total_connections,
       COUNT(DISTINCT host) AS unique_hosts
  FROM performance_schema.accounts
  LEFT JOIN sys.x$user_summary_by_statement_latency AS stmt ON accounts.user = stmt.user
  LEFT JOIN sys.x$user_summary_by_file_io AS io ON accounts.user = io.user
 WHERE accounts.user IS NOT NULL
 GROUP BY accounts.user;

/*
 * View: x$user_summary
 *
 * Summarizes statement activity, file IO and connections by user.
 *
 * mysql> select * from x$user_summary;
 * +------+------------+-------------------+-----------------------+-------------+----------+-----------------+---------------------+-------------------+--------------+
 * | user | statements | statement_latency | statement_avg_latency | table_scans | file_ios | file_io_latency | current_connections | total_connections | unique_hosts |
 * +------+------------+-------------------+-----------------------+-------------+----------+-----------------+---------------------+-------------------+--------------+
 * | root |       2925 |   239577283481000 |      81906763583.2479 |          83 |    54709 |  55605611965150 |                   1 |                 1 |            1 |
 * +------+------------+-------------------+-----------------------+-------------+----------+-----------------+---------------------+-------------------+--------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$user_summary (
  user,
  statements,
  statement_latency,
  statement_avg_latency,
  table_scans,
  file_ios,
  file_io_latency,
  current_connections,
  total_connections,
  unique_hosts
) AS
SELECT accounts.user,
       SUM(stmt.total) AS statements,
       SUM(stmt.total_latency) AS statement_latency,
       SUM(stmt.total_latency) / SUM(stmt.total) AS statement_avg_latency,
       SUM(stmt.full_scans) AS table_scans,
       SUM(io.ios) AS file_ios,
       SUM(io.io_latency) AS file_io_latency,
       SUM(accounts.current_connections) AS current_connections,
       SUM(accounts.total_connections) AS total_connections,
       COUNT(DISTINCT host) AS unique_hosts
  FROM performance_schema.accounts
  LEFT JOIN sys.x$user_summary_by_statement_latency AS stmt ON accounts.user = stmt.user
  LEFT JOIN sys.x$user_summary_by_file_io AS io ON accounts.user = io.user
 WHERE accounts.user IS NOT NULL
 GROUP BY accounts.user;
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
 * View: user_summary_by_file_io
 *
 * Summarizes file IO totals per user.
 *
 * When the user found is NULL, it is assumed to be a "background" thread.
 *
 * mysql> select * from user_summary_by_file_io;
 * +------------+-------+------------+
 * | user       | ios   | io_latency |
 * +------------+-------+------------+
 * | root       | 26457 | 21.58 s    |
 * | background |  1189 | 394.21 ms  |
 * +------------+-------+------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW user_summary_by_file_io (
  user,
  ios,
  io_latency
) AS
SELECT user, 
       SUM(total) AS ios,
       sys.format_time(SUM(latency)) AS io_latency 
  FROM x$user_summary_by_file_io_type
 GROUP BY user
 ORDER BY SUM(latency) DESC;

/*
 * View: x$user_summary_by_file_io
 *
 * Summarizes file IO totals per user.
 *
 * When the user found is NULL, it is assumed to be a "background" thread.
 *
 * mysql> select * from x$user_summary_by_file_io;
 * +------------+-------+----------------+
 * | user       | ios   | io_latency     |
 * +------------+-------+----------------+
 * | root       | 26457 | 21579585586390 |
 * | background |  1189 |   394212617370 |
 * +------------+-------+----------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$user_summary_by_file_io (
  user,
  ios,
  io_latency
) AS
SELECT user, 
       SUM(total) AS ios,
       SUM(latency) AS io_latency 
  FROM x$user_summary_by_file_io_type
 GROUP BY user
 ORDER BY SUM(latency) DESC;
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
 * View: user_summary_by_file_io_type
 *
 * Summarizes file IO by event type per user.
 *
 * When the user found is NULL, it is assumed to be a "background" thread.
 *
 * mysql> select * from user_summary_by_file_io_type;
 * +------------+--------------------------------------+-------+-----------+-------------+
 * | user       | event_name                           | total | latency   | max_latency |
 * +------------+--------------------------------------+-------+-----------+-------------+
 * | background | wait/io/file/sql/FRM                 |   871 | 168.15 ms | 18.48 ms    |
 * | background | wait/io/file/innodb/innodb_data_file |   173 | 129.56 ms | 34.09 ms    |
 * | background | wait/io/file/innodb/innodb_log_file  |    20 | 77.53 ms  | 60.66 ms    |
 * | background | wait/io/file/myisam/dfile            |    40 | 6.54 ms   | 4.58 ms     |
 * | background | wait/io/file/mysys/charset           |     3 | 4.79 ms   | 4.71 ms     |
 * | background | wait/io/file/myisam/kfile            |    67 | 4.38 ms   | 300.04 us   |
 * | background | wait/io/file/sql/ERRMSG              |     5 | 2.72 ms   | 1.69 ms     |
 * | background | wait/io/file/sql/pid                 |     3 | 266.30 us | 185.47 us   |
 * | background | wait/io/file/sql/casetest            |     5 | 246.81 us | 150.19 us   |
 * | background | wait/io/file/sql/global_ddl_log      |     2 | 21.24 us  | 18.59 us    |
 * | root       | wait/io/file/sql/file_parser         |  1422 | 4.80 s    | 135.14 ms   |
 * | root       | wait/io/file/sql/FRM                 |   865 | 85.82 ms  | 9.81 ms     |
 * | root       | wait/io/file/myisam/kfile            |  1073 | 37.14 ms  | 15.79 ms    |
 * | root       | wait/io/file/myisam/dfile            |  2991 | 25.53 ms  | 5.25 ms     |
 * | root       | wait/io/file/sql/dbopt               |    20 | 1.07 ms   | 153.07 us   |
 * | root       | wait/io/file/sql/misc                |     4 | 59.71 us  | 33.75 us    |
 * | root       | wait/io/file/archive/data            |     1 | 13.91 us  | 13.91 us    |
 * +------------+--------------------------------------+-------+-----------+-------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW user_summary_by_file_io_type (
  user,
  event_name,
  total,
  latency,
  max_latency
) AS
SELECT IF(user IS NULL, 'background', user) AS user,
       event_name,
       count_star AS total,
       sys.format_time(sum_timer_wait) AS latency,
       sys.format_time(max_timer_wait) AS max_latency
  FROM performance_schema.events_waits_summary_by_user_by_event_name
 WHERE event_name LIKE 'wait/io/file%'
   AND count_star > 0
 ORDER BY user, sum_timer_wait DESC;

/*
 * View: x$user_summary_by_file_io_type
 *
 * Summarizes file IO by event type per user.
 *
 * When the user found is NULL, it is assumed to be a "background" thread.
 *
 * mysql> select * from x$user_summary_by_file_io_type;
 * +------------+--------------------------------------+-------+---------------+--------------+
 * | user       | event_name                           | total | latency       | max_latency  |
 * +------------+--------------------------------------+-------+---------------+--------------+
 * | background | wait/io/file/sql/FRM                 |   871 |  168148450470 |  18482624810 |
 * | background | wait/io/file/innodb/innodb_data_file |   173 |  129564287450 |  34087423890 |
 * | background | wait/io/file/innodb/innodb_log_file  |    20 |   77525706960 |  60657475320 |
 * | background | wait/io/file/myisam/dfile            |    40 |    6544493800 |   4580546230 |
 * | background | wait/io/file/mysys/charset           |     3 |    4793558770 |   4713476430 |
 * | background | wait/io/file/myisam/kfile            |    67 |    4384332810 |    300035450 |
 * | background | wait/io/file/sql/ERRMSG              |     5 |    2717434850 |   1687316280 |
 * | background | wait/io/file/sql/pid                 |     3 |     266301490 |    185468920 |
 * | background | wait/io/file/sql/casetest            |     5 |     246814360 |    150193030 |
 * | background | wait/io/file/sql/global_ddl_log      |     2 |      21236410 |     18593640 |
 * | root       | wait/io/file/sql/file_parser         |  1422 | 4801104756760 | 135138518970 |
 * | root       | wait/io/file/sql/FRM                 |   865 |   85818594810 |   9812303410 |
 * | root       | wait/io/file/myisam/kfile            |  1073 |   37143664870 |  15793838190 |
 * | root       | wait/io/file/myisam/dfile            |  2991 |   25528215700 |   5252232050 |
 * | root       | wait/io/file/sql/dbopt               |    20 |    1067339780 |    153073310 |
 * | root       | wait/io/file/sql/misc                |     4 |      59713030 |     33752810 |
 * | root       | wait/io/file/archive/data            |     1 |      13907530 |     13907530 |
 * +------------+--------------------------------------+-------+---------------+--------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$user_summary_by_file_io_type (
  user,
  event_name,
  total,
  latency,
  max_latency
) AS
SELECT IF(user IS NULL, 'background', user) AS user,
       event_name,
       count_star AS total,
       sum_timer_wait AS latency,
       max_timer_wait AS max_latency
  FROM performance_schema.events_waits_summary_by_user_by_event_name
 WHERE event_name LIKE 'wait/io/file%'
   AND count_star > 0
 ORDER BY user, sum_timer_wait DESC;
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
 * View: user_summary_by_stages
 *
 * Summarizes stages by user, ordered by user and total latency per stage.
 * 
 * mysql> select * from user_summary_by_stages;
 * +------+--------------------------------+-------+-----------+-----------+
 * | user | event_name                     | total | wait_sum  | wait_avg  |
 * +------+--------------------------------+-------+-----------+-----------+
 * | root | stage/sql/Opening tables       |   889 | 1.97 ms   | 2.22 us   |
 * | root | stage/sql/Creating sort index  |     4 | 1.79 ms   | 446.30 us |
 * | root | stage/sql/init                 |    10 | 312.27 us | 31.23 us  |
 * | root | stage/sql/checking permissions |    10 | 300.62 us | 30.06 us  |
 * | root | stage/sql/freeing items        |     5 | 85.89 us  | 17.18 us  |
 * | root | stage/sql/statistics           |     5 | 79.15 us  | 15.83 us  |
 * | root | stage/sql/preparing            |     5 | 69.12 us  | 13.82 us  |
 * | root | stage/sql/optimizing           |     5 | 53.11 us  | 10.62 us  |
 * | root | stage/sql/Sending data         |     5 | 44.66 us  | 8.93 us   |
 * | root | stage/sql/closing tables       |     5 | 37.54 us  | 7.51 us   |
 * | root | stage/sql/System lock          |     5 | 34.28 us  | 6.86 us   |
 * | root | stage/sql/query end            |     5 | 24.37 us  | 4.87 us   |
 * | root | stage/sql/end                  |     5 | 8.60 us   | 1.72 us   |
 * | root | stage/sql/Sorting result       |     5 | 8.33 us   | 1.67 us   |
 * | root | stage/sql/executing            |     5 | 5.37 us   | 1.07 us   |
 * | root | stage/sql/cleaning up          |     5 | 4.60 us   | 919.00 ns |
 * +------+--------------------------------+-------+-----------+-----------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW user_summary_by_stages (
  user,
  event_name,
  total,
  wait_sum,
  wait_avg
) AS
SELECT user,
       event_name,
       count_star AS total,
       sys.format_time(sum_timer_wait) AS wait_sum, 
       sys.format_time(avg_timer_wait) AS wait_avg 
  FROM performance_schema.events_stages_summary_by_user_by_event_name
 WHERE user IS NOT NULL 
   AND sum_timer_wait != 0 
 ORDER BY user, sum_timer_wait DESC;

/*
 * View: x$user_summary_by_stages
 *
 * Summarizes stages by user, ordered by user and total latency per stage.
 * 
 * mysql> select * from x$user_summary_by_stages;
 * +------+--------------------------------+-------+-------------+-----------+
 * | user | event_name                     | total | wait_sum    | wait_avg  |
 * +------+--------------------------------+-------+-------------+-----------+
 * | root | stage/sql/Opening tables       |  1114 | 71919037000 |  64559000 |
 * | root | stage/sql/Creating sort index  |     5 |  2245762000 | 449152000 |
 * | root | stage/sql/init                 |    13 |   428798000 |  32984000 |
 * | root | stage/sql/checking permissions |    13 |   363231000 |  27940000 |
 * | root | stage/sql/freeing items        |     7 |   137728000 |  19675000 |
 * | root | stage/sql/statistics           |     6 |    93955000 |  15659000 |
 * | root | stage/sql/preparing            |     6 |    82571000 |  13761000 |
 * | root | stage/sql/optimizing           |     6 |    63338000 |  10556000 |
 * | root | stage/sql/Sending data         |     6 |    53400000 |   8900000 |
 * | root | stage/sql/closing tables       |     7 |    46922000 |   6703000 |
 * | root | stage/sql/System lock          |     6 |    40175000 |   6695000 |
 * | root | stage/sql/query end            |     7 |    31723000 |   4531000 |
 * | root | stage/sql/Sorting result       |     6 |     9855000 |   1642000 |
 * | root | stage/sql/end                  |     6 |     9556000 |   1592000 |
 * | root | stage/sql/cleaning up          |     7 |     7312000 |   1044000 |
 * | root | stage/sql/executing            |     6 |     6487000 |   1081000 |
 * +------+--------------------------------+-------+-------------+-----------+ *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$user_summary_by_stages (
  user,
  event_name,
  total,
  wait_sum,
  wait_avg
) AS
SELECT user,
       event_name,
       count_star AS total,
       sum_timer_wait AS wait_sum, 
       avg_timer_wait AS wait_avg 
  FROM performance_schema.events_stages_summary_by_user_by_event_name
 WHERE user IS NOT NULL 
   AND sum_timer_wait != 0 
 ORDER BY user, sum_timer_wait DESC;
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
 * View: user_summary_by_statement_latency
 *
 * Summarizes overall statement statistics by user.
 *
 * mysql> select * from user_summary_by_statement_latency;
 * +------+-------+---------------+-------------+--------------+-----------+---------------+---------------+------------+
 * | user | total | total_latency | max_latency | lock_latency | rows_sent | rows_examined | rows_affected | full_scans |
 * +------+-------+---------------+-------------+--------------+-----------+---------------+---------------+------------+
 * | root |  3381 | 00:02:09.13   | 1.48 s      | 1.07 s       |      1151 |         93947 |           150 |         91 |
 * +------+-------+---------------+-------------+--------------+-----------+---------------+---------------+------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW user_summary_by_statement_latency (
  user,
  total,
  total_latency,
  max_latency,
  lock_latency,
  rows_sent,
  rows_examined,
  rows_affected,
  full_scans
) AS
SELECT user,
       SUM(total) AS total,
       sys.format_time(SUM(total_latency)) AS total_latency,
       sys.format_time(SUM(max_latency)) AS max_latency,
       sys.format_time(SUM(lock_latency)) AS lock_latency,
       SUM(rows_sent) AS rows_sent,
       SUM(rows_examined) AS rows_examined,
       SUM(rows_affected) AS rows_affected,
       SUM(full_scans) AS full_scans
  FROM sys.x$user_summary_by_statement_type
 GROUP BY user
 ORDER BY SUM(total_latency) DESC;

/*
 * View: x$user_summary_by_statement_latency
 *
 * Summarizes overall statement statistics by user.
 *
 * mysql> select * from x$user_summary_by_statement_latency;
 * +------+-------+-----------------+---------------+---------------+-----------+---------------+---------------+------------+
 * | user | total | total_latency   | max_latency   | lock_latency  | rows_sent | rows_examined | rows_affected | full_scans |
 * +------+-------+-----------------+---------------+---------------+-----------+---------------+---------------+------------+
 * | root |  3382 | 129134039432000 | 1483246743000 | 1069831000000 |      1152 |         94286 |           150 |         92 |
 * +------+-------+-----------------+---------------+---------------+-----------+---------------+---------------+------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$user_summary_by_statement_latency (
  user,
  total,
  total_latency,
  max_latency,
  lock_latency,
  rows_sent,
  rows_examined,
  rows_affected,
  full_scans
) AS
SELECT user,
       SUM(total) AS total,
       SUM(total_latency) AS total_latency,
       SUM(max_latency) AS max_latency,
       SUM(lock_latency) AS lock_latency,
       SUM(rows_sent) AS rows_sent,
       SUM(rows_examined) AS rows_examined,
       SUM(rows_affected) AS rows_affected,
       SUM(full_scans) AS full_scans
  FROM sys.x$user_summary_by_statement_type
 GROUP BY user
 ORDER BY SUM(total_latency) DESC;
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
 * View: user_summary_by_statement_type
 *
 * Summarizes the types of statements executed by each user.
 *
 * mysql> select * from user_summary_by_statement_type;
 * +------+----------------------+--------+---------------+-------------+--------------+-----------+---------------+---------------+------------+
 * | user | statement            | total  | total_latency | max_latency | lock_latency | rows_sent | rows_examined | rows_affected | full_scans |
 * +------+----------------------+--------+---------------+-------------+--------------+-----------+---------------+---------------+------------+
 * | root | create_view          |   2063 | 00:05:04.20   | 463.58 ms   | 1.42 s       |         0 |             0 |             0 |          0 |
 * | root | select               |    174 | 40.87 s       | 28.83 s     | 858.13 ms    |      5212 |        157022 |             0 |         82 |
 * | root | stmt                 |   6645 | 15.31 s       | 491.78 ms   | 0 ps         |         0 |             0 |          7951 |          0 |
 * | root | call_procedure       |     17 | 4.78 s        | 1.02 s      | 37.94 ms     |         0 |             0 |            19 |          0 |
 * | root | create_table         |     19 | 3.04 s        | 431.71 ms   | 0 ps         |         0 |             0 |             0 |          0 |
 * ...
 * +------+----------------------+--------+---------------+-------------+--------------+-----------+---------------+---------------+------------+
 * 
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW user_summary_by_statement_type (
  user,
  statement,
  total,
  total_latency,
  max_latency,
  lock_latency,
  rows_sent,
  rows_examined,
  rows_affected,
  full_scans
) AS
SELECT user,
       SUBSTRING_INDEX(event_name, '/', -1) AS statement,
       count_star AS total,
       sys.format_time(sum_timer_wait) AS total_latency,
       sys.format_time(max_timer_wait) AS max_latency,
       sys.format_time(sum_lock_time) AS lock_latency,
       sum_rows_sent AS rows_sent,
       sum_rows_examined AS rows_examined,
       sum_rows_affected AS rows_affected,
       sum_no_index_used + sum_no_good_index_used AS full_scans
  FROM performance_schema.events_statements_summary_by_user_by_event_name
 WHERE user IS NOT NULL
   AND sum_timer_wait != 0
 ORDER BY user, sum_timer_wait DESC;

/*
 * View: x$user_summary_by_statement_type
 *
 * Summarizes the types of statements executed by each user.
 *
 * mysql> select * from x$user_summary_by_statement_type;
 * +------+----------------------+--------+-----------------+----------------+----------------+-----------+---------------+---------------+------------+
 * | user | statement            | total  | total_latency   | max_latency    | lock_latency   | rows_sent | rows_examined | rows_affected | full_scans |
 * +------+----------------------+--------+-----------------+----------------+----------------+-----------+---------------+---------------+------------+
 * | root | create_view          |   2110 | 312717366332000 |   463578029000 |  1432355000000 |         0 |             0 |             0 |          0 |
 * | root | select               |    177 |  41115690428000 | 28827579292000 |   858709000000 |      5254 |        157437 |             0 |         83 |
 * | root | stmt                 |   6645 |  15305389969000 |   491780297000 |              0 |         0 |             0 |          7951 |          0 |
 * | root | call_procedure       |     17 |   4783806053000 |  1016083397000 |    37936000000 |         0 |             0 |            19 |          0 |
 * | root | create_table         |     19 |   3035120946000 |   431706815000 |              0 |         0 |             0 |             0 |          0 |
 * ...
 * +------+----------------------+--------+-----------------+----------------+----------------+-----------+---------------+---------------+------------+
 * 
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$user_summary_by_statement_type (
  user,
  statement,
  total,
  total_latency,
  max_latency,
  lock_latency,
  rows_sent,
  rows_examined,
  rows_affected,
  full_scans
) AS
SELECT user,
       SUBSTRING_INDEX(event_name, '/', -1) AS statement,
       count_star AS total,
       sum_timer_wait AS total_latency,
       max_timer_wait AS max_latency,
       sum_lock_time AS lock_latency,
       sum_rows_sent AS rows_sent,
       sum_rows_examined AS rows_examined,
       sum_rows_affected AS rows_affected,
       sum_no_index_used + sum_no_good_index_used AS full_scans
  FROM performance_schema.events_statements_summary_by_user_by_event_name
 WHERE user IS NOT NULL
   AND sum_timer_wait != 0
 ORDER BY user, sum_timer_wait DESC;
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
 * View: wait_classes_global_by_avg_latency
 * 
 * Lists the top wait classes by average latency, ignoring idle (this may be very large).
 *
 * mysql> select * from wait_classes_global_by_avg_latency where event_class != 'idle';
 * +-------------------+--------+---------------+-------------+-------------+-------------+
 * | event_class       | total  | total_latency | min_latency | avg_latency | max_latency |
 * +-------------------+--------+---------------+-------------+-------------+-------------+
 * | wait/io/file      | 543123 | 44.60 s       | 19.44 ns    | 82.11 µs    | 4.21 s      |
 * | wait/io/table     |  22002 | 766.60 ms     | 148.72 ns   | 34.84 µs    | 44.97 ms    |
 * | wait/io/socket    |  79613 | 967.17 ms     | 0 ps        | 12.15 µs    | 27.10 ms    |
 * | wait/lock/table   |  35409 | 18.68 ms      | 65.45 ns    | 527.51 ns   | 969.88 µs   |
 * | wait/synch/rwlock |  37935 | 4.61 ms       | 21.38 ns    | 121.61 ns   | 34.65 µs    |
 * | wait/synch/mutex  | 390622 | 18.60 ms      | 19.44 ns    | 47.61 ns    | 10.32 µs    |
 * +-------------------+--------+---------------+-------------+-------------+-------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW wait_classes_global_by_avg_latency (
  event_class,
  total,
  total_latency,
  min_latency,
  avg_latency,
  max_latency
) AS
SELECT SUBSTRING_INDEX(event_name,'/', 3) AS event_class,
       SUM(COUNT_STAR) AS total,
       sys.format_time(CAST(SUM(sum_timer_wait) AS UNSIGNED)) AS total_latency,
       sys.format_time(MIN(min_timer_wait)) AS min_latency,
       sys.format_time(SUM(sum_timer_wait) / SUM(COUNT_STAR)) AS avg_latency,
       sys.format_time(CAST(MAX(max_timer_wait) AS UNSIGNED)) AS max_latency
  FROM performance_schema.events_waits_summary_global_by_event_name
 WHERE sum_timer_wait > 0
   AND event_name != 'idle'
 GROUP BY event_class
 ORDER BY SUM(sum_timer_wait) / SUM(COUNT_STAR) DESC;

/*
 * View: x$wait_classes_global_by_avg_latency
 * 
 * Lists the top wait classes by average latency, ignoring idle (this may be very large).
 *
 * mysql> select * from x$wait_classes_global_by_avg_latency;
 * +-------------------+---------+-------------------+-------------+--------------------+------------------+
 * | event_class       | total   | total_latency     | min_latency | avg_latency        | max_latency      |
 * +-------------------+---------+-------------------+-------------+--------------------+------------------+
 * | idle              |    4331 | 16044682716000000 |     2000000 | 3704613880397.1369 | 1593550454000000 |
 * | wait/io/file      |   23037 |    20856702551880 |           0 |     905356711.0249 |     350700491310 |
 * | wait/io/table     |  224924 |      719670285750 |      116870 |       3199615.3623 |     208579012460 |
 * | wait/lock/table   |    6972 |        3674766030 |      109330 |        527074.8752 |          8855730 |
 * | wait/synch/rwlock |   11916 |        1273279800 |       37700 |        106854.6324 |          6838780 |
 * | wait/synch/mutex  | 1031881 |       80464286240 |       56550 |         77978.2613 |       2590408470 |
 * +-------------------+---------+-------------------+-------------+--------------------+------------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$wait_classes_global_by_avg_latency (
  event_class,
  total,
  total_latency,
  min_latency,
  avg_latency,
  max_latency
) AS
SELECT SUBSTRING_INDEX(event_name,'/', 3) AS event_class,
       SUM(COUNT_STAR) AS total,
       SUM(sum_timer_wait) AS total_latency,
       MIN(min_timer_wait) AS min_latency,
       SUM(sum_timer_wait) / SUM(COUNT_STAR) AS avg_latency,
       MAX(max_timer_wait) AS max_latency
  FROM performance_schema.events_waits_summary_global_by_event_name
 WHERE sum_timer_wait > 0
   AND event_name != 'idle'
 GROUP BY event_class
 ORDER BY SUM(sum_timer_wait) / SUM(COUNT_STAR) DESC;
 
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
 * View: wait_classes_global_by_latency
 * 
 * Lists the top wait classes by total latency, ignoring idle (this may be very large).
 *
 * mysql> select * from wait_classes_global_by_latency;
 * +-------------------+--------+---------------+-------------+-------------+-------------+
 * | event_class       | total  | total_latency | min_latency | avg_latency | max_latency |
 * +-------------------+--------+---------------+-------------+-------------+-------------+
 * | wait/io/file      | 550470 | 46.01 s       | 19.44 ns    | 83.58 µs    | 4.21 s      |
 * | wait/io/socket    | 228833 | 2.71 s        | 0 ps        | 11.86 µs    | 29.93 ms    |
 * | wait/io/table     |  64063 | 1.89 s        | 99.79 ns    | 29.43 µs    | 68.07 ms    |
 * | wait/lock/table   |  76029 | 47.19 ms      | 65.45 ns    | 620.74 ns   | 969.88 µs   |
 * | wait/synch/mutex  | 635925 | 34.93 ms      | 19.44 ns    | 54.93 ns    | 107.70 µs   |
 * | wait/synch/rwlock |  61287 | 7.62 ms       | 21.38 ns    | 124.37 ns   | 34.65 µs    |
 * +-------------------+--------+---------------+-------------+-------------+-------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW wait_classes_global_by_latency (
  event_class,
  total,
  total_latency,
  min_latency,
  avg_latency,
  max_latency
) AS
SELECT SUBSTRING_INDEX(event_name,'/', 3) AS event_class, 
       SUM(COUNT_STAR) AS total,
       sys.format_time(SUM(sum_timer_wait)) AS total_latency,
       sys.format_time(MIN(min_timer_wait)) min_latency,
       sys.format_time(SUM(sum_timer_wait) / SUM(COUNT_STAR)) AS avg_latency,
       sys.format_time(MAX(max_timer_wait)) AS max_latency
  FROM performance_schema.events_waits_summary_global_by_event_name
 WHERE sum_timer_wait > 0
   AND event_name != 'idle'
 GROUP BY SUBSTRING_INDEX(event_name,'/', 3) 
 ORDER BY SUM(sum_timer_wait) DESC;

/*
 * View: x$wait_classes_global_by_latency
 * 
 * Lists the top wait classes by total latency, ignoring idle (this may be very large).
 *
 * mysql> SELECT * FROM x$wait_classes_global_by_latency;
 * +-------------------+---------+----------------+-------------+----------------+--------------+
 * | event_class       | total   | total_latency  | min_latency | avg_latency    | max_latency  |
 * +-------------------+---------+----------------+-------------+----------------+--------------+
 * | wait/io/file      |   29468 | 27100905420290 |           0 | 919672370.7170 | 350700491310 |
 * | wait/io/table     |  224924 |   719670285750 |      116870 |   3199615.3623 | 208579012460 |
 * | wait/synch/mutex  | 1532036 |   118515948070 |       56550 |     77358.4616 |   2590408470 |
 * | wait/io/socket    |    1193 |    10677541030 |           0 |   8950160.1257 |    287760330 |
 * | wait/lock/table   |    6972 |     3674766030 |      109330 |    527074.8752 |      8855730 |
 * | wait/synch/rwlock |   13646 |     1579833580 |       37700 |    115772.6499 |     28293850 |
 * +-------------------+---------+----------------+-------------+----------------+--------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$wait_classes_global_by_latency (
  event_class,
  total,
  total_latency,
  min_latency,
  avg_latency,
  max_latency
) AS
SELECT SUBSTRING_INDEX(event_name,'/', 3) AS event_class, 
       SUM(COUNT_STAR) AS total,
       SUM(sum_timer_wait) AS total_latency,
       MIN(min_timer_wait) AS min_latency,
       SUM(sum_timer_wait) / SUM(COUNT_STAR) AS avg_latency,
       MAX(max_timer_wait) AS max_latency
  FROM performance_schema.events_waits_summary_global_by_event_name
 WHERE sum_timer_wait > 0
   AND event_name != 'idle'
 GROUP BY SUBSTRING_INDEX(event_name,'/', 3) 
 ORDER BY SUM(sum_timer_wait) DESC;
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
 * View: waits_by_user_by_latency
 *
 * Lists the top wait events by their total latency, ignoring idle (this may be very large).
 *
 * mysql> select * from waits_by_user_by_latency;
 * +------+-----------------------------------------------------+--------+---------------+-------------+-------------+
 * | user | event                                               | total  | total_latency | avg_latency | max_latency |
 * +------+-----------------------------------------------------+--------+---------------+-------------+-------------+
 * | root | wait/io/file/sql/file_parser                        |  13743 | 00:01:00.46   | 4.40 ms     | 231.88 ms   |
 * | root | wait/io/file/innodb/innodb_data_file                |   4699 | 3.02 s        | 643.38 us   | 46.93 ms    |
 * | root | wait/io/file/sql/FRM                                |  11462 | 2.60 s        | 226.83 us   | 61.72 ms    |
 * | root | wait/io/file/myisam/dfile                           |  26776 | 746.70 ms     | 27.89 us    | 308.79 ms   |
 * | root | wait/io/file/myisam/kfile                           |   7126 | 462.66 ms     | 64.93 us    | 88.76 ms    |
 * | root | wait/io/file/sql/dbopt                              |    179 | 137.58 ms     | 768.59 us   | 15.46 ms    |
 * | root | wait/io/file/csv/metadata                           |      8 | 86.60 ms      | 10.82 ms    | 50.32 ms    |
 * | root | wait/synch/mutex/mysys/IO_CACHE::append_buffer_lock | 798080 | 66.46 ms      | 82.94 ns    | 161.03 us   |
 * | root | wait/io/file/sql/binlog                             |     19 | 49.11 ms      | 2.58 ms     | 9.40 ms     |
 * | root | wait/io/file/sql/misc                               |     26 | 22.38 ms      | 860.80 us   | 15.30 ms    |
 * | root | wait/io/file/csv/data                               |      4 | 297.46 us     | 74.37 us    | 111.93 us   |
 * | root | wait/synch/rwlock/sql/MDL_lock::rwlock              |    944 | 287.86 us     | 304.62 ns   | 874.64 ns   |
 * | root | wait/io/file/archive/data                           |      4 | 82.71 us      | 20.68 us    | 40.74 us    |
 * | root | wait/synch/mutex/myisam/MYISAM_SHARE::intern_lock   |     60 | 12.21 us      | 203.20 ns   | 512.72 ns   |
 * | root | wait/synch/mutex/innodb/trx_mutex                   |     81 | 5.93 us       | 73.14 ns    | 252.59 ns   |
 * +------+-----------------------------------------------------+--------+---------------+-------------+-------------+
 * 
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW waits_by_user_by_latency (
  user,
  event,
  total,
  total_latency,
  avg_latency,
  max_latency
) AS
SELECT user,
       event_name AS event,
       count_star AS total,
       sys.format_time(sum_timer_wait) AS total_latency,
       sys.format_time(avg_timer_wait) AS avg_latency,
       sys.format_time(max_timer_wait) AS max_latency
  FROM performance_schema.events_waits_summary_by_user_by_event_name
 WHERE event_name != 'idle'
   AND user IS NOT NULL
   AND sum_timer_wait > 0
 ORDER BY user, sum_timer_wait DESC;

/*
 * View: waits_by_user_by_latency_raw
 *
 * Lists the top wait events by their total latency, ignoring idle (this may be very large).
 *
 * mysql> select * from x$waits_by_user_by_latency;
 * +------+-----------------------------------------------------+--------+----------------+-------------+--------------+
 * | user | event                                               | total  | total_latency  | avg_latency | max_latency  |
 * +------+-----------------------------------------------------+--------+----------------+-------------+--------------+
 * | root | wait/io/file/sql/file_parser                        |  13745 | 60462025415480 |  4398837508 | 231881092170 |
 * | root | wait/io/file/innodb/innodb_data_file                |   4699 |  3023248450820 |   643381037 |  46928334180 |
 * | root | wait/io/file/sql/FRM                                |  11467 |  2600067790580 |   226743257 |  61718277920 |
 * | root | wait/io/file/myisam/dfile                           |  26776 |   746701506200 |    27886690 | 308785046960 |
 * | root | wait/io/file/myisam/kfile                           |   7126 |   462661061590 |    64925432 |  88756408780 |
 * | root | wait/io/file/sql/dbopt                              |    179 |   137577467690 |   768589146 |  15457199810 |
 * | root | wait/io/file/csv/metadata                           |      8 |    86599791590 | 10824973666 |  50322529270 |
 * | root | wait/synch/mutex/mysys/IO_CACHE::append_buffer_lock | 798080 |    66461175430 |       82940 |    161028010 |
 * | root | wait/io/file/sql/binlog                             |     19 |    49110632610 |  2584770058 |   9400449760 |
 * | root | wait/io/file/sql/misc                               |     26 |    22380676630 |   860795052 |  15298475270 |
 * | root | wait/io/file/csv/data                               |      4 |      297460540 |    74365135 |    111931300 |
 * | root | wait/synch/rwlock/sql/MDL_lock::rwlock              |    944 |      287862120 |      304616 |       874640 |
 * | root | wait/io/file/archive/data                           |      4 |       82713800 |    20678450 |     40738620 |
 * | root | wait/synch/mutex/myisam/MYISAM_SHARE::intern_lock   |     60 |       12211030 |      203203 |       512720 |
 * | root | wait/synch/mutex/innodb/trx_mutex                   |     81 |        5926440 |       73138 |       252590 |
 * +------+-----------------------------------------------------+--------+----------------+-------------+--------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$waits_by_user_by_latency (
  user,
  event,
  total,
  total_latency,
  avg_latency,
  max_latency
) AS
SELECT user,
       event_name AS event,
       count_star AS total,
       sum_timer_wait AS total_latency,
       avg_timer_wait AS avg_latency,
       max_timer_wait AS max_latency
  FROM performance_schema.events_waits_summary_by_user_by_event_name
 WHERE event_name != 'idle'
   AND user IS NOT NULL
   AND sum_timer_wait > 0
 ORDER BY user, sum_timer_wait DESC;
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
 * View: waits_global_by_latency
 *
 * Lists the top wait events by their total latency, ignoring idle (this may be very large).
 *
 * mysql> select * from waits_global_by_latency limit 5;
 * +--------------------------------------+------------+---------------+-------------+-------------+
 * | event                                | total      | total_latency | avg_latency | max_latency |
 * +--------------------------------------+------------+---------------+-------------+-------------+
 * | wait/io/file/myisam/dfile            | 3623719744 | 00:47:49.09   | 791.70 ns   | 312.96 ms   |
 * | wait/io/table/sql/handler            |   69114944 | 00:44:30.74   | 38.64 us    | 879.49 ms   |
 * | wait/io/file/innodb/innodb_log_file  |   28100261 | 00:37:42.12   | 80.50 us    | 476.00 ms   |
 * | wait/io/socket/sql/client_connection |  200704863 | 00:18:37.81   | 5.57 us     | 1.27 s      |
 * | wait/io/file/innodb/innodb_data_file |    2829403 | 00:08:12.89   | 174.20 us   | 455.22 ms   |
 * +--------------------------------------+------------+---------------+-------------+-------------+
 * 
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW waits_global_by_latency (
  events,
  total,
  total_latency,
  avg_latency,
  max_latency
) AS
SELECT event_name AS event,
       count_star AS total,
       sys.format_time(sum_timer_wait) AS total_latency,
       sys.format_time(avg_timer_wait) AS avg_latency,
       sys.format_time(max_timer_wait) AS max_latency
  FROM performance_schema.events_waits_summary_global_by_event_name
 WHERE event_name != 'idle'
   AND sum_timer_wait > 0
 ORDER BY sum_timer_wait DESC;

/*
 * View: x$waits_global_by_latency
 *
 * Lists the top wait events by their total latency, ignoring idle (this may be very large).
 *
 * mysql> select * from x$waits_global_by_latency limit 5;
 * +--------------------------------------+-------+---------------+-------------+--------------+
 * | event                                | total | total_latency | avg_latency | max_latency  |
 * +--------------------------------------+-------+---------------+-------------+--------------+
 * | wait/io/file/sql/file_parser         |   679 | 3536136351540 |  5207858773 | 129860439800 |
 * | wait/io/file/innodb/innodb_data_file |   195 |  848170566100 |  4349592637 | 350700491310 |
 * | wait/io/file/sql/FRM                 |  1355 |  400428476500 |   295518990 |  44823120940 |
 * | wait/io/file/innodb/innodb_log_file  |    20 |   54298899070 |  2714944765 |  30108124800 |
 * | wait/io/file/mysys/charset           |     3 |   24244722970 |  8081574072 |  24151547420 |
 * +--------------------------------------+-------+---------------+-------------+--------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$waits_global_by_latency (
  events,
  total,
  total_latency,
  avg_latency,
  max_latency
) AS
SELECT event_name AS event,
       count_star AS total,
       sum_timer_wait AS total_latency,
       avg_timer_wait AS avg_latency,
       max_timer_wait AS max_latency
  FROM performance_schema.events_waits_summary_global_by_event_name
 WHERE event_name != 'idle'
   AND sum_timer_wait > 0
 ORDER BY sum_timer_wait DESC;
