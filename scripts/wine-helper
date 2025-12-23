#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
# Linux Gaming Performance Management Script Analysis

This Bash script is a comprehensive system utility designed for Linux gaming optimization, 
particularly focusing on Wine-based gaming environments. Here are its key strengths and capabilities:

## Core Functionalities
1. Wine Process Management: Implements robust Wine process control through a specialized kill 
function that ensures complete termination of all Wine-related processes, including Steam and 
Epic Games processes. This is particularly useful when games crash or become unresponsive.

2. Process Priority Management: Features sophisticated process priority control through two distinct renice functions:
   - Wine-specific process priority adjustment
   - User-wide process priority management with predefined shortcuts (r1 through r4)
   - Visual feedback through top command integration

3. CPU Performance Optimization: Includes an advanced CPU frequency management system that:
   - Automatically detects maximum CPU frequency capabilities
   - Sets the CPU governor to performance mode
   - Configures optimal frequency settings for gaming

## Technical Strengths
- Error Handling: Implements comprehensive error checking for command-line arguments and CPU frequency detection
- User Feedback: Provides clear feedback for all operations through echo statements
- Modularity: Well-structured with separate functions for each major operation
- Documentation: Features a detailed help menu with clear usage instructions
- Flexibility: Supports both long and short command-line options for better usability

This script serves as a powerful tool for Linux gamers who need to optimize their system performance, particularly 
when running Windows games through Wine. Its combination of process management, CPU optimization, and user-friendly 
interface makes it an excellent utility for gaming performance enhancement.
DOCUMENTATION

# Function to forcefully kill wine processes
kill_wine() {
    ps ax | egrep '*\.exe' | grep -v 'egrep' | awk '{print $1 }' | xargs kill -9
    wineserver -k
    wineserver -k9
    pkill -9 .exe
    pkill -9 Steam
    pkill -9 steam
    pkill -9 Epic
    pkill -9 wine
    pkill -9 wineserver
    killall -9 wine wineserver
    killall -9 .exe
    echo "All wine-related processes have been forcefully terminated."
}

# Function to renice wine processes
renicewine() {
    local priority="$1"
    ps ax | egrep '*\.exe' | grep -v 'egrep' | awk '{print $1 }' | xargs sudo renice -n "$priority"
    echo "---"
    top -bn 1 | grep -Ei --color .exe
    echo "---"
    echo "Renice command executed with priority: $priority"
}

# Function to renice user processes
reniceuser() {
    local priority="$1"
    sudo renice -n "$priority" -u "$USER"
    echo "---"
    top -bn 1 | grep -Ei --color "$USER"
    echo "---"
    echo "Renice command executed for user $USER with priority: $priority"
}

# CPU performance configuration
game_performance_cpu() {
    max_frequency=$(LC_ALL=en cpupower frequency-info | awk '/hardware limits:/ {print $6}' | sed 's/GHz//g' | sort -nr | head -n 1)
    if [ -z "$max_frequency" ]; then
        echo "Unable to detect the maximum available CPU frequency."
        return 1
    fi
    sudo cpupower frequency-set -u ${max_frequency}G
    sudo cpupower frequency-set -g performance
    echo "CPU set to maximum performance mode at ${max_frequency}GHz."
}

# Help menu
show_help() {
    echo "Usage: ${0##*/} [option] [arguments]"
    echo "Options:"
    echo "  -h, --help                 Show this help menu."
    echo "  -k, --kill-wine            Forcefully terminate all wine-related processes."
    echo "  -r, --renice-wine PRIORITY Adjust the priority of wine processes to the specified level."
    echo "  -u, --renice-user PRIORITY Adjust the priority of all processes for the current user."
    echo "  -p, --performance-cpu      Set the CPU to maximum performance mode for gaming."
    echo ""
    echo "Shortcuts:"
    echo "  r1, r2, r3, r4             Renice user processes with pre-defined priority levels:"
    echo "                               r1: -2, r2: -3, r3: -5, r4: -7"
}

# Main script logic
case "$1" in
    -h|--help)
        show_help
        ;;
    -k|--kill-wine)
        kill_wine
        ;;
    -r|--renice-wine)
        if [[ -z "$2" ]]; then
            echo "Error: Priority level is required."
            show_help
            exit 1
        fi
        renicewine "$2"
        ;;
    -u|--renice-user)
        if [[ -z "$2" ]]; then
            echo "Error: Priority level is required."
            show_help
            exit 1
        fi
        reniceuser "$2"
        ;;
    -p|--performance-cpu)
        game_performance_cpu
        ;;
    r1)
        reniceuser -2
        ;;
    r2)
        reniceuser -3
        ;;
    r3)
        reniceuser -5
        ;;
    r4)
        reniceuser -7
        ;;
    *)
        echo "Invalid option: $1"
        show_help
        exit 1
        ;;
esac
