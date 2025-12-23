#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script retrieves information about connected screens and their dimensions using the 'xrandr' command. 
It extracts the screen name, width, and height in millimeters, converts these measurements to inches, and calculates 
the diagonal size in inches. The results are then printed in a formatted table displaying the screen name, width, height, and diagonal dimensions.
DOCUMENTATION

# change the round factor if you like
#r=1

# Get connected screens and their dimensions
screens=$(xrandr | grep " connected")

# Print header
echo -e "Screen\twidth\theight\tdiagonal\n$(printf '%.0s-' {1..32})"

# Process each screen
while read -r line; do
    # Extract screen name, width, and height
    screen_name=$(echo "$line" | awk '{print $1}')
    width_mm=$(echo "$line" | grep -oP '\d+(?=mm)' | head -n 1)
    height_mm=$(echo "$line" | grep -oP '\d+(?=mm)' | tail -n 1)

    # Check if width and height are not empty
    if [[ -n "$width_mm" && -n "$height_mm" ]]; then
        # Convert to inches
        width_in=$(echo "scale=1; $width_mm / 25.4" | bc)
        height_in=$(echo "scale=1; $height_mm / 25.4" | bc)

        # Calculate diagonal
        diagonal_in=$(echo "scale=1; sqrt(($width_in^2) + ($height_in^2))" | bc)

        # Print the results
        echo -e "$screen_name\t$width_in\t$height_in\t$diagonal_in"
    fi
done <<< "$screens"