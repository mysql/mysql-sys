/* 
 * Procedure: dump_thread_stack()
 *
 * Dumps all data within performance_schema for an instrumented thread
 * to create a DOT formatted graph file. 
 * Each resultset returned from the procedure should be used for a complete graph
 *
 * Example command line:
 *    CALL ps_helper.dump_thread_stack(218, '/tmp/stack.dot', 10.00, 1.0, TRUE, TRUE, FALSE)
 * 
 * After this dot file is generated, load in to a graphing package such as Graphviz
 *
 * Parameters
 *   in_thread_id  : The thread that you would like a stack trace for
 *   in_max_runtime: The maximum time to keep collecting data. Use NULL to get the default which is 60 seconds.
 *   in_interval   : How long to sleep between data collections. Use NULL to get the default which is 1 second.
 *   in_start_fresh: Whether to reset all P_S data.
 *   in_auto_setup : Whether to disable all other threads and enable all consumers/instruments. This will also reset
 *                   the settings at the end of the run.
 *   in_debug      : Whether you would like to include file:lineno in the graph
 *
 * Versions: 5.6.3+
 * 
 * Parts contributed by Jesper Krogh of MySQL Support @ Oracle
 */


DROP PROCEDURE IF EXISTS dump_thread_stack;

DELIMITER $$
CREATE PROCEDURE dump_thread_stack(IN in_thread_id INT, IN in_outfile varchar(255), IN in_max_runtime DECIMAL(20,2),
    IN in_interval DECIMAL(20,2), IN in_start_fresh BOOLEAN, IN in_auto_setup BOOLEAN, IN in_debug BOOLEAN)
    COMMENT 'Parameters: in_thread_id (int), in_outfile (varchar(255)), in_max_runtime (decumal(20,2) - default 60 seconds), in_interval (DECIMAL(20,2) - default 1 second), in_start_fresh (boolean), in_auto_setup(boolean), in_debug (boolean)'
