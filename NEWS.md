# Change history for the MySQL sys schema

## 1.4.0 (not yet released)

### Backwards Incompatible Changes

* The `memory_global_by_current_allocated` views were renamed to `memory_global_by_current_bytes` for consistency with the other memory views
* The `ps_setup_enable_consumers` procedure was renamed to `ps_setup_disable_consumer` for naming consistency (everything is now singular, not plural)

### Improvements

* The innodb_lock_waits/x$innodb_lock_waits views were improved (Contributed by Jesper Wisborg Krogh)
** Added the wait_started column
** Added the wait_age column
** Order the result set so the oldest lock waits are first
** The waiting_table and waiting_index will always be the same as the blocking_table and blocking_index. So the blocking_% columns have been removed and the waiting_% columns have been renamed to locked_%
** The waiting_lock_typeand blocking_lock_type will also always the same. So these were removed and replaced with a single locked_type column
** Rename the waiting_thread and blocking_thread to waiting_pid and blocking_pid respectively to avoid confusion with the threads from the Performance Schema.
* Added the `sys_get_config` function, used to get configuration parameters from the sys_config table - primarily from other sys objects, but can be used individually (Contributed by Jesper Wisborg Krogh)
* Add an option to generate_sql_file.sh to generate a mysql_install_db / --bootstrap format friendly file.

### Bug Fixes

* The 5.6 host_summary and x$host_summary views incorrectly had the column with COUNT(DISTINCT accounts.user) named unique_hosts instead of unique_users (Contributed by Jesper Wisborg Krogh)

### Implementation Details

Various changes were made to allow better generation of integration sql files:

* The formatting for all comments has been standardized on -- line comments. C-style /* comments */ have been removed
** Issue #35 had one instance of this resolved in this release (contributed by Joe Grasse), but the entire code base has now been done
* Each object has been created within it's own file. No longer do x$ views live with their non-x$ counterparts
* DELIMITERs were standardized to $$

## 1.3.0 (23/10/2014)

### Improvements

* Added an `innodb_lock_waits` set of views, showing each thread that is waiting on a lock within InnoDB, and the blocking thread lock information (Contributed by Jesper Wisborg Krogh)

### Bug Fixes

* Fixed broken `host_summary_by_stages` views, broken with a last minute change before the 1.2.0 release that went unnoticed (facepalm)

## 1.2.0 (22/10/2014)

### Backwards Incompatible Changes

