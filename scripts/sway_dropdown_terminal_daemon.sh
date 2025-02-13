#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script automates the management of a terminal window titled "QuakeTerminal" in a Sway window manager environment. 
Its purpose is to ensure the terminal is always available in the scratchpad, providing quick access.  

Key Strengths:  
1. Automation: Continuously checks and opens the terminal if not present.  
2. Efficiency: Moves the terminal to the scratchpad for quick access.  
3. Customization: Allows easy modification of the terminal title and behavior.  

Capabilities:  
- Monitors and manages terminal windows dynamically.  
- Integrates seamlessly with Sway's window management features.  
- Ensures a persistent, accessible terminal instance.
DOCUMENTATION

# Terminal title
title="QuakeTerminal"
term='terminator -T "$title"'

filter() {                     
    "$@" | grep '"QuakeTerminal"'
}

while true; do
    # Checking interval in seconds
    sleep 1.5

    check_string=$(filter swaymsg -t get_tree)
    # Check if there is a window with the title QuakeTerminal
    if [[ -z "$check_string" ]]; then
        if ! filter swaymsg -t get_tree; then
            # Open Terminator with the title QuakeTerminal
            eval "$term" &
            
            # Wait a brief moment to ensure Terminator has been opened
            sleep 0.3
            
            # Move the terminal to the scratchpad
            swaymsg [title="$title"] move container to scratchpad
            echo "Terminal $title opened and moved to scratchpad."
        fi
    fi
done
