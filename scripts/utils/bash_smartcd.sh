#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

smartcd() {
    local dir="$*"

    # Expand ~ manually
    [[ $dir == "~"* ]] && dir="${dir/#\~/$HOME}"

    # Use printf '%q' to correctly escape spaces and special characters
    builtin cd "$(printf '%b' "$dir")" 2>/dev/null || builtin cd "$dir"
}

alias cd='smartcd'