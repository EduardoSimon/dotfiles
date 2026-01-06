#!/usr/bin/env fish

set INPUT_FILE "Brewfile"
set OUTPUT_DIR ".chezmoidata"
set OUTPUT_FILE "$OUTPUT_DIR/brew_packages.yaml"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Start YAML structure
echo "packages:" > $OUTPUT_FILE
echo "  darwin:" >> $OUTPUT_FILE

# Extract taps
echo "    taps:" >> $OUTPUT_FILE
grep '^tap ' $INPUT_FILE | sed 's/tap "\(.*\)"/      - \x27\1\x27/' >> $OUTPUT_FILE

# Extract brews
echo "    brews:" >> $OUTPUT_FILE
grep '^brew ' $INPUT_FILE | sed 's/brew "\(.*\)"/      - \x27\1\x27/' >> $OUTPUT_FILE

# Extract casks
echo "    casks:" >> $OUTPUT_FILE
grep '^cask ' $INPUT_FILE | sed 's/cask "\(.*\)"/      - \x27\1\x27/' >> $OUTPUT_FILE

echo "$OUTPUT_FILE created successfully"
