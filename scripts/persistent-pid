#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script is to keep the program open in X seconds. The default is 5 seconds.
DOCUMENTATION

doc() {
    cat "$0" | head -n6 | tail -n1
    echo
}

error() {
    echo 'It must be an executable command: script or binary'
    exit 1
}

command="$1"
check_pids=()
delay="${delay:-5}"
native_command=$(command -v "$command")
ban_term=$(echo "$command" | sed '/^-/d')

if [[ -z "$command" ]] || [[ -z "$ban_term" ]]; then
    doc
    echo "Usage: ${0##*/} [command]
Example:
        delay=20 ${0##*/} tint2
"
    exit 0
fi


if [[ -z "$native_command" ]]; then
    error
elif [[ ! -x "$command" && ! -f "$command" ]]; then
    error
fi

# if pgrep -f "${0##*/}"; then
# 	exit 1
# fi

_check() {
    local test=$1
    sleep "$delay"

    if [[ -z "$test" ]] && ! pidof "$command"; then
        clear
        echo "$command not working"
        # Kill all script processes
        kill -9 $(jobs -p) 2>/dev/null
        exit 1
    fi
}

# Cleaning function
cleanup() {
    # Kill all child processes
    kill -9 $(jobs -p) 2>/dev/null 2>/dev/null
    # Clear the PID array
    check_pids=()
    exit
}

main() {
    local pid
    
    # Configure traps for different signals
    trap cleanup EXIT INT TERM
    
    while true; do
        pid=$(pidof "$command")
        
        if [[ -z "$pid" ]]; then
            "$command" &
            # Store the PID for possible cleaning
            check_pids+=($!)
        fi
        
        sleep "$delay"

        if [[ -z "$pid" ]]; then
            _check "$pid" &
        fi
        
        # Clear PIDs of processes that have already finished
        for i in "${!check_pids[@]}"; do
            if ! kill -0 "${check_pids[$i]}" 2>/dev/null; then
                unset "check_pids[$i]"
            fi
        done
    done
}

main
