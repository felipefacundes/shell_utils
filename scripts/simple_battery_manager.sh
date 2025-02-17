#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script is a battery monitoring tool designed to alert users when their laptop's battery level falls below certain 
thresholds and to initiate a shutdown if necessary. 

Purpose:
- To monitor battery status and provide alerts based on battery percentage.

Strengths:
1. Real-time Monitoring: Continuously checks battery status every 20 seconds.
2. User  Notifications: Sends critical notifications to the user when battery levels are low.
3. Shutdown Mechanism: Automatically shuts down the system if the battery level drops below 30%, ensuring data safety.
4. Lock File Management: Prevents multiple shutdown alerts from being triggered simultaneously.
5. Logging: Records shutdown events in a log file for future reference.

Capabilities:
- Detects battery status using the 'acpi' command.
- Utilizes 'notify-send' for user-friendly notifications.
- Handles various battery percentage ranges with specific actions for each range.
DOCUMENTATION

# Define a signal handler to capture SIGINT (Ctrl+C)
trap 'kill $(jobs -p)' SIGTERM #SIGHUP #SIGINT #SIGQUIT #SIGABRT #SIGKILL #SIGALRM #SIGTERM

TMPDIR="${TMPDIR:-/tmp}"

icon=~/.shell_utils/icons/exclamation.png
log_file=~/.battery_check_unplugged.log
lock_file="${TMPDIR}/battery_check_unplugged.lock_file"
shutdown=false

while true
    do sleep 20
    battery_check=$(LC_ALL=c acpi | awk '{ print $6 }')
    percent=$(LC_ALL=c acpi | sed 's/,/\n/g' | head -n2 | tail -n1 | sed 's/[[:space:]]//g' | cut -f 1 -d'%')

    if [[ "$percent" =~ ^[0-9]+$ ]] && [[ "$battery_check" == "remaining" ]]; then

        if (( "$percent" > 35 )) && (( "$percent" < 60 )); then
            [[ ! -f "$lock_file" ]] && notify-send -i "$icon" -u critical "<b>Battery Alert</b>" "Power Unplugged"

        elif (( "$percent" > 1 )) && (( "$percent" < 30 )); then
            touch "$lock_file"
            sleep 15
            notify-send -i "$icon" -u critical "<b>Battery Alert</b>" "Battery below 30%.\nThe system will be shutdown"

            if ! pidof pacman >/dev/null; then
                [[ ! -f "$log_file" ]] && touch "$log_file"
                [[ "$shutdown" != true ]] && shutdown=true && echo -e "System shutdown: $(LC_ALL=c date "+%Y-%m-%d | %H:%M:%S")" >> "$log_file"
                systemctl poweroff
            else
                sleep 5
                notify-send -i "$icon" -u critical "<b>Battery Alert</b>" "Battery below 30%.\nYour system will be shutdown soon."
            fi
        elif (( "$percent" > 1 )) && (( "$percent" < 35 )); then
            notify-send -i "$icon" -u critical "<b>Battery Alert</b>" "Battery below 35%.\nYour system will be shutdown soon"
            sleep 15
        fi
    fi
done

# Wait for all child processes to finish
wait
