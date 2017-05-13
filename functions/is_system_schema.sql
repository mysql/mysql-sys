-- Copyright (c) 2015, Oracle and/or its affiliates. All rights reserved.
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; version 2 of the License.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA

DROP FUNCTION IF EXISTS is_system_schema;

DELIMITER $$

CREATE DEFINER='root'@'localhost' FUNCTION is_system_schema(
        in_schema TEXT
    )
    RETURNS BOOLEAN
    COMMENT '
             Description
             -----------

             Takes a schema name and returns TRUE if this is considered a system schema

             Useful for excluding systems schema in information_schema queries

             Parameters
             -----------

             in_schema (TEXT):
               The schema name to check

             Returns
             -----------

             BOOLEAN

             Example
             --------

             mysql> select schema_name, sys.is_system_schema(SCHEMA_NAME) from information_schema.schemata;
             +--------------------+-----------------------------------+
             | schema_name        | sys.is_system_schema(SCHEMA_NAME) |
             +--------------------+-----------------------------------+
             | information_schema |                                 1 |
             | mysql              |                                 1 |
             | performance_schema |                                 1 |
             | sys                |                                 1 |
             | test               |                                 0 |
             +--------------------+-----------------------------------+
             5 rows in set (0.00 sec)

            '
    SQL SECURITY INVOKER
    DETERMINISTIC
    CONTAINS SQL
BEGIN

    IF (in_schema IN (
        'mysql',
        'information_schema',
        'performance_schema',
        'sys',
        'ndbinfo',                         -- MySQL Cluster / NDB
        'innodb_memcache',                 -- InnoDB Memcache Plugin
        'mysql_innodb_cluster_metadata',   -- InnoDB Cluster
        'query_rewrite'                    -- Query Rewrite Plugin
    )) THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;

END$$

DELIMITER ;
