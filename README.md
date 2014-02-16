# The MySQL sys schema

A collection of views, functions and procedures to help MySQL administrators get insight in to MySQL Database usage.

There are install files available for 5.6 and 5.7 respectively. To load these, you must position yourself within the directory that you downloaded to, as these top level files SOURCE individual files that are shared across versions in most cases (though not all).

## Installation

The objects should all be created as the root user (but run with the privileges of the invoker).

For instance if you download to /tmp/mysql-sys/, and want to install the 5.6 version you should:

    cd /tmp/mysql-sys/
    mysql -u root -p < ./sys_56.sql

Or if you would like to log in to the client, and install the 5.7 version:

    cd /tmp/mysql-sys/
    mysql -u root -p 
    SOURCE ./sys_57.sql

Alternatively, you could just choose to load individual files based on your needs, but beware, certain objects have dependencies on other objects. You will need to ensure that these are also loaded.

## Overview of objects

### Procedures

#### create_synonym_db

##### Description

Takes a source database name and synonym name, and then creates the synonym database with views that point to all of the tables within the source database.

Useful for creating a "ps" synonym for "performance_schema", or "is" instead of "information_schema", for example.

##### Parameters

* in_db_name (VARCHAR(64)):
** The database name that you would like to create a synonym for.
* in_synonym (VARCHAR(64)):
** The database synonym name.

##### Example

             mysql> SHOW DATABASES;
             +--------------------+
             | Database           |
             +--------------------+
             | information_schema |
             | mysql              |
             | performance_schema |
             | sys                |
             | test               |
             +--------------------+
             5 rows in set (0.00 sec)

             mysql> CALL sys.create_synonym_db('performance_schema', 'ps');
             +-------------------------------------+
             | summary                             |
             +-------------------------------------+
             | Created 74 views in the ps database |
             +-------------------------------------+
             1 row in set (8.57 sec)

             Query OK, 0 rows affected (8.57 sec)

             mysql> SHOW DATABASES;
             +--------------------+
             | Database           |
             +--------------------+
             | information_schema |
             | mysql              |
             | performance_schema |
             | ps                 |
             | sys                |
             | test               |
             +--------------------+
             6 rows in set (0.00 sec)

             mysql> SHOW FULL TABLES FROM ps;
             +------------------------------------------------------+------------+
             | Tables_in_ps                                         | Table_type |
             +------------------------------------------------------+------------+
             | accounts                                             | VIEW       |
             | cond_instances                                       | VIEW       |
             | events_stages_current                                | VIEW       |
             | events_stages_history                                | VIEW       |
             ...
            

#### ps_setup_disable_background_threads

##### Description

Disable all background thread instrumentation within Performance Schema.

Requires the SUPER privilege for "SET sql_log_bin = 0;".

##### Parameters

None.

##### Example

             mysql> CALL sys.ps_setup_disable_background_threads();
             +--------------------------------+
             | summary                        |
             +--------------------------------+
             | Disabled 18 background threads |
             +--------------------------------+
             1 row in set (0.00 sec)
            

#### ps_setup_disable_instrument

##### Description

Disables instruments within Performance Schema  matching the input pattern.

Requires the SUPER privilege for "SET sql_log_bin = 0;".

##### Parameters

* in_pattern (VARCHAR(128)): A LIKE pattern match (using "%in_pattern%") of events to disable

##### Example

To disable all mutex instruments:

             mysql> CALL sys.ps_setup_disable_instrument('wait/synch/mutex');
             +--------------------------+
             | summary                  |
             +--------------------------+
             | Disabled 155 instruments |
             +--------------------------+
             1 row in set (0.02 sec)

             To disable just a the scpecific TCP/IP based network IO instrument:

             mysql> CALL sys.ps_setup_disable_instrument('wait/io/socket/sql/server_tcpip_socket');
             +------------------------+
             | summary                |
             +------------------------+
             | Disabled 1 instruments |
             +------------------------+
             1 row in set (0.00 sec)

             To enable all instruments:

             mysql> CALL sys.ps_setup_disable_instrument('');
             +--------------------------+
             | summary                  |
             +--------------------------+
             | Disabled 547 instruments |
             +--------------------------+
             1 row in set (0.01 sec)
            

