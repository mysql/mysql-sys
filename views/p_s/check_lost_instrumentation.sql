/*
 * View: check_lost_instrumentation
 * 
 * Used to check whether Performance Schema is not able to monitor
 * all runtime data - only returns variables that have lost instruments
 *
 * Versions: 5.5+
 */

DROP VIEW IF EXISTS check_lost_instrumentation;

CREATE SQL SECURITY INVOKER VIEW check_lost_instrumentation AS
SELECT variable_name, variable_value
  FROM information_schema.global_status
 WHERE variable_name LIKE 'perf%lost'
   AND variable_value > 0;
