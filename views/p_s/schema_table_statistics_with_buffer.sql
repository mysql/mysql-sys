/* 
 * View: schema_table_statistics_with_buffer
 *
 * Mimic TABLE_STATISTICS from Google et al
 * However, order by the total wait time descending, and add in more statistics
 * such as caching stats for the InnoDB buffer pool with InnoDB tables
 *
 * mysql> select * from schema_table_statistics_with_buffer limit 1\G
 * *************************** 1. row ***************************
 *                  table_schema: mem
 *                    table_name: mysqlserver
 *                  rows_fetched: 27087
 *                 fetch_latency: 442.72 ms
 *                 rows_inserted: 2
 *                insert_latency: 185.04 µs 
 *                  rows_updated: 5096
 *                update_latency: 1.39 s
 *                  rows_deleted: 0
 *                delete_latency: 0 ps
 *              io_read_requests: 2565
 *                 io_read_bytes: 1121627
 *               io_read_latency: 10.07 ms
 *             io_write_requests: 1691
 *                io_write_bytes: 128383
 *              io_write_latency: 14.17 ms
 *              io_misc_requests: 2698
 *               io_misc_latency: 433.66 ms
 *           innodb_buffer_pages: 19
 *    innodb_buffer_pages_hashed: 19
 *       innodb_buffer_pages_old: 19
 * innodb_buffer_bytes_allocated: 311296
 *      innodb_buffer_bytes_data: 1924
 *     innodb_buffer_rows_cached: 2
 * 
 * (Example from 5.6.6)
 *
 * Versions: 5.6.2+
 *
 */ 
 
DROP VIEW IF EXISTS schema_table_statistics_with_buffer;

CREATE SQL SECURITY INVOKER VIEW schema_table_statistics_with_buffer AS 
SELECT pst.object_schema AS table_schema,
       pst.object_name AS table_name,
       pst.count_fetch AS rows_fetched,
       format_time(pst.sum_timer_fetch) AS fetch_latency,
       pst.count_insert AS rows_inserted,
       format_time(pst.sum_timer_insert) AS insert_latency,
       pst.count_update AS rows_updated,
       format_time(pst.sum_timer_update) AS update_latency,
       pst.count_delete AS rows_deleted,
       format_time(pst.sum_timer_delete) AS delete_latency,
       SUM(fsbi.count_read) AS io_read_requests,
       format_bytes(SUM(fsbi.sum_number_of_bytes_read)) AS io_read,
       format_time(SUM(fsbi.sum_timer_read)) AS io_read_latency,
       SUM(fsbi.count_write) AS io_write_requests,
       format_bytes(SUM(fsbi.sum_number_of_bytes_write)) AS io_write,
       format_time(SUM(fsbi.sum_timer_write)) AS io_write_latency,
       SUM(fsbi.count_misc) AS io_misc_requests,
       format_time(SUM(fsbi.sum_timer_misc)) AS io_misc_latency,
       ibp.allocated AS innodb_buffer_allocated,
       ibp.data AS innodb_buffer_data,
       ibp.pages AS innodb_buffer_pages,
       ibp.pages_hashed AS innodb_buffer_pages_hashed,
       ibp.pages_old AS innodb_buffer_pages_old,
       ibp.rows_cached AS innodb_buffer_rows_cached
  FROM performance_schema.table_io_waits_summary_by_table AS pst
  LEFT JOIN performance_schema.file_summary_by_instance AS fsbi
    ON pst.object_schema = extract_schema_from_file_name(fsbi.file_name)
   AND pst.object_name = extract_table_from_file_name(fsbi.file_name)
  LEFT JOIN ps_helper.innodb_buffer_stats_by_table AS ibp
    ON pst.object_schema = ibp.object_schema
   AND pst.object_name = ibp.object_name
 GROUP BY pst.object_schema, pst.object_name
 ORDER BY pst.sum_timer_wait DESC;

/* 
 * View: schema_table_statistics_with_buffer_raw
 *
 * Mimic TABLE_STATISTICS from Google et al
 * However, order by the total wait time descending, and add in more statistics
 * such as caching stats for the InnoDB buffer pool with InnoDB tables
 *
 * mysql> SELECT * FROM schema_table_statistics_with_buffer_raw LIMIT 1\G
 * *************************** 1. row ***************************
 *               table_schema: common_schema
 *                 table_name: help_content
 *               rows_fetched: 0
 *              fetch_latency: 0
 *              rows_inserted: 169
 *             insert_latency: 409815527680
 *               rows_updated: 0
 *             update_latency: 0
 *               rows_deleted: 0
 *             delete_latency: 0
 *           io_read_requests: 14
 *                    io_read: 1180
 *            io_read_latency: 52406770
 *          io_write_requests: 131
 *                   io_write: 11719246
 *           io_write_latency: 133726902790
 *           io_misc_requests: 61
 *            io_misc_latency: 209081089750
 *    innodb_buffer_allocated: 688128
 *         innodb_buffer_data: 423667
 *        innodb_buffer_pages: 42
 * innodb_buffer_pages_hashed: 42
 *    innodb_buffer_pages_old: 42
 *  innodb_buffer_rows_cached: 210
 * 1 row in set (1.18 sec)
 * 
 * (Example from 5.6.6)
 *
 * Versions: 5.6.2+
 *
 */ 
 
DROP VIEW IF EXISTS schema_table_statistics_with_buffer_raw;

CREATE SQL SECURITY INVOKER VIEW schema_table_statistics_with_buffer_raw AS 
SELECT pst.object_schema AS table_schema,
       pst.object_name AS table_name,
       pst.count_fetch AS rows_fetched,
       pst.sum_timer_fetch AS fetch_latency,
       pst.count_insert AS rows_inserted,
       pst.sum_timer_insert AS insert_latency,
       pst.count_update AS rows_updated,
       pst.sum_timer_update AS update_latency,
       pst.count_delete AS rows_deleted,
       pst.sum_timer_delete AS delete_latency,
       SUM(fsbi.count_read) AS io_read_requests,
       SUM(fsbi.sum_number_of_bytes_read) AS io_read,
       SUM(fsbi.sum_timer_read) AS io_read_latency,
       SUM(fsbi.count_write) AS io_write_requests,
       SUM(fsbi.sum_number_of_bytes_write) AS io_write,
       SUM(fsbi.sum_timer_write) AS io_write_latency,
       SUM(fsbi.count_misc) AS io_misc_requests,
       SUM(fsbi.sum_timer_misc) AS io_misc_latency,
       ibp.allocated AS innodb_buffer_allocated,
       ibp.data AS innodb_buffer_data,
       ibp.pages AS innodb_buffer_pages,
       ibp.pages_hashed AS innodb_buffer_pages_hashed,
       ibp.pages_old AS innodb_buffer_pages_old,
       ibp.rows_cached AS innodb_buffer_rows_cached
  FROM performance_schema.table_io_waits_summary_by_table AS pst
  LEFT JOIN performance_schema.file_summary_by_instance AS fsbi
    ON pst.object_schema = extract_schema_from_file_name(fsbi.file_name)
   AND pst.object_name = extract_table_from_file_name(fsbi.file_name)
  LEFT JOIN ps_helper.innodb_buffer_stats_by_table_raw AS ibp
    ON pst.object_schema = ibp.object_schema
   AND pst.object_name = ibp.object_name
 GROUP BY pst.object_schema, pst.object_name
 ORDER BY pst.sum_timer_wait DESC;