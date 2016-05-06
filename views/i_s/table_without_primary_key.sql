-- Copyright (c) 2016, Oracle and/or its affiliates. All rights reserved.
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
-- Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA

--
-- View: table_without_primary_key
--
-- Tables that don't have a Primary Key.
-- Note that, for InnoDB tables, this does not necessarily mean that a clustered index is automatically generated.
--
-- mysql> SELECT * FROM table_without_primary_key WHERE table_schema = 'test' LIMIT 3;
--          +--------------+------------+--------+
--          | table_schema | table_name | engine |
--          +--------------+------------+--------+
--          | test         | t          | InnoDB |
--          | test         | user_ax    | InnoDB |
--          | test         | user_bd    | InnoDB |
--          +--------------+------------+--------+
--          3 rows in set (0.05 sec)
--

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER
VIEW table_without_primary_key (
  table_schema,
  table_name,
  engine
) AS
SELECT
    t.TABLE_SCHEMA, t.TABLE_NAME, t.ENGINE
  FROM information_schema.COLUMNS c
  RIGHT JOIN information_schema.TABLES t
    ON t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME AND c.COLUMN_KEY = 'PRI'
  WHERE
    c.COLUMN_NAME IS NULL;
