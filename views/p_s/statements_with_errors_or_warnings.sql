/*
 * View: statements_with_errors_or_warnings
 *
 * List all normalized statements that have raised errors or warnings.
 *
 * mysql> select * from statements_with_errors_or_warnings;
 * +-------------------------------------------------------------------+------------+--------+-----------+----------+-------------+----------------------------------+
 * | query                                                             | exec_count | errors | error_pct | warnings | warning_pct | digest                           |
 * +-------------------------------------------------------------------+------------+--------+-----------+----------+-------------+----------------------------------+
 * | CREATE PROCEDURE currently_ena ... w_instruments BOOLEAN DEFAULT  |          2 |      2 |  100.0000 |        0 |      0.0000 | ad6024cfc2db562ae268b25e65ef27c0 |
 * | CREATE PROCEDURE currently_ena ... ents WHERE enabled = ? ; END   |          2 |      1 |   50.0000 |        0 |      0.0000 | 4aac3ab9521a432ff03313a69cfcc58f |
 * | CREATE PROCEDURE currently_enabled ( BOOLEAN show_instruments     |          1 |      1 |  100.0000 |        0 |      0.0000 | c6df6711da3d1a26bc136dc8b354f6eb |
 * | CREATE PROCEDURE disable_backg ... d = ? WHERE TYPE = ? ; END IF  |          1 |      1 |  100.0000 |        0 |      0.0000 | 12e0392402780424c736c9555bcc9703 |
 * | DROP PROCEDURE IF EXISTS currently_enabled                        |         12 |      0 |    0.0000 |        6 |     50.0000 | 44cc7e655d08f430e0dd8f3110ed816c |
 * | DROP PROCEDURE IF EXISTS disable_background_threads               |          3 |      0 |    0.0000 |        2 |     66.6667 | 0153b7158dae80672bda6181c73f172c |
 * | CREATE SCHEMA IF NOT EXISTS ps_helper                             |          2 |      0 |    0.0000 |        1 |     50.0000 | a12cabd32d1507c758c71478075f5290 |
 * +-------------------------------------------------------------------+------------+--------+-----------+----------+-------------+----------------------------------+
 * 
 * Versions 5.6.5+
 *
 */

DROP VIEW IF EXISTS statements_with_errors_or_warnings;

CREATE SQL SECURITY INVOKER VIEW statements_with_errors_or_warnings AS
SELECT format_statement(DIGEST_TEXT) AS query,
       COUNT_STAR AS exec_count,
       SUM_ERRORS AS errors,
       (SUM_ERRORS / COUNT_STAR) * 100 as error_pct,
       SUM_WARNINGS AS warnings,
       (SUM_WARNINGS / COUNT_STAR) * 100 as warning_pct,
       DIGEST AS digest
  FROM performance_schema.events_statements_summary_by_digest
 WHERE SUM_ERRORS > 0
    OR SUM_WARNINGS > 0
ORDER BY SUM_ERRORS DESC, SUM_WARNINGS DESC;
