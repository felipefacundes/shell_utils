#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script is designed to move all subdirectories from the current directory to its parent directory. 

Strengths:
1. Efficiently processes all directories in the current location.
2. Utilizes 'find' command to target only immediate subdirectories.
3. Ensures safe navigation with error handling.

Capabilities:
- Moves directories while preserving their structure.
- Operates within a Bash environment, leveraging shell scripting.
DOCUMENTATION

for dir in *; do
    if [[ -d "$dir" ]]; then
        cd "$dir" || exit
        find . -mindepth 1 -maxdepth 1 -type d -exec mv {} .. \; -quit
        cd ..
    fi
done