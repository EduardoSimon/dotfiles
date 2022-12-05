#!/usr/bin/env bash

set -euo pipefail

source "$DOTFILES_PATH/scripts_helper.sh"

##? Prints the owner for a port
#?? 1.0.0
##?
##? Usage:
##?   port_owner <port>
docs_parse "$@"

lsof -n -i4TCP:$port | grep LISTEN
