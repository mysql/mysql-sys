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

DROP PROCEDURE IF EXISTS sys_get_config;

DELIMITER $$

CREATE DEFINER='root'@'localhost' PROCEDURE sys_get_config (
        IN in_variable_name VARCHAR(128),
        IN in_default_value VARCHAR(128)
    )
    COMMENT '
             Description
             -----------

             Gets the value for the requested variable using the following logic:

                1. If the option exists in sys.sys_config return the value from there.
                2. Else fall back on the provided default value.
             
             This will overwrite any existing value already stored in the corresponding user variable.

             Parameters
             -----------

             in_variable_name (VARCHAR(128)):
               The name of the config option to return the value for.

             in_default_value (VARCHAR(128)):
               The default value to return if neither a use variable exists nor the variable exists
               in sys.sys_config.

             Example
             -----------

             mysql> CALL sys.sys_get_config(''sys.statement_truncate_len'', 128);
             Query OK, 0 rows affected (0.00 sec)

             mysql> SELECT @sys.statement_truncate_len;
             +-----------------------------+
             | @sys.statement_truncate_len |
             +-----------------------------+
             | 64                          |
             +-----------------------------+
             1 row in set (0.01 sec)

            '
    SQL SECURITY INVOKER
    DETERMINISTIC
    NO SQL
BEGIN
    /* Check if we have the variable in the sys.sys_config table */
    SET @sys.sys_get_config_tmp_value = (SELECT value FROM sys.sys_config WHERE variable = in_variable_name);
  
    /* Protection against the variable not existing in sys_config */
    IF (@sys.sys_get_config_tmp_value IS NULL) THEN
        SET @sys.sys_get_config_tmp_value = in_default_value;
    END IF;

    /* Set the user variable */
    SET @SQL = CONCAT('SET @', in_variable_name, ' = @sys.sys_get_config_tmp_value');
    PREPARE stmt_user_var FROM @SQL;
    EXECUTE stmt_user_var;
    DEALLOCATE PREPARE stmt_user_var;
END $$

DELIMITER ;
