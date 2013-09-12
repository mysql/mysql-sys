/*
 * Procedure: reload_saved_config()
 * 
 * Reloads configuration of performance_schema, as saved by
 * the save_current_config() procedure.
 *
 * Versions: 5.6+
 *
 * Contributed by Jesper Krogh of MySQL Support @ Oracle, extended by Mark Leith
 */

DROP PROCEDURE IF EXISTS reload_saved_config;

DELIMITER $$

CREATE PROCEDURE reload_saved_config()
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_done bool DEFAULT FALSE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SIGNAL SQLSTATE VALUE '90000'
           SET MESSAGE_TEXT = 'An error occurred, was save_current_config() run before this procedure?';
    END;

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
                             ps_helper.is_account_enabled(PROCESSLIST_HOST, PROCESSLIST_USER),
                             'YES')
     WHERE THREAD_ID NOT IN (SELECT THREAD_ID FROM tmp_threads);

    DROP TEMPORARY TABLE tmp_setup_actors;
    DROP TEMPORARY TABLE tmp_setup_consumers;
    DROP TEMPORARY TABLE tmp_setup_instruments;
    DROP TEMPORARY TABLE tmp_threads;
END$$

DELIMITER ;