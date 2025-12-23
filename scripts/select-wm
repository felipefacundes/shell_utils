#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script is designed to facilitate the selection and execution of different session types and window managers in a Linux environment. 

Purpose:
The script allows users to choose between X11, Wayland, or a terminal session, and subsequently select a window manager from the available options.

Strengths:
1. User -Friendly Interface: Prompts users to select session types and window managers with clear instructions.
2. Dynamic Window Manager Listing: Automatically lists available window managers based on the selected session type.
3. Signal Handling: Implements a signal handler to manage interruptions gracefully.
4. Input Validation: Ensures that user inputs are valid, providing feedback for invalid selections.
5. Session Execution: Executes the chosen window manager or terminal session seamlessly.

Capabilities:
- Supports multiple session types (X11, Wayland, Terminal).
- Lists and executes user-selected window managers.
- Handles user interruptions and invalid inputs effectively.
DOCUMENTATION

# Define a signal handler to capture SIGINT (Ctrl+C)
trap 'kill $(jobs -p)' SIGQUIT SIGHUP #SIGTERM #SIGHUP #SIGINT #SIGQUIT #SIGABRT #SIGKILL #SIGALRM #SIGTERM

shell_here() {
    if command -v fish 1>/dev/null; then
        fish
    elif command -v zsh 1>/dev/null; then
        zsh
    else
        bash
    fi
}

echo "Choose the type of session:"
echo "1) X11"
echo "2) Wayland"
echo "3) Terminal"
read -rp "Enter the desired option (1 to 3): " session

case $session in
    1)
        echo "You chose x11."
        dir="/usr/share/xsessions"
        ;;
    2)
        echo "You chose Wayland."
        dir="/usr/share/wayland-sessions"
        ;;
    3)
        echo "You chose terminal."
        shell_here
        ;;
    *)
        echo "Invalid option."
        exit 1
        ;;
esac

# List available window managers
wms=($(ls $dir))
count=${#wms[@]}

echo "Window Managers Available:"
for ((i=0; i<$count; i++)); do
    echo "$((i+1))) ${wms[$i]}"
done

read -rp "Choose Window Manager (1-$count): " wm_choice

# Check if the choice is valid
if [[ $wm_choice -lt 1 ]] || [[ $wm_choice -gt $count ]]; then
    echo "Invalid option."
    exit 1
fi

# Extract the value after Exec = from the selected .desktop file
wm_file="${wms[$((wm_choice-1))]}"
exec_value=$(grep -oP '(?<=Exec=).*' "$dir/$wm_file")

if [[ $session -eq 1 ]]; then
    # Exports the choice for the start_wm variable to x11
    export start_wm=$exec_value
    echo "The Window Manager chosen was $start_wm"
else
    # Execute directly to Wayland
    exec $exec_value
fi

# Wait for all child processes to finish
wait