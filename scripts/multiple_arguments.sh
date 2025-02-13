#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This is a standard template for a bash script with multiple arguments.
DOCUMENTATION

# Define a signal handler to capture SIGINT (Ctrl+C)
trap 'kill $(jobs -p)' SIGTERM #SIGINT #SIGHUP #SIGQUIT #SIGABRT #SIGKILL #SIGALRM

doc() {
    less -FX "$0" | head -n6 | tail -n1
}

help() {
    cat <<EOF #| less -i -R

    $(doc)

    Usage: ${0##*/} [args]

        Help...

    Enter q to quit this help.
EOF
    exit 0
}

fail() {
    [[ -z "$1" ]] && help
}

clear_all_variables_and_functions() {
    for VAR in $(grep -E '[a-zA-Z0-9"'\''\[\]]*=' "${0}" | grep -v '^#' | cut -d'=' -f1 | awk '{print $1}'); do
        eval unset "\${VAR}"
    done
}

if [[ -z "$1" ]]; then
    help
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -a)
            a="$2"
            shift 2
            fail "$a"
            continue
            ;;
        -b)
            b="$2"
            shift 2
            fail "$b"
            continue
            ;;
        -c)
            c="$2"
            shift 2
            fail "$c"
            continue
            ;;
        -d)
            d="$2"
            shift 2
            fail "$d"
            continue
            ;;
        -e)
            e="$2"
            shift 2
            fail "$e"
            continue
            ;;
        *)
            help
            ;;
    esac
done

echo "a: $a"
echo "b: $b"
echo "c: $c"
echo "d: $d"
echo "e: $e"

clear_all_variables_and_functions
# Wait for all child processes to finish
wait