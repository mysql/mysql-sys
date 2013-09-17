SOURCE ./before_setup.sql

SOURCE ./functions/extract_schema_from_file_name.sql
SOURCE ./functions/extract_table_from_file_name.sql
SOURCE ./functions/format_bytes.sql
SOURCE ./functions/format_path.sql
SOURCE ./functions/format_time.sql
SOURCE ./functions/reverse_format_time.sql

SOURCE ./procedures/currently_enabled_55.sql
SOURCE ./procedures/currently_disabled_55.sql
SOURCE ./procedures/only_enable.sql
SOURCE ./procedures/truncate_all.sql

SOURCE ./views/i_s/innodb_buffer_stats_by_schema.sql
SOURCE ./views/i_s/innodb_buffer_stats_by_table.sql
SOURCE ./views/i_s/schema_object_overview.sql

SOURCE ./views/p_s/check_lost_instrumentation.sql

SOURCE ./views/p_s/latest_file_io.sql
SOURCE ./views/p_s/io_by_thread_by_latency_55.sql
SOURCE ./views/p_s/io_global_by_file_by_bytes.sql
SOURCE ./views/p_s/io_global_by_wait_by_bytes_55.sql
SOURCE ./views/p_s/io_global_by_wait_by_latency_55.sql

SOURCE ./views/p_s/wait_classes_global_by_avg_latency.sql
SOURCE ./views/p_s/wait_classes_global_by_latency.sql
SOURCE ./views/p_s/waits_global_by_latency.sql

SOURCE ./after_setup.sql
