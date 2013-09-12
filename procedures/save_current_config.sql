/*
 * Procedure: save_current_config()
 * 
 * Saves the current configuration of performance_schema, so that you 
 * can alter the setup, but restore it to what was set before.
 * 
 * Use the companion procedure - reload_saved_config(), to 
 * restore the saved config.
 *
 * Versions: 5.6+
 *
 * Contributed by Jesper Krogh of MySQL Support @ Oracle
 */

DROP PROCEDURE IF EXISTS save_current_config;

DELIMITER $$

CREATE PROCEDURE save_current_config()
    SQL SECURITY INVOKER
BEGIN
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
END$$

DELIMITER ;