#!/bin/bash
# Merge Claude Code base settings with existing local settings
# Local settings (AWS, statusLine) take precedence

set -e

BASE_SETTINGS="$HOME/.claude/settings.base.json"
LOCAL_SETTINGS="$HOME/.claude/settings.json"
TEMP_MERGED="/tmp/claude-settings-merged.json"

# If no local settings exist, copy base settings
if [ ! -f "$LOCAL_SETTINGS" ]; then
    cp "$BASE_SETTINGS" "$LOCAL_SETTINGS"
    echo "Created ~/.claude/settings.json from base settings"
    exit 0
fi

# Merge: local settings override base settings
# This preserves AWS config while updating shared settings from dotfiles
if command -v jq >/dev/null 2>&1; then
    jq -s '.[0] * .[1]' "$BASE_SETTINGS" "$LOCAL_SETTINGS" > "$TEMP_MERGED"
    mv "$TEMP_MERGED" "$LOCAL_SETTINGS"
    echo "Merged Claude Code settings (local settings preserved)"
else
    echo "Warning: jq not found, skipping Claude settings merge"
fi
