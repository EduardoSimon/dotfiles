#!/usr/bin/env bash

set -eo pipefail

if [ -z "$1" ]; then
  seleted_branch=$(git branch | fzf | awk '{$1=$1};1')
else
  seleted_branch=$1
fi

if [ -z "$2" ]; then
  current_branch=$(git branch --show-current)
else
  current_branch=$2
fi

git diff ${current_branch}..${seleted_branch##*( )} | delta
