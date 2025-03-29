#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

# Define a signal handler to capture SIGINT (Ctrl+C)
trap 'kill $(jobs -p)' SIGTERM #SIGHUP #SIGINT #SIGQUIT #SIGABRT #SIGKILL #SIGALRM #SIGTERM

# User-specific variables should be placed in ${HOME}/.config/openbox/environment
export DISPLAY=:0
# set main XDG variables
start_wm="${start_wm:-openbox}"
export XDG_CONFIG_DIRS=/etc/xdg
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_DIRS=/usr/local/share:/usr/share
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_CURRENT_DESKTOP="${start_wm}"
export XDG_SESSION_DESKTOP="${start_wm}"
export XDG_MENU_PREFIX="${start_wm}-"
export XDG_SESSION_TYPE=x11

# clean DM influence
export DESKTOP_SESSION="${start_wm}"
unset GDMSESSION

# Vblank
export vblank_mode=0
export __GL_SYNC_TO_VBLANK=0

# for reducing GTK stderr spam
export NO_AT_BRIDGE=1

# fix and sync Qt and GTK theming
export GTK2_RC_FILES="${HOME}/.gtkrc-2.0:${XDG_CONFIG_HOME}/gtk-2.0/gtkrc:/etc/gtk-2.0/gtkrc"
export QT_QPA_PLATFORMTHEME=gtk2
export QT_QPA_PLATFORM=xcb
export QT_STYLE_OVERRIDE=gtk2
export GTK_RC_FILES="${XDG_CONFIG_HOME:-${HOME}/.config}/gtk-3.0/settings.ini"

# Scripts dir
scripts=~/.shell_utils/scripts

# Default delay loop
delay=10

gnome_keyring_fix() {
    exec "${scripts}"/gnome-keyring-fix.sh
}

# Cursor Theme fix for WMs: openbox, i3 and more...
# How to use lxappearance
xsetroot -cursor_name left_ptr >/dev/null 2>&1
xrdb -merge ~/.Xresources >/dev/null 2>&1

only_xrdb() {
    exec "${scripts}"/cursor_theme_fix.sh -o
}

alarm_daemon() {
	! pgrep -f alarm-daemon-multilingual.sh && exec "${scripts}"/alarm-daemon-multilingual.sh -r
}

# Restore persistent volume TV
restore_persistent_volume_tv_lg() {
    local script_restore=~/.local/bin/tv-default-volume.sh
    
    old_vol=$(cat "$script_restore" | head -5 | sed -n 5p | cut -c 16-17 | grep -E "[^[:blank:]]")
    sed -i "5 s|$old_vol|12|g" "$script_restore"
    ~/.local/bin/tv-default-volume.sh &
    ~/.local/bin/fix_no-at_shutdown_lgtv.sh &
    #eval $(atrm $(seq 999); at -f ~/.local/bin/at-lgtv.sh 23:59) &
}

has_the_kernel_been_updated() {
    exec "${scripts}"/kernel_check_update.sh
}

battery_check() {
    exec "${scripts}"/simple_battery_manager.sh
}

monitor_mode() {
    sleep 2

    ###xrandr --setprovideroutputsource modesetting modesetting &  # restar x
    ###xrandr --auto
    ###--rate 120.00

    xrandr --output eDP-1-1 --primary --mode 1920x1080 --auto \
        --pos 0x0 --rotate normal --output HDMI-0 --off

    sleep 2
    #cvt 1920 1080
    #xrandr -s 1920x1080 --auto
    xrandr --newmode "1920x1080_148"  148.50  1920 2008 2052 2200  1080 1084 1089 1125 +hsync +vsync
    xrandr --verbose --addmode eDP-1-1 "1920x1080_148"
    xrandr --output eDP-1-1 --mode "1920x1080_148"
    xrandr --newmode "$(cvt 1920 1080 | tail -n1 | sed 's#Modeline ##g' | sed 's#"##g')"
    xrandr --verbose --addmode eDP-1-1 "$(cvt 1920 1080 | tail -n1 | awk '{print $2}' | sed 's#"##g')"
    xrandr --output eDP-1-1 --mode "$(cvt 1920 1080 | tail -n1 | awk '{print $2}' | sed 's#"##g')"
    xrandr -s 1920x1080 -r 70
    xrandr -s 1920x1080 -r 75
    xrandr -s 1920x1080 -r 89
    #xrandr -s "1920x1080_148" --auto
    xrandr -s "$(cvt 1920 1080 | tail -n1 | awk '{print $2}' | sed 's#"##g')" --auto
}

random_wallpaper() {
    exec "${scripts}"/random_wallpaper.sh -o
}

start_sound() {
    exec "${scripts}"/fix_pulseaudio.sh
}

