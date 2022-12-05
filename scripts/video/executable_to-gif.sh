#!/usr/bin/env bash
set -eo pipefail

source "$DOTFILES_PATH/scripts_helper.sh"

##? Transforms a video to gif
##?
##? Usage:
##?   to-gif <video_path>
##?
docs_parse "$@"

ffmpeg \
  -i "$video_path" \
  -r 15 \
  -vf scale=512:-1 \
  "$video_path.gif"
