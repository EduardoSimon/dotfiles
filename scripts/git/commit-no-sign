#!/usr/bin/env bash

set -eo pipefail

git add -A

if [ -z "$1" ]; then
  git commit
else
  git commit -m "$1"
fi
