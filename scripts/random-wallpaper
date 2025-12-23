#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Load a random wallpaper.
DOCUMENTATION

# Define a signal handler to capture SIGINT (Ctrl+C)
trap 'kill $(jobs -p)' SIGTERM #SIGHUP #SIGINT #SIGQUIT #SIGABRT #SIGKILL #SIGALRM #SIGTERM

doc() {
    less -FX "${0}" | head -n6 | tail -n1
}

help() {
    doc
    echo "Usage: ${0##*/} [args]

    -o,
        Set a random wallpaper once
    -r,
        Sets a wallpaper every X minutes. Default is 5 minutes

Example:
        minutes=2 ${0##*/} -r"
}

if [[ -z "${1}" ]]; then
    help
    exit 0
fi

#data_dirs=${XDG_DATA_DIRS:-${datadir:-/usr/share}}:${XDG_DATA_HOME:-~/.local/share}
wallpaper_dir="${HOME}/Pictures/Wallpapers/"
minutes="${minutes:-5}"
delay="${minutes}m"

cd "${wallpaper_dir}" || exit 0
wallpapers=(*.[JjPpSsGg][PpNnVvIi][GgFf])

wall_app_wayland_check_daemon() {
    while true
        do swww=$(pidof swww-daemon)
        sleep 10
        if [ -z "${swww}" ]; then
            swww init &
        fi
        sleep "$delay"
    done
}

if [[ "$XDG_SESSION_TYPE" == x11 ]]; then

    if command -v feh; then
		export wall_app='feh --bg-fill'
	else
		export wall_app='nitrogen --set-auto'
	fi    

elif [[ "$XDG_SESSION_TYPE" == wayland ]]; then
    export wall_app='swww img'
    wall_app_wayland_check_daemon &
fi

random_wallpaper() {
    while true
        do
            for i in "${wallpaper_dir}/${wallpapers[@]}"
            do
                eval "${wall_app}" "${i}" || exit 0
                sleep "${delay}"
            done
    done
}

only_set_random_wallpaper() {
	xrefresh -white
	sleep 2
    eval "${wall_app}" "$(find "${wallpaper_dir}" -name '*[jJpP][nNpP][gG]' | shuf -n 1)" || exit 0
}

while [[ $# -gt 0 ]]; do
    case "${1}" in
        -o)
            only_set_random_wallpaper
            shift
            continue
            ;;
        -r)
            random_wallpaper
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