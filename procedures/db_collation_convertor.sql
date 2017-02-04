--  Copyright (c) 2015, Oracle and/or its affiliates. All rights reserved.
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; version 2 of the License.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA

DROP PROCEDURE IF EXISTS db_collation_convertor;

DELIMITER $$

CREATE DEFINER='root'@'localhost' PROCEDURE db_collation_convertor (
	in in_dbname varchar(100), in in_charset varchar(100) , in in_collation varchar(100)
	)
	COMMENT '
		Description
		-----------
		Convert all tables in database to new character set and collation .


		Parameters
		-----------

		in_dbname (varchar(100)):
			The Database name
		
		in_charset (varchar(100)):
			The Character Set name, Example utf8

		in_collation (varchar(100)):
			The Collation name, Example: ut8_persian_ci

		Example
		--------

		mysql> CALL sys.db_collation_covertor(''dbname'',''utf8'',''utf8_persian_ci'');

		Query OK, 0 rows affected (0.00 sec)
            '
BEGIN
	DECLARE finish INT DEFAULT 0;
	DECLARE tab varchar(100);
	DECLARE db_tables CURSOR FOR select table_name from information_schema.tables WHERE table_schema = in_dbname and table_type = 'base table';
	DECLARE continue HANDLER FOR NOT found SET finish = 1;
	IF NOT EXISTS (select COLLATION_NAME , CHARACTER_SET_NAME from information_schema.COLLATION_CHARACTER_SET_APPLICABILITY where COLLATION_NAME = in_collation and CHARACTER_SET_NAME = in_charset) THEN
			SELECT CONCAT('Invalid collation "', in_collation ,'" with character set "', in_charset,'"') AS Summary;
			SET finish = 1;
	END IF;
	OPEN db_tables;
	dbcolconv: LOOP
		FETCH db_tables INTO tab;
		IF finish = 1 THEN
			LEAVE dbcolconv;
		END IF;
		SET @sql = CONCAT('alter table ', tab,' convert to character set ',in_charset,' collate ', in_collation);
		PREPARE stmt FROM @sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	END LOOP;
		CLOSE db_tables;
END; $$
DELIMITER ;
