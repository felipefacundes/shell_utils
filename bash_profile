#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes
if [[ ! $DISPLAY && ${XDG_VTNR} != 0 ]]; then
if [[ "${XDG_SESSION_TYPE}" = [Tt][Tt][Yy] ]]; then
#
### KEYBOARD
export XKB_DEFAULT_LAYOUT=br
export XKB_DEFAULT_OPTIONS=grp:alt_shift_toggle
# COLORS VARIABLES
. ~/.shell_utils/variables/shell_colors.sh
#export vblank_mode=0
#export __GL_SYNC_TO_VBLANK=0

export SSH_AUTH_SOCK
file=~/.zprofile
export wms_logs_dir="${HOME}/.WMs_logs_dir"
wms_logs_dir_size=$(du "${wms_logs_dir}" | awk '{print $1}')
scripts=~/.shell_utils/scripts

if [ ! -d "${wms_logs_dir}" ]; then
    mkdir -p "${wms_logs_dir}"
fi
 
if [ "${wms_logs_dir_size}" -gt 2097152 ]; then
    find "${wms_logs_dir}" -type f \( -name "*.log" \) -size +100M -exec rm {} \; > /dev/null 2>&1 &
fi

# Systemd log
(systemd-analyze blame > ~/.sysAnalyze) > /dev/null 2>&1

[[ "$XDG_SESSION_TYPE" = "wayland" ]] && export MOZ_ENABLE_WAYLAND=1

# FIX XDG HOME DIRS
[[ ! -d ~/Pictures ]] && rm ~/.config/user-dirs.dirs && LANG=en xdg-user-dirs-update > /dev/null 2>&1

# function read
# automatically run startx when logging in on tty1

rm ~/.startx_log
touch ~/.startx_log
clear

local_count() {
    echo "${shell_color_palette[bgreen]}Exiting:${shell_color_palette[color_off]}"
    for i in {1..2}; do
        echo -n "${i}. "
        sleep 0.4
    done
    clear
}

cursor_theme_fix()
{
    exec "${scripts}"/cursor-gtk-theme-fix.sh -t
}
cursor_theme_fix &

wm_wayland() {
    export __GLX_VENDOR_LIBRARY_NAME=intel
    export GTK_IM_MODULE=uim 
    export QT_IM_MODULE=uim 
    export XMODIFIERS=@im=uim 
    export XDG_CURRENT_DESKTOP="${wm_wayland}" 
    export WB_AUTOSTART_ENVIRONMENT=GNOME:KDE 
    export GDK_BACKEND=wayland 
    #export QT_QPA_PLATFORM=wayland
    export QT_STYLE_OVERRIDE=kvantum #QT_STYLE_OVERRIDE=gtk2 # needed qt5-styleplugins
    export WLR_NO_HARDWARE_CURSORS=1 
    export MOZ_ENABLE_WAYLAND=1 
    #export MOZ_USE_XINPUT2=1   # causes crashes
    export XDG_SESSION_TYPE=wayland 
    #/usr/bin/dbus-daemon --session --address=unix:path=/tmp/dbus-session-socket &
    #export DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/dbus-session-socket

    # WM LOG OUTPUT
    echo -e "${wm_wayland} log - $(date +'%d/%m/%Y - %T')\n\
------------------------------------\n\n" >> "${wms_logs_dir}"/"${wm_wayland}_$(date +'%d-%m-%Y - %T')".log > /dev/null 2>&1

    eval "${wm_wayland}" "$@" >> "${wms_logs_dir}"/"${wm_wayland}_$(date +'%d-%m-%Y - %T')".log > /dev/null 2>&1

}

standard_wm() {
    standard_wm_conf="${HOME}/.standard_wm.conf"
    [[ ! -f "${standard_wm_conf}" ]] && touch "${standard_wm_conf}"

    if [ "${wm_wayland}" ]
    then
        echo 'protocol=1' | tee "${standard_wm_conf}" > /dev/null 2>&1
        echo -e "swm=${wm_wayland}" | tee -a "${standard_wm_conf}" > /dev/null 2>&1
    fi

    if [ "${start_wm}" ]
    then
        echo 'protocol=2' | tee "${standard_wm_conf}" > /dev/null 2>&1
        echo -e "swm=${start_wm}" | tee -a "${standard_wm_conf}" > /dev/null 2>&1
    fi
}

echo -e "\n${shell_color_palette[byellow]}Choose an Option:\n"
echo -e "${shell_color_palette[bpurple]}1 - Wayland"
echo -e "${shell_color_palette[bwhite]}2 - X11"
echo -e "${shell_color_palette[bcyan]}3 - Terminal${shell_color_palette[color_off]}"
echo
read -r option
echo

clear

