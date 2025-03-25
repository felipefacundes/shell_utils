#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This is a script to control the volume, and show it on the screen using xosd, good for using WMs
DOCUMENTATION

# Define a signal handler to capture SIGINT (Ctrl+C)
trap 'kill $(jobs -p)' SIGTERM #SIGHUP #SIGINT #SIGQUIT #SIGABRT #SIGKILL #SIGALRM #SIGTERM

doc() {
    less "$0" | head -n6 | tail -n1
}

help() {
    doc
echo "
Usage: ${0##*/} [args]

    -v +5%,
            Increases volume by value%
    -v -5%,
            Decreases volume by value%
    -m,
            Toggle mute
"
}

default_device() {
    local sink_name=$(pactl get-default-sink)
    pactl list short sinks | awk -v sink_name="$sink_name" '$2 == sink_name {print $1}'
}

get_current_volume() {
    local sink_name=$(pactl get-default-sink)
    LC_ALL=c pactl list sinks | awk -v sink_name="$sink_name" '
        $0 ~ "Sink #" {in_sink = 0} 
        $0 ~ "Name: " sink_name {in_sink = 1} 
        in_sink && $0 ~ "Volume:" {gsub("%","",$5); print $5; exit}
    '
}

volume_set() {
    local volume="$1"
    # Limit volume to 0-150% (PulseAudio permite até 150%)
    if (( volume > 150 )); then
        volume=150
    elif (( volume < 0 )); then
        volume=0
    fi
    pactl set-sink-volume "$(default_device)" "$volume%"
    pkill -9 osd_cat
    xrefresh
}

volume_filter() {
    local current_volume=$(get_current_volume)
    echo "Volume: $current_volume%"
}

# xset fp+ ~/.fonts

# xhost +si:localuser:root
# sudo xset fp+ /usr/share/fonts/TTF

# More fonts, see:
# xlsfonts
display_xosd() {
    # Fonts:
    #'lucidasanstypewriter-bold-24'
    #'-*-helvetica-bold-*-*-*-44-*-*-*-*-*-*'

    osd_cat -d 1 -s 4 -S cyan -A center -l 1 -O 2 -p middle -o 0 -c green -f '-adobe-utopia-bold-*-*-*-64-*-*-*-*-*-*'
}

volume() {
    local change="$1"
    local current_volume=$(get_current_volume)
    local new_volume
    
    # Remove % sign if present
    change=${change%\%}
    
    # Calculate new volume
    if [[ $change == +* ]]; then
        new_volume=$(( current_volume + ${change#+} ))
    elif [[ $change == -* ]]; then
        new_volume=$(( current_volume - ${change#-} ))
    else
        new_volume=$change
    fi
    
    # Ensure new volume is between 0 and 150
    if (( new_volume > 150 )); then
        new_volume=150
    elif (( new_volume < 0 )); then
        new_volume=0
    fi
    
    echo "$(volume_set "$new_volume"; pkill -9 osd_cat; xrefresh; volume_filter | display_xosd)"
}

display_mute() {
    local sink_name=$(pactl get-default-sink)
    local mute_status=$(LC_ALL=c pactl list sinks | awk -v sink_name="$sink_name" '
        $0 ~ "Sink #" {in_sink = 0} 
        $0 ~ "Name: " sink_name {in_sink = 1} 
        in_sink && $0 ~ "Mute:" {print $2; exit}
    ')
    
    if [[ "$mute_status" == "yes" ]]; then
        echo "Muted"
    else
        echo "Unmuted"
    fi
}

toggle_mute() {
    pactl set-sink-mute @DEFAULT_SINK@ toggle
}

mute() {
    echo "$(toggle_mute; display_mute | display_xosd)"
}

if [[ -z "$1" ]] || [[ $1 == "-h" || $1 == "--help" ]]; then
    help
    exit 0
fi

case $1 in
	-v)
		volume "$2"
		;;
	-m)
		mute
		;;
	*)
		help
		;;
esac

# Wait for all child processes to finish
wait