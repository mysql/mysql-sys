/*
 * Function: format_time()
 * 
 * Takes a raw picoseconds value, and converts it to a human readable form.
 * Picoseconds are the precision that all latency values are printed in 
 * within MySQL's Performance Schema.
 *
 * Parameters
 *   picoseconds: The raw picoseconds value to convert
 *
 * mysql> select format_time(342342342342345);
 * +------------------------------+
 * | format_time(342342342342345) |
 * +------------------------------+
 * | 00:05:42                     |
 * +------------------------------+
 * 1 row in set (0.00 sec)
 * 
 * mysql> select format_time(342342342);
 * +------------------------+
 * | format_time(342342342) |
 * +------------------------+
 * | 342.34 µs              |
 * +------------------------+
 * 1 row in set (0.00 sec)
 * 
 * mysql> select format_time(34234);
 * +--------------------+
 * | format_time(34234) |
 * +--------------------+
 * | 34.23 ns           |
 * +--------------------+
 * 1 row in set (0.00 sec)
 * 
 * mysql> select format_time(342);
 * +------------------+
 * | format_time(342) |
 * +------------------+
 * | 342 ps           |
 * +------------------+
 * 1 row in set (0.00 sec)
 */

DROP FUNCTION IF EXISTS format_time;

DELIMITER $$

CREATE FUNCTION format_time(picoseconds BIGINT UNSIGNED)
  RETURNS VARCHAR(16) CHARSET UTF8 DETERMINISTIC
BEGIN
  IF picoseconds IS NULL THEN RETURN NULL;
  ELSEIF picoseconds >= 3600000000000000 THEN RETURN CONCAT(ROUND(picoseconds / 3600000000000000, 2), 'h');
  ELSEIF picoseconds >= 60000000000000 THEN RETURN SEC_TO_TIME(ROUND(picoseconds / 1000000000000, 2));
  ELSEIF picoseconds >= 1000000000000 THEN RETURN CONCAT(ROUND(picoseconds / 1000000000000, 2), ' s');
  ELSEIF picoseconds >= 1000000000 THEN RETURN CONCAT(ROUND(picoseconds / 1000000000, 2), ' ms');
  ELSEIF picoseconds >= 1000000 THEN RETURN CONCAT(ROUND(picoseconds / 1000000, 2), ' us');
  ELSEIF picoseconds >= 1000 THEN RETURN CONCAT(ROUND(picoseconds / 1000, 2), ' ns');
  ELSE RETURN CONCAT(picoseconds, ' ps');
  END IF;
END $$

DELIMITER ;
