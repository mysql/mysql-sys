/*
 * Procedure: currently_disabled()
 *
 * Show all disabled events / consumers
 *
 * Parameters
 *   show_instruments: Whether to show instrument configuration as well
 *
 * Versions: 5.5+
 *
 * mysql> call currently_disabled(true);
 * +----------------------------+
 * | performance_schema_enabled |
 * +----------------------------+
 * |                          1 |
 * +----------------------------+
 * 1 row in set (0.00 sec)
 * 
 * +--------------------------------+
 * | disabled_consumers             |
 * +--------------------------------+
 * | events_stages_current          |
 * | events_stages_history          |
 * | events_stages_history_long     |
 * | events_statements_history      |
 * | events_statements_history_long |
 * | events_waits_current           |
 * | events_waits_history           |
 * | events_waits_history_long      |
 * +--------------------------------+
 * 8 rows in set (0.00 sec)
 * 
 * +---------------------------------------------------------------------------------------+-------+
 * | disabled_instruments                                                                  | timed |
 * +---------------------------------------------------------------------------------------+-------+
 * | wait/synch/mutex/sql/PAGE::lock                                                       | NO    |
 * | wait/synch/mutex/sql/TC_LOG_MMAP::LOCK_sync                                           | NO    |
 * | wait/synch/mutex/sql/TC_LOG_MMAP::LOCK_active                                         | NO    |
 * ...
 * | stage/sql/Waiting for event metadata lock                                             | NO    |
 * | stage/sql/Waiting for commit lock                                                     | NO    |
 * | wait/io/socket/sql/server_tcpip_socket                                                | NO    |
 * | wait/io/socket/sql/server_unix_socket                                                 | NO    |
 * | wait/io/socket/sql/client_connection                                                  | NO    |
 * +---------------------------------------------------------------------------------------+-------+
 * 302 rows in set (0.03 sec)
 * 
 * Query OK, 0 rows affected (1.19 sec)
 */

DROP PROCEDURE IF EXISTS currently_disabled;

DELIMITER $$

CREATE PROCEDURE currently_disabled(show_instruments BOOLEAN)
    COMMENT 'Parameters: show_instruments (boolean)'
    SQL SECURITY INVOKER 
BEGIN
    SELECT @@performance_schema AS performance_schema_enabled;

    SELECT name AS disabled_consumers
      FROM performance_schema.setup_consumers
     WHERE enabled = 'NO';

    IF (show_instruments) THEN
        SELECT name AS disabled_instruments,
               timed
          FROM performance_schema.setup_instruments
         WHERE enabled = 'NO';
    END IF;
END$$

DELIMITER ;