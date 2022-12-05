#!/usr/bin/env bash

set -euo pipefail

DATE_FORMATTED=$1/1000

gdate -d @$DATE_FORMATTED
