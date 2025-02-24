#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script is designed to monitor kernel updates on a Linux system and prompt the user to reboot 
when an update is detected. 

Purpose:
- To ensure that the system is running the latest kernel version by notifying the user when an update 
occurs and facilitating a reboot.

Strengths:
1. Signal Handling: The script captures termination signals to cleanly manage background jobs.
2. Kernel Update Detection: It checks if the kernel has been updated by comparing the current 
and installed kernel versions.
3. User  Notification: Utilizes graphical notifications to inform the user about the need for 
a reboot after a kernel update.
4. Sound Alerts: Plays a sound alert to draw attention to the reboot prompt.
5. User  Interaction: Provides a user-friendly interface for confirming the reboot through a dialog box.

Capabilities:
- Monitors kernel updates continuously.
- Sends notifications and plays sounds to alert the user.
- Offers a simple yes/no dialog for reboot confirmation.
- Manages background processes effectively to ensure smooth operation.
DOCUMENTATION

# Define a signal handler to capture SIGINT (Ctrl+C)
trap 'kill $(jobs -p)' SIGTERM #SIGHUP #SIGINT #SIGQUIT #SIGABRT #SIGKILL #SIGALRM #SIGTERM

TMPDIR="${TMPDIR:-/tmp}"

delay=10
kernel_booted_temp_file=${TMPDIR}/kernel_booted.temp_file

if [[ ! -f "${kernel_booted_temp_file}" ]]; then
    touch "${kernel_booted_temp_file}"
    echo "$(LC_ALL=c ls -l /boot/initramfs-linux.img | awk '{print $6 $7 $8}')" | tee "${kernel_booted_temp_file}"
fi

beep_reboot() {

    beep=~/.shell_utils/sounds/system_reboot_pearl.ogg
    pactl upload-sample "$beep"
    paplay "$beep" --volume=76767
}

ask_reboot() {

    choose=$(zenity --title='System restart?' --list --text='Kernel updated successfully, system restart?' --radiolist --column 'Choice' --radiolist --column 'Choice' False 'Yes' True 'No')
    if [[ "$choose" == 'Yes' ]]; then
        systemctl reboot -i 
    fi
}

has_the_kernel_been_updated() {
    kernel_booted=$(cat "${kernel_booted_temp_file}")
    kernel_initiated="$(uname -r | sed 's|-|.|g')"

    while true
        do sleep "$delay"
        installed_kernel="$(LC_ALL=en pacman -Si linux | grep -i "^Version" | awk '{print $3}' | sed 's|-|.|g')"
        kernel_updated="$(LC_ALL=c ls -l /boot/initramfs-linux.img | awk '{print $6 $7 $8}')"
        lock_file="${TMPDIR}/has_the_kernel_been_updated.lock_file"
        icon=~/.shell_utils/icons/exclamation.png

        if [[ "$kernel_initiated" != "$installed_kernel" ]]; then
            if [[ "$kernel_booted" != "$kernel_updated" ]]; then
                [[ ! -f "${lock_file}.notification" ]] && notify-send -i "$icon" -u critical "Updated kernel" "Reboot system"
                if [[ ! -f "$lock_file" ]]; then 
                    sleep 15; ~/.shell_utils/scripts/systray_icon.py -i "$icon" -t "Reboot System" -m "Updated kernel" -n "Reboot system" &
                    sleep 15; beep_reboot & ask_reboot &
                    touch "$lock_file"
                fi
            fi
        fi
        sleep 15
    done
}

has_the_kernel_been_updated &
pid=$!

# Wait for all child processes to finish
wait "$pid"