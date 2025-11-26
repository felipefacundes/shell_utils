#!/usr/bin/env bash
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
    ~/.shell_utils_configs/shell_utils_beep_sound.conf

    To ENABLE sound:
        echo 'BEEP=1' > ~/.shell_utils_configs/shell_utils_beep_sound.conf

    To DISABLE sound:
        echo 'BEEP=0' > ~/.shell_utils_configs/shell_utils_beep_sound.conf

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
    ~/.shell_utils_configs/shell_utils_beep_sound.conf - Configuration
    ~/.shell_utils/scripts/beep_sound.sh - Main sound script

USAGE EXAMPLES:
    # Reload configuration
    source ~/.shell_utils/scripts/shell_beep_sound.sh

    # Temporarily enable/disable
    export BEEP=1  # Enable
    export BEEP=0  # Disable

    # Test sound manually
    beep_sound

NOTES:
    - Sound is executed in background to not block the terminal
    - All output is redirected to /dev/null
    - The system respects persistent configuration in the .conf file

AUTHOR: Felipe Facundes
LICENSE: GPLv3
DOCUMENTATION

CONFIG_DIR="${HOME}/.shell_utils_configs"
CONFIG_FILE="${CONFIG_DIR}/shell_utils_beep_sound.conf"
alias beep_sound='(~/.shell_utils/scripts/beep_sound.sh -d &) >/dev/null 2>&1'

if [[ ! -f "$CONFIG_FILE" ]]; then
    touch "$CONFIG_FILE"
    echo 'BEEP=0' | tee "$CONFIG_FILE" 1>/dev/null
fi

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

if [[ -n "$ZSH_VERSION" ]]; then
    precmd() {
        [[ "$BEEP" == 1 ]] && beep_sound
    }
elif [[ -n "$BASH_VERSION" ]] && [[ -z "$PROMPT_COMMAND" ]]; then
    PROMPT_COMMAND='[[ "$BEEP" == 1 ]] && beep_sound'
fi

unset CONFIG_DIR
unset CONFIG_FILE