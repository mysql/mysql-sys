/*
 * Procedure: truncate_all()
 *
 * Truncates all summary tables, to reset all performance schema statistics
 *
 * Parameters
 *   verbose: Whether to print each TRUNCATE statement before running
 *
 * Versions: 5.5+
 */

DROP PROCEDURE IF EXISTS truncate_all;

DELIMITER $$

CREATE PROCEDURE truncate_all(IN verbose BOOLEAN)
    COMMENT 'Parameters: verbose (boolean)'
    SQL SECURITY INVOKER 
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_ps_table VARCHAR(64);
    DECLARE ps_tables CURSOR FOR
        SELECT table_name 
          FROM INFORMATION_SCHEMA.TABLES 
         WHERE table_schema = 'performance_schema' 
           AND (table_name LIKE '%summary%' 
           OR table_name LIKE '%history%');
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    SET @log_bin := @@sql_log_bin;
    SET sql_log_bin = 0;

    OPEN ps_tables;

    ps_tables_loop: LOOP
        FETCH ps_tables INTO v_ps_table;
        IF v_done THEN
          LEAVE ps_tables_loop;
        END IF;

        SET @truncate_stmt := CONCAT('TRUNCATE TABLE performance_schema.', v_ps_table);
        IF verbose THEN
            SELECT CONCAT('Running: ', @truncate_stmt) AS status;
        END IF;

        PREPARE truncate_stmt FROM @truncate_stmt;
        EXECUTE truncate_stmt;
        DEALLOCATE PREPARE truncate_stmt;

    END LOOP;

    CLOSE ps_tables;

    SET sql_log_bin = @log_bin;

END$$

DELIMITER ;