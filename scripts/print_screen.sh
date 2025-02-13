#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script is used to print the screen using scrot, 
play an alert sound and use the various available scrot modes, 
good for WM users

Awesome WM:
    -- Print Screen
    awful.key({ }, "Print", function()
        awful.spawn("bash -c '~/.shell_utils/scripts/print_with_scrot.sh -p -beep'")
    end, {description = "Print Screen", group = "client"}),
DOCUMENTATION

doc() {
    awk '
    BEGIN { inside_block = 0 }

    # Check the beginning of the DOCUMENTATION block
    /: <<'\''DOCUMENTATION'\''/ { inside_block = 1; next }

    # Check the end of the DOCUMENTATION block
    inside_block && $0 == "DOCUMENTATION" { inside_block = 0; exit }

    # Print lines within the DOCUMENTATION block
    inside_block { print }
    ' "$0"
}

date=$(date +"%Y-%m-%d %H:%M:%S")
default_dir="${default_dir:-$HOME/Pictures/Capture}"
beep="${HOME}/.shell_utils/sounds/camera_shutter.ogg"
icon="${HOME}/.shell_utils/icons/dslr-camera.png"
#icon="/usr/share/icons/HighContrast/48x48/devices/camera-photo.png"
#icon="/usr/share/icons/breeze/devices/64/camera-photo.svg"
file="${default_dir}/${date} - Capture.png"
delay="${delay:-4}"

[[ ! -d "$default_dir" ]] && mkdir -p "$default_dir"

if [[ $XDG_SESSION_TYPE = wayland ]]; then
    m1='grim "$file"'
    m2='sleep "$delay" && grim "$file"'
    m3='grim -g "$(slurp)" "$file"'
    m4='grim "$file"'
    clip='wl-copy'
    clipv='wl-paste'
else
    m1='scrot "$file"'
    m2='scrot -d "$delay" "$file"'
    m3='scrot -f -s "$file"'
    m4='scrot -u "$file"'
    clip='xclip -selection clipboard -target image/png -i'
    clipv='xclip -selection clipboard -o -t image/png'
fi

help() {
    doc
    echo "
Usage: ${0##*/} [args]
Example: ${0##*/} -p -beep

    -p,
          Print Screen.
    -sp,
          Print Screen: Interactively select a window or rectangle with the mouse.
    -cp,
          Print Screen of currently focused window.
    -ap,
          Print Screen with delay in seconds (default is 4).

          Example: delay=10 ${0##*/} -ap
    -beep,
          Play a sound.
    -msg,
          Show message.
    -d,
          Display ScreeShot.

Default: In all of the options above, when generating the Print Screen, the image is also copied to the clipboard.
"
}

capture_sound() {
    pactl upload-sample "$beep"
    paplay "$beep" --volume=76767
}

completed_message() {
    #notify-send -i "$icon" -u critical "ScreenShot" "Completed"
    notify-send -i "$icon" -u critical "Screen Shot" "Completed successfully" &
}

func_clipboard() {
    IFS= eval "cat \"$file\" | $clip"
}

display_screenShot() {
    IFS= eval "$clipv" | feh -
}

# Print Screen
capture_screen_m1() {
    IFS= eval "$m1"
    func_clipboard
}

# Print Screen with delay
# In Openbox or labwm: <keybind key="A-S-Print">
capture_screen_m2() {
    IFS= eval "$m2"
    func_clipboard
}
    
# Print Screen: Interactively select a window or rectangle with the mouse.
# In Openbox or labwm: <keybind key="S-Print">
capture_screen_m3() {
    IFS= eval "$m3"
    func_clipboard
}

# Print Screen of currently focused window.
# In Openbox or labwm: <keybind key="C-Print">
capture_screen_m4() {
    IFS= eval "$m4"
    func_clipboard
}
    
if [[ -z $1 ]]; then
    help
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -p)
            capture_screen_m1
            shift
            continue
            ;;
        -ap)
            capture_screen_m2
            shift
            continue
            ;;
        -sp)
            capture_screen_m3
            shift
            continue
            ;;
        -cp)
            capture_screen_m4
            shift
            continue
            ;;
        -beep)
            capture_sound
            shift
            continue
            ;;
        -msg)
            completed_message
            shift
            continue
            ;;
        -d)
            display_screenShot
            shift
            continue
            ;;
        *)
            help
            break
            ;;
    esac
done