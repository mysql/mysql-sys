/*
 * View: statement_analysis
 *
 * Lists a normalized statement view with aggregated statistics,
 * mimics the MySQL Enterprise Monitor Query Analysis view,
 * ordered by the total execution time per normalized statement
 * 
 * mysql> select * from statement_analysis limit 5;
 * +-------------------------------------------------------------------+-----------+------------+-----------+------------+---------------+-------------+-------------+--------------+-----------+---------------+--------------+------------+-----------------+-------------+-------------------+----------------------------------+
 * | query                                                             | full_scan | exec_count | err_count | warn_count | total_latency | max_latency | avg_latency | lock_latency | rows_sent | rows_sent_avg | rows_scanned | tmp_tables | tmp_disk_tables | rows_sorted | sort_merge_passes | digest                           |
 * +-------------------------------------------------------------------+-----------+------------+-----------+------------+---------------+-------------+-------------+--------------+-----------+---------------+--------------+------------+-----------------+-------------+-------------------+----------------------------------+
 * | INSERT INTO `mem__quan` . `exa ...  `hostTo` ) , `hostTo` ) , ... |           |      48183 |         0 |          0 | 00:34:07.14   | 663.32 ms   | 42.49 ms    | 00:01:49.68  |         0 |             0 |            0 |          0 |               0 |           0 |                 0 | b0542e318db3e65d09574082d3f63cec |
 * | INSERT INTO `mem__quan` . `nor ... nDuration` = IF ( VALUES ( ... |           |      48241 |         0 |          0 | 00:15:37.60   | 712.57 ms   | 19.44 ms    | 00:02:03.80  |         0 |             0 |            0 |          0 |               0 |           0 |                 0 | 361bbfa1983c4ec4901cb2237f256138 |
 * | INSERT INTO `mem__quan` . `nor ... `lastSeen` ) ) , `lastSeen` )  |           |      49660 |      1428 |          0 | 00:08:04.46   | 379.57 ms   | 9.76 ms     | 00:01:41.35  |         0 |             0 |            0 |          0 |               0 |           0 |                 0 | 6134e9d6f25eb8e6cddf11f6938f202a |
 * | COMMIT                                                            |           |     111127 |         0 |          0 | 00:07:40.62   | 1.30 s      | 4.14 ms     | 0 ps         |         0 |             0 |            0 |          0 |               0 |           0 |                 0 | e51be358a1cbf99c1acab35cc1c6b683 |
 * | SELECT DISTINCTROW `agent0_` . ... ` . `hid` = `mysqlproce1_` ... | *         |       2737 |         0 |          0 | 00:01:49.62   | 1.06 s      | 40.05 ms    | 887.95 ms    |      2729 |             1 |         8335 |       2737 |            2737 |           0 |                 0 | 218d4bf81d6bd134908da4bc6570d3c0 |
 * +-------------------------------------------------------------------+-----------+------------+-----------+------------+---------------+-------------+-------------+--------------+-----------+---------------+--------------+------------+-----------------+-------------+-------------------+----------------------------------+
 * 5 rows in set (0.02 sec) *
 * 
 * (Example from 5.6.6)
 *
 * Versions: 5.6.5+
 */

DROP VIEW IF EXISTS statement_analysis;

CREATE SQL SECURITY INVOKER VIEW statement_analysis AS
SELECT ps_helper.format_statement(DIGEST_TEXT) AS query,
       IF(SUM_NO_GOOD_INDEX_USED > 0 OR SUM_NO_INDEX_USED > 0, '*', '') AS full_scan,
       COUNT_STAR AS exec_count,
       SUM_ERRORS AS err_count,
       SUM_WARNINGS AS warn_count,
       ps_helper.format_time(SUM_TIMER_WAIT) AS total_latency,
       ps_helper.format_time(MAX_TIMER_WAIT) AS max_latency,
       ps_helper.format_time(AVG_TIMER_WAIT) AS avg_latency,
       ps_helper.format_time(SUM_LOCK_TIME) AS lock_latency,
       SUM_ROWS_SENT AS rows_sent,
       ROUND(SUM_ROWS_SENT / COUNT_STAR) AS rows_sent_avg,
       SUM_ROWS_EXAMINED AS rows_scanned,
       SUM_CREATED_TMP_TABLES AS tmp_tables,
       SUM_CREATED_TMP_DISK_TABLES AS tmp_disk_tables,
       SUM_SORT_ROWS AS rows_sorted,
       SUM_SORT_MERGE_PASSES AS sort_merge_passes,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
