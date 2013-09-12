/*
 * Function: extract_table_from_file_name()
 * 
 * Takes a raw file path, and extracts the table name from it
 *
 * Parameters
 *   path: The raw file name value to extract the table name from
 */

DROP FUNCTION IF EXISTS extract_table_from_file_name;

DELIMITER $$

CREATE FUNCTION extract_table_from_file_name(path VARCHAR(512))
  RETURNS VARCHAR(512) DETERMINISTIC
  RETURN SUBSTRING_INDEX(REPLACE(SUBSTRING_INDEX(REPLACE(path, '\\', '/'), '/', -1), '@0024', '$'), '.', 1);
$$

DELIMITER ;
