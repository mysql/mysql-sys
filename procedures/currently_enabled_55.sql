/*
 * Procedure: currently_enabled()
 *
 * Show all enabled events / consumers
 *
 * Parameters
 *   show_instruments: Whether to show instrument configuration as well
 *
 * Versions: 5.5+
 *
 * mysql> call currently_enabled(TRUE);
 * +----------------------------+
 * | performance_schema_enabled |
 * +----------------------------+
 * |                          1 |
 * +----------------------------+
 * 1 row in set (0.00 sec)
 * 
 * +----------------------------+
 * | enabled_consumers          |
 * +----------------------------+
 * | file_summary_by_event_name |
 * | file_summary_by_instance   |
 * +----------------------------+
 * 2 rows in set (0.02 sec)
 * 
 * +---------------------------------+-------+
 * | enabled_instruments             | timed |
 * +---------------------------------+-------+
 * | wait/io/file/sql/map            | YES   |
 * ...
 * | wait/io/file/myisam/log         | YES   |
 * | wait/io/file/myisammrg/MRG      | YES   |
 * +---------------------------------+-------+
 * 39 rows in set (0.03 sec)
 */

DROP PROCEDURE IF EXISTS currently_enabled;

DELIMITER $$

CREATE PROCEDURE currently_enabled(show_instruments BOOLEAN)
    COMMENT 'Parameters: show_instruments (boolean)'
    SQL SECURITY INVOKER 
BEGIN
    SELECT @@performance_schema AS performance_schema_enabled;

    SELECT name AS enabled_consumers
      FROM performance_schema.setup_consumers
     WHERE enabled = 'YES';

    IF (show_instruments) THEN
        SELECT name AS enabled_instruments,
               timed
          FROM performance_schema.setup_instruments
         WHERE enabled = 'YES';
    END IF;
END$$

DELIMITER ;