ORDER BY SUM_TIMER_WAIT DESC;

/*
 * View: statement_analysis_raw
 *
 * Lists a normalized statement view with aggregated statistics,
 * mimics the MySQL Enterprise Monitor Query Analysis view,
 * ordered by the total execution time per normalized statement
 * 
 * mysql> select * from statement_analysis_raw limit 5;
 * +-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------+------------+-----------+------------+------------------+---------------+-------------+-----------+---------------+--------------+----------------------------------+
 * | query                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | full_scan | exec_count | err_count | warn_count | total_latency    | max_latency   | avg_latency | rows_sent | rows_sent_avg | rows_scanned | digest                           |
 * +-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------+------------+-----------+------------+------------------+---------------+-------------+-----------+---------------+--------------+----------------------------------+
 * | INSERT INTO `mem__quan` . `example_statements` ( `bytes` , `comments` , `connectionId` , ERRORS , `execTime` , `hostFrom` , `hostTo` , `noGoodIndexUsed` , `noIndexUsed` , ROWS , `source_location_id` , `text` , TIMESTAMP , SYSTEM_USER , WARNINGS , `round_robin_bin` , `normalized_statement_by_server_by_schema_id` ) VALUES (...) ON DUPLICATE KEY UPDATE `bytes` = IF ( VALUES ( `timestamp` ) >= `timestamp` , VALUES ( `bytes` ) , `bytes` ) , `comments` = IF ( VALUES ( `timestamp` ) >= `timestamp` , VALUES ( `comments` ) , `comments` ) , `connectionId` = IF ( VALUES ( `timestamp` ) >= `timestamp` , VALUES ( `connectionId` ) , `connectionId` ) , ERRORS = IF ( VALUES ( `timestamp` ) >= `timestamp` , VALUES ( ERRORS ) , ERRORS ) , `execTime` = IF ( VALUES ( `timestamp` ) >= `timestamp` , VALUES ( `execTime` ) , `execTime` ) , `hostFrom` = IF ( VALUES ( `timestamp` ) >= `timestamp` , VALUES ( `hostFrom` ) , `hostFrom` ) , `hostTo` = IF ( VALUES ( `timestamp` ) >= `timestamp` , VALUES ( `hostTo` ) , `hostTo` ) , ... |           |      48581 |         0 |          0 | 2064385387382000 |  663318001000 | 42493678000 |         0 |             0 |            0 | b0542e318db3e65d09574082d3f63cec |
 * | INSERT INTO `mem__quan` . `normalized_statements_by_server_by_schema_data` ( `bytesMax` , `bytesMin` , `bytesTotal` , `collectionDuration` , `createdTmpDiskTables` , `createdTmpTables` , `errorCount` , `execCount` , `execTimeMax` , `execTimeMin` , `execTimeTotal` , `lockTimeTotal` , `noGoodIndexUsedCount` , `noIndexUsedCount` , `rowsExaminedTotal` , `rowsMax` , `rowsMin` , `rowsTotal` , `selectFullJoin` , `selectFullRangeJoin` , `selectRange` , `selectRangeCheck` , `selectScan` , `sortMergePasses` , `sortRange` , `sortRows` , `sortScan` , TIMESTAMP , `warningCount` , `round_robin_bin` , `normalized_statement_by_server_by_schema_id` ) VALUES (...) ON DUPLICATE KEY UPDATE `bytesMax` = IF ( VALUES ( `timestamp` ) >= `timestamp` , VALUES ( `bytesMax` ) , `bytesMax` ) , `bytesMin` = IF ( VALUES ( `timestamp` ) >= `timestamp` , VALUES ( `bytesMin` ) , `bytesMin` ) , `bytesTotal` = IF ( VALUES ( `timestamp` ) >= `timestamp` , VALUES ( `bytesTotal` ) , `bytesTotal` ) , `collectionDuration` = IF ( VALUES ( ...    |           |      48644 |         0 |          0 |  942743947256000 |  712569590000 | 19380477000 |         0 |             0 |            0 | 361bbfa1983c4ec4901cb2237f256138 |
 * | INSERT INTO `mem__quan` . `normalized_statements_by_server_by_schema` ( `firstSeen` , `lastSeen` , `normalized_statement_id` , `schema` , SERVER , `id` ) VALUES (...) ON DUPLICATE KEY UPDATE `firstSeen` = COALESCE ( `LEAST` ( `firstSeen` , VALUES ( `firstSeen` ) ) , `firstSeen` ) , `lastSeen` = COALESCE ( `GREATEST` ( `lastSeen` , VALUES ( `lastSeen` ) ) , `lastSeen` )                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |           |      50063 |      1428 |          0 |  485443623892000 |  379567835000 |  9696654000 |         0 |             0 |            0 | 6134e9d6f25eb8e6cddf11f6938f202a |
 * | COMMIT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |           |     111994 |         0 |          0 |  463603956226000 | 1300702917000 |  4139542000 |         0 |             0 |            0 | e51be358a1cbf99c1acab35cc1c6b683 |
 * | SELECT DISTINCTROW `agent0_` . `hid` AS `hid1776_` , `agent0_` . `id` AS `id2_1776_` , `agent0_` . `hostname` AS `hostname3_1776_` , `agent0_` . `hasHostname` AS `hasHostn4_1776_` , `agent0_` . `reachable` AS `reachable5_1776_` , `agent0_` . `hasReachable` AS `hasReach6_1776_` , `agent0_` . `timestamp` AS `timestamp7_1776_` , `agent0_` . `version` AS `version8_1776_` , `agent0_` . `hasVersion` AS `hasVersion9_1776_` , `agent0_` . `agentConfiguration` AS `agentCo10_1776_` , `agent0_` . `hasAgentConfiguration` AS `hasAgen11_1776_` , `agent0_` . `jvm` AS `jvm12_1776_` , `agent0_` . `hasJvm` AS `hasJvm13_1776_` , `agent0_` . `os` AS `os14_1776_` , `agent0_` . `hasOs` AS `hasOs15_1776_` , `agent0_` . `hasMysqlConnections` AS `hasMysq16_1776_` , `agent0_` . `hasMysqlProcesses` AS `hasMysq17_1776_` , `agent0_` . `hasMysqlServers` AS `hasMysq18_1776_` FROM `mem__inventory` . `Agent` `agent0_` INNER JOIN `mem__inventory` . `Agent_mysqlProcesses` `mysqlproce1_` ON `agent0_` . `hid` = `mysqlproce1_` ...             | *         |       2760 |         0 |          0 |  109905347333000 | 1062783078000 | 39820778000 |      2752 |             1 |         8410 | 218d4bf81d6bd134908da4bc6570d3c0 |
 * +-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------+------------+-----------+------------+------------------+---------------+-------------+-----------+---------------+--------------+----------------------------------+
 * 5 rows in set (0.10 sec)
 *
 * (Example from 5.6.6)
 *
 * Versions: 5.6.5+
 */

DROP VIEW IF EXISTS statement_analysis_raw;

CREATE SQL SECURITY INVOKER VIEW statement_analysis_raw AS
SELECT DIGEST_TEXT AS query,
       IF(SUM_NO_GOOD_INDEX_USED > 0 OR SUM_NO_INDEX_USED > 0, '*', '') AS full_scan,
       COUNT_STAR AS exec_count,
       SUM_ERRORS AS err_count,
       SUM_WARNINGS AS warn_count,
       SUM_TIMER_WAIT AS total_latency,
       MAX_TIMER_WAIT AS max_latency,
       AVG_TIMER_WAIT AS avg_latency,
       SUM_ROWS_SENT AS rows_sent,
       ROUND(SUM_ROWS_SENT / COUNT_STAR) AS rows_sent_avg,
       SUM_ROWS_EXAMINED AS rows_scanned,
       SUM_CREATED_TMP_TABLES AS tmp_tables,
       SUM_CREATED_TMP_DISK_TABLES AS tmp_disk_tables,
       SUM_SORT_ROWS AS rows_sorted,
       SUM_SORT_MERGE_PASSES AS sort_merge_passes,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
ORDER BY SUM_TIMER_WAIT DESC;
