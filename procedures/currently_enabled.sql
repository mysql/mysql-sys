/*
 * Procedure: currently_enabled()
 *
 * Show all enabled events / consumers
 *
 * Parameters
 *   show_instruments: Whether to show instrument configuration as well
 *   show_threads: Whether to show threads that are currently enabled
 *
 * Versions: 5.5+
 *
 * mysql> call currently_enabled(TRUE, TRUE);
 * +----------------------------+
 * | performance_schema_enabled |
 * +----------------------------+
 * |                          1 |
 * +----------------------------+
 * 1 row in set (0.00 sec)
 * 
 * +---------------+
 * | enabled_users |
 * +---------------+
 * | '%'@'%'       |
 * +---------------+
 * 1 row in set (0.01 sec)
 * 
 * +----------------------+---------+-------+
 * | objects              | enabled | timed |
 * +----------------------+---------+-------+
 * | mysql.%              | NO      | NO    |
 * | performance_schema.% | NO      | NO    |
 * | information_schema.% | NO      | NO    |
 * | %.%                  | YES     | YES   |
 * +----------------------+---------+-------+
 * 4 rows in set (0.01 sec)
 * 
 * +---------------------------+
 * | enabled_consumers         |
 * +---------------------------+
 * | events_statements_current |
 * | global_instrumentation    |
 * | thread_instrumentation    |
 * | statements_digest         |
 * +---------------------------+
 * 4 rows in set (0.05 sec)
 * 
 * +--------------------------+-------------+
 * | enabled_threads          | thread_type |
 * +--------------------------+-------------+
 * | innodb/srv_master_thread | BACKGROUND  |
 * | root@localhost           | FOREGROUND  |
 * | root@localhost           | FOREGROUND  |
 * | root@localhost           | FOREGROUND  |
 * | root@localhost           | FOREGROUND  |
 * +--------------------------+-------------+
 * 5 rows in set (0.03 sec)
 * 
 * +-------------------------------------+-------+
 * | enabled_instruments                 | timed |
 * +-------------------------------------+-------+
 * | wait/io/file/sql/map                | YES   |
 * | wait/io/file/sql/binlog             | YES   |
 * ...
 * | statement/com/Error                 | YES   |
 * | statement/com/                      | YES   |
 * | idle                                | YES   |
 * +-------------------------------------+-------+
 * 210 rows in set (0.08 sec)
 * 
 * Query OK, 0 rows affected (0.89 sec)
 * 
 */

DROP PROCEDURE IF EXISTS currently_enabled;

DELIMITER $$

CREATE PROCEDURE currently_enabled(IN show_instruments BOOLEAN, IN show_threads BOOLEAN)
    COMMENT 'Parameters: show_instruments (boolean), show_threads (boolean)'
    SQL SECURITY INVOKER 
BEGIN
    SELECT @@performance_schema AS performance_schema_enabled;

    SELECT CONCAT('\'', host, '\'@\'', user, '\'') AS enabled_users
      FROM performance_schema.setup_actors;

    SELECT CONCAT(object_schema, '.', object_name) AS objects,
           enabled,
           timed
      FROM performance_schema.setup_objects;

    SELECT name AS enabled_consumers
      FROM performance_schema.setup_consumers
     WHERE enabled = 'YES';

    IF (show_threads) THEN
        SELECT IF(name = 'thread/sql/one_connection', 
                  CONCAT(processlist_user, '@', processlist_host), 
                  REPLACE(name, 'thread/', '')) AS enabled_threads,
        TYPE AS thread_type
          FROM performance_schema.threads
         WHERE INSTRUMENTED = 'YES';
    END IF;

    IF (show_instruments) THEN
        SELECT name AS enabled_instruments,
               timed
          FROM performance_schema.setup_instruments
         WHERE enabled = 'YES';
    END IF;
END$$

DELIMITER ;
