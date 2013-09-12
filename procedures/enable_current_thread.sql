/*
 * Procedure: enable_current_thread()
 *
 * Enable performance_schema instrumentation for the current thread
 *
 * Example: CALL enable_current_thread();
 *
 * Versions: 5.6.2+
 */

DROP PROCEDURE IF EXISTS enable_current_thread;

DELIMITER $$

CREATE PROCEDURE enable_current_thread()
    SQL SECURITY INVOKER 
BEGIN
     UPDATE performance_schema.threads
        SET instrumented = 'YES'
      WHERE processlist_id = CONNECTION_ID();
END$$

DELIMITER ;