#### ps_setup_disable_thread

##### Description

Disable the given connection/thread in Performance Schema.

Requires the SUPER privilege for "SET sql_log_bin = 0;".

##### Parameters

* in_connection_id (BIGINT): The connection ID (PROCESSLIST_ID from performance_schema.threads or the ID shown within SHOW PROCESSLIST)

##### Example

             mysql> CALL sys.ps_setup_disable_thread(3);
             +-------------------+
             | summary           |
             +-------------------+
             | Disabled 1 thread |
             +-------------------+
             1 row in set (0.01 sec)

             To disable the current connection:

             mysql> CALL sys.ps_setup_disable_thread(CONNECTION_ID());
             +-------------------+
             | summary           |
             +-------------------+
             | Disabled 1 thread |
             +-------------------+
             1 row in set (0.00 sec)
            

#### ps_setup_enable_background_threads

##### Description

Enable all background thread instrumentation within Performance Schema.

Requires the SUPER privilege for "SET sql_log_bin = 0;".

##### Parameters

None.

##### Example

             mysql> CALL sys.ps_setup_enable_background_threads();
             +-------------------------------+
             | summary                       |
             +-------------------------------+
             | Enabled 18 background threads |
             +-------------------------------+
             1 row in set (0.00 sec)
            

#### ps_setup_enable_instrument

##### Description

Enables instruments within Performance Schema matching the input pattern.

Requires the SUPER privilege for "SET sql_log_bin = 0;".

##### Parameters


* in_pattern (VARCHAR(128)): A LIKE pattern match (using "%in_pattern%") of events to enable

##### Example

To enable all mutex instruments:

             mysql> CALL sys.ps_setup_enable_instrument('wait/synch/mutex');
             +-------------------------+
             | summary                 |
             +-------------------------+
             | Enabled 155 instruments |
             +-------------------------+
             1 row in set (0.02 sec)

             Query OK, 0 rows affected (0.02 sec)

To enable just a the scpecific TCP/IP based network IO instrument:

             mysql> CALL sys.ps_setup_enable_instrument('wait/io/socket/sql/server_tcpip_socket');
             +-----------------------+
             | summary               |
             +-----------------------+
             | Enabled 1 instruments |
             +-----------------------+
             1 row in set (0.00 sec)

             Query OK, 0 rows affected (0.00 sec)

To enable all instruments:

             mysql> CALL sys.ps_setup_enable_instrument('');
             +-------------------------+
             | summary                 |
             +-------------------------+
             | Enabled 547 instruments |
             +-------------------------+
             1 row in set (0.01 sec)

             Query OK, 0 rows affected (0.01 sec)
            

#### ps_setup_enable_thread

##### Description

Enable the given connection/thread in Performance Schema.

Requires the SUPER privilege for "SET sql_log_bin = 0;".

##### Parameters


* in_connection_id (BIGINT): The connection ID (PROCESSLIST_ID from performance_schema.threads or the ID shown within SHOW PROCESSLIST)

##### Example


             mysql> CALL sys.ps_setup_enable_thread(3);
             +------------------+
             | summary          |
             +------------------+
             | Enabled 1 thread |
             +------------------+
             1 row in set (0.01 sec)

To enable the current connection:

             mysql> CALL sys.ps_setup_enable_thread(CONNECTION_ID());
             +------------------+
             | summary          |
             +------------------+
             | Enabled 1 thread |
             +------------------+
             1 row in set (0.00 sec)
            

#### ps_setup_reload_saved

##### Description

Reloads a saved Performance Schema configuration, so that you can alter the setup for debugging purposes, but restore it to a previous state.
             
Use the companion procedure - ps_setup_save(), to save a configuration.

Requires the SUPER privilege for "SET sql_log_bin = 0;".

##### Parameters

None.

##### Example


             mysql> CALL sys.ps_setup_save();
             Query OK, 0 rows affected (0.08 sec)

             mysql> UPDATE performance_schema.setup_instruments SET enabled = 'YES', timed = 'YES';
             Query OK, 547 rows affected (0.40 sec)
             Rows matched: 784  Changed: 547  Warnings: 0

             /* Run some tests that need more detailed instrumentation here */

             mysql> CALL sys.ps_setup_reload_saved();
             Query OK, 0 rows affected (0.32 sec)
            

