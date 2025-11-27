# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
SHELL BEEP NOTIFICATION SYSTEM - SHELL_UTILS FRAMEWORK

DESCRIPTION:
    This script configures an audio notification system for Bash and Zsh
    shells, integrated with the SHELL_UTILS framework. When enabled, it emits
    a sound after each command execution in the terminal.

REQUIREMENTS:
    - Must be loaded via 'source' or '.' in the current shell
    - beep_sound.sh script must be located at ~/.shell_utils/scripts/
    - Sound support on the system (afplay on macOS, paplay on Linux, etc)

INSTALLATION:
    source /path/to/this/script.sh

CONFIGURATION:
    The system uses a configuration file at:
    ~/.shell_utils_configs/shell_utils_notifications.conf

    To ENABLE sound:
        echo 'BEEP=1' | tee ~/.shell_utils_configs/shell_utils_notifications.conf

    To DISABLE sound:
        echo 'BEEP=0' | tee ~/.shell_utils_configs/shell_utils_notifications.conf

    To ENABLE notifications:
        echo 'NOTIFY=1' | tee -a ~/.shell_utils_configs/shell_utils_notifications.conf

    To DISABLE notifications:
        echo 'NOTIFY=0' | tee -a ~/.shell_utils_configs/shell_utils_notifications.conf

FEATURES:
    - Automatically detects whether the shell is Bash or Zsh
    - Creates a 'beep_sound' alias to play sound in background
    - Suppresses all command output (PID, etc)
    - Configures precmd (Zsh) or PROMPT_COMMAND (Bash) to monitor commands
    - Removes temporary variables after configuration

COMPATIBILITY:
    - Bash 4.0+
    - Zsh 5.0+
    - macOS (afplay) and Linux (paplay/other)

CREATED ALIAS:
    beep_sound - Executes the sound script in background without output

FILES:
    ~/.shell_utils_configs/shell_utils_notifications.conf - Configuration
    ~/.shell_utils/scripts/beep_sound.sh - Main sound script

USAGE EXAMPLES:
    # Reload configuration
    source ~/.shell_utils/scripts/shell_beep_sound.sh

    # Temporarily enable/disable
    export BEEP=1  # Enable
    export BEEP=0  # Disable
    export NOTIFY=1  # Enable notifications
    export NOTIFY=0  # Disable notifications

    # Test sound manually
    beep_sound

NOTES:
    - Sound is executed in background to not block the terminal
    - All output is redirected to /dev/null
    - The system respects persistent configuration in the .conf file
DOCUMENTATION

CONFIG_DIR="${HOME}/.shell_utils_configs"
CONFIG_FILE="${CONFIG_DIR}/shell_utils_notifications.conf"
alias beep_sound='(~/.shell_utils/scripts/beep_sound.sh -d &) >/dev/null 2>&1'

if [[ ! -f "$CONFIG_FILE" ]]; then
    mkdir -p "$CONFIG_DIR"
    cat > "$CONFIG_FILE" << 'EOF'
# Shell Utils Notifications Configuration
# 
# BEEP: Audio feedback after command completion
#   BEEP=1 - Enable sound notifications
#   BEEP=0 - Disable sound notifications
#
# NOTIFY: Desktop notifications after command completion  
#   NOTIFY=1 - Enable desktop notifications
#   NOTIFY=0 - Disable desktop notifications
#
# Examples:
#   BEEP=1
#   NOTIFY=0
#
# To modify: edit this file or use the commands:
#   enable_beep / disable_beep
#   enable_notify / disable_notify

BEEP=0
NOTIFY=0
EOF
fi

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

if [[ -n "$ZSH_VERSION" ]]; then
	precmd() {
		local exit_status=$?
		[[ "$BEEP" == 1 ]] && beep_sound
		[[ "$NOTIFY" == 1 ]] && notify-send "Command finished" "Status: $exit_status"
	}
elif [[ -n "$BASH_VERSION" ]] && [[ -z "$PROMPT_COMMAND" ]]; then
	notifications() {
		local exit_status=$?
		[[ "$BEEP" == 1 ]] && beep_sound
		[[ "$NOTIFY" == 1 ]] && notify-send "Command finished" "Status: $exit_status"
	}

	PROMPT_COMMAND="notifications; $PROMPT_COMMAND"
fi

beep_toggle() {
	local conf_file="$HOME/.shell_utils_configs/shell_utils_notifications.conf"
	if [[ "$BEEP" == 0 ]]; then
		BEEP=1
		echo -e "🗹 BEEP temporarily set to: $BEEP\n💡 For persistent setting, edit BEEP in: $conf_file"
	else
		BEEP=0
		echo -e "🗵 BEEP temporarily set to: $BEEP\n💡 For persistent setting, edit BEEP in: $conf_file"
	fi
}

notify_toggle() {
	local conf_file="$HOME/.shell_utils_configs/shell_utils_notifications.conf"
	if [[ "$NOTIFY" == 0 ]]; then
		NOTIFY=1
		echo -e "🗹 NOTIFY temporarily set to: $NOTIFY\n💡 For persistent setting, edit NOTIFY in: $conf_file"
	else
		NOTIFY=0
		echo -e "🗵 NOTIFY temporarily set to: $NOTIFY\n💡 For persistent setting, edit NOTIFY in: $conf_file"
	fi
}

unset CONFIG_DIR
unset CONFIG_FILE