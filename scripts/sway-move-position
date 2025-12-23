#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script is designed to manage the position of a window in the Sway window manager by moving it based on user input. 
The script maintains a temporary file to store the current position of the window and updates it according to the specified direction 
(left, right, up, or down). 

Strengths:
1. User -Friendly: Simple command-line interface for moving windows with intuitive key bindings.
2. Position Persistence: Stores the window position in a temporary file, allowing for continuous movement without losing the state.
3. Boundary Handling: Prevents the window from moving out of the screen boundaries.
4. Integration with Sway: Utilizes Swaymsg to interact with the Sway window manager, ensuring seamless window management.
5. Error Handling: Provides feedback for incorrect usage and checks for the main output detection.

Capabilities:
- Moves the window in four directions based on user input.
- Automatically initializes the position file if it doesn't exist.
- Detects the main output for accurate window positioning.
DOCUMENTATION

TMPDIR="${TMPDIR:-/tmp}"

# File to store the position
position_file="${TMPDIR}/sway_window_position"

# If the file does not exist, create it with a standard position
if [ ! -e "$position_file" ]; then
    echo "0 0" > "$position_file"
fi

# Read the current position of the file
current_position=$(cat "$position_file")

# Determine the action based on the argument provided
case "$1" in
    "h")
        # Move to the left
        awk '{print ($1 - 25 < 0) ? "0" : $1 - 25, $2}' <<< "$current_position" > "$position_file"
        ;;
    "l")
        # Move to the right
        awk '{print $1 + 25, $2}' <<< "$current_position" > "$position_file"
        ;;
    "k")
        # Move to the up
        awk '{print $1, ($2 - 25 < 0) ? "0" : $2 - 25}' <<< "$current_position" > "$position_file"
        ;;
    "j")
        # Move to the down
        awk '{print $1, $2 + 25}' <<< "$current_position" > "$position_file"
        ;;
    *)
        echo "Uso: ${0##*/} {h|l|k|j}"
        exit 1
        ;;
esac

# Read the new position of the file
new_position=$(cat "$position_file")

# Extrair as coordenadas X e Y da nova posição
new_x=$(echo "$new_position" | awk '{print $1}')
new_y=$(echo "$new_position" | awk '{print $2}')

# Detect the main output using Swaymsg and JQ
output=$(swaymsg -t get_outputs | jq -r '.[0].name')

# Check that the output was detected
if [ -n "$output" ]; then
    # Run the Swaymsg command to move the window to the new position
    swaymsg -t command move position "$new_x" "$new_y"
else
    echo "Error: It was not possible to detect the main output."
fi
