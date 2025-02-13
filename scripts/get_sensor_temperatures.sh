#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script provides a simple interface for managing temperature sensors on a system. 
Users can find available sensors and display their temperatures, with an option to colorize the output using 'lolcat'. 
It includes help documentation and handles command-line arguments for easy usage.
DOCUMENTATION

# Usage: $0 [options]
# 
# Options:
# -h, --help                  Show this help message and exit
# -f, --find-sensors          Find and display temperature sensors
# -t, --get-temperatures      Display temperatures of sensors
#     --color, -c, -l         Display output with lolcat if available (only with -t)
# 
# Examples:
# $0 -f                       Find and list available temperature sensors
# $0 -t                       Get and display sensor temperatures
# $0 -t --color               Display sensor temperatures with colors if lolcat is available

# General Help Menu Display Function
. ~/.shell_utils/modules_for_scripts/help_for_commented_texts.sh

# Lists the available sensors
find_temperature_sensor() {
    local sensors_output
    sensors_output=$(sensors 2>/dev/null)

    if echo "$sensors_output" | grep -q "temp1"; then
        temp1() {
            echo "$sensors_output" | grep --color=always -i "temp1"
        }

        if check_com -c lolcat; then
            temp1 | lolcat
        else
            temp1
        fi
    else
        echo "No temperature sensor found."
    fi
}

# Lists the temperatures of specific sensor
get_sensor_temperatures() {
    temp_sensor() {
        python3 - <<'END_PYTHON_SCRIPT'
import subprocess
import re

def get_sensor_temperatures():
    try:
        result = subprocess.run(['sensors'], capture_output=True, text=True)
        if result.returncode != 0:
            raise Exception(f"Error executing the 'sensors' command: {result.stderr}")

        sensor_info = re.findall(r'(\S+)-virtual-0\nAdapter: Virtual device\ntemp1:\s+([+-]?\d+\.\d+\u00B0C)', result.stdout)
        for sensor, temperature in sensor_info:
            print(f"{sensor}: {temperature}")

    except Exception as e:
        print(f"Error: {e}")

get_sensor_temperatures()
END_PYTHON_SCRIPT
    }

    temp_sensor_color() {
        if command -v lolcat 1>/dev/null; then
            temp_sensor | lolcat
        else
            temp_sensor
        fi
    }

    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo "Usage: get_sensor_temperatures [--color | -c | -l | --lolcat]"
        echo "  --color, -c, -l, --lolcat  Display the output with lolcat if available."
    elif [[ "$1" == "--color" || "$1" == "-c" || "$1" == "--lolcat" || "$1" == "-l" ]]; then
        temp_sensor_color
    else
        temp_sensor
    fi
}

# Processes the arguments
if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--find-sensors)
            find_temperature_sensor
            shift
            ;;
        -t|--get-temperatures)
            shift
            get_sensor_temperatures "$1"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done
