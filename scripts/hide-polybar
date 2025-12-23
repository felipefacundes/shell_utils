#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script dynamically hides or shows the Polybar based on the mouse position relative to the bottom of the screen, 
enhancing user interface interaction.
DOCUMENTATION

polybar_height=15
delay=1

while true; do
    window_height=$(xrandr | grep -m1 -oP '\d{3,}x\d+' | cut -d 'x' -f 2)
    mouse_y=$(xdotool getmouselocation | grep -oP 'y:\K\d+' | cut -d ':' -f 2)
    distance_from_bottom=$((window_height - mouse_y))

    if [ "$distance_from_bottom" -ge "$polybar_height" ]; then
        polybar-msg cmd hide
    else
        polybar-msg cmd show
    fi

    sleep "$delay"
done
