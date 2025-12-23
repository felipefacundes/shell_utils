#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script is designed to check and list installed local fonts on a system. 
It includes a signal handler to terminate running processes gracefully when interrupted. 
Users can choose to list all local fonts or display them without their identifiers using specific command-line arguments. 
The script provides a help function to guide users on how to use the available options. 
Overall, it serves as a simple and effective tool for managing and viewing installed fonts in a user-friendly manner.
DOCUMENTATION

# Define a signal handler to capture SIGINT (Ctrl+C)
trap 'kill $(jobs -p)' SIGTERM #SIGHUP #SIGINT #SIGQUIT #SIGABRT #SIGKILL #SIGALRM #SIGTERM

doc() {
    less -FX "$0" | head -n10 | tail -n5
}

help() {
    cat <<EOF

    $(doc)

    Usage: ${0##*/} [args]

        -l
            list local fonts installed
        -ni
            list local fonts installed without identifier
EOF
}

local_font()
{
    fc-list | grep -v /usr/ | sed "s|${HOME}/|~/|g"
}

list_local_font_without_identifier()
{
    fc-list | grep -v /usr/ | sed "s|${HOME}/|~/|g" | cut -d':' -f1
}


if [[ -z $1 ]] || [[ $1 == "-h" || $1 == "--help" ]]; then
    help
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -l)
            local_font
            shift
            continue
            ;;
        -ni)
            list_local_font_without_identifier
            shift
            continue
            ;;
        *)
            help
            break
            ;;
    esac
done

# Wait for all child processes to finish
wait