* The `host_summary_by_stages` and `user_summary_by_stages` `wait_sum` and `wait_avg` columns were renamed to `total_latency` and `avg_latency` respectively, for consistency.
* The `host_summary_by_file_io_type` and `user_summary_by_file_io_type `latency` column was renamed to `total_latency`, for consistency.

### Improvements

* Made the truncation length for the `format_statement` view configurable
  * This includes adding a new persistent `sys_config` table to store the new variable - `statement_truncate_len` - see the README for usage
* Added `total_latency` to the `schema_tables_with_full_table_scans` view, and added an x$ counterpart
* Added `innodb_buffer_free` to the `schema_table_statistics_with_buffer` view, to summarize how much free space is allocated per table in the buffer pool
* The `schema_unused_indexes` view now ignores indexes named `PRIMARY` (primary keys)
* Added `rows_affected` and `rows_affected_avg` stats to the `statement_analysis` views
* The `statements_with_full_table_scans` view now ignores any SQL that starts with `SHOW`
* Added a script, `generate_sql_file.sh`, that can be used to generate a single SQL file, also allowing substitution of the MySQL user to use, and/or whether the `SET sql_log_bin ...` statements should be omitted.
** This is useful for those using RDS, where the root@localhost user is not accessible, and sql_log_bin is disabled (Issue #5)
* Added a set of `memory_by_thread_by_current_bytes` views, that summarize memory usage per thread with MySQL 5.7's memory instrumentation
* Improved each of the host specific views to return aggregate values for `background` threads, instead of ignoring them, in the same way as the user summary views

### Bug Fixes

* Added the missing `memory_by_host` view for MySQL 5.7
* Added missing space for hour notation within the `format_time` function
* Fixed views affected by MySQL 5.7 ONLY_FULL_GROUP_BY and functional dependency changes

## 1.1.0 (04/09/2014)

### Improvements

* Added host summary views, which have the same structure as the user summary views, but aggregated by host instead (Contributed by Arnaud Adant)
   * `host_summary`
   * `host_summary_by_file_io_type`
   * `host_summary_by_file_io`
   * `host_summary_by_statement_type`
   * `host_summary_by_statement_latency`
   * `host_summary_by_stages`
   * `waits_by_host_by_latency`

* Added functions which return instruments are either enabled, or timed by default (#15) (Contributed by Jesper Wisborg Krogh)
   * `ps_is_instrument_default_enabled`
   * `ps_is_instrument_default_timed`

* Added a `ps_thread_id` function, which returns the thread_id value exposed within performance_schema for the current connection (Contributed by Jesper Wisborg Krogh)
* Improved each of the user specific views to return aggregate values for `background` threads, instead of ignoring them (Contributed by Joe Grasse)
* Optimized the `schema_table_statistics` and `schema_table_statistics_with_buffer` views, to use a new view that will get materialized (`x$ps_schema_table_statistics_io`), along with the changes to the RETURN types for `extract_schema_from_file_name` and `extract_table_from_file_name`, this results in a significant performance improvement - in one test changing the run time from 14 minutes to 20 seconds. (Conceived by Roy Lyseng, Mark Leith and Jesper Wisborg Krogh, implemented and contributed by Jesper Wisborg Krogh)

### Bug Fixes

* Removed unintentially committed sys_56_rds.sql file (See Issue #5, which is still outstanding)
* Fixed the `ps_trace_statement_digest` and `ps_trace_thread` procedures to properly set sql_log_bin, and reset the thread INSTRUMENTED value correctly (Contributed by Jesper Wisborg Krogh)
* Removed various sql_log_bin disabling from other procedures that no longer require it - DML against the performance_schema data is no longer replicated (Contributed by Jesper Wisborg Krogh)
* Fixed EXPLAIN within `ps_trace_statement_digest` procedure (Contributed by Jesper Wisborg Krogh)
* Fixed the datatype for the `thd_id` variable within the `ps_thread_stack` procedure (Contributed by Jesper Wisborg Krogh)
* Fixed datatypes used for temporary tables within the `ps_trace_statement_digest` procedure (Contributed by Jesper Wisborg Krogh)
* Fixed the RETURN datatype `extract_schema_from_file_name` and `extract_table_from_file_name` to return a VARCHAR(64) (Contributed by Jesper Wisborg Krogh)
* Added events_transactions_current to the default enabled consumers in 5.7 (#25)

## 1.0.1 (23/05/2014)

### Improvements

* Added procedures to enable / disable Performance Schema consumers. (Contributed by the MySQL QA Team)
   * `ps_setup_disable_consumers(<LIKE string>)` allows disabling any consumers matching the LIKE string.
   * `ps_setup_enable_consumers(<LIKE string>)` allows enabling any consumers matching the LIKE string.

* Added procedures to show both enabled and disbled consumers or instruments individually, these are more useful for tooling than the `ps_setup_show_enabled`/`ps_setup_show_disabled` procedures which show all configuration in multiple result sets.  (Contributed by the MySQL QA Team)
   * `ps_setup_show_disabled_consumers` shows only disabled consumers.
   * `ps_setup_show_disabled_instruments` shows only disabled instruments.
   * `ps_setup_show_enabled_consumers` shows only enabled consumers.
   * `ps_setup_show_enabled_instruments` shows only enabled instruments.

### Bug Fixes

* Running the installation scripts sometimes failed because of the comment format. (#1) (Contributed by Joe Grasse)
* Some views did not work with the ERROR_FOR_DIVISION_BY_ZERO SQL mode. (#6) (Contributed by Joe Grasse)
* On Windows the `ps_thread_stack()` stored function failed to escape file path backslashes correctly within the JSON output.

## 1.0.0 (11/04/2014)
