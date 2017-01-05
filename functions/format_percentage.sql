-- Copyright (c) 2014, 2015, Oracle and/or its affiliates. All rights reserved.
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; version 2 of the License.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA

DROP FUNCTION IF EXISTS format_percentage;

DELIMITER $$

CREATE DEFINER='root'@'localhost' FUNCTION format_percentage (
        -- We feed in and return TEXT here, as aggregates of
        -- picoseconds can return numbers larger than BIGINT UNSIGNED
        percentage TEXT
    )
    RETURNS TEXT CHARSET UTF8
    COMMENT '
             Description
             -----------

             Takes a raw value between 0 and 1, and converts it to a human 
             readable percentage formatted to two decimal places.
             
             Parameters
             -----------

             percentage (TEXT): 
               The raw percentage to format.

             Returns
             -----------

             TEXT

             Example
             -----------

             mysql> select format_percentage(0.99921);
             +----------------------------+
             | format_percentage(0.99921) |
             +----------------------------+
             | 99.92 %                    |
             +----------------------------+
             1 row in set (0.01 sec)

             mysql> select format_percentage(0.012);
             +--------------------------+
             | format_percentage(0.012) |
             +--------------------------+
             | 1.20 %                   |
             +--------------------------+
             1 row in set (0.00 sec)

             mysql> select format_percentage(0);
             +----------------------+
             | format_percentage(0) |
             +----------------------+
             | 0.00 %               |
             +----------------------+
             1 row in set (0.00 sec)
             
             mysql> select format_percentage(1);
             +----------------------+
             | format_percentage(1) |
             +----------------------+
             | 100.00 %             |
             +----------------------+
             1 row in set (0.00 sec)
                         '
    SQL SECURITY INVOKER
    DETERMINISTIC
    NO SQL
    BEGIN
     RETURN CONCAT(ROUND(100 * (percentage), 2), ' %');
  END$$

DELIMITER ;
