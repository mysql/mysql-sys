# The MySQL sys schema

A collection of views, functions and procedures to help MySQL administrators get insight in to MySQL Database usage.

There are install files available for 5.6 and 5.7 respectively. To load these, you must position yourself within the directory that you downloaded to, as these top level files SOURCE individual files that are shared across versions in most cases (though not all).

The objects should all be created as the root user (but run with the privileges of the invoker).

For instance if you download to /tmp/mysql-sys/, and want to install the 5.6 version you should:

    cd /tmp/mysql-sys/
    mysql -u root -p < ./sys_56.sql

Or if you would like to log in to the client, and install the 5.7 version:

    cd /tmp/mysql-sys/
    mysql -u root -p 
    SOURCE ./sys_57.sql

Alternatively, you could just choose to load individual files based on your needs, but beware, certain objects have dependencies on other objects. You will need to ensure that these are also loaded.