#### ps_setup_reset_to_default

##### Description

Resets the Performance Schema setup to the default settings.

##### Parameters

* in_verbose (BOOLEAN): Whether to print each setup stage (including the SQL) whilst running.

##### Example


             mysql> CALL sys.ps_setup_reset_to_default(true)G
             *************************** 1. row ***************************
             status: Resetting: setup_actors
             DELETE
             FROM performance_schema.setup_actors
              WHERE NOT (HOST = '%' AND USER = '%' AND ROLE = '%')
             1 row in set (0.00 sec)

             *************************** 1. row ***************************
             status: Resetting: setup_actors
             INSERT IGNORE INTO performance_schema.setup_actors
             VALUES ('%', '%', '%')
             1 row in set (0.00 sec)
             ...

             mysql> CALL sys.ps_setup_reset_to_default(false)G
             Query OK, 0 rows affected (0.00 sec)
            

#### ps_setup_save

##### Description

Saves the current configuration of Performance Schema, so that you can alter the setup for debugging purposes, but restore it to a previous state.

Use the companion procedure - ps_setup_reload_saved(), to restore the saved config.

Requires the SUPER privilege for "SET sql_log_bin = 0;".

##### Parameters

None.

##### Example


             mysql> CALL sys.ps_setup_save();
             Query OK, 0 rows affected (0.08 sec)

             mysql> UPDATE performance_schema.setup_instruments 
                 ->    SET enabled = 'YES', timed = 'YES';
             Query OK, 547 rows affected (0.40 sec)
             Rows matched: 784  Changed: 547  Warnings: 0

             /* Run some tests that need more detailed instrumentation here */

             mysql> CALL sys.ps_setup_reload_saved();
             Query OK, 0 rows affected (0.32 sec)
            

#### ps_setup_show_disabled

##### Description

Shows all currently disable Performance Schema configuration.

##### Parameters

* in_in_show_instruments (BOOLEAN): Whether to print disabled instruments (can print many items)
* in_in_show_threads (BOOLEAN): Whether to print disabled threads

##### Example


             mysql> CALL sys.ps_setup_show_disabled(TRUE, TRUE);
             +----------------------------+
             | performance_schema_enabled |
             +----------------------------+
             |                          1 |
             +----------------------------+
             1 row in set (0.00 sec)

             +--------------------+
             | enabled_users      |
             +--------------------+
             | 'mark'@'localhost' |
             +--------------------+
             1 row in set (0.00 sec)

             +-------------+----------------------+---------+-------+
             | object_type | objects              | enabled | timed |
             +-------------+----------------------+---------+-------+
             | EVENT       | mysql.%              | NO      | NO    |
             | EVENT       | performance_schema.% | NO      | NO    |
             | EVENT       | information_schema.% | NO      | NO    |
             | FUNCTION    | mysql.%              | NO      | NO    |
             | FUNCTION    | performance_schema.% | NO      | NO    |
             | FUNCTION    | information_schema.% | NO      | NO    |
             | PROCEDURE   | mysql.%              | NO      | NO    |
             | PROCEDURE   | performance_schema.% | NO      | NO    |
             | PROCEDURE   | information_schema.% | NO      | NO    |
             | TABLE       | mysql.%              | NO      | NO    |
             | TABLE       | performance_schema.% | NO      | NO    |
             | TABLE       | information_schema.% | NO      | NO    |
             | TRIGGER     | mysql.%              | NO      | NO    |
             | TRIGGER     | performance_schema.% | NO      | NO    |
             | TRIGGER     | information_schema.% | NO      | NO    |
             +-------------+----------------------+---------+-------+
             15 rows in set (0.00 sec)

             +----------------------------------+
             | disabled_consumers               |
             +----------------------------------+
             | events_stages_current            |
             | events_stages_history            |
             | events_stages_history_long       |
             | events_statements_history        |
             | events_statements_history_long   |
             | events_transactions_history      |
             | events_transactions_history_long |
             | events_waits_current             |
             | events_waits_history             |
             | events_waits_history_long        |
             +----------------------------------+
             10 rows in set (0.00 sec)

             Empty set (0.00 sec)
             
             +---------------------------------------------------------------------------------------+-------+
             | disabled_instruments                                                                  | timed |
             +---------------------------------------------------------------------------------------+-------+
             | wait/synch/mutex/sql/TC_LOG_MMAP::LOCK_tc                                             | NO    |
             | wait/synch/mutex/sql/LOCK_des_key_file                                                | NO    |
             | wait/synch/mutex/sql/MYSQL_BIN_LOG::LOCK_commit                                       | NO    |
             ...
             | memory/sql/servers_cache                                                              | NO    |
             | memory/sql/udf_mem                                                                    | NO    |
             | wait/lock/metadata/sql/mdl                                                            | NO    |
             +---------------------------------------------------------------------------------------+-------+
             547 rows in set (0.00 sec)

             Query OK, 0 rows affected (0.01 sec)
            

