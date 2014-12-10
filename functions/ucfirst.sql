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
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA */


DROP FUNCTION IF EXISTS ucfirst;

CREATE FUNCTION ucfirst(in_string LONGTEXT charset utf8)
    RETURNS LONGTEXT charset utf8
    COMMENT '
             Description
             -----------

             Takes a string and returns the same string with the first character in upper case
             and the remaining in lower case.

             Parameters
             -----------

             in_string TEXT
               The string to convert

             Returns
             -----------

             TEXT

             Example
             -----------

             mysql> SELECT ucfirst(''YES'');
             +--------------------+
             | sys.ucfirst(''YES'') |
             +--------------------+
             | Yes                |
             +--------------------+
             1 row in set (0.00 sec)
            '
    SQL SECURITY INVOKER
    DETERMINISTIC 
    NO SQL 
  RETURN CONCAT(UPPER(SUBSTRING(in_string, 1, 1)), LOWER(SUBSTRING(in_string, 2)));
