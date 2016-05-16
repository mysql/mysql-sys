DROP FUNCTION IF EXISTS is_valid_name;

DELIMITER $$

CREATE DEFINER='root'@'localhost' PROCEDURE is_valid_name (
        IN in_name varchar(64) CHARACTER SET UTF8,
        OUT out_ret BOOL
    )
    COMMENT '
             Description
             -----------

             Returns weather the passed string is a valid name in current MySQL version.


             Parameters
             -----------

             in_name (varchar(64) CHARACTER SET UTF8):
               The string to test.
             out_ret (bool)
               Return value.


             Example
             --------

             mysql> CALL sys.is_valid_name(''valid_name'', @x);
             Query OK, 0 rows affected (0.00 sec)

             mysql> CALL sys.is_valid_name(''select'', @y);
             Query OK, 0 rows affected (0.00 sec)

             mysql> SELECT @x, @y;
             +------+------+
             | @x   | @y   |
             +------+------+
             |    1 |    0 |
             +------+------+
             1 row in set (0.00 sec)

            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    CONTAINS SQL
BEGIN
    -- error in query occurs if in_name is not a valid alias
    DECLARE EXIT HANDLER
      FOR 1064
    BEGIN
      SET out_ret = FALSE;
    END;

    SET @sql_query = CONCAT('DO (SELECT 0 AS ', `in_name`, ');');
    PREPARE stmt FROM @sql_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
 
    SET out_ret = TRUE;
END$$

DELIMITER ;
