/*
 * Procedure: disable_current_thread()
 *
 * Disable performance_schema instrumentation for the current thread
 *
 * Example: CALL disable_current_thread();
 *
 * Versions: 5.6.2+
 */

DROP PROCEDURE IF EXISTS disable_current_thread;

DELIMITER $$

CREATE PROCEDURE disable_current_thread()
    SQL SECURITY INVOKER 
BEGIN
    UPDATE performance_schema.threads
       SET instrumented = 'NO'
     WHERE processlist_id = CONNECTION_ID();
END$$

DELIMITER ;
