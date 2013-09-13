SOURCE ./before_setup.sql

SOURCE ./functions/extract_schema_from_file_name.sql
SOURCE ./functions/extract_table_from_file_name.sql
SOURCE ./functions/format_bytes.sql
SOURCE ./functions/format_path.sql
SOURCE ./functions/format_statement.sql
SOURCE ./functions/format_time.sql
SOURCE ./functions/is_account_enabled.sql
SOURCE ./functions/reverse_format_time.sql

SOURCE ./procedures/analyze_statement_digest.sql
SOURCE ./procedures/currently_enabled.sql
SOURCE ./procedures/disable_background_threads.sql
SOURCE ./procedures/disable_current_thread.sql
SOURCE ./procedures/dump_thread_stack.sql
SOURCE ./procedures/enable_background_threads.sql
SOURCE ./procedures/enable_current_thread.sql
SOURCE ./procedures/only_enable.sql
SOURCE ./procedures/reload_saved_config.sql
SOURCE ./procedures/reset_to_default_57.sql
SOURCE ./procedures/save_current_config.sql
SOURCE ./procedures/truncate_all.sql

SOURCE ./views/i_s/innodb_buffer_stats_by_schema.sql
SOURCE ./views/i_s/innodb_buffer_stats_by_table.sql
SOURCE ./views/i_s/schema_object_overview.sql

SOURCE ./views/p_s/check_lost_instrumentation.sql
SOURCE ./views/p_s/processlist_57.sql

SOURCE ./views/p_s/latest_file_io.sql
SOURCE ./views/p_s/io_by_thread_by_latency.sql
SOURCE ./views/p_s/io_global_by_file_by_bytes.sql
SOURCE ./views/p_s/io_global_by_file_by_latency.sql
SOURCE ./views/p_s/io_global_by_wait_by_bytes.sql
SOURCE ./views/p_s/io_global_by_wait_by_latency.sql

SOURCE ./views/p_s/memory_by_user.sql
SOURCE ./views/p_s/memory_global_by_current_allocated.sql
SOURCE ./views/p_s/memory_global_total.sql

SOURCE ./views/p_s/schema_index_statistics.sql
SOURCE ./views/p_s/schema_table_statistics.sql
SOURCE ./views/p_s/schema_table_statistics_with_buffer.sql
SOURCE ./views/p_s/schema_tables_with_full_table_scans.sql
SOURCE ./views/p_s/schema_unused_indexes.sql

SOURCE ./views/p_s/statement_analysis.sql
SOURCE ./views/p_s/statements_with_errors_or_warnings.sql
SOURCE ./views/p_s/statements_with_full_table_scans.sql
SOURCE ./views/p_s/statements_with_runtimes_in_95th_percentile.sql
SOURCE ./views/p_s/statements_with_sorting.sql
SOURCE ./views/p_s/statements_with_temp_tables.sql

SOURCE ./views/p_s/user_summary_57.sql
SOURCE ./views/p_s/user_summary_by_statement_type.sql
SOURCE ./views/p_s/user_summary_by_stages.sql

SOURCE ./views/p_s/wait_classes_global_by_avg_latency.sql
SOURCE ./views/p_s/wait_classes_global_by_latency.sql
SOURCE ./views/p_s/waits_by_user_by_latency.sql
SOURCE ./views/p_s/waits_global_by_latency.sql

SOURCE ./after_setup.sql
