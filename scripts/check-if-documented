#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script checks for files in the current directory that do not contain the exact string ': <<'DOCUMENTATION''.
It lists those files in the output.
DOCUMENTATION

# String to be checked
SEARCH_STRING=": <<'DOCUMENTATION'"

# Loop through all files in the current directory
for file in *; do
    # Check if it is a regular file
    if [ -f "$file" ]; then
        # Check if the file does not contain the string
        if ! grep -qF "$SEARCH_STRING" "$file"; then
            echo "$file"
        fi
    fi
done