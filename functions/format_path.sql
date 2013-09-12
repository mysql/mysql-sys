/*
 * Function: format_path()
 * 
 * Takes a raw path value, and strips out the datadir or tmpdir
 * replacing with @@datadir and @@tmpdir respectively. 
 *
 * Also normalizes the paths across operating systems, so backslashes
 * on Windows are converted to forward slashes
 *
 * Parameters
 *   path: The raw file path value to format
 *
 * mysql> select @@datadir;
 * +-----------------------------------------------+
 * | @@datadir                                     |
 * +-----------------------------------------------+
 * | /Users/mark/sandboxes/SmallTree/AMaster/data/ |
 * +-----------------------------------------------+
 * 1 row in set (0.06 sec)
 * 
 * mysql> select format_path('/Users/mark/sandboxes/SmallTree/AMaster/data/mysql/proc.MYD');
 * +----------------------------------------------------------------------------+
 * | format_path('/Users/mark/sandboxes/SmallTree/AMaster/data/mysql/proc.MYD') |
 * +----------------------------------------------------------------------------+
 * | @@datadir/mysql/proc.MYD                                                   |
 * +----------------------------------------------------------------------------+
 * 1 row in set (0.03 sec)
 */

DROP FUNCTION IF EXISTS format_path;

DELIMITER $$

CREATE FUNCTION format_path(path VARCHAR(260))
  RETURNS VARCHAR(260) CHARSET UTF8 DETERMINISTIC
BEGIN
  DECLARE v_path VARCHAR(260);

  /* OSX hides /private/ in variables, but Performance Schema does not */
  IF path LIKE '/private/%' 
    THEN SET v_path = REPLACE(path, '/private', '');
    ELSE SET v_path = path;
  END IF;

  IF v_path IS NULL THEN RETURN NULL;
  ELSEIF v_path LIKE CONCAT(@@global.datadir, '%') ESCAPE '|' THEN 
    RETURN REPLACE(REPLACE(REPLACE(v_path, @@global.datadir, '@@datadir/'), '\\\\', ''), '\\', '/');
  ELSEIF v_path LIKE CONCAT(@@global.tmpdir, '%') ESCAPE '|' THEN 
    RETURN REPLACE(REPLACE(REPLACE(v_path, @@global.tmpdir, '@@tmpdir/'), '\\\\', ''), '\\', '/');
  ELSE RETURN v_path;
  END IF;
END$$

DELIMITER ;
