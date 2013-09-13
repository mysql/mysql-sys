/**
 * Procedure: reset_to_default
 *
 * Reset the settings to the default 5.7 settings.
 *
 * Parameters
 *   in_verbose: Whether to print each statement before executing
 *
 * Versions: 5.7+
 *
 * Contributed by Jesper Krogh of MySQL Support @ Oracle
 */

-- Because of bug 11750980/bug 41686, set the sql_mode to ''
SET @old_sql_mode = @@session.sql_mode;
SET sql_mode = '';

DROP PROCEDURE IF EXISTS reset_to_default;

DELIMITER $$

CREATE PROCEDURE reset_to_default(IN in_verbose BOOLEAN)
   COMMENT 'Parameters: in_verbose (boolean)'
BEGIN
   SET @query = 'DELETE
  				   FROM performance_schema.setup_actors
                  WHERE NOT (HOST = ''%'' AND USER = ''%'' AND ROLE = ''%'')';

   IF (in_verbose) THEN
      SELECT CONCAT('Resetting: setup_actors\n', @query) AS status;
   END IF;

   PREPARE reset_stmt FROM @query;
   EXECUTE reset_stmt;
   DEALLOCATE PREPARE reset_stmt;

   SET @query = 'INSERT IGNORE INTO performance_schema.setup_actors
                 VALUES (''%'', ''%'', ''%'')';

   IF (in_verbose) THEN
      SELECT CONCAT('Resetting: setup_actors\n', @query) AS status;
   END IF;

   PREPARE reset_stmt FROM @query;
   EXECUTE reset_stmt;
   DEALLOCATE PREPARE reset_stmt;

   SET @query = 'UPDATE performance_schema.setup_instruments
                    SET ENABLED = ''NO'', TIMED = ''NO''
                  WHERE NAME NOT LIKE ''wait/io/file/%''
                    AND NAME NOT LIKE ''wait/io/table/%''
                    AND NAME NOT LIKE ''statement/%''
                    AND NAME NOT IN (''wait/lock/table/sql/handler'', ''idle'')';

   IF (in_verbose) THEN
      SELECT CONCAT('Resetting: setup_instruments\n', @query) AS status;
   END IF;

   PREPARE reset_stmt FROM @query;
   EXECUTE reset_stmt;
   DEALLOCATE PREPARE reset_stmt;
         
   SET @query = 'UPDATE performance_schema.setup_consumers
                    SET ENABLED = IF(NAME IN (''events_statements_current'', ''global_instrumentation'', ''thread_instrumentation'', ''statements_digest''), ''YES'', ''NO'')';

   IF (in_verbose) THEN
      SELECT CONCAT('Resetting: setup_consumers\n', @query) AS status;
   END IF;

   PREPARE reset_stmt FROM @query;
   EXECUTE reset_stmt;
   DEALLOCATE PREPARE reset_stmt;

   SET @query = 'DELETE
                   FROM performance_schema.setup_objects
                  WHERE NOT (OBJECT_TYPE IN (''EVENT'', ''FUNCTION'', ''PROCEDURE'', ''TABLE'', ''TRIGGER'') AND OBJECT_NAME = ''%'' 
                  	AND (OBJECT_SCHEMA = ''mysql''              AND ENABLED = ''NO''  AND TIMED = ''NO'' )
                     OR (OBJECT_SCHEMA = ''performance_schema'' AND ENABLED = ''NO''  AND TIMED = ''NO'' )
                     OR (OBJECT_SCHEMA = ''information_schema'' AND ENABLED = ''NO''  AND TIMED = ''NO'' )
                     OR (OBJECT_SCHEMA = ''%''                  AND ENABLED = ''YES'' AND TIMED = ''YES''))';

   IF (in_verbose) THEN
      SELECT CONCAT('Resetting: setup_objects\n', @query) AS status;
   END IF;

   PREPARE reset_stmt FROM @query;
   EXECUTE reset_stmt;
   DEALLOCATE PREPARE reset_stmt;

   SET @query = 'INSERT IGNORE INTO performance_schema.setup_objects
                 VALUES (''EVENT''    , ''mysql''             , ''%'', ''NO'' , ''NO'' ),
                        (''EVENT''    , ''performance_schema'', ''%'', ''NO'' , ''NO'' ),
                        (''EVENT''    , ''information_schema'', ''%'', ''NO'' , ''NO'' ),
                        (''EVENT''    , ''%''                 , ''%'', ''YES'', ''YES''),
                        (''FUNCTION'' , ''mysql''             , ''%'', ''NO'' , ''NO'' ),
                        (''FUNCTION'' , ''performance_schema'', ''%'', ''NO'' , ''NO'' ),
                        (''FUNCTION'' , ''information_schema'', ''%'', ''NO'' , ''NO'' ),
                        (''FUNCTION'' , ''%''                 , ''%'', ''YES'', ''YES''),
                        (''PROCEDURE'', ''mysql''             , ''%'', ''NO'' , ''NO'' ),
                        (''PROCEDURE'', ''performance_schema'', ''%'', ''NO'' , ''NO'' ),
                        (''PROCEDURE'', ''information_schema'', ''%'', ''NO'' , ''NO'' ),
                        (''PROCEDURE'', ''%''                 , ''%'', ''YES'', ''YES''),
                        (''TABLE''    , ''mysql''             , ''%'', ''NO'' , ''NO'' ),
                        (''TABLE''    , ''performance_schema'', ''%'', ''NO'' , ''NO'' ),
                        (''TABLE''    , ''information_schema'', ''%'', ''NO'' , ''NO'' ),
                        (''TABLE''    , ''%''                 , ''%'', ''YES'', ''YES''),
                        (''TRIGGER''  , ''mysql''             , ''%'', ''NO'' , ''NO'' ),
                        (''TRIGGER''  , ''performance_schema'', ''%'', ''NO'' , ''NO'' ),
                        (''TRIGGER''  , ''information_schema'', ''%'', ''NO'' , ''NO'' ),
                        (''TRIGGER''  , ''%''                 , ''%'', ''YES'', ''YES'')';

   IF (in_verbose) THEN
      SELECT CONCAT('Resetting: setup_objects\n', @query) AS status;
   END IF;

   PREPARE reset_stmt FROM @query;
   EXECUTE reset_stmt;
   DEALLOCATE PREPARE reset_stmt;

   SET @query = 'UPDATE performance_schema.threads
                    SET INSTRUMENTED = ''YES''';

   IF (in_verbose) THEN
      SELECT CONCAT('Resetting: threads\n', @query) AS status;
   END IF;

   PREPARE reset_stmt FROM @query;
   EXECUTE reset_stmt;
   DEALLOCATE PREPARE reset_stmt;
END$$

DELIMITER ;

SET sql_mode = @old_sql_mode;
