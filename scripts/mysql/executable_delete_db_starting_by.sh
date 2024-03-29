#!/usr/bin/env bash

set -euo pipefail

source "$DOTFILES_PATH/scripts_helper.sh"

##? Delete all mysql databses starting by
#?? 1.0.0
##?
##? Usage:
##?   delete_db_starting_by <preffix_to_delete>
docs_parse "$@"

mysql -uroot -N -B -e "SELECT CONCAT('DROP DATABASE ', SCHEMA_NAME, ';') AS QUERY FROM information_schema.SCHEMATA WHERE SCHEMA_NAME LIKE '$1%';" | while read line; do
  echo "Executing $line"
  mysql -uroot -e "$line"
done