# persistent pid of openbox, tint2 and more...
persistent_pid() {

    rm ~/.wm_log
    touch ~/.wm_log
    while true
        do wm=$(pidof "${start_wm}")
        tint2=$(pidof tint2)
        xpad=$(pidof xpad)
        parcellite=$(pidof parcellite)
        #transmission=`pidof transmission-gtk`

    ######## MY WM:
            if [ -z "${wm}" ]; then
                if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
                        # if not found, launch a new one
                        export "$(dbus-launch)" &
                        eval "$(dbus-launch --sh-syntax --exit-with-session ${start_wm})" &
                        echo "D-Bus per-session daemon address is: $DBUS_SESSION_BUS_ADDRESS"
                        monitor_mode &
                else
                        # WM LOG OUTPUT
                        echo -e "${start_wm} log - $(date +'%d/%m/%Y - %T')\n\
    ------------------------------------\n\n" >> "${wms_logs_dir}"/"${start_wm}_$(date +'%d-%m-%Y - %T')".log

                        if [ "${start_wm}" = openbox ]; then
                            "${start_wm}" --debug >> "${wms_logs_dir}"/"${start_wm}_$(date +'%d-%m-%Y - %T')".log &
                        elif [ "${start_wm}" = fluxbox ]; then
                            "${start_wm}" -log "${wms_logs_dir}"/"${start_wm}_$(date +'%d-%m-%Y - %T')".log &
                        elif [ "${start_wm}" = trinity ]; then
                            exec /opt/trinity/bin/starttde >> "${wms_logs_dir}"/"${start_wm}_$(date +'%d-%m-%Y - %T')".log
                        else
                            exec "${start_wm}" >> "${wms_logs_dir}"/"${start_wm}_$(date +'%d-%m-%Y - %T')".log &
                        fi

                        monitor_mode &
                fi
            fi

    ######## TINT2 SLAVE PIDs
            if [[ "${start_wm}" != fluxbox ]] && [[ "${start_wm}" != blackbox ]] \
            && [[ "${start_wm}" != awesome ]] && [[ "${start_wm}" != trinity ]] \
            && [ "${wm}" ] && [ -z "${tint2}" ]; then
                xrefresh
                tint2 &
            fi
            if [ "${tint2}" ] && [ -z "${parcellite}" ]; then
                parcellite &
            fi
            if [ "${tint2}" ] && [ -z "${xpad}" ]; then
                xpad -h &
            fi
            #if [ -n "${tint2}" ] && [ -z "${transmission}" ]; then
            #    exec transmission-gtk -m &
            #fi
        sleep "$delay"
    done
}

delay_exec() {
    sleep "$delay";
    exec transmission-gtk -m;
}

# Suspend if inert 
suspend_if_inert() {
    exec "${scripts}"/suspend_if_inert.sh
}

# this file is run when calling startx
# default arch init scripts
#if [ -d /etc/X11/xinit/xinitrc.d ]; then
#    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
#        [ -x "$f" ] && . "$f"
#    done
#fi

# user init scripts and settings
#[ -r /etc/X11/xinit/.Xmodmap ] && xmodmap /etc/X11/xinit/.Xmodmap
#[ -r ~/.Xmodmap ] && xmodmap ~/.Xmodmap
#[ -r ~/.Xresources ] && xrdb -merge ~/.Xresources
#[ -r ~/.xprofile ] && . ~/.xprofile

####################################################################
########################## START SERVICES ##########################
if [[ "${start_wm}" != trinity ]] && [[ "${start_wm}" != awesome ]]; then
	### Video ##
	xcompmgr &
	#picom --experimental-backends --backend glx --xrender-sync-fence &
	random_wallpaper &
	xrefresh
	monitor_mode &
		
	### Daemons ###
	#/usr/lib/mate-settings-daemon/mate-settings-daemon &
	/usr/lib/notify-osd/notify-osd &
	#/usr/lib/mate-notification-daemon/mate-notification-daemon &
	
	### System e more ###
	delay_exec &
	numlockx on &
fi

# Gnome Keyring fix
gnome_keyring_fix &

# LG TV
restore_persistent_volume_tv_lg &

### Sound ###
start_sound &

### Battery ###
battery_check &

### Alarm ###
alarm_daemon &

# Notifies if the kernel has been updated
has_the_kernel_been_updated &

### Lock and ScreenSaver ###
#screen -S suspend_if_inert -d -m bash &
#screen -r suspend_if_inert -X stuff "suspend_if_inert" &
suspend_if_inert &

### Fix Mouse Theme ###
only_xrdb &

### WM / tint2 e more..
persistent_pid

# Wait for all child processes to finish
wait