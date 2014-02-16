/* Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; version 2 of the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA */

/*
 * View: statement_analysis
 *
 * Lists a normalized statement view with aggregated statistics,
 * mimics the MySQL Enterprise Monitor Query Analysis view,
 * ordered by the total execution time per normalized statement
 * 
 * mysql> select * from statement_analysis limit 5;
 * +-------------------------------------------------------------------+------+-----------+------------+-----------+------------+---------------+-------------+-------------+--------------+-----------+---------------+---------------+-------------------+------------+-----------------+-------------+-------------------+----------------------------------+---------------------+---------------------+
 * | query                                                             | db   | full_scan | exec_count | err_count | warn_count | total_latency | max_latency | avg_latency | lock_latency | rows_sent | rows_sent_avg | rows_examined | rows_examined_avg | tmp_tables | tmp_disk_tables | rows_sorted | sort_merge_passes | digest                           | first_seen          | last_seen           |
 * +-------------------------------------------------------------------+------+-----------+------------+-----------+------------+---------------+-------------+-------------+--------------+-----------+---------------+---------------+-------------------+------------+-----------------+-------------+-------------------+----------------------------------+---------------------+---------------------+
 * | INSERT INTO `mem__quan` . `nor ... nDuration` = IF ( VALUES ( ... | mem  |           |    7604979 |         0 |          0 | 27.36h        | 831.62 ms   | 12.95 ms    | 2.24h        |         0 |             0 |             0 |                 0 |          0 |               0 |           0 |                 0 | 361bbfa1983c4ec4901cb2237f256138 | 2013-12-04 20:05:34 | 2013-12-18 17:50:34 |
 * | COMMIT                                                            | mem  |           |   23437411 |         0 |          0 | 7.60h         | 3.69 s      | 1.17 ms     | 0 ps         |         0 |             0 |             0 |                 0 |          0 |               0 |           0 |                 0 | e51be358a1cbf99c1acab35cc1c6b683 | 2013-12-04 20:04:08 | 2013-12-18 17:50:55 |
 * | INSERT INTO `mem__quan` . `nor ... `lastSeen` ) ) , `lastSeen` )  | mem  |           |    7603328 |       644 |          0 | 5.34h         | 840.00 ms   | 2.53 ms     | 00:39:13.55  |         0 |             0 |             0 |                 0 |          0 |               0 |           0 |                 0 | 6134e9d6f25eb8e6cddf11f6938f202a | 2013-12-04 20:05:34 | 2013-12-18 17:50:34 |
 * | SELECT `fsstatisti0_` . `fs` A ...  `fsstatisti0_` . `timestamp`  | mem  |           |     160159 |         0 |          0 | 4.90h         | 1.89 s      | 110.24 ms   | 00:01:36.52  | 229526539 |          1433 |     229532297 |              1433 |          0 |               0 |           0 |                 0 | 8e87c94dc6567954202c0dbe56e626e8 | 2013-12-04 20:04:54 | 2013-12-18 17:50:44 |
 * | SELECT `blockdevic0_` . `hid`  ... vic0_` . `hid` = ? FOR UPDATE  | mem  |           |    1400390 |         0 |          0 | 1.89h         | 2.01 s      | 4.86 ms     | 00:03:31.29  |   1400381 |             1 |       1400381 |                 1 |          0 |               0 |           0 |                 0 | ac9fdbb96f5ebdebdaa963251162e6d4 | 2013-12-04 20:04:53 | 2013-12-18 17:50:44 |
 * +-------------------------------------------------------------------+------+-----------+------------+-----------+------------+---------------+-------------+-------------+--------------+-----------+---------------+---------------+-------------------+------------+-----------------+-------------+-------------------+----------------------------------+---------------------+---------------------+
 * 5 rows in set (0.02 sec)
 *
 * (Example from 5.6.14)
 *
 * Versions: 5.6.9+
 */

DROP VIEW IF EXISTS statement_analysis;

