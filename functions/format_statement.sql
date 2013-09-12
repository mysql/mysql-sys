/*
 * Function: format_statement()
 * 
 * Formats a normalized statement with a truncated string if > 64 characters long
 *
 * Parameters
 *   filename: The raw file name value to extract the table name from
 */

DROP FUNCTION IF EXISTS format_statement;

DELIMITER $$

CREATE FUNCTION format_statement(statement LONGTEXT)
  RETURNS VARCHAR(65) DETERMINISTIC
BEGIN
  IF LENGTH(statement) > 64 THEN RETURN REPLACE(CONCAT(LEFT(statement, 30), ' ... ', RIGHT(statement, 30)), '\n', ' ');
  ELSE RETURN REPLACE(statement, '\n', ' ');
  END IF;
END $$

DELIMITER ;
