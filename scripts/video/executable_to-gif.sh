#!/usr/bin/env bash
set -eo pipefail

ffmpeg \
  -i "$1" \
  -r 15 \
  -vf scale=512:-1 \
  "$1.gif"