case "$option" in
    "1")
        echo -e "\n${shell_color_palette[byellow]}Choose an Option:\n"
        echo -e "${shell_color_palette[bwhite]}0 - Wayfire - Wayland"
        echo -e "${shell_color_palette[bgreen]}1 - LabWC - Wayland"
        echo -e "${shell_color_palette[bcyan]}2 - Sway - Wayland${shell_color_palette[color_off]}"
        echo -e "${shell_color_palette[ipurple]}3 - Hyprland - Wayland${shell_color_palette[color_off]}"
        echo -e "${shell_color_palette[iyellow]}4 - Weston - Wayland${shell_color_palette[color_off]}"
        echo -e "${shell_color_palette[cyan]}5 - Hikari - Wayland${shell_color_palette[color_off]}"
        echo -e "${shell_color_palette[bred]}6 - Back Menu${shell_color_palette[color_off]}"
        echo
        read -r WM
        echo
            case "$WM" in
                "0")
                    wm_wayland='wayfire -d'
                    standard_wm
                    wm_wayland
                    local_count
                    exit
                ;;
                "1")
                    wm_wayland=labwc
                    standard_wm
                    wm_wayland
                    local_count
                    exit
                ;;
                "2")
                    wm_wayland='sway --unsupported-gpu'
                    standard_wm
                    wm_wayland
                    local_count
                    exit
                ;;
                "3")
                    wm_wayland=Hyprland 
                    standard_wm
                    wm_wayland
                    local_count
                    exit
                ;;
                "4")
                    wm_wayland=weston 
                    standard_wm
                    wm_wayland
                    local_count
                    exit
                ;;
                "5")
                    wm_wayland=hikari
                    standard_wm
                    wm_wayland
                    local_count
                    exit
                ;;        
                "6")
                    local_count
                    source "${file}"
                ;;
                *)
                    echo -e "${shell_color_palette[bred]}Wrong Option!${shell_color_palette[color_off]}"
                    local_count
                    source "${file}"
                ;;
            esac
    ;;
    "2")
        echo -e "\n${shell_color_palette[byellow]}Choose an Option:\n"
        echo -e "${shell_color_palette[bwhite]}0 - Fluxbox - X11"
        echo -e "${shell_color_palette[bgreen]}1 - Openbox - X11"
        echo -e "${shell_color_palette[byellow]}2 - JWM - X11${shell_color_palette[color_off]}"
        echo -e "${shell_color_palette[bcyan]}3 - PekWM - X11${shell_color_palette[color_off]}"
        echo -e "${shell_color_palette[ipurple]}4 - Awesome - X11${shell_color_palette[color_off]}"
        echo -e "${shell_color_palette[iyellow]}5 - BlackBox - X11${shell_color_palette[color_off]}"
        echo -e "${shell_color_palette[cyan]}6 - i3WM - X11${shell_color_palette[color_off]}"
        echo -e "${shell_color_palette[iwhite]}7 - BSPWM - X11${shell_color_palette[color_off]}"
        echo -e "${shell_color_palette[bgreen]}8 - Trinity - X11${shell_color_palette[color_off]}"
        echo -e "${shell_color_palette[bred]}9 - Back Menu${shell_color_palette[color_off]}"
        echo
        read -r WM
        echo
            case "$WM" in
                "0")
                    export start_wm='fluxbox'
                    standard_wm
                    [ $XDG_VTNR ] && exec startx >> ~/.startx_log > /dev/null 2>&1
                    local_count
                    exit
                ;;
                "1")
                    export start_wm='openbox'
                    standard_wm
                    [ $XDG_VTNR ] && exec startx >> ~/.startx_log > /dev/null 2>&1
                    local_count
                    exit
                ;;
                "2")
                    export start_wm='jwm'
                    standard_wm
                    [ $XDG_VTNR ] && exec startx >> ~/.startx_log > /dev/null 2>&1
                    local_count
                    exit
                ;;
                "3")
                    export start_wm='pekwm'
                    standard_wm
                    [ $XDG_VTNR ] && exec startx >> ~/.startx_log > /dev/null 2>&1
                    local_count
                    exit
                ;;
                "4")
                    export start_wm='awesome'
                    standard_wm
                    [ $XDG_VTNR ] && exec startx >> ~/.startx_log > /dev/null 2>&1
                    local_count
                    exit
                ;;
                "5")
                    export start_wm='blackbox'
                    standard_wm
                    [ $XDG_VTNR ] && exec startx >> ~/.startx_log > /dev/null 2>&1
                    local_count
                    exit
                ;;
                "6")
                    export start_wm='i3'
                    standard_wm
                    [ $XDG_VTNR ] && exec startx >> ~/.startx_log > /dev/null 2>&1
                    local_count
                    exit
                ;;
                "7")
                    export start_wm='bspwm'
                    standard_wm
                    [ $XDG_VTNR ] && exec startx >> ~/.startx_log > /dev/null 2>&1
                    local_count
                    exit
                ;;
                "8")
                    export start_wm='trinity'
                    standard_wm
                    [ $XDG_VTNR ] && exec startx >> ~/.startx_log > /dev/null 2>&1
                    local_count
                    exit
                ;;
                "9")
                    local_count
                    source "${file}"
                ;;
                *)
                    echo -e "${shell_color_palette[bred]}Wrong Option!${shell_color_palette[color_off]}"
                    local_count
                    source "${file}"
                ;;
            esac
    ;;
    "3")
        echo -e "${shell_color_palette[bgreen]}Welcome terminal!${shell_color_palette[color_off]}\n"
        zsh
        local_count
        source "${file}"
    ;;
    *)
        protocol=$(cat ~/.standard_wm.conf | head -n1 | cut -f2 -d'=')
        swm=$(cat ~/.standard_wm.conf | tail -n1 | cut -f2 -d'=')

        if [ "${protocol}" = 1 ]; then
            wm_wayland="${swm}"
            wm_wayland
            local_count
        elif [ "${protocol}" = 2 ]; then
            export start_wm="${swm}"
            [ "$XDG_VTNR" ] && exec startx >> ~/.startx_log > /dev/null 2>&1
            local_count
        else
            echo -e "${shell_color_palette[bred]}Wrong Option!${shell_color_palette[color_off]}"
            local_count
            source "${file}"
        fi
    ;;
esac

fi
fi