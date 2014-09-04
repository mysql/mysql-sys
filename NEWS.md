# Change history for the MySQL sys schema

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
