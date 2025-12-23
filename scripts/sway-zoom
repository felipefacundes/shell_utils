#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script is designed to dynamically adjust the zoom scale of a display in a Sway window manager environment. 
It maintains a persistent scale value in a temporary file and allows users to increase or decrease this value through 
command-line arguments. 

Strengths:
1. Persistent Storage: The scale value is stored in a temporary file, ensuring that changes are retained across sessions.
2. Dynamic Adjustment: Users can easily modify the zoom level by providing simple command-line inputs.
3. Error Handling: The script includes checks for file existence and output detection, providing user-friendly error messages.
4. Integration with Sway: It utilizes Swaymsg and WLR-randr to interact with the display settings effectively.
5. Simplicity: The script is straightforward and easy to use, making it accessible for users with basic command-line knowledge.

Capabilities:
- Increases or decreases the zoom scale by 0.5 increments.
- Automatically detects the main output for applying the new scale.
- Provides usage instructions when incorrect arguments are supplied.
DOCUMENTATION

TMPDIR="${TMPDIR:-/tmp}"

# File to store the value of the scale
scale_file="${TMPDIR}/sway_zoom_scale"

# If the file does not exist, create it with a default value
if [ ! -e "$scale_file" ]; then
    echo "1.0" > "$scale_file"
fi

# Read the current value of the file scale
current_scale=$(cat "$scale_file")

# Determine the action based on the argument provided
case "$1" in
    "+")
        # Increase dynamically
        new_scale=$(echo "$current_scale + 0.5" | bc)
        ;;
    "-")
        # Decrease dynamically
        new_scale=$(echo "$current_scale - 0.5" | bc)
        ;;
    *)
        echo "Uso: $0 <+ ou ->"
        exit 1
        ;;
esac

# Update the file with the new scale value
echo "$new_scale" > "$scale_file"

# Detect the main output using Swaymsg and JQ
output=$(swaymsg -t get_outputs | jq -r '.[0].name')

# Check that the output was detected
if [ -n "$output" ]; then
    # Run the WLR-randr command with the detected output and the new scale value
    wlr-randr --output "$output" --scale "$new_scale"
else
    echo "Error: It was not possible to detect the main output."
fi
