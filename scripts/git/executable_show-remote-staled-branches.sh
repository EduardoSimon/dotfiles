#!/usr/bin/env bash

set -euo pipefail

for branch in $(git branch -r --merged | egrep -v "origin/HEAD|origin/master"); do echo -e $(git show --format="%ci %cr %an" $branch | head -n 1) \\t$branch; done | sort -r