#### ps_setup_show_enabled

##### Description

Shows all currently enabled Performance Schema configuration.

##### Parameters

* in_show_instruments (BOOLEAN): Whether to print enabled instruments (can print many items)
* in_show_threads (BOOLEAN): Whether to print enabled threads

##### Example


             mysql> CALL sys.ps_setup_show_enabled(TRUE, TRUE);
             +----------------------------+
             | performance_schema_enabled |
             +----------------------------+
             |                          1 |
             +----------------------------+
             1 row in set (0.00 sec)

             +---------------+
             | enabled_users |
             +---------------+
             | '%'@'%'       |
             +---------------+
             1 row in set (0.01 sec)

             +----------------------+---------+-------+
             | objects              | enabled | timed |
             +----------------------+---------+-------+
             | mysql.%              | NO      | NO    |
             | performance_schema.% | NO      | NO    |
             | information_schema.% | NO      | NO    |
             | %.%                  | YES     | YES   |
             +----------------------+---------+-------+
             4 rows in set (0.01 sec)

             +---------------------------+
             | enabled_consumers         |
             +---------------------------+
             | events_statements_current |
             | global_instrumentation    |
             | thread_instrumentation    |
             | statements_digest         |
             +---------------------------+
             4 rows in set (0.05 sec)

             +--------------------------+-------------+
             | enabled_threads          | thread_type |
             +--------------------------+-------------+
             | innodb/srv_master_thread | BACKGROUND  |
             | root@localhost           | FOREGROUND  |
             | root@localhost           | FOREGROUND  |
             | root@localhost           | FOREGROUND  |
             | root@localhost           | FOREGROUND  |
             +--------------------------+-------------+
             5 rows in set (0.03 sec)

             +-------------------------------------+-------+
             | enabled_instruments                 | timed |
             +-------------------------------------+-------+
             | wait/io/file/sql/map                | YES   |
             | wait/io/file/sql/binlog             | YES   |
             ...
             | statement/com/Error                 | YES   |
             | statement/com/                      | YES   |
             | idle                                | YES   |
             +-------------------------------------+-------+
             210 rows in set (0.08 sec)

             Query OK, 0 rows affected (0.89 sec)
            

#### ps_statement_avg_latency_histogram

##### Description

Outputs a textual histogram graph of the average latency values across all normalized queries tracked within the Performance Schema events_statements_summary_by_digest table.

Can be used to show a very high level picture of what kind of latency distribution statements running within this instance have.

##### Parameters

None.

##### Example


             mysql> CALL sys.ps_statement_avg_latency_histogram()G
             *************************** 1. row ***************************
             Performance Schema Statement Digest Average Latency Histogram:

               . = 1 unit
               * = 2 units
               # = 3 units

             (0 - 38ms)     240 | ################################################################################
             (38 - 77ms)    38  | ......................................
             (77 - 115ms)   3   | ...
             (115 - 154ms)  62  | *******************************
             (154 - 192ms)  3   | ...
             (192 - 231ms)  0   |
             (231 - 269ms)  0   |
             (269 - 307ms)  0   |
             (307 - 346ms)  0   |
             (346 - 384ms)  1   | .
             (384 - 423ms)  1   | .
             (423 - 461ms)  0   |
             (461 - 499ms)  0   |
             (499 - 538ms)  0   |
             (538 - 576ms)  0   |
             (576 - 615ms)  1   | .

               Total Statements: 350; Buckets: 16; Bucket Size: 38 ms;
            