CREATE SQL SECURITY INVOKER VIEW statement_analysis AS
SELECT sys.format_statement(DIGEST_TEXT) AS query,
       SCHEMA_NAME AS db,
       IF(SUM_NO_GOOD_INDEX_USED > 0 OR SUM_NO_INDEX_USED > 0, '*', '') AS full_scan,
       COUNT_STAR AS exec_count,
       SUM_ERRORS AS err_count,
       SUM_WARNINGS AS warn_count,
       sys.format_time(SUM_TIMER_WAIT) AS total_latency,
       sys.format_time(MAX_TIMER_WAIT) AS max_latency,
       sys.format_time(AVG_TIMER_WAIT) AS avg_latency,
       sys.format_time(SUM_LOCK_TIME) AS lock_latency,
       SUM_ROWS_SENT AS rows_sent,
       ROUND(SUM_ROWS_SENT / COUNT_STAR) AS rows_sent_avg,
       SUM_ROWS_EXAMINED AS rows_examined,
       ROUND(SUM_ROWS_EXAMINED / COUNT_STAR)  AS rows_examined_avg,
       SUM_CREATED_TMP_TABLES AS tmp_tables,
       SUM_CREATED_TMP_DISK_TABLES AS tmp_disk_tables,
       SUM_SORT_ROWS AS rows_sorted,
       SUM_SORT_MERGE_PASSES AS sort_merge_passes,
       DIGEST AS digest,
       FIRST_SEEN AS first_seen,
       LAST_SEEN as last_seen
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
 * +----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------+-----------+------------+-----------+------------+-------------------+---------------+--------------+-----------+---------------+---------------+-------------------+------------+-----------------+-------------+-------------------+----------------------------------+---------------------+---------------------+
 * | query                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | db   | full_scan | exec_count | err_count | warn_count | total_latency     | max_latency   | avg_latency  | rows_sent | rows_sent_avg | rows_examined | rows_examined_avg | tmp_tables | tmp_disk_tables | rows_sorted | sort_merge_passes | digest                           | first_seen          | last_seen           |
 * +----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------+-----------+------------+-----------+------------+-------------------+---------------+--------------+-----------+---------------+---------------+-------------------+------------+-----------------+-------------+-------------------+----------------------------------+---------------------+---------------------+
 * | INSERT INTO `mem__quan` . `normalized_statements_by_server_by_schema_data` ( `bytesMax` , `bytesMin` , `bytesTotal` , `collectionDuration` , `createdTmpDiskTables` , `createdTmpTables` , `errorCount` , `execCount` , `execTimeMax` , `execTimeMin` , `execTimeTotal` , `lockTimeTotal` , `noGoodIndexUsedCount` , `noIndexUsedCount` , `rowsExaminedTotal` , `rowsMax` , `rowsMin` , `rowsTotal` , `selectFullJoin` , `selectFullRangeJoin` , `selectRange` , `selectRangeCheck` , `selectScan` , `sortMergePasses` , `sortRange` , `sortRows` , `sortScan` , TIMESTAMP , `warningCount` , `round_robin_bin` , `normalized_statement_by_server_by_schema_id` ) VALUES (...) ON DUPLICATE KEY UPDATE `bytesMax` = IF ( VALUES ( `timestamp` ) >= `timestamp` , VALUES ( `bytesMax` ) , `bytesMax` ) , `bytesMin` = IF ( VALUES ( `timestamp` ) >= `timestamp` , VALUES ( `bytesMin` ) , `bytesMin` ) , `bytesTotal` = IF ( VALUES ( `timestamp` ) >= `timestamp` , VALUES ( `bytesTotal` ) , `bytesTotal` ) , `collectionDuration` = IF ( VALUES ( ... | mem  |           |    7603726 |         0 |          0 | 98469133153813000 |  831617448000 |  12950115000 |         0 |             0 |             0 |                 0 |          0 |               0 |           0 |                 0 | 361bbfa1983c4ec4901cb2237f256138 | 2013-12-04 20:05:34 | 2013-12-18 17:46:35 |
 * | COMMIT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | mem  |           |   23433832 |         0 |          0 | 27348748128106000 | 3692522134000 |   1167062000 |         0 |             0 |             0 |                 0 |          0 |               0 |           0 |                 0 | e51be358a1cbf99c1acab35cc1c6b683 | 2013-12-04 20:04:08 | 2013-12-18 17:47:18 |
 * | INSERT INTO `mem__quan` . `normalized_statements_by_server_by_schema` ( `firstSeen` , `lastSeen` , `normalized_statement_id` , `schema` , SERVER , `id` ) VALUES (...) ON DUPLICATE KEY UPDATE `firstSeen` = COALESCE ( `LEAST` ( `firstSeen` , VALUES ( `firstSeen` ) ) , `firstSeen` ) , `lastSeen` = COALESCE ( `GREATEST` ( `lastSeen` , VALUES ( `lastSeen` ) ) , `lastSeen` )                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | mem  |           |    7602075 |       640 |          0 | 19210969261301000 |  840000846000 |   2527069000 |         0 |             0 |             0 |                 0 |          0 |               0 |           0 |                 0 | 6134e9d6f25eb8e6cddf11f6938f202a | 2013-12-04 20:05:34 | 2013-12-18 17:46:35 |
 * | SELECT `fsstatisti0_` . `fs` AS `col_0_0_` , `fsstatisti0_` . `timestamp` AS `col_0_1_` , `fsstatisti0_` . `free` AS `col_0_2_` , `fsstatisti0_` . `total` AS `col_0_3_` , `fsstatisti0_` . `perSec` AS `col_0_4_` , `fsstatisti0_` . `perSecIntercept` AS `col_0_5_` , `fsstatisti0_` . `perMinute` AS `col_0_6_` , `fsstatisti0_` . `perMinuteIntercept` AS `col_0_7_` , `fsstatisti0_` . `perHour` AS `col_0_8_` , `fsstatisti0_` . `perHourIntercept` AS `col_0_9_` , `fsstatisti0_` . `perDay` AS `col_0_10_` , `fsstatisti0_` . `perDayIntercept` AS `col_0_11_` FROM `mem__instruments` . `FsStatistics` `fsstatisti0_` WHERE ( `fsstatisti0_` . `fs` IN (?) ) AND `fsstatisti0_` . `timestamp` >= ? AND `fsstatisti0_` . `timestamp` <= ? ORDER BY `fsstatisti0_` . `fs` , `fsstatisti0_` . `timestamp`                                                                                                                                                                                                                                          | mem  |           |     160131 |         0 |          0 | 17654951709541000 | 1889823768000 | 110253178000 | 229486238 |          1433 |     229491996 |              1433 |          0 |               0 |           0 |                 0 | 8e87c94dc6567954202c0dbe56e626e8 | 2013-12-04 20:04:54 | 2013-12-18 17:47:05 |
 * | SELECT `blockdevic0_` . `hid` AS `hid1829_0_` , `blockdevic0_` . `id` AS `id2_1829_0_` , `blockdevic0_` . `name` AS `name3_1829_0_` , `blockdevic0_` . `hasName` AS `hasName4_1829_0_` , `blockdevic0_` . `timestamp` AS `timestamp5_1829_0_` , `blockdevic0_` . `os` AS `os6_1829_0_` , `blockdevic0_` . `hasOs` AS `hasOs7_1829_0_` FROM `mem__inventory` . `BlockDevice` `blockdevic0_` WHERE `blockdevic0_` . `hid` = ? FOR UPDATE                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | mem  |           |    1400146 |         0 |          0 |  6800141572899000 | 2007817708000 |   4856737000 |   1400137 |             1 |       1400137 |                 1 |          0 |               0 |           0 |                 0 | ac9fdbb96f5ebdebdaa963251162e6d4 | 2013-12-04 20:04:53 | 2013-12-18 17:47:05 |
 * +----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------+-----------+------------+-----------+------------+-------------------+---------------+--------------+-----------+---------------+---------------+-------------------+------------+-----------------+-------------+-------------------+----------------------------------+---------------------+---------------------+
 * 5 rows in set (0.02 sec)
 *
 * (Example from 5.6.14)
 *
 * Versions: 5.6.9+
 */

DROP VIEW IF EXISTS statement_analysis_raw;

CREATE SQL SECURITY INVOKER VIEW statement_analysis_raw AS
SELECT DIGEST_TEXT AS query,
       SCHEMA_NAME AS db,
       IF(SUM_NO_GOOD_INDEX_USED > 0 OR SUM_NO_INDEX_USED > 0, '*', '') AS full_scan,
       COUNT_STAR AS exec_count,
       SUM_ERRORS AS err_count,
       SUM_WARNINGS AS warn_count,
       SUM_TIMER_WAIT AS total_latency,
       MAX_TIMER_WAIT AS max_latency,
       AVG_TIMER_WAIT AS avg_latency,
       SUM_ROWS_SENT AS rows_sent,
       ROUND(SUM_ROWS_SENT / COUNT_STAR) AS rows_sent_avg,
       SUM_ROWS_EXAMINED AS rows_examined,
       ROUND(SUM_ROWS_EXAMINED / COUNT_STAR)  AS rows_examined_avg,
       SUM_CREATED_TMP_TABLES AS tmp_tables,
       SUM_CREATED_TMP_DISK_TABLES AS tmp_disk_tables,
       SUM_SORT_ROWS AS rows_sorted,
       SUM_SORT_MERGE_PASSES AS sort_merge_passes,
       DIGEST AS digest,
       FIRST_SEEN AS first_seen,
       LAST_SEEN as last_seen
  FROM performance_schema.events_statements_summary_by_digest
ORDER BY SUM_TIMER_WAIT DESC;
