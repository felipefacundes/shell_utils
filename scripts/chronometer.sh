#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script functions as a versatile chronometer with three different modes of operation. 
It includes a signal handler to gracefully terminate running processes when interrupted. 
Users can choose from three modes: a simple chronometer, a real-time display of elapsed time, 
or an advanced chronometer that supports resetting and maintains time in a file. 
The script provides a help function to guide users on how to use the various options and includes error handling for invalid inputs. 
Overall, it offers a user-friendly way to track time in different formats.
DOCUMENTATION

# Define a signal handler to capture SIGINT (Ctrl+C)
trap 'kill $(jobs -p)' SIGTERM #SIGHUP #SIGINT #SIGQUIT #SIGABRT #SIGKILL #SIGALRM #SIGTERM

doc() {
    less -FX "$0" | head -n11 | tail -n6
}

help() {
    cat <<EOF

    $(doc)

    Usage: ${0##*/} [options]

    Options:
        -m1   : Run chronometer1
        -m2   : Run chronometer2
        -m3   : Run chronometer3 [options]
                this last mode supports summary

    Additional Options for -m3:
        -r   : Reset the chronometer

EOF
}

chronometer() {

    now=$(date +%s)sec
    watch -n0.01 -p TZ=UTC date --date now-"${now}" +%H:%M:%S.%N

}

chronometer2() {

    DATA=$(date +%s)
    while true
    do
        echo -ne "$(date -u --date @$(($(date +%s) - "$DATA")) +%H:%M:%S)\r"
    done

}

chronometer3() {
    # Check if the -r argument was provided to reset the chronometer
    if [ "$1" == "-r" ]; then
        echo "Chronometer reset."
        echo 0 > tempo.txt
        exit 0
    fi

    # Check if the tempo.txt file exists, if not, create it with the value 0
    if [ ! -f "tempo.txt" ]; then
        echo 0 > tempo.txt
    fi

    # Function to display formatted time
    format_time() {
        seconds=$1
        minutes=$((seconds / 60))
        seconds=$((seconds % 60))
        hours=$((minutes / 60))
        minutes=$((minutes % 60))
        echo "$hours hours $minutes minutes $seconds seconds"
    }

    # Read the current time from the file
    time=$(cat tempo.txt)

    # Loop to increment time every second
    while true; do
        clear
        echo "Chronometer running. Press Ctrl+C to stop."
        format_time $time
        ((time++))
        echo $time > tempo.txt
        sleep 1
    done
}

if [[ -z $1 ]] || [[ $1 == "-h" || $1 == "--help" ]]; then
    help
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -m1)
            chronometer
            shift
            continue
            ;;
        -m2)
            chronometer2
            shift
            continue
            ;;
        -m3)
            chronometer3 "$2"
            shift 2
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
