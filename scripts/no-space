#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script is to remove command space output.
DOCUMENTATION

doc() {
    less -FX "$0" | head -n6 | tail -n1
    echo
}

# Check if arguments are provided to the script
if [ "$#" -eq 0 ]; then
    doc
    echo "Usage: ${0##*/} command [arguments]"
    exit 1
fi

# Execute the command with the arguments
output="$("$@")"

# Remove spaces from the output
output_without_spaces=$(echo "$output" | sed 's/ //g')

# Display the output without spaces
echo "$output_without_spaces"
