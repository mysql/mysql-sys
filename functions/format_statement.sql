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
