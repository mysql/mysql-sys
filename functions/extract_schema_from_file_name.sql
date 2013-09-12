/*
 * Function: extract_schema_from_file_name()
 * 
 * Takes a raw file path, and extracts the schema name from it
 *
 * Parameters
 *   path: The raw file name value to extract the schema name from
 */

DROP FUNCTION IF EXISTS extract_schema_from_file_name;

DELIMITER $$

CREATE FUNCTION extract_schema_from_file_name(path VARCHAR(512))
  RETURNS VARCHAR(512) DETERMINISTIC
  RETURN SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(path, '\\', '/'), '/', -2), '/', 1)
$$

DELIMITER ;