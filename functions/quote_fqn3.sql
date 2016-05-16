DROP FUNCTION IF EXISTS quote_fqn3;

DELIMITER $$

CREATE DEFINER='root'@'localhost' FUNCTION quote_fqn3 (
        in_name1 varchar(64) CHARACTER SET UTF8,
        in_name2 varchar(64) CHARACTER SET UTF8,
        in_name3 varchar(64) CHARACTER SET UTF8
    )
    RETURNS VARCHAR(200)
    COMMENT '
             Description
             -----------

             Returns a quoted MySQL FQN, in the form `db_name`.`tab_name`.`col_name`.
             The quote char and the escape char are both ` (ASCII 96).
             If one of the parameters is NULL, NULL is returned.

             This function can be used to compose prepared statements when table or column names are not known in advance.


             Parameters
             -----------

             in_name1 (varchar(64) CHARACTER SET UTF8):
               First part of FQN.
             in_name2 (varchar(64) CHARACTER SET UTF8):
               Second part of the FQN.
             in_name3 (varchar(64) CHARACTER SET UTF8):
               Third part of the FQN.


             Example
             --------

             mysql> SELECT sys.quote_fqn3(''my_db'', ''my_table'', ''my_col'');
             +-----------------------------------------------+
             | sys.quote_fqn3(''my_db'', ''my_table'', ''my_col'') |
             +-----------------------------------------------+
             | `my_db`.`my_table`.`my_col`                   |
             +-----------------------------------------------+
             1 row in set (0.00 sec)

            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    CONTAINS SQL
BEGIN
    RETURN CONCAT(
      '`', REPLACE(in_name1, '`', '``'), '`',
      '.',
      '`', REPLACE(in_name2, '`', '``'), '`',
      '.',
      '`', REPLACE(in_name3, '`', '``'), '`'
    );
END$$

DELIMITER ;
