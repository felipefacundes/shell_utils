#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script is designed to convert frequency values from kilohertz (KHz), megahertz (MHz), and gigahertz (GHz) into hertz (Hz). 
It defines a function that validates the input format, ensuring it adheres to the expected frequency notation. 
The script removes any whitespace and extracts the numeric value and unit before performing the conversion to hertz. 
If the input format is invalid, it provides an error message and usage instructions. 
The script requires the user to provide the frequency as a command-line argument, prefixed by the '-f' option.
DOCUMENTATION

# Function to convert frequency to number
convert_freq_to_number() {
    declare -l freq
    freq="$1"

    # Remove white spaces from the frequency
    freq=$(echo "$freq" | sed 's/[[:space:]]//g')

    # Check if the input has a valid unit (KHz, MHz, GHz)
    if [[ ! "$freq" =~ ^[0-9.]+(khz|mhz|ghz)$ ]]; then
        echo "Invalid format. Use frequency in the format: 140KHz, 50MHz, 99GHz, etc."
        exit 1
    fi

    # Extract the value and unit from the input
    local value=$(echo "$freq" | sed 's/[^0-9.]//g')
    local unit=$(echo "$freq" | sed 's/[0-9.]//g')

    # Convert to Hz (default unit)
    case "$unit" in
        "khz") value=$(echo "scale=9; $value * 1000" | bc);;
        "mhz") value=$(echo "scale=9; $value * 1000000" | bc);;
        "ghz") value=$(echo "scale=9; $value * 1000000000" | bc);;
    esac

    echo "The frequency $freq is equal to $value Hz."
}

# Check if the float precision is provided as an optional argument
if [[ $# -eq 2 && "$1" == "-f" ]]; then
    convert_freq_to_number "$2"
else
    echo "Usage: ${0##*/} -f <frequency>"
    echo "Example: ${0##*/} -f 140KHz"
    echo "Example 2: ${0##*/} -f \"140 KHz\""
    exit 1
fi
