#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script manages system operations like reboot, shutdown, suspend, or hibernate, 
ensuring no action is taken if the 'pacman' package manager is active. It provides a 
simple command-line interface with options for each operation and includes safety checks 
to prevent interruptions during system updates.
DOCUMENTATION

show_help() {
    cat <<EOF
Usage: ${0##*/} [option]
Manages system shutdown, reboot, suspend, or hibernate.

Options:
  -r        Reboots the system.
  -p        Powers off the system.
  -s        Suspends the system.
  -h        Hibernates the system.

Note: The script checks if the 'pacman' package manager is running.
      If it is, no action will be taken, and a notification will be shown.

Example:
${0##*/} -r   Reboots the system immediately.
${0##*/} -p   Powers off the system immediately.
EOF
    exit 0
}

reboot_or_shutdown() {
    case "$1" in
        "-r")
            systemctl reboot 2>/dev/null
            /bin/openrc-shutdown --reboot now 2>/dev/null
            ;;
        "-p")
            systemctl poweroff 2>/dev/null
            /bin/openrc-shutdown --poweroff now 2>/dev/null
            ;;
        "-s")
            systemctl suspend
            ;;
        "-h")
            systemctl hibernate
            ;;
        *)
            show_help
            ;;
    esac
}

if ! pidof pacman >/dev/null; then 
    reboot_or_shutdown "$@"
else 
    notify-send 'System being updated, please wait.'
fi