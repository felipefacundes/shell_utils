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

clear_all_variables_and_functions() {
    for VAR in $(grep -E '[a-zA-Z0-9"'\''\[\]]*=' "${0}" | grep -v '^#' | cut -d'=' -f1 | awk '{print $1}'); do
        eval unset "\${VAR}"
    done
}

if [[ -z "$1" ]]; then
    help
fi

while getopts ":a:b:c:d:e:" opt; do
    case ${opt} in
        a )
            a=$OPTARG
            ;;
        b )
            b=$OPTARG
            ;;
        c )
            c=$OPTARG
            ;;
        d )
            d=$OPTARG
            ;;
        e )
            e=$OPTARG
            ;;
        \? )
            help
            ;;
    esac
done
shift $((OPTIND -1))

echo "a: $a"
echo "b: $b"
echo "c: $c"
echo "d: $d"
echo "e: $e"

clear_all_variables_and_functions
# Wait for all child processes to finish
wait