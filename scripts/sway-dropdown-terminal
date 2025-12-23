#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script, titled "QuakeTerminal," is designed to manage a terminal window in a Sway window manager environment. 
Its primary purpose is to open and manipulate a terminal window with a specific title, ensuring it is displayed efficiently and organized.

Strengths:
1. Automation: The script automates the opening and management of the terminal window, saving user time.
2. Existence Check: It checks if a window with the same title is already open before creating a new one, preventing duplicates.
3. Resizing and Positioning: The script automatically adjusts the window's dimensions and position to fit well on the screen.
4. Sway Integration: It utilizes Sway commands to manipulate windows, showcasing its ability to integrate with the desktop environment.
5. Scratchpad Usage: The window is moved to the scratchpad, allowing users to keep their workspace organized.

Capabilities:
- Opens a terminal window with a specific title.
- Resizes and repositions the window based on screen dimensions.
- Moves the window to the scratchpad for better management.
- Allows toggling the visibility of the window in the scratchpad. This Bash script, titled "QuakeTerminal," is designed to manage a terminal 
window in a Sway window manager environment. Its primary purpose is to open and manipulate a terminal window with a specific title, ensuring 
it is displayed efficiently and organized.

Strengths:
1. Automation: The script automates the opening and management of the terminal window, saving user time.
2. Existence Check: It checks if a window with the same title is already open before creating a new one, preventing duplicates.
3. Resizing and Positioning: The script automatically adjusts the window's dimensions and position to fit well on the screen.
4. Sway Integration: It utilizes Sway commands to manipulate windows, showcasing its ability to integrate with the desktop environment.
5. Scratchpad Usage: The window is moved to the scratchpad, allowing users to keep their workspace organized.

Capabilities:
- Opens a terminal window with a specific title.
- Resizes and repositions the window based on screen dimensions.
- Moves the window to the scratchpad for better management.
- Allows toggling the visibility of the window in the scratchpad.
DOCUMENTATION

# Terminal title
title="QuakeTerminal"
term='alacritty -T "$title"'

raw_width=$(swaymsg -t get_outputs | jq '.[0].rect.width')
raw_height=$(swaymsg -t get_outputs | jq '.[0].rect.height')

# Usage awk
safe_margin=$(awk "BEGIN { printf \"%.0f\", $raw_width * 0.0102 }")
width=$(awk "BEGIN { printf \"%.0f\", $raw_width - $safe_margin }")
height=$(awk "BEGIN { printf \"%.0f\", $raw_height * 0.55559 }")

filter() {                     
    "$@" | grep '"QuakeTerminal"'
}

check_string=$(filter swaymsg -t get_tree)
# Check if there is a window with the title QuakeTerminal
if [[ -z "$check_string" ]]; then
    if ! filter swaymsg -t get_tree; then
        # Open Terminator with the title QuakeTerminal
        eval "$term" &
        
        # Dimensions and position
        swaymsg [title="$title"] -t command resize set width "${width}px" height "${height}px"
        swaymsg [title="$title"] -t command move position 0 0
        
        # Wait a brief moment to ensure Terminator has been opened
        sleep 0.1

        # Move the terminal to the scratchpad
        swaymsg [title="$title"] move container to scratchpad
        echo "Terminal $title opened and moved to scratchpad."
    fi
fi

# Sleep for 0.1 seconds, possibly to allow for some previous actions to complete.
sleep 0.1

# Check if the specified title is not in the scratchpad.
if ! swaymsg [title="$title"] scratchpad show; then 

    # If the title is not in the scratchpad, move the container with the specified title to the scratchpad.
    swaymsg [title="$title"] move container to scratchpad

# If the title is already in the scratchpad.
elif swaymsg [title="$title"] scratchpad show; then

    # Show the container with the specified title in the scratchpad.
    swaymsg [title="$title"] scratchpad show

    # Dimensions and position
    swaymsg [title="$title"] -t command resize set width "${width}px" height "${height}px"
    swaymsg [title="$title"] -t command move position 0 0

# End of the conditional statement.
fi