#### ps_trace_statement_digest

##### Description

Traces all instrumentation within Performance Schema for a specific Statement Digest. 

When finding a statement of interest within the performance_schema.events_statements_summary_by_digest table, feed the DIGEST MD5 value in to this procedure, set how long to poll for, and at what interval to poll, and it will generate a report of all statistics tracked within Performance Schema for that digest for the interval.

It will also attempt to generate an EXPLAIN for the longest running example of the digest during the interval.

Note this may fail, as Performance Schema truncates long SQL_TEXT values (and hence the EXPLAIN will fail due to parse errors).

##### Parameters

* in_digest VARCHAR(32): The statement digest identifier you would like to analyze
* in_runtime (INT): The number of seconds to run analysis for (defaults to a minute)
* in_interval (DECIMAL(2,2)): The interval (in seconds, may be fractional) at which to try and take snapshots (defaults to a second)
* in_start_fresh (BOOLEAN): Whether to TRUNCATE the events_statements_history_long and events_stages_history_long tables before starting (default false)
* in_auto_enable (BOOLEAN): Whether to automatically turn on required consumers (default false)

##### Example

             mysql> call ps_analyze_statement_digest('891ec6860f98ba46d89dd20b0c03652c', 10, 0.1, true, true);
             +--------------------+
             | SUMMARY STATISTICS |
             +--------------------+
             | SUMMARY STATISTICS |
             +--------------------+
             1 row in set (9.11 sec)

             +------------+-----------+-----------+-----------+---------------+------------+------------+
             | executions | exec_time | lock_time | rows_sent | rows_examined | tmp_tables | full_scans |
             +------------+-----------+-----------+-----------+---------------+------------+------------+
             |         21 | 4.11 ms   | 2.00 ms   |         0 |            21 |          0 |          0 |
             +------------+-----------+-----------+-----------+---------------+------------+------------+
             1 row in set (9.11 sec)

             +------------------------------------------+-------+-----------+
             | event_name                               | count | latency   |
             +------------------------------------------+-------+-----------+
             | stage/sql/checking query cache for query |    16 | 724.37 µs |
             | stage/sql/statistics                     |    16 | 546.92 µs |
             | stage/sql/freeing items                  |    18 | 520.11 µs |
             | stage/sql/init                           |    51 | 466.80 µs |
             ...
             | stage/sql/cleaning up                    |    18 | 11.92 µs  |
             | stage/sql/executing                      |    16 | 6.95 µs   |
             +------------------------------------------+-------+-----------+
             17 rows in set (9.12 sec)

             +---------------------------+
             | LONGEST RUNNING STATEMENT |
             +---------------------------+
             | LONGEST RUNNING STATEMENT |
             +---------------------------+
             1 row in set (9.16 sec)
             
             +-----------+-----------+-----------+-----------+---------------+------------+-----------+
             | thread_id | exec_time | lock_time | rows_sent | rows_examined | tmp_tables | full_scan |
             +-----------+-----------+-----------+-----------+---------------+------------+-----------+
             |    166646 | 618.43 µs | 1.00 ms   |         0 |             1 |          0 |         0 |
             +-----------+-----------+-----------+-----------+---------------+------------+-----------+
             1 row in set (9.16 sec)

             // Truncated for clarity...
             +-----------------------------------------------------------------+
             | sql_text                                                        |
             +-----------------------------------------------------------------+
             | select hibeventhe0_.id as id1382_, hibeventhe0_.createdTime ... |
             +-----------------------------------------------------------------+
             1 row in set (9.17 sec)

             +------------------------------------------+-----------+
             | event_name                               | latency   |
             +------------------------------------------+-----------+
             | stage/sql/init                           | 8.61 µs   |
             | stage/sql/Waiting for query cache lock   | 453.23 µs |
             | stage/sql/init                           | 331.07 ns |
             | stage/sql/checking query cache for query | 43.04 µs  |
             ...
             | stage/sql/freeing items                  | 30.46 µs  |
             | stage/sql/cleaning up                    | 662.13 ns |
             +------------------------------------------+-----------+
             18 rows in set (9.23 sec)

             +----+-------------+--------------+-------+---------------+-----------+---------+-------------+------+-------+
             | id | select_type | table        | type  | possible_keys | key       | key_len | ref         | rows | Extra |
             +----+-------------+--------------+-------+---------------+-----------+---------+-------------+------+-------+
             |  1 | SIMPLE      | hibeventhe0_ | const | fixedTime     | fixedTime | 775     | const,const |    1 | NULL  |
             +----+-------------+--------------+-------+---------------+-----------+---------+-------------+------+-------+
             1 row in set (9.27 sec)

             Query OK, 0 rows affected (9.28 sec)
            

