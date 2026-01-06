#!/usr/bin/env fish

set OUTPUT_DIR ".chezmoidata"
set OUTPUT_FILE "$OUTPUT_DIR/brew_packages.yaml"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

echo "Generating package list from current brew installations (direct packages only)..."

# Start YAML structure
echo "packages:" > $OUTPUT_FILE
echo "  darwin:" >> $OUTPUT_FILE

# Extract taps
echo "    taps:" >> $OUTPUT_FILE
brew tap | sed 's/\(.*\)/      - \x27\1\x27/' >> $OUTPUT_FILE

# Extract brews (only direct installations, not dependencies)
echo "    brews:" >> $OUTPUT_FILE
brew leaves | sed 's/\(.*\)/      - \x27\1\x27/' >> $OUTPUT_FILE

# Extract casks
echo "    casks:" >> $OUTPUT_FILE
brew list --cask | sed 's/\(.*\)/      - \x27\1\x27/' >> $OUTPUT_FILE

echo "$OUTPUT_FILE created successfully"
echo "Direct packages only (dependencies will be installed automatically)"
