#!/usr/bin/env bash
# Credits: kristoferus75
# https://github.com/swaywm/sway/issues/4121

# Get available windows
windows=$(swaymsg -t get_tree | jq -r '.nodes[1].nodes[].nodes[] | .. | (.id|tostring) + " " + .name?' | grep -e "[0-9]* ."  )

# Select window with rofi
selected=$(echo "$windows" | rofi -dmenu -i | awk '{print $1}')

# Tell sway to focus said window
swaymsg [con_id="$selected"] focus