#### ps_trace_thread

##### Description

Dumps all data within Performance Schema for an instrumented thread, to create a DOT formatted graph file. 

Each resultset returned from the procedure should be used for a complete graph

##### Parameters

* in_thread_id (INT): The thread that you would like a stack trace for
* in_outfile  (VARCHAR(255)): The filename the dot file will be written to
* in_max_runtime (DECIMAL(20,2)): The maximum time to keep collecting data. Use NULL to get the default which is 60 seconds.
* in_interval (DECIMAL(20,2)): How long to sleep between data collections. Use NULL to get the default which is 1 second.
* in_start_fresh (BOOLEAN): Whether to reset all Performance Schema data before tracing.
* in_auto_setup (BOOLEAN): Whether to disable all other threads and enable all consumers/instruments. This will also reset the settings at the end of the run.
* in_debug (BOOLEAN): Whether you would like to include file:lineno in the graph

##### Example


             mysql> CALL sys.ps_dump_thread_stack(25, CONCAT('/tmp/stack-', REPLACE(NOW(), ' ', '-'), '.dot'), NULL, NULL, TRUE, TRUE, TRUE);
             +-------------------+
             | summary           |
             +-------------------+
             | Disabled 1 thread |
             +-------------------+
             1 row in set (0.00 sec)

             +---------------------------------------------+
             | Info                                        |
             +---------------------------------------------+
             | Data collection starting for THREAD_ID = 25 |
             +---------------------------------------------+
             1 row in set (0.03 sec)

             +-----------------------------------------------------------+
             | Info                                                      |
             +-----------------------------------------------------------+
             | Stack trace written to /tmp/stack-2014-02-16-21:18:41.dot |
             +-----------------------------------------------------------+
             1 row in set (60.07 sec)

             +-------------------------------------------------------------------+
             | Convert to PDF                                                    |
             +-------------------------------------------------------------------+
             | dot -Tpdf -o /tmp/stack_25.pdf /tmp/stack-2014-02-16-21:18:41.dot |
             +-------------------------------------------------------------------+
             1 row in set (60.07 sec)

             +-------------------------------------------------------------------+
             | Convert to PNG                                                    |
             +-------------------------------------------------------------------+
             | dot -Tpng -o /tmp/stack_25.png /tmp/stack-2014-02-16-21:18:41.dot |
             +-------------------------------------------------------------------+
             1 row in set (60.07 sec)

             +------------------+
             | summary          |
             +------------------+
             | Enabled 1 thread |
             +------------------+
             1 row in set (60.32 sec)


#### ps_truncate_all_tables

##### Description

Truncates all summary tables within Performance Schema, resetting all aggregated instrumentation as a snapshot.

Requires the SUPER privilege for "SET sql_log_bin = 0;".

##### Parameters

* in_verbose (BOOLEAN): Whether to print each TRUNCATE statement before running

##### Example


             mysql> CALL sys.ps_truncate_all_tables(false);
             +---------------------+
             | summary             |
             +---------------------+
             | Truncated 44 tables |
             +---------------------+
             1 row in set (0.10 sec)

             Query OK, 0 rows affected (0.10 sec)
