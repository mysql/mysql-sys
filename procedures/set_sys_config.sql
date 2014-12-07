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

DROP PROCEDURE IF EXISTS set_sys_config;

DELIMITER $$

CREATE DEFINER='root'@'localhost' PROCEDURE set_sys_config (
        IN in_variable_name VARCHAR(128),
        IN in_default_value VARCHAR(128)
    )
    COMMENT '
             Description
             -----------

             Sets the value for the requested variable using the following logic:

                1. If a user variable with the name exists, then return that as the value.
                2. Otherwise if the option exists in sys.sys_config return the value from there.
                3. Else fall back on the provided default value.

             Parameters
             -----------

             in_variable_name (VARCHAR(128)):
               The name of the config option to return the value for.

             in_default_value (VARCHAR(128)):
               The default value to return if neither a use variable exists nor the variable exists
               in sys.sys_config.

             Example
             -----------

             mysql> CALL sys.set_sys_config(''statement_truncate_len'', 128);
             Query OK, 0 rows affected (0.00 sec)

             mysql> SELECT @statement_truncate_len;
             +-------------------------+
             | @statement_truncate_len |
             +-------------------------+
             | 64                      |
             +-------------------------+
             1 row in set (0.01 sec)

            '
    SQL SECURITY INVOKER
    DETERMINISTIC
    NO SQL
BEGIN
   DECLARE v_value VARCHAR(128) DEFAULT NULL;
   DECLARE v_has_ps_user_vars BOOLEAN DEFAULT FALSE;

   SET v_has_ps_user_vars = EXISTS(SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'performance_schema' AND TABLE_NAME = 'user_variables_by_thread');
   
   /* Check if a user variable has been set */
   IF (v_has_ps_user_vars) THEN
      SET v_value = (SELECT VARIABLE_VALUE FROM performance_schema.user_variables_by_thread WHERE THREAD_ID = sys.ps_thread_id(CONNECTION_ID()) AND VARIABLE_NAME = in_variable_name);
   ELSE
      SET @SQL = CONCAT('SELECT @', in_variable_name, ' INTO @sys.tmp');
      PREPARE stmt_user_var FROM @SQL;
      EXECUTE stmt_user_var;
      DEALLOCATE PREPARE stmt_user_var;
      SET v_value = @sys.tmp;
   END IF;

   /* Check if we have the variable in the sys.sys_config table, if not, init it */
   IF (v_value IS NULL) THEN
      SET v_value = (SELECT value FROM sys.sys_config WHERE variable = in_variable_name);
   END IF;
  
   /* Protection against the variable not existing in sys_config */
   IF (v_value IS NULL) THEN
      SET v_value = in_default_value;
   END IF;

   /* Set the user variable */
   SET @sys.tmp = v_value;
   SET @SQL = CONCAT('SET @', in_variable_name, ' = @sys.tmp');
   PREPARE stmt_user_var FROM @SQL;
   EXECUTE stmt_user_var;
   DEALLOCATE PREPARE stmt_user_var;
END $$

DELIMITER ;
