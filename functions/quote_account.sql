DROP FUNCTION IF EXISTS quote_account;

DELIMITER $$

CREATE DEFINER='root'@'localhost' FUNCTION quote_account (
        in_user varchar(32) CHARACTER SET UTF8,
        in_host varchar(60) CHARACTER SET UTF8
    )
    RETURNS VARCHAR(200)
    COMMENT '
             Description
             -----------

             Returns a quoted MySQL account, in the form `username`@`host`.
             The quote char and the escape char are both ` (ASCII 96).
             If one of the parameters is NULL, NULL is returned.

             This function can be used to compose prepared statements when table or column names are not known in advance.


             Parameters
             -----------

             in_user (varchar(32) CHARACTER SET UTF8):
               First part of FQN.
             in_host (varchar(60) CHARACTER SET UTF8):
               Second part of the FQN.


             Example
             --------

             mysql> SELECT sys.quote_account(''root'', ''localhost'');
             +----------------------------------------+
             | sys.quote_account(''root'', ''localhost'') |
             +----------------------------------------+
             | `root`@`localhost`                     |
             +----------------------------------------+
             1 row in set (0.00 sec)

            '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    CONTAINS SQL
BEGIN
    RETURN CONCAT(
      '`', REPLACE(in_user, '`', '``'), '`',
      '@',
      '`', REPLACE(in_host, '`', '``'), '`'
    );
END$$

DELIMITER ;
