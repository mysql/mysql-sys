/**
 * Procedure: reset_to_default
 *
 * Reset the settings to the default 5.6 settings.
 *
 * Parameters
 *   in_verbose: Whether to print each statement before executing
 *
 * Versions: 5.6+
 *
 * Contributed by Jesper Krogh of MySQL Support @ Oracle
 */

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
                    SET ENABLED = ''NO''
                  WHERE NAME NOT IN (''events_statements_current'', ''global_instrumentation'', ''thread_instrumentation'', ''statements_digest'')';

   IF (in_verbose) THEN
      SELECT CONCAT('Resetting: setup_consumers\n', @query) AS status;
   END IF;

   PREPARE reset_stmt FROM @query;
   EXECUTE reset_stmt;
   DEALLOCATE PREPARE reset_stmt;

   SET @query = 'DELETE
                   FROM performance_schema.setup_objects
                  WHERE NOT (OBJECT_TYPE = ''TABLE'' AND OBJECT_NAME = ''%''
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
                 VALUES (''TABLE'', ''mysql''             , ''%'', ''NO'' , ''NO'' ),
                        (''TABLE'', ''performance_schema'', ''%'', ''NO'' , ''NO'' ),
                        (''TABLE'', ''information_schema'', ''%'', ''NO'' , ''NO'' ),
                        (''TABLE'', ''%''                 , ''%'', ''YES'', ''YES'')';

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
