dbahelper
=========

A collection of scripts to help MySQL DBAs

There are install files available for 5.5, 5.6 and 5.7 respectively. To load these, you must position yourself within the directory that you downloaded to, as these top level files SOURCE individual files that are shared across versions in most cases (though not all).

For instance if you download to /tmp/dbahelper/ you should:

cd /tmp/dbahelper/
mysql -u user -p < ./ps_helper_<version>.sql

Or if you would like to log in to the client:

cd /tmp/dbahelper/
mysql -u user -p 
SOURCE ./ps_helper_<version>.sql

Alternatively, you could just choose to load individual files based on your needs, but beware, certain objects have dependencies on other objects.
