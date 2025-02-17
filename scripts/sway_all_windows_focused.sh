#!/bin/bash
# Credits: Felipe Facundes
# Initial Credits: shapeoflambda # https://github.com/swaywm/sway/issues/4121
# Tweaked the above code to make it work with floating windows.

: <<'DOCUMENTATION'
This Bash script is designed to manage windows in the Sway window manager, offering functionality to focus, close, or forcefully terminate windows. 
It retrieves both regular and floating windows, presents them to the user via the 'wofi' menu, and performs actions based on user selection. 
Below are its key strengths and capabilities:

1. Window Management: The script effectively handles both regular and floating windows in Sway, providing a unified interface for managing them.  
2. User Interaction: It uses 'wofi' for user-friendly interaction, allowing users to select windows and choose actions (focus, close, or kill).  
3. Process Termination: It includes the ability to forcefully terminate processes associated with selected windows using the 'kill' command.  
4. Error Handling: The script includes checks to ensure no duplicate instances of 'wofi' are running and notifies the user if no windows are open.  
5. Flexibility: It dynamically adapts to the presence of regular or floating windows, ensuring smooth operation in various scenarios.  

This script is a powerful tool for Sway users seeking enhanced window management capabilities.
DOCUMENTATION

TMPDIR="${TMPDIR:-/tmp}"

# Get regular windows
regular_windows=$(swaymsg -t get_tree | jq -r '.nodes[1].nodes[].nodes[] | .. | (.id|tostring) + " " + .name?' | grep -e "[0-9]* .")

# Get floating windows
floating_windows=$(swaymsg -t get_tree | jq '.nodes[1].nodes[].floating_nodes[] | (.id|tostring) + " " + .name?' | grep -e "[0-9]* ." | tr -d '"')

lock="${TMPDIR}/${0##*/}-lock"
enter=$'\n'

if pidof wofi; then
    exit 1
fi

if [[ $regular_windows || $floating_windows ]]; then
    if [[ $regular_windows && $floating_windows ]]; then
        all_windows="$regular_windows$enter$floating_windows"
    elif [[ $regular_windows ]]; then
        all_windows=$regular_windows
    else
        all_windows=$floating_windows
    fi

    [[ -f "$lock" ]] && rm "$lock"

    # Select action (focus or close) with wofi
    action=$(echo -e "focus\nclose\nkill" | wofi --show dmenu)

    # Select window with wofi
    selected=$(echo "$all_windows" | wofi --show dmenu | awk '{print $1}')

    # Perform action based on user selection
    case $action in
        "close")
            swaymsg [con_id="$selected"] kill
            ;;
        "kill")
            # Get the process ID (PID) associated with the window
            window_pid=$(swaymsg -t get_tree | jq -r '.. | select(.nodes? or .floating_nodes?) | .nodes[].nodes? | .[] | select(.id == '$selected') | .pid')
        
            # Use kill to forcefully terminate the process
            if [ -n "$window_pid" ]; then
                kill -9 "$window_pid"
            else
                echo "Failed to retrieve process ID for the selected window."
            fi
            ;;
        *)
            # Tell sway to focus said window
            swaymsg [con_id="$selected"] focus
            ;;
    esac
else
    [[ ! -f "$lock" ]] && touch "$lock" && notify-send 'There are no open windows' && sleep 5 && rm "$lock"
fi