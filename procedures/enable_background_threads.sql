/*
 * Procedure: enable_background_threads()
 *
 * Enable performance_schema instrumentation for all background threads
 *
 * Example: CALL enable_background_threads();
 *
 * Versions: 5.6.2+
 */

DROP PROCEDURE IF EXISTS enable_background_threads;

DELIMITER $$

CREATE PROCEDURE enable_background_threads()
BEGIN
    UPDATE performance_schema.threads
       SET instrumented = 'YES'
     WHERE type = 'BACKGROUND';
END$$

DELIMITER ;
