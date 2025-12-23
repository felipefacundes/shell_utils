#!/usr/bin/env fish
# License: GPLv3
# Credits: Felipe Facundes

: "
SHELL BEEP NOTIFICATION SYSTEM - SHELL_UTILS FRAMEWORK

DESCRIPTION:
    This script configures an audio notification system for Fish shell,
    integrated with the SHELL_UTILS framework. When enabled, it emits
    a sound after each command execution in the terminal.

REQUIREMENTS:
    - Must be loaded via 'source' in the current shell
    - beep-sound script must be located at ~/.shell_utils/scripts/
    - Sound support on the system (afplay on macOS, paplay on Linux, etc)

INSTALLATION:
    source /path/to/this/script.fish

CONFIGURATION:
    The system uses a configuration file at:
    ~/.shell_utils_configs/shell_utils_notifications.conf

    To ENABLE sound:
        echo 'set BEEP 1' | tee ~/.shell_utils_configs/shell_utils_notifications.conf

    To DISABLE sound:
        echo 'set BEEP 0' | tee ~/.shell_utils_configs/shell_utils_notifications.conf

    To ENABLE notifications:
        echo 'set NOTIFY 1' | tee -a ~/.shell_utils_configs/shell_utils_notifications.conf

    To DISABLE notifications:
        echo 'set NOTIFY 0' | tee -a ~/.shell_utils_configs/shell_utils_notifications.conf

FEATURES:
    - Creates a 'beep_sound' function to play sound in background
    - Suppresses all command output (PID, etc)
    - Uses Fish event system to monitor command completion
    - Removes temporary variables after configuration

COMPATIBILITY:
    - Fish 3.0+
    - macOS (afplay) and Linux (paplay/other)

CREATED FUNCTION:
    beep_sound - Executes the sound script in background without output

FILES:
    ~/.shell_utils_configs/shell_utils_notifications.conf - Configuration
    ~/.shell_utils/scripts/beep-sound - Main sound script

USAGE EXAMPLES:
    # Reload configuration
    source ~/.shell_utils/scripts/shell_beep_sound.fish

    # Temporarily enable/disable
    set -gx BEEP 1  # Enable
    set -gx BEEP 0  # Disable
    set -gx NOTIFY 1  # Enable notifications
    set -gx NOTIFY 0  # Disable notifications

    # Test sound manually
    beep_sound

NOTES:
    - Sound is executed in background to not block the terminal
    - All output is redirected to /dev/null
    - The system respects persistent configuration in the .conf file
"

set -g CONFIG_DIR "$HOME/.shell_utils_configs"
set -g CONFIG_FILE "$CONFIG_DIR/shell_utils_notifications.fish_conf"

function beep_sound --description "Play beep sound silently"
    ~/.shell_utils/scripts/beep-sound -d >/dev/null 2>&1 &
end

# Create config file if it doesn't exist
if not test -f "$CONFIG_FILE"
    mkdir -p "$CONFIG_DIR"

    echo "
# Shell Utils Notifications Configuration
# 
# BEEP: Audio feedback after command completion
#   set BEEP 1 - Enable sound notifications
#   set BEEP 0 - Disable sound notifications
#
# NOTIFY: Desktop notifications after command completion  
#   set NOTIFY 1 - Enable desktop notifications
#   set NOTIFY 0 - Disable desktop notifications
#
# Examples:
#   set BEEP 1
#   set NOTIFY 0
#
# To modify: edit this file or use the commands:
#   enable_beep / disable_beep
#   enable_notify / disable_notify

set BEEP 0
set NOTIFY 0
" | tee "$CONFIG_FILE" 1>/dev/null
end

# Source config file if it exists
if test -f "$CONFIG_FILE"
    source "$CONFIG_FILE"
end

# Fish event handler for command completion
function fish_postexec --on-event fish_postexec
    set exit_status $status

    if test "$BEEP" = 1
        beep_sound
    end

    if test "$NOTIFY" = 1
        notify-send "Command finished" "Status: $exit_status"
    end
end

function beep_toggle
	set -l conf_file ~/.shell_utils_configs/shell_utils_notifications.conf
    if test "$BEEP" = "0"
        set BEEP 1
        echo -e "🗹 BEEP temporarily set to: $BEEP\n💡 For persistent setting, edit BEEP in: $conf_file"
    else
        set BEEP 0
        echo -e "🗵 BEEP temporarily set to: $BEEP\n💡 For persistent setting, edit BEEP in: $conf_file"
    end
end

function notify_toggle
	set -l conf_file ~/.shell_utils_configs/shell_utils_notifications.conf
    if test "$NOTIFY" = "0"
        set NOTIFY 1
        echo -e "🗹 NOTIFY temporarily set to: $NOTIFY\n💡 For persistent setting, edit NOTIFY in: $conf_file"
    else
        set NOTIFY 0
        echo -e "🗵 NOTIFY temporarily set to: $NOTIFY\n💡 For persistent setting, edit NOTIFY in: $conf_file"
    end
end

# Clean up temporary variables
set -e CONFIG_DIR
set -e CONFIG_FILE
