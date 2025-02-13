#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script is to keep the program open in X seconds. The default is 5 seconds.
DOCUMENTATION

doc() {
    less -FX "$0" | head -n6 | tail -n1
    echo
}

error() {
    echo 'It must be an executable command: script or binary'
    exit 1
}

command="$1"
ban_term=$(echo "$command" | sed '/^-/d')

if [[ -z "$command" ]] || [[ -z "$ban_term" ]]; then
    doc
    echo "Usage: ${0##*/} [command]
Example:
        delay=20 ${0##*/} tint2
"
    exit 0
fi

native_command=$(command -v "$command")
delay="${delay:-5}"

if [[ -z "$native_command" ]]; then
    error
elif [[ ! -x "$command" && ! -f "$command" ]]; then
    error
fi

while true
        do pid=$(pidof "$command")

        if [[ -z "$pid" ]]; then
            exec "$command" &
        fi
        sleep "$delay"
done