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
 * Function: extract_table_from_file_name()
 * 
 * Takes a raw file path, and attempts to extract the table name from it
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
