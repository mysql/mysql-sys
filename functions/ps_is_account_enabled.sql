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
 * Function: ps_is_account_enabled()
 * 
 * Determines whether instrumentation of an account is enabled.
 *
 * Parameters
 *   in_host .....: The hostname of the account to check.
 *   in_user .....: The username of the account to check.
 *   
 * Returns
 *   An enum whether the account is enabled or not.
 *
 * mysql> SELECT ps_is_account_enabled('localhost', 'root');
 * +-----------------------------------------+
 * | ps_is_account_enabled('localhost', 'root') |
 * +-----------------------------------------+
 * | YES                                     |
 * +-----------------------------------------+
 * 1 row in set (0.00 sec)
 *
 * Contributed by Jesper Krogh of MySQL Support @ Oracle
 */

DROP FUNCTION IF EXISTS ps_is_account_enabled;

DELIMITER $$

CREATE DEFINER='root'@'localhost' FUNCTION ps_is_account_enabled (
        in_host VARCHAR(60), 
        in_user VARCHAR(16)
    ) 
    RETURNS enum('YES', 'NO', 'PARTIAL')
    COMMENT 'Returns whether a user account is enabled within Performance Schema.'
    LANGUAGE SQL
    DETERMINISTIC 
    READS SQL DATA 
    SQL SECURITY INVOKER
BEGIN
    

    RETURN IF(EXISTS(SELECT 1
                       FROM performance_schema.setup_actors
                      WHERE (`HOST` = '%' OR in_host LIKE `HOST`)
                        AND (`USER` = '%' OR `USER` = in_user)
                    ),
              'YES', 'NO'
           );
END $$

DELIMITER ;