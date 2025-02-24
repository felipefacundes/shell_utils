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

volume_set() {
    local volume="$1"
    pactl set-sink-volume "$(default_device)" "$volume"
    pkill -9 osd_cat
    xrefresh
}

volume_filter() {
    # Obtém o nome do sink padrão
    local sink_name=$(pactl get-default-sink)
    
    # Obtém o volume do sink padrão
    local volume=$(LC_ALL=c pactl list sinks | awk -v sink_name="$sink_name" '
        $0 ~ "Sink #" {in_sink = 0} 
        $0 ~ "Name: " sink_name {in_sink = 1} 
        in_sink && $0 ~ "Volume:" {print $5; exit}
    ')
    
    echo "Volume: $volume"
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
    local volume="$1"
    echo "$(volume_set "$volume"; pkill -9 osd_cat; xrefresh; volume_filter | display_xosd)"
}

display_mute() {
    LC_ALL=c pactl list sinks | grep "Mute:" | head -n1 | cut -f2
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

while [[ $# -gt 0 ]]; do
    case $1 in
        -v)
            volume "$2"
            shift 2
            continue
            ;;
        -m)
            mute
            shift 
            continue
            ;;
        *)
            help
            ;;
    esac
done

# Wait for all child processes to finish
wait