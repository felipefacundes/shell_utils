#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
# Script name: flash-screen.sh

The 'flash-screen.sh' script is a versatile screen gamma manipulation utility designed 
to work across both X11 and Wayland display servers. Its key capabilities include:

1. Cross-Platform Compatibility: Dynamically detects and supports both X11 and Wayland environments, 
with specific gamma control mechanisms for each display server type.

2. Sophisticated Screen Flashing Mechanism: Implements a strobe-like effect by rapidly cycling through 
predefined gamma configurations, creating a visual flashing or strobing screen effect.

3. Robust Error Handling: Checks for required dependencies like 'xrandr' or 'wl-gammactl' before execution, 
providing clear error messages if essential tools are missing.

4. Automatic Settings Restoration: Includes a comprehensive cleanup function that ensures original monitor 
settings are restored when the script terminates, preventing permanent display configuration changes.

5. Configurable Parameters: Offers flexible gamma configurations for both X11 and Wayland, with adjustable 
waiting times between gamma changes and multiple gamma preset arrays.

The script demonstrates advanced shell scripting techniques, including conditional execution, trap handling, 
background process management, and dynamic system environment detection.
DOCUMENTATION

if [[ ${XDG_SESSION_TYPE,,} == [xX]11 ]] && ! command -v xrandr &> /dev/null; then
    echo "Error: 'xrandr' command not found. Please install it to proceed." >&2
    exit 1
elif [[ ${XDG_SESSION_TYPE,,} == [wW][aA][yY][lL][aA][nN][dD] ]] && ! command -v wl-gammactl &> /dev/null; then
    echo "Error: 'wl-gammactl' command not found. Please install it to proceed." >&2
    exit 1
fi

# Gamma configurations for Wayland and X11
gamma_configs_wayland=("1" "1.500")
gamma_configs_x11=("2.0:0.5:0.5" "0.5:2.0:0.5" "0.5:0.5:2.0")   # hard
#gamma_configs_x11=("1:1:1" "1:2:1" "1:1:2" "2:1:1")            # smooth

# Waiting time between gamma changes (in seconds)
wait_time=0.3

# Variables to restore original settings in X11
original_gamma=""
original_brightness=""

# Get the active monitor output name
output_name=$(xrandr --listmonitors | grep '+' | awk '{print $4}')

# Check if the monitor output was detected
if [[ -z "$output_name" ]]; then
    echo "Unable to detect monitor output"
    exit 1
fi

# Function to capture the current monitor settings (X11)
_capture_original_settings() {
    original_gamma=$(xrandr --verbose | grep -A 5 "^$output_name" | grep "Gamma:" | awk '{print $2}')
    original_brightness=$(xrandr --verbose | grep -A 5 "^$output_name" | grep "Brightness:" | awk '{print $2}')
    if [[ -z "$original_gamma" || -z "$original_brightness" ]]; then
        echo "Error capturing original settings. Check the xrandr status."
        exit 1
    fi
}

# Function to restore the original monitor settings (X11)
_restore_original_settings() {
    if [[ -n "$original_gamma" && -n "$original_brightness" ]]; then
        xrandr --output "$output_name" --gamma "$original_gamma" --brightness "$original_brightness"
    else
        echo "Original settings not captured. No restoration possible."
    fi
}

# Function to terminate wl-gammactl (Wayland)
_stop_wl_gammactl() {
    while :; do
        if pidof wl-gammactl >/dev/null 2>&1; then
            pkill -9 wl-gammactl
        fi
        sleep "$wait_time"
    done
}

# Main function for the strobe effect
_flash_screen() {
    trap 'cleanup' EXIT  # Restore settings on exit

    if [[ ${XDG_SESSION_TYPE,,} == [wW][aA][yY][lL][aA][nN][dD] ]]; then
        while :; do
            for gamma_config in "${gamma_configs_wayland[@]}"; do
                wl-gammactl -c 1 -b 1 -g "$gamma_config"
                sleep "$wait_time"
            done
        done
    elif [[ ${XDG_SESSION_TYPE,,} == [xX]11 ]]; then
        _capture_original_settings  # Capture original settings before changing
        while :; do
            for gamma_config in "${gamma_configs_x11[@]}"; do
                xrandr --output "$output_name" --gamma "$gamma_config"
                sleep "$wait_time"
            done
        done
    fi
}

# Cleanup function to restore settings
cleanup() {
    if [[ ${XDG_SESSION_TYPE,,} == [xX]11 ]]; then
        _restore_original_settings
    elif [[ ${XDG_SESSION_TYPE,,} == [wW][aA][yY][lL][aA][nN][dD] ]]; then
        _stop_wl_gammactl
    fi
    exit 0
}

# Script entry point
_stop_wl_gammactl >/dev/null 2>&1 &
_flash_screen
