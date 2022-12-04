#!/usr/bin/env sh

set -euo pipefail

##? download & decompress into folder without intermediate file
#?? 1.0.0
##?
##? Usage:
##?   unzip <url> <folder>
docs::parse "$@"

curl -s "$url" | tar -xz -C "$folder" --strip-components=1