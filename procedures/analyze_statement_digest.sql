/* 
 * Procedure: analyze_statement_digest()
 *
 * Parameters
 *   digest_in:   The statement digest identifier you would like to analyze
 *   runtime:     The number of seconds to run analysis for (defaults to a minute)
 *   interval_in: The interval (in seconds, may be fractional) at which to try
 *                and take snapshots (defaults to a second)
 *   start_fresh: Whether to TRUNCATE the events_statements_history_long and
 *                events_stages_history_long tables before starting (default false)
 *   auto_enable: Whether to automatically turn on required consumers (default false)
 *
 * mysql> call analyze_statement_digest('891ec6860f98ba46d89dd20b0c03652c', 10, 0.1, true, true);
 * +--------------------+
 * | SUMMARY STATISTICS |
 * +--------------------+
 * | SUMMARY STATISTICS |
 * +--------------------+
 * 1 row in set (9.11 sec)
 * 
 * +------------+-----------+-----------+-----------+---------------+------------+------------+
 * | executions | exec_time | lock_time | rows_sent | rows_examined | tmp_tables | full_scans |
 * +------------+-----------+-----------+-----------+---------------+------------+------------+
 * |         21 | 4.11 ms   | 2.00 ms   |         0 |            21 |          0 |          0 |
 * +------------+-----------+-----------+-----------+---------------+------------+------------+
 * 1 row in set (9.11 sec)
 * 
 * +------------------------------------------+-------+-----------+
 * | event_name                               | count | latency   |
 * +------------------------------------------+-------+-----------+
 * | stage/sql/checking query cache for query |    16 | 724.37 µs |
 * | stage/sql/statistics                     |    16 | 546.92 µs |
 * | stage/sql/freeing items                  |    18 | 520.11 µs |
 * | stage/sql/init                           |    51 | 466.80 µs |
 * | stage/sql/Waiting for query cache lock   |    17 | 460.18 µs |
 * | stage/sql/Sending data                   |    16 | 164.54 µs |
 * | stage/sql/Opening tables                 |    18 | 162.22 µs |
 * | stage/sql/optimizing                     |    16 | 101.64 µs |
 * | stage/sql/updating                       |     1 | 75.48 µs  |
 * | stage/sql/System lock                    |    17 | 68.86 µs  |
 * | stage/sql/preparing                      |    16 | 62.90 µs  |
 * | stage/sql/closing tables                 |    18 | 37.08 µs  |
 * | stage/sql/query end                      |    18 | 22.51 µs  |
 * | stage/sql/checking permissions           |    17 | 20.86 µs  |
 * | stage/sql/end                            |    18 | 15.56 µs  |
 * | stage/sql/cleaning up                    |    18 | 11.92 µs  |
 * | stage/sql/executing                      |    16 | 6.95 µs   |
 * ------------------------------------------+-------+-----------+
 * 17 rows in set (9.12 sec)
 * 
 * +---------------------------+
 * | LONGEST RUNNING STATEMENT |
 * +---------------------------+
 * | LONGEST RUNNING STATEMENT |
 * +---------------------------+
 * 1 row in set (9.16 sec)
 * 
 * +-----------+-----------+-----------+-----------+---------------+------------+-----------+
 * | thread_id | exec_time | lock_time | rows_sent | rows_examined | tmp_tables | full_scan |
 * +-----------+-----------+-----------+-----------+---------------+------------+-----------+
 * |    166646 | 618.43 µs | 1.00 ms   |         0 |             1 |          0 |         0 |
 * +-----------+-----------+-----------+-----------+---------------+------------+-----------+
 * 1 row in set (9.16 sec)
 * 
 * // Truncated for clarity...
 * +-----------------------------------------------------------------+
 * | sql_text                                                        |
 * +-----------------------------------------------------------------+
 * | select hibeventhe0_.id as id1382_, hibeventhe0_.createdTime ... |
 * +-----------------------------------------------------------------+
 * 1 row in set (9.17 sec)
 * 
 * +------------------------------------------+-----------+
 * | event_name                               | latency   |
 * +------------------------------------------+-----------+
 * | stage/sql/init                           | 8.61 µs   |
 * | stage/sql/Waiting for query cache lock   | 453.23 µs |
 * | stage/sql/init                           | 331.07 ns |
 * | stage/sql/checking query cache for query | 43.04 µs  |
 * | stage/sql/checking permissions           | 1.32 µs   |
 * | stage/sql/Opening tables                 | 8.61 µs   |
 * | stage/sql/init                           | 16.22 µs  |
 * | stage/sql/System lock                    | 2.98 µs   |
 * | stage/sql/optimizing                     | 5.63 µs   |
 * | stage/sql/statistics                     | 30.13 µs  |
 * | stage/sql/preparing                      | 3.31 µs   |
 * | stage/sql/executing                      | 331.07 ns |
 * | stage/sql/Sending data                   | 9.60 µs   |
 * | stage/sql/end                            | 662.13 ns |
 * | stage/sql/query end                      | 993.20 ns |
 * | stage/sql/closing tables                 | 1.66 µs   |
 * | stage/sql/freeing items                  | 30.46 µs  |
 * | stage/sql/cleaning up                    | 662.13 ns |
 * +------------------------------------------+-----------+
 * 18 rows in set (9.23 sec)
 * 
 * +----+-------------+--------------+-------+---------------+-----------+---------+-------------+------+-------+
 * | id | select_type | table        | type  | possible_keys | key       | key_len | ref         | rows | Extra |
 * +----+-------------+--------------+-------+---------------+-----------+---------+-------------+------+-------+
 * |  1 | SIMPLE      | hibeventhe0_ | const | fixedTime     | fixedTime | 775     | const,const |    1 | NULL  |
 * +----+-------------+--------------+-------+---------------+-----------+---------+-------------+------+-------+
 * 1 row in set (9.27 sec)
 * 
 * Query OK, 0 rows affected (9.28 sec)
 * 
 * Versions: 5.6.3+
 */

