#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script is to fix the mouse cursor theme.
# Cursor Theme fix for WMs: openbox, i3 and more...
# How to use lxappearance. No stress.
DOCUMENTATION

# Define a signal handler to capture SIGINT (Ctrl+C)
trap 'kill $(jobs -p)' SIGTERM #SIGHUP #SIGINT #SIGQUIT #SIGABRT #SIGKILL #SIGALRM #SIGTERM

doc() {
    less -FX "$0" | head -n8 | tail -n3
    echo
}

help() {
    doc
    echo "Usage: ${0##*/} [args]

    -o,
        Only xrdb fix loop

    -t,
        Cursor theme e GTK theme fix loop"
}

delay=5
xsetroot -cursor_name left_ptr >/dev/null 2>&1
xrdb -merge ~/.Xresources >/dev/null 2>&1

only_xrdb() {
    while true
    do 
        xrdb ~/.Xresources > /dev/null 2>&1
        xrdb -I"${HOME}" ~/.Xresources > /dev/null 2>&1
        xrdb -merge -I"${HOME}" ~/.Xresources > /dev/null 2>&1
        xrdb -merge ~/.Xresources > /dev/null 2>&1
        xsetroot -cursor_name left_ptr > /dev/null 2>&1

        sleep "$delay"
    done
}

cursor_theme_fix()
{

    [[ ! -s ~/.Xresources ]] && rm ~/.Xresources
    [[ ! -f ~/.Xresources ]] && wget -nc https://raw.githubusercontent.com/felipefacundes/dotfiles/master/config/.Xresources -O ~/.Xresources
    
    [[ ! -d ~/.config/gtk-4.0/ ]] && mkdir -p ~/.config/gtk-4.0/
    [[ -d ~/.config/gtk-4.0/ ]] && cp -f ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini

    while true; 
    do 
        export GTK_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0/settings.ini"
        export GTK2_RC_FILES="${HOME}/.gtkrc-2.0" #"${HOME}/.gtkrc-2.0:${XDG_CONFIG_HOME}/gtk-2.0/gtkrc:/etc/gtk-2.0/gtkrc"
        export GTK_THEME="$(grep 'gtk-theme-name' ${GTK_RC_FILES} | cut -d'=' -f2)"
        # ICON ...
        export XCURSOR_THEME="$(grep 'gtk-cursor-theme-name' ${GTK_RC_FILES} | cut -d'=' -f2)"
        export XCURSOR_SIZE="$(grep 'gtk-cursor-theme-size' ${GTK_RC_FILES} | cut -d'=' -f2)"

        export xresources_xcursor_theme="$(grep -i 'Xcursor.theme:' ~/.Xresources | cut -f2 -d':')"
        export xresources_xcursor_size="$(grep -i 'Xcursor.size:' ~/.Xresources | cut -f2 -d':' | sed '/^$/d')"

        if [ "${xresources_xcursor_theme}" != "${XCURSOR_THEME}" ] || [ "${xresources_xcursor_size}" != "${XCURSOR_SIZE}" ]; then
            sed -i "2 s#${xresources_xcursor_theme}# ${XCURSOR_THEME}#g" ~/.Xresources
            sed -i "3 s#${xresources_xcursor_size}# ${XCURSOR_SIZE}#g" ~/.Xresources
            xrdb ~/.Xresources > /dev/null 2>&1
            #xrdb -I$HOME ~/.Xresources > /dev/null 2>&1
            #xrdb -merge -I$HOME ~/.Xresources > /dev/null 2>&1
            xrdb -merge ~/.Xresources > /dev/null 2>&1
            xsetroot -cursor_name left_ptr > /dev/null 2>&1
        fi

        export gnome_schema="org.gnome.desktop.interface"
        export icon_theme="$(grep 'gtk-icon-theme-name' ${GTK_RC_FILES} | cut -d'=' -f2)"
        export font_name="$(grep 'gtk-font-name' ${GTK_RC_FILES} | cut -d'=' -f2)"
        gsettings set "${gnome_schema}" gtk-theme "${GTK_THEME}"
        gsettings set "${gnome_schema}" icon-theme "${icon_theme}"
        gsettings set "${gnome_schema}" cursor-theme "${XCURSOR_THEME}"
        gsettings set "${gnome_schema}" font-name "${font_name}"

        sleep "$delay"
    done
}

if [[ -z "${1}" ]]; then
    help
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -o)
            only_xrdb
            shift
            continue
            ;;
        -t)
            cursor_theme_fix
            shift
            continue
            ;;
        *)
            help
            break
            ;;
    esac
done

# Wait for all child processes to finish
wait