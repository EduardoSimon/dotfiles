#!/usr/bin/env bash

set -euo pipefail

git::is_in_repo() {
	git rev-parse HEAD >/dev/null 2>&1
}

if (! git::is_in_repo); then
  echo "Not in a git repo!"
  exit 0
fi

file=$(git -c color.status=always status --short |
  fzf --height 100% --ansi \
    --preview '(git diff HEAD --color=always -- {-1} | sed 1,4d)' \
    --preview-window right:65% |
  cut -c4- |
  sed 's/.* -> //' |
  tr -d '\n')

vim "$file"
