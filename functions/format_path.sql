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
