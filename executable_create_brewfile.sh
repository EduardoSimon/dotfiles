#!/usr/bin/env bash
set -euo pipefail

OUTPUT_DIR=".chezmoidata"
OUTPUT_FILE="$OUTPUT_DIR/brew_packages.yaml"

mkdir -p "$OUTPUT_DIR"

echo "Generating package list from current brew installations (direct packages only)..."

echo "packages:" > "$OUTPUT_FILE"
echo "  darwin:" >> "$OUTPUT_FILE"

echo "    taps:" >> "$OUTPUT_FILE"
brew tap | sed "s/\(.*\)/      - '\1'/" >> "$OUTPUT_FILE"

echo "    brews:" >> "$OUTPUT_FILE"
brew leaves | sed "s/\(.*\)/      - '\1'/" >> "$OUTPUT_FILE"

echo "    casks:" >> "$OUTPUT_FILE"
brew list --cask | sed "s/\(.*\)/      - '\1'/" >> "$OUTPUT_FILE"

echo "$OUTPUT_FILE created successfully"
echo "Direct packages only (dependencies will be installed automatically)"
