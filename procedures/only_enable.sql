/*
 * Procedure: only_enable()
 *
 * Only enable a certain form of wait event
 *
 * Parameters
 *   pattern: A LIKE pattern match of events to leave enabled
 *
 * Versions: 5.5+
 */

DROP PROCEDURE IF EXISTS only_enable;

DELIMITER $$

CREATE PROCEDURE only_enable(IN pattern VARCHAR(128))
    COMMENT 'Parameters: pattern (VARCHAR(128))'
    SQL SECURITY INVOKER 
BEGIN
    UPDATE performance_schema.setup_instruments
       SET enabled = IF(name LIKE pattern, 'YES', 'NO'),
           timed = IF(name LIKE pattern, 'YES', 'NO');
END$$

DELIMITER ;