DROP PROCEDURE IF EXISTS analyze_statement_digest;

DELIMITER $$

CREATE PROCEDURE analyze_statement_digest(IN digest_in VARCHAR(32), IN runtime INT, 
    IN interval_in DECIMAL(2,2), IN start_fresh BOOLEAN, IN auto_enable BOOLEAN)
    COMMENT 'Parameters: digest_in (varchar(32)), runtime (int), interval_in (decimal(2,2)), start_fresh (boolean), auto_enable (boolean)'
    SQL SECURITY INVOKER 
BEGIN

    DECLARE v_start_fresh BOOLEAN DEFAULT false;
    DECLARE v_auto_enable BOOLEAN DEFAULT false;
    DECLARE v_runtime INT DEFAULT 0;
    DECLARE v_start INT DEFAULT 0;
    DECLARE v_found_stmts INT;

    /* Do not track the current thread, it will kill the stack */
    CALL disable_current_thread();

    DROP TEMPORARY TABLE IF EXISTS stmt_trace;
    CREATE TEMPORARY TABLE stmt_trace (
        thread_id BIGINT,
        timer_start BIGINT,
        event_id BIGINT,
        sql_text longtext,
        timer_wait BIGINT,
        lock_time BIGINT,
        errors BIGINT,
        mysql_errno BIGINT,
        rows_affected BIGINT,
        rows_examined BIGINT,
        created_tmp_tables BIGINT,
        created_tmp_disk_tables BIGINT,
        no_index_used BIGINT,
        PRIMARY KEY (thread_id, timer_start)
    );

    DROP TEMPORARY TABLE IF EXISTS stmt_stages;
    CREATE TEMPORARY TABLE stmt_stages (
       event_id BIGINT,
       stmt_id BIGINT,
       event_name VARCHAR(128),
       timer_wait BIGINT,
       PRIMARY KEY (event_id)
    );

    SET v_start_fresh = start_fresh;
    IF v_start_fresh THEN
        TRUNCATE TABLE performance_schema.events_statements_history_long;
        TRUNCATE TABLE performance_schema.events_stages_history_long;
    END IF;

    SET v_auto_enable = auto_enable;
    IF v_auto_enable THEN
        CALL ps_helper.save_current_config();
    END IF;

    WHILE v_runtime < runtime DO
        SELECT UNIX_TIMESTAMP() INTO v_start;

        INSERT IGNORE INTO stmt_trace
        SELECT thread_id, timer_start, event_id, sql_text, timer_wait, lock_time, errors, mysql_errno, 
               rows_affected, rows_examined, created_tmp_tables, created_tmp_disk_tables, no_index_used
          FROM performance_schema.events_statements_history_long
        WHERE digest = digest_in;

        INSERT IGNORE INTO stmt_stages
        SELECT stages.event_id, stmt_trace.event_id,
               stages.event_name, stages.timer_wait
          FROM performance_schema.events_stages_history_long AS stages
          JOIN stmt_trace ON stages.nesting_event_id = stmt_trace.event_id;

        SELECT SLEEP(interval_in) INTO @sleep;
        SET v_runtime = v_runtime + (UNIX_TIMESTAMP() - v_start);
    END WHILE;

    IF v_auto_enable THEN
        CALL ps_helper.reload_saved_config();
    END IF;

    SELECT "SUMMARY STATISTICS";

    SELECT COUNT(*) executions,
           format_time(SUM(timer_wait)) AS exec_time,
           format_time(SUM(lock_time)) AS lock_time,
           SUM(rows_affected) AS rows_sent,
           SUM(rows_examined) AS rows_examined,
           SUM(created_tmp_tables) AS tmp_tables,
           SUM(no_index_used) AS full_scans
      FROM stmt_trace;

    SELECT event_name,
           COUNT(*) as count,
           format_time(SUM(timer_wait)) as latency
      FROM stmt_stages
     GROUP BY event_name
     ORDER BY SUM(timer_wait) DESC;

    SELECT "LONGEST RUNNING STATEMENT";

    SELECT thread_id,
           format_time(timer_wait) AS exec_time,
           format_time(lock_time) AS lock_time,
           rows_affected AS rows_sent,
           rows_examined,
           created_tmp_tables AS tmp_tables,
           no_index_used AS full_scan
      FROM stmt_trace
     ORDER BY timer_wait DESC LIMIT 1;

    SELECT sql_text
      FROM stmt_trace
     ORDER BY timer_wait DESC LIMIT 1;

    SELECT sql_text, event_id INTO @sql, @sql_id
      FROM stmt_trace
    ORDER BY timer_wait DESC LIMIT 1;

    SELECT event_name,
           format_time(timer_wait) as latency
      FROM stmt_stages
     WHERE stmt_id = @sql_id
     ORDER BY event_id;

    DROP TEMPORARY TABLE stmt_trace;
    DROP TEMPORARY TABLE stmt_stages;

    SET @stmt := CONCAT("EXPLAIN ", @sql);
    PREPARE explain_stmt FROM @stmt;
    EXECUTE explain_stmt;
    DEALLOCATE PREPARE explain_stmt;

END$$

DELIMITER ;
