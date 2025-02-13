#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
The provided Bash script is designed to manage system inactivity by locking the screen and suspending 
the system after a specified period of inactivity. Its main purpose is to enhance security and conserve 
energy by automatically locking the screen and putting the system into a low-power state when not in use.

Strengths:
1. Signal Handling: The script includes a signal handler to gracefully terminate child processes when interrupted.
2. Configurable Settings: Users can easily configure lock screen and suspend timings through a dedicated configuration file.
3. Idle Detection: It effectively detects user inactivity using the 'xprintidle' command to determine when to lock the screen or suspend the system.
4. Multiple Locking Options: The script supports different locking mechanisms, including 'xscreensaver' and 'slimlock', providing flexibility based on user preference.
5. DPMS Management: It manages Display Power Management Signaling (DPMS) settings to prevent screen blanking or to enable it based on user-defined parameters.

Capabilities:
- Automatically locks the screen after a user-defined period of inactivity.
- Puts the system into suspend mode based on user-defined settings.
- Logs actions taken (like locking and suspending) with timestamps for monitoring.
- Adjusts DPMS settings to manage power consumption effectively.
DOCUMENTATION

# Define a signal handler to capture SIGINT (Ctrl+C)
trap 'kill $(jobs -p)' SIGTERM #SIGHUP #SIGINT #SIGQUIT #SIGABRT #SIGKILL #SIGALRM #SIGTERM

# Inert suspend
# Convert minutes to milliseconds
# 15 minutes = (15 * 60) * 1000
# get_mouse_pointer=`echo $(xdotool getmouselocation | grep -oP "[0-9]+ y:[0-9]+" | sed 's/ y://' | tr -d '\n')`

delay=10

while true
    do sleep "$delay"
        numlockx on         # Enabled numlock

        log_file="/tmp/suspend_if_inert.log"
        config_file="${HOME}/.suspend_if_inert.conf"

            if [ ! -f "${log_file}" ]; then
                touch "${log_file}"
                echo `date +'%d/%m/%Y - %T'` | tee "${log_file}"
                #echo "PID of this script: $$" | tee -a "${log_file}"
            fi

            if [ ! -f "${config_file}" ]; then
                touch "${config_file}"
                echo '# The number must be greater than 0' | tee "${config_file}"
                echo '# Set the screen lock minutes.' | tee -a "${config_file}"
                echo 'Lockscreen = 0' | tee -a "${config_file}"
                echo '# Set the minutes of DPMS - Display Power Management Signaling.' | tee -a "${config_file}"
                echo '# DPMS to disabled is 0.' | tee -a "${config_file}"
                echo 'DPMS = 0' | tee -a "${config_file}"
                echo '# Set the system sleep minutes.' | tee -a "${config_file}"
                echo 'Suspend = 0' | tee -a "${config_file}"
            fi

        idle=$(xprintidle)
        lockscreen_minutes=$(cat "${config_file}" | head -3 | tail -1 | sed '/^$/d' | cut -f2 -d'=' | sed '/^$/d')
        lockscreen_milliseconds=$(echo "$(((${lockscreen_minutes}*60)*1000))")
        dpms_minutes=$(cat "${config_file}" | head -6 | tail -1 | sed '/^$/d' | cut -f2 -d'=' | sed '/^$/d')
        dpms_seconds=$(echo "$((${dpms_minutes}*60))")
        suspend_minutes=$(cat "${config_file}" | head -8 | tail -1 | sed '/^$/d' | cut -f2 -d'=' | sed '/^$/d')
        suspend_milliseconds=$(echo "$(((${suspend_minutes}*60)*1000))")

        _var_update()
        {
            pid_xscrsaver=`pidof xscreensaver`
            pid_xscrsaver_gfx=`pidof xscreensaver-gfx`
            pid_slimlock=`pidof slimlock`
        }

        if [ "${lockscreen_minutes}" -gt 0 ]; then
            if [ "${idle}" -gt "${lockscreen_milliseconds}" ]; then

                _var_update

                if [ -z "${pid_xscrsaver}" ] && [ -z "${pid_slimlock}" ]; then
                    pkill -9 xscreensaver;
                    xscreensaver-command -exit >/dev/null 2>&1;
                    xscreensaver -no-splash >/dev/null 2>&1 &
                fi

                _var_update

                if ([ "${pid_xscrsaver}" ] && [ -z "${pid_xscrsaver_gfx}" ]) && [ -z "${pid_slimlock}" ]; then
                    echo "Lockscreen at `date +'%T'`" | tee -a "${log_file}"
                    xscreensaver-command -lock >/dev/null 2>&1 &
                    sleep 4 && xrefresh
                fi

                _var_update

                if [ -z "${pid_xscrsaver}" ] && [ -z "${pid_slimlock}" ]; then
                    echo "Lockscreen at `date +'%T'`" | tee -a "${log_file}"
                    slimlock >/dev/null 2>&1 &
                    sleep 4 && xrefresh
                fi
            fi
        fi

        if [ "${dpms_minutes}" -gt 0 ]; then
            standby=`LC_ALL=C xset q | awk '/Standby:/ {print $4}'`
            dpms_check=`LC_ALL=C xset q | awk '/DPMS is Disabled/'`

            if [ "${standby}" != "${dpms_seconds}" ]; then
                xset dpms 0 "${dpms_seconds}" "${dpms_seconds}"
            fi
            if [ "${dpms_check}" = '  DPMS is Disabled' ]; then
                xset dpms
            fi

        else
            xset -dpms          # Disable DPMS and prevent screen from blanking
            xset s off -dpms    # Disable DPMS and prevent screen from blanking
        fi

        if [ "${suspend_minutes}" -gt 0 ]; then
            if [ "${idle}" -gt "${suspend_milliseconds}" ]; then

                _var_update

                if ([ "${pid_xscrsaver_gfx}" ] || [ "${pid_slimlock}" ]) && [ "${idle}" -gt "${suspend_milliseconds}" ]; then
                    sleep 4
                    echo "Suspended at `date +'%T'`" | tee -a "${log_file}"
                    systemctl suspend
                fi
            fi

        fi
done

# Wait for all child processes to finish
wait