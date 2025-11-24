#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

CONFIG_DIR="${HOME}/.shell_utils_configs"
BEEP_SCRIPT="$HOME/.shell_utils/scripts/beep_sound.sh"
CONFIG_FILE="${CONFIG_DIR}/shell_utils_beep_sound.conf"

if [[ ! -f "$CONFIG_FILE" ]]; then
    touch "$CONFIG_FILE"
    echo 'BEEP=0' | tee "$CONFIG_FILE" 1>/dev/null
fi

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

if [[ -n "$ZSH_VERSION" ]] && [[ "$BEEP" == 1 ]]; then
    precmd() {
        # In ZSH, &! suppress job control output
        "$BEEP_SCRIPT" -d &!
    }
elif [[ -n "$BASH_VERSION" ]] && [[ "$BEEP" == 1 ]]; then
    # In Bash, redirect stdout and stderr before &
    PROMPT_COMMAND='"$BEEP_SCRIPT" -d &>/dev/null &'
fi