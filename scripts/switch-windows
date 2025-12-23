#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTAION'
This Bash script allows the user to select an open window on their system and bring it into focus.

Strengths:
1. Utilizes 'wmctrl' to list open windows.
2. Integrates with 'rofi' for a user-friendly selection interface.
3. Enables easy access and management of windows.

Capabilities:
- Lists active windows.
- Selects a window through a graphical interface.
- Focuses on the selected window.
DOCUMENTAION

wm_list=$(wmctrl -l | awk '{print $1 " - " $4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19}')
[[ "$wm_list" ]] && win_id=$(echo "$wm_list" | rofi -dmenu -i -p "Select Window" | awk '{print $1}' )
[[ "$wm_list" ]] && wmctrl -i -a "$win_id"