BEGIN
    DECLARE v_done bool DEFAULT FALSE;
    DECLARE v_start, v_runtime DECIMAL(20,2) DEFAULT 0.0;
    DECLARE v_min_event_id bigint unsigned DEFAULT 0;
    DECLARE v_event longtext;
    DECLARE c_stack CURSOR FOR
        SELECT CONCAT(IF(nesting_event_id IS NOT NULL, CONCAT(nesting_event_id, ' -> '), ''), 
                    event_id, '; ', event_id, ' [label="',
                    /* Convert from picoseconds to microseconds */
                    '(', ps_helper.format_time(timer_wait), ') ',
                    IF (event_name NOT LIKE 'wait/io%', 
                        SUBSTRING_INDEX(event_name, '/', -2), 
                        IF (event_name NOT LIKE 'wait/io/file%' OR event_name NOT LIKE 'wait/io/socket%',
                            SUBSTRING_INDEX(event_name, '/', -4),
                            event_name)
                        ),
                    /* Always dump the extra wait information gathered for statements */
                    IF (event_name LIKE 'statement/%', IFNULL(CONCAT('\\n', wait_info), ''), ''),
                    /* If debug is enabled, add the file:lineno information for waits */
                    IF (in_debug AND event_name LIKE 'wait%', wait_info, ''),
                    '", ', 
                    /* Depending on the type of event, style appropriately */
                    CASE WHEN event_name LIKE 'wait/io/file%' THEN 
                           'shape=box, style=filled, color=red'
                         WHEN event_name LIKE 'wait/io/table%' THEN 
                           'shape=box, style=filled, color=green'
                         WHEN event_name LIKE 'wait/io/socket%' THEN
                           'shape=box, style=filled, color=yellow'
                         WHEN event_name LIKE 'wait/synch/mutex%' THEN
                           'style=filled, color=lightskyblue'
                         WHEN event_name LIKE 'wait/synch/cond%' THEN
                           'style=filled, color=darkseagreen3'
                         WHEN event_name LIKE 'wait/synch/rwlock%' THEN
                           'style=filled, color=orchid'
                         WHEN event_name LIKE 'wait/lock%' THEN
                           'shape=box, style=filled, color=tan'
                         WHEN event_name LIKE 'statement/%' THEN
                           CONCAT('shape=box, style=bold',
                                  /* Style statements depending on COM vs SQL */
                                  CASE WHEN event_name LIKE 'statement/com/%' THEN
                                         ' style=filled, color=darkseagreen'
                                       ELSE
                                         /* Use long query time from the server to
                                            flag long running statements in red */
                                         IF((timer_wait/1000000000000) > @@long_query_time, 
                                            ' style=filled, color=red', 
                                            ' style=filled, color=lightblue')
                                  END
                           )
                         WHEN event_name LIKE 'stage/%' THEN
                           'style=filled, color=slategray3'
                         /* IDLE events are on their own, call attention to them */
                         WHEN event_name LIKE '%idle%' THEN
                           'shape=box, style=filled, color=firebrick3'
                         ELSE '' END,
                     '];\n'
                   ) event, event_id
        FROM (
             /* Select all statements, with the extra tracing information available */
             (SELECT thread_id, event_id, event_name, timer_wait, timer_start, nesting_event_id, 
                     CONCAT(sql_text, '\\n',
                            'errors: ', errors, '\\n',
                            'warnings: ', warnings, '\\n',
                            'lock time: ', ps_helper.format_time(lock_time),'\\n',
                            'rows affected: ', rows_affected, '\\n',
                            'rows sent: ', rows_sent, '\\n',
                            'rows examined: ', rows_examined, '\\n',
                            'tmp tables: ', created_tmp_tables, '\\n',
                            'tmp disk tables: ', created_tmp_disk_tables, '\\n'
                            'select scan: ', select_scan, '\\n',
                            'select full join: ', select_full_join, '\\n',
                            'select full range join: ', select_full_range_join, '\\n',
                            'select range: ', select_range, '\\n',
                            'select range check: ', select_range_check, '\\n', 
                            'sort merge passes: ', sort_merge_passes, '\\n',
                            'sort rows: ', sort_rows, '\\n',
                            'sort range: ', sort_range, '\\n',
                            'sort scan: ', sort_scan, '\\n',
                            'no index used: ', IF(no_index_used, 'TRUE', 'FALSE'), '\\n',
                            'no good index used: ', IF(no_good_index_used, 'TRUE', 'FALSE'), '\\n'
                     ) AS wait_info
                FROM performance_schema.events_statements_history_long
               WHERE thread_id = in_thread_id AND event_id > v_min_event_id)
             UNION
             /* Select all stages */
             (SELECT thread_id, event_id, event_name, timer_wait, timer_start, nesting_event_id, null AS wait_info
                FROM performance_schema.events_stages_history_long 
               WHERE thread_id = in_thread_id AND event_id > v_min_event_id)
             UNION 
             /* Select all events, adding information appropriate to the event */
             (SELECT thread_id, event_id, 
                     CONCAT(event_name, 
                            IF(event_name NOT LIKE 'wait/synch/mutex%', IFNULL(CONCAT(' - ', operation), ''), ''), 
                            IF(number_of_bytes IS NOT NULL, CONCAT(' ', number_of_bytes, ' bytes'), ''),
                            IF(event_name LIKE 'wait/io/file%', '\\n', ''),
                            IF(object_schema IS NOT NULL, CONCAT('\\nObject: ', object_schema, '.'), ''), 
                            IF(object_name IS NOT NULL, 
                               IF (event_name LIKE 'wait/io/socket%',
                                   /* Print the socket if used, else the IP:port as reported */
                                   CONCAT('\\n', IF (object_name LIKE ':0%', @@socket, object_name)),
                                   object_name),
                               ''
                            ),
                            IF(index_name IS NOT NULL, CONCAT(' Index: ', index_name), ''), '\\n'
                     ) AS event_name,
                     timer_wait, timer_start, nesting_event_id, source AS wait_info
                FROM performance_schema.events_waits_history_long
               WHERE thread_id = in_thread_id AND event_id > v_min_event_id)
           ) events 
       ORDER BY event_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    /* Do not track the current thread, it will kill the stack */
    CALL ps_helper.disable_current_thread();

    IF (in_auto_setup) THEN
        CALL ps_helper.save_current_config();
        
        /* Ensure only the thread to create the stack trace for is instrumented and that we instrument
           everything. */
        DELETE FROM performance_schema.setup_actors;

        UPDATE performance_schema.threads
           SET INSTRUMENTED = IF(THREAD_ID = in_thread_id, 'YES', 'NO');

        UPDATE performance_schema.setup_consumers
           SET ENABLED = 'YES'
         WHERE NAME NOT LIKE '%\_history'; -- only the %_history_long tables and it ancestors are needed

        UPDATE performance_schema.setup_instruments
           SET ENABLED = 'YES',
               TIMED   = 'YES';
    END IF;

    IF (in_start_fresh) THEN
        TRUNCATE performance_schema.events_statements_history_long;
        TRUNCATE performance_schema.events_stages_history_long;
        TRUNCATE performance_schema.events_waits_history_long;
    END IF;

    DROP TEMPORARY TABLE IF EXISTS tmp_events;
    CREATE TEMPORARY TABLE tmp_events (
      event_id bigint unsigned NOT NULL,
      event longblob,
      PRIMARY KEY (event_id)
    );

    /* Print headers for a .dot file */
    INSERT INTO tmp_events VALUES (0, CONCAT('digraph events { rankdir=LR; nodesep=0.10;\n',
                                             '// Stack created .....: ', NOW(), '\n',
                                             '// MySQL version .....: ', VERSION(), '\n',
                                             '// MySQL hostname ....: ', @@hostname, '\n',
                                             '// MySQL port ........: ', @@port, '\n',
                                             '// MySQL socket ......: ', @@socket, '\n',
                                             '// MySQL user ........: ', CURRENT_USER(), '\n'));

    SELECT CONCAT('Data collection starting for THREAD_ID = ', in_thread_id) AS 'Info';

    SET v_min_event_id = 0,
        v_start        = UNIX_TIMESTAMP(NOW(2)),
        in_interval    = IFNULL(in_interval, 1.00),
        in_max_runtime = IFNULL(in_max_runtime, 60.00);

    WHILE (v_runtime < in_max_runtime
           AND (SELECT INSTRUMENTED FROM performance_schema.threads WHERE THREAD_ID = in_thread_id) = 'YES') DO
        SET v_done = FALSE;
        OPEN c_stack;
        c_stack_loop: LOOP
            FETCH c_stack INTO v_event, v_min_event_id;
            IF v_done THEN
                LEAVE c_stack_loop;
            END IF;

            IF (LENGTH(v_event) > 0) THEN
                INSERT INTO tmp_events VALUES (v_min_event_id, v_event);
            END IF;
        END LOOP;
        CLOSE c_stack;

        DO SLEEP(in_interval);
        SET v_runtime = (UNIX_TIMESTAMP(NOW(2)) - v_start);
    END WHILE;

    /* Reset the settings for the performance schema */
    IF (in_auto_setup) THEN
        CALL ps_helper.reload_saved_config();
    END IF;

    INSERT INTO tmp_events VALUES (v_min_event_id+1, '}');
   
    SET @query = CONCAT('SELECT event FROM tmp_events ORDER BY event_id INTO OUTFILE ''', in_outfile, ''' FIELDS ESCAPED BY '''' LINES TERMINATED BY ''''');
    PREPARE stmt_output FROM @query;
    EXECUTE stmt_output;
    DEALLOCATE PREPARE stmt_output;
   
    SELECT CONCAT('Stack trace written to ', in_outfile) AS 'Info';
    SELECT CONCAT('dot -Tpdf -o /tmp/stack_', in_thread_id, '.pdf ', in_outfile) AS 'Convert to PDF';
    SELECT CONCAT('dot -Tpng -o /tmp/stack_', in_thread_id, '.png ', in_outfile) AS 'Convert to PNG';
    DROP TEMPORARY TABLE tmp_events;
END$$

DELIMITER ;
