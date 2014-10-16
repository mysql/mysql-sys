#!/bin/bash
#  Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; version 2 of the License.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA

OS=`uname`

# Grab the current sys version
SYSVERSIONTMP=`cat ./before_setup.sql | grep sys_version | awk '{print $8}'`
SYSVERSION=`echo "${SYSVERSIONTMP//\'}"`

MYSQLUSER="'root'@'localhost'"

USAGE="
Options:
================

    v: The version of MySQL to build the sys schema for, either '56' or '57'

    b: Whether to omit any lines that deal with sql_log_bin (useful for RDS)

    u: The user to set as the owner of the objects (useful for RDS)

Examples:
================

Generate a MySQL 5.7 SQL file that uses the 'mark'@'localhost' user:

    $0 -v 57 -u \"'mark'@'localhost'\"

Generate a MySQL 5.6 SQL file for RDS:

    $0 -v 56 -b -u CURRENT_USER
"

# Grab options
while getopts ":v:hbu:" opt; do
  case $opt in
    b)
      SKIPBINLOG=true
      ;;
    h)
      echo $"$USAGE"
      exit 0
      ;;
    u)
      MYSQLUSER="${OPTARG}"
      ;;
    v)
      if [ $OPTARG == "56" ] || [ $OPTARG == "57" ] ;
      then
        MYSQLVERSION=$OPTARG
      else
      	echo "Invalid -v option, please run again with either '-v 56' or '-v 57'"
      	exit 1
      fi
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo $"$USAGE"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      echo $"$USAGE"
      exit 1
      ;;
  esac
done

# Check required options
if [[ -z "$MYSQLVERSION" ]] ;
then
  echo "  -v (MySQL Version) parameter required, please run again with either '-v 56' or '-v 57'"
  exit 1
fi

# Create output file name
OUTPUTFILE="sys_${SYSVERSION}_${MYSQLVERSION}_inline.sql"

# Create the initial output file
if [ $OS == "Darwin" ] ;
then
  cat "./sys_$MYSQLVERSION.sql" | tr -d '\r' | grep 'SOURCE' | sed -E 's .{8}  ' | sed 's/^/./' | \
      xargs sed -e "s/'root'@'localhost'/$MYSQLUSER/g" > "temp_${OUTPUTFILE}"
else
  cat "./sys_$MYSQLVERSION.sql" | tr -d '\r' | grep 'SOURCE' | sed -r 's .{8}  ' | sed 's/^/./' | \
      xargs sed -e "s/'root'@'localhost'/$MYSQLUSER/g" > "temp_${OUTPUTFILE}"
fi

# Strip copyrights, retaining the first one
head -n 15 "temp_${OUTPUTFILE}" > $OUTPUTFILE
sed -e '/Copyright/,/51 Franklin St/d' "temp_${OUTPUTFILE}" >> $OUTPUTFILE
rm "temp_${OUTPUTFILE}"

# Check if sql_log_bin lines should be removed
if [[ ! -z "$SKIPBINLOG" ]] ;
then
  sed -e "/sql_log_bin/d" $OUTPUTFILE > "temp_${OUTPUTFILE}"
  mv "temp_${OUTPUTFILE}" $OUTPUTFILE
  SKIPBINLOG="disabled"
else
  SKIPBINLOG="enabled"
fi

# Print summary
echo $"
       Wrote: $OUTPUTFILE
        User: $MYSQLUSER
 sql_log_bin: $SKIPBINLOG
 "
