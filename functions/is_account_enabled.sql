/*
 * Function: is_account_enabled()
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
 * mysql> SELECT is_account_enabled('localhost', 'root');
 * +-----------------------------------------+
 * | is_account_enabled('localhost', 'root') |
 * +-----------------------------------------+
 * | YES                                     |
 * +-----------------------------------------+
 * 1 row in set (0.00 sec)
 *
 * Contributed by Jesper Krogh of MySQL Support @ Oracle
 */

DROP FUNCTION IF EXISTS is_account_enabled;

DELIMITER $$

CREATE DEFINER='root'@'localhost' FUNCTION is_account_enabled(in_host VARCHAR(60), in_user VARCHAR(16)) RETURNS enum('YES','NO', 'PARTIAL')
  COMMENT 'Returns whether a user account is enabled.'
  LANGUAGE SQL
  DETERMINISTIC 
  READS SQL DATA 
  SQL SECURITY INVOKER
BEGIN
    RETURN IF(EXISTS(SELECT 1
                       FROM performance_schema.setup_actors
                      WHERE     (`HOST` = '%' OR `HOST` = in_host)
                            AND (`USER` = '%' OR `USER` = in_user)
                    ),
              'YES', 'NO'
           );
END $$

DELIMITER ;