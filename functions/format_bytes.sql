/*
 * Function: format_bytes()
 * 
 * Takes a raw bytes value, and converts it to a human readable form
 *
 * Parameters
 *   bytes: The raw bytes value to convert
 *
 * mysql> select format_bytes(2348723492723746);
 * +--------------------------------+
 * | format_bytes(2348723492723746) |
 * +--------------------------------+
 * | 2.09 PiB                       |
 * +--------------------------------+
 * 1 row in set (0.00 sec)
 * 
 * mysql> select format_bytes(2348723492723);
 * +-----------------------------+
 * | format_bytes(2348723492723) |
 * +-----------------------------+
 * | 2.14 TiB                    |
 * +-----------------------------+
 * 1 row in set (0.00 sec)
 * 
 * mysql> select format_bytes(23487234);
 * +------------------------+
 * | format_bytes(23487234) |
 * +------------------------+
 * | 22.40 MiB              |
 * +------------------------+
 * 1 row in set (0.00 sec)
 */

DROP FUNCTION IF EXISTS format_bytes;

DELIMITER $$

CREATE FUNCTION format_bytes(bytes BIGINT)
  RETURNS VARCHAR(16) DETERMINISTIC
BEGIN
  IF bytes IS NULL THEN RETURN NULL;
  ELSEIF bytes >= 1125899906842624 THEN RETURN CONCAT(ROUND(bytes / 1125899906842624, 2), ' PiB');
  ELSEIF bytes >= 1099511627776 THEN RETURN CONCAT(ROUND(bytes / 1099511627776, 2), ' TiB');
  ELSEIF bytes >= 1073741824 THEN RETURN CONCAT(ROUND(bytes / 1073741824, 2), ' GiB');
  ELSEIF bytes >= 1048576 THEN RETURN CONCAT(ROUND(bytes / 1048576, 2), ' MiB');
  ELSEIF bytes >= 1024 THEN RETURN CONCAT(ROUND(bytes / 1024, 2), ' KiB');
  ELSE RETURN CONCAT(bytes, ' bytes');
  END IF;
END $$

DELIMITER ;
