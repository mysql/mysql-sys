/* 
 * Procedure: create_synonym_db()
 *
 * Parameters
 *   in_db_name: The database you would like to create a synonym for.
 *   in_synonym: The synonym you would like to create.
 *
 * Versions: 5.5+
 */

DROP PROCEDURE IF EXISTS create_synonym_db;

DELIMITER $$

CREATE PROCEDURE create_synonym_db(IN in_db_name VARCHAR(64), IN in_synonym VARCHAR(64))
    SQL SECURITY INVOKER
    COMMENT 'Parameters: in_db_name (VARCHAR(64)), in_synonym (VARCHAR(64))'
BEGIN
    DECLARE v_done bool DEFAULT FALSE;
    DECLARE v_db_name_check VARCHAR(64);
    DECLARE v_db_err_msg TEXT;
    DECLARE v_table VARCHAR(64);

    DECLARE db_doesnt_exist CONDITION FOR SQLSTATE '42000';
    DECLARE db_name_exists CONDITION FOR SQLSTATE 'HY000';

    DECLARE c_table_names CURSOR FOR 
        SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = in_db_name;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    /* Check if the source database exists */
    SELECT SCHEMA_NAME INTO v_db_name_check
      FROM INFORMATION_SCHEMA.SCHEMATA
     WHERE SCHEMA_NAME = in_db_name;

    IF v_db_name_check IS NULL THEN
        SET v_db_err_msg = CONCAT('Unknown database ', in_db_name);
        SIGNAL SQLSTATE 'HY000'
            SET MESSAGE_TEXT = v_db_err_msg;
    END IF;

    /* Check if a database of the synonym name already exists */
    SELECT SCHEMA_NAME INTO v_db_name_check
      FROM INFORMATION_SCHEMA.SCHEMATA
     WHERE SCHEMA_NAME = in_synonym;

    IF v_db_name_check = in_synonym THEN
        SET v_db_err_msg = CONCAT('Can\'t create database ', in_synonym, '; database exists');
        SIGNAL SQLSTATE 'HY000'
            SET MESSAGE_TEXT = v_db_err_msg;
    END IF;

    /* All good, create the database and views */
    SET @create_db_stmt := CONCAT('CREATE DATABASE ', in_synonym);
    PREPARE create_db_stmt FROM @create_db_stmt;
    EXECUTE create_db_stmt;
    DEALLOCATE PREPARE create_db_stmt;

    SET v_done = FALSE;
    OPEN c_table_names;
    c_table_names: LOOP
        FETCH c_table_names INTO v_table;
        IF v_done THEN
            LEAVE c_table_names;
        END IF;

        SET @create_view_stmt = CONCAT('CREATE SQL SECURITY INVOKER VIEW ', in_synonym, '.', v_table, ' AS SELECT * FROM ', in_db_name, '.', v_table);
        PREPARE create_view_stmt FROM @create_view_stmt;
        EXECUTE create_view_stmt;
        DEALLOCATE PREPARE create_view_stmt;
    END LOOP;
    CLOSE c_table_names;

END$$

DELIMITER ;