/*
 * Procedure: disable_background_threads()
 *
 * Disable performance_schema instrumentation for all background threads
 *
 * Example: CALL disable_background_threads();
 *
 * Versions: 5.6.2+
 */

DROP PROCEDURE IF EXISTS disable_background_threads;

DELIMITER $$

CREATE PROCEDURE disable_background_threads()
    SQL SECURITY INVOKER 
BEGIN
    UPDATE performance_schema.threads
       SET instrumented = 'NO'
     WHERE type = 'BACKGROUND';
END$$

DELIMITER ;
