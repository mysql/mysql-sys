# The MySQL sys schema

A collection of views, functions and procedures to help MySQL administrators get insight in to MySQL Database usage.

There are install files available for 5.6 and 5.7 respectively. To load these, you must position yourself within the directory that you downloaded to, as these top level files SOURCE individual files that are shared across versions in most cases (though not all).

## Installation

The objects should all be created as the root user (but run with the privileges of the invoker).

For instance if you download to /tmp/mysql-sys/, and want to install the 5.6 version you should:

    cd /tmp/mysql-sys/
    mysql -u root -p < ./sys_56.sql

Or if you would like to log in to the client, and install the 5.7 version:

    cd /tmp/mysql-sys/
    mysql -u root -p 
    SOURCE ./sys_57.sql

Alternatively, you could just choose to load individual files based on your needs, but beware, certain objects have dependencies on other objects. You will need to ensure that these are also loaded.

## Overview of objects

### Procedures

#### create_synonym_db

##### Description

Takes a source database name and synonym name, and then creates the synonym database with views that point to all of the tables within the source database.

Useful for creating a "ps" synonym for "performance_schema", or "is" instead of "information_schema", for example.

##### Parameters

* in_db_name (VARCHAR(64)):
** The database name that you would like to create a synonym for.
* in_synonym (VARCHAR(64)):
** The database synonym name.

##### Example

             mysql> SHOW DATABASES;
             +--------------------+
             | Database           |
             +--------------------+
             | information_schema |
             | mysql              |
             | performance_schema |
             | sys                |
             | test               |
             +--------------------+
             5 rows in set (0.00 sec)

             mysql> CALL sys.create_synonym_db('performance_schema', 'ps');
             +-------------------------------------+
             | summary                             |
             +-------------------------------------+
             | Created 74 views in the ps database |
             +-------------------------------------+
             1 row in set (8.57 sec)

             Query OK, 0 rows affected (8.57 sec)

             mysql> SHOW DATABASES;
             +--------------------+
             | Database           |
             +--------------------+
             | information_schema |
             | mysql              |
             | performance_schema |
             | ps                 |
             | sys                |
             | test               |
             +--------------------+
             6 rows in set (0.00 sec)

             mysql> SHOW FULL TABLES FROM ps;
             +------------------------------------------------------+------------+
             | Tables_in_ps                                         | Table_type |
             +------------------------------------------------------+------------+
             | accounts                                             | VIEW       |
             | cond_instances                                       | VIEW       |
             | events_stages_current                                | VIEW       |
             | events_stages_history                                | VIEW       |
             ...
            

#### ps_setup_disable_background_threads

##### Description

Disable all background thread instrumentation within Performance Schema.

Requires the SUPER privilege for "SET sql_log_bin = 0;".

##### Parameters

None.

##### Example

             mysql> CALL sys.ps_setup_disable_background_threads();
             +--------------------------------+
             | summary                        |
             +--------------------------------+
             | Disabled 18 background threads |
             +--------------------------------+
             1 row in set (0.00 sec)