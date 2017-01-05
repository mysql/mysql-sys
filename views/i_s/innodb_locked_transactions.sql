-- 
-- Locked transactions, the locks they are waiting on and the transactions holding those locks.
-- 
CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER
VIEW innodb_locked_transactions AS
  SELECT 
    locked_transaction.trx_id AS locked_trx_id,
    locked_transaction.trx_started AS locked_trx_started,
    locked_transaction.trx_wait_started AS locked_trx_wait_started,
    locked_transaction.trx_mysql_thread_id AS locked_trx_mysql_thread_id,
    locked_transaction.trx_query AS locked_trx_query,
    INNODB_LOCK_WAITS.requested_lock_id,
    INNODB_LOCK_WAITS.blocking_lock_id,
    locking_transaction.trx_id AS locking_trx_id,
    locking_transaction.trx_started AS locking_trx_started,
    locking_transaction.trx_wait_started AS locking_trx_wait_started,
    locking_transaction.trx_mysql_thread_id AS locking_trx_mysql_thread_id,
    locking_transaction.trx_query AS locking_trx_query,
    TIMESTAMPDIFF(SECOND, locked_transaction.trx_wait_started, NOW()) as trx_wait_seconds,
    CONCAT('KILL QUERY ', locking_transaction.trx_mysql_thread_id) AS sql_kill_blocking_query,
    CONCAT('KILL ', locking_transaction.trx_mysql_thread_id) AS sql_kill_blocking_connection    
  FROM 
    INFORMATION_SCHEMA.INNODB_TRX AS locked_transaction
    JOIN INFORMATION_SCHEMA.INNODB_LOCK_WAITS ON (locked_transaction.trx_id = INNODB_LOCK_WAITS.requesting_trx_id)
    JOIN INFORMATION_SCHEMA.INNODB_TRX AS locking_transaction ON (locking_transaction.trx_id = INNODB_LOCK_WAITS.blocking_trx_id)
  WHERE
    locking_transaction.trx_mysql_thread_id != CONNECTION_ID()
;
