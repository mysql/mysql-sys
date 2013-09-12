SET NAMES utf8;
SET @sql_log_bin = @@sql_log_bin;
SET sql_log_bin = 0;

CREATE DATABASE IF NOT EXISTS ps_helper DEFAULT CHARACTER SET utf8;

USE ps_helper;

CREATE OR REPLACE VIEW version AS SELECT '2.0.0';