DROP FUNCTION IF EXISTS quote_name;

DELIMITER $$

CREATE DEFINER='root'@'localhost' FUNCTION quote_name (
        in_name varchar(64) CHARACTER SET UTF8
    )
    RETURNS VARCHAR(70)
    COMMENT '
             Description
             -----------

             Returns the given string as a quoted MySQL identifier.
             The quote char and the escape char are both ` (ASCII 96).
             If in_name is NULL, NULL is returned.

             This function can be used to compose prepared statements when table or column names are not known in advance.


             Parameters
             -----------

             in_name (varchar(64) CHARACTER SET UTF8):
               The name to quote.


             Example
             --------

             mysql> SELECT sys.quote_name(''my_table''), sys.quote_name(''my`table'');
             +----------------------------+----------------------------+
             | sys.quote_name(''my_table'') | sys.quote_name(''my`table'') |
             +----------------------------+----------------------------+
             | `my_table`                 | `my``table`                |
             +----------------------------+----------------------------+
             1 row in set (0.00 sec)
            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    CONTAINS SQL
BEGIN
    RETURN CONCAT('`', REPLACE(in_name, '`', '``'), '`');
END$$

DELIMITER ;
