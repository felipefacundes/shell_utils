#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script converts a hexadecimal color code to its RGB equivalent. 
It defines a function that extracts the red, green, and blue components from the hex code, 
converts them to decimal, and displays the result. The script also includes usage instructions for the user.
DOCUMENTATION

# Function to convert hexadecimal to RGB
hex_to_rgb() {
    # Extrais the components of color r, g, b
    r=$(echo "$1" | cut -c1-2)
    g=$(echo "$1" | cut -c3-4)
    b=$(echo "$1" | cut -c5-6)

    # Convert from hexadecimal to decimal
    r=$(printf "%d" 0x$r)
    g=$(printf "%d" 0x$g)
    b=$(printf "%d" 0x$b)

    # Displays the result
    echo "RGB: $r, $g, $b"
}

# Checks if the number of arguments is valid
if [ $# -eq 0 ] || [[ "$1" == '-h' || "$1" == '--help' ]]; then
    cat <<EOF
        Usage: ${0##*/} HEXCOLOR

        Example: ${0##*/} 5B7E7E
EOF
    exit 0
fi

# Call the function by passing the hexadecimal color as an argument
hex_to_rgb "$1"
