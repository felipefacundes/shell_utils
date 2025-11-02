#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Displays system information for panels such as: tint2, polibar, awesome panel widget and etc...
DOCUMENTATION

# Define a signal handler to capture SIGINT (Ctrl+C)
trap 'kill $(jobs -p)' SIGTERM #SIGHUP #SIGINT #SIGQUIT #SIGABRT #SIGKILL #SIGALRM #SIGTERM

doc() {
    less -FX "$0" | head -n6 | tail -n1
}

help() {
    doc
    echo "
    Usage: ${0##*/} [args]
    
    -m,
        print memory status

    -f
        print cpu frequency status

    -cp [1|2]
        print cpu percent usage

    -t 
        print cpu temperature
        
    -c
        print all cpu info

    -num
        print numlock status

    -caps
        print capslock status

    -gpu
        print NVIDIA GPU status: if Intel is current or NVIDIA

    -up
        print uptime status
    
    -vol
        print volume status

    -pac
        print status pacman: installed packages of ArchLinux

"
}

cpu_freq() {
    echo " $(cpupower frequency-info | grep -i asserted | cut -c 26-28)$(cpupower frequency-info | grep -i asserted | cut -c 30-33) "
}

cpu_percent() {
    local mode="$1"

    if [[ "$mode" == 2 ]]; then
        echo " $((100 - $(vmstat 1 2|tail -1|awk '{print $15}')))% "
    else
        echo " $(mpstat 1 1 | awk '$12 ~ /[0-9.]+/ { print 100 - $12 }' | head -n 1)% "
        exit 0
    fi
}

cpu_temp() {
    echo " $(sensors | awk '/^Core 0:/ {print $3}' | sed 's/+//') "
}

cpu_all() {
    cpu_all="$(cpu_freq)/$(cpu_percent 1)/$(cpu_temp)"
    cpu_all_no_space="${cpu_all// /}" # remove blank space
    echo [🧠 "$cpu_all_no_space"]
}

memory() {
    local mode="$1"
    
    if [[ "$mode" == 3 ]]; then
        echo " $( free -m | awk 'NR==2{printf "RAM: %.2f%% (%dMB/%dMB)\nSwap: %.2f%% (%dMB/%dMB)", $3*100/$2, $3, $2, $7*100/$2, $7, $2}' ) "

    elif [[ "$mode" == 2 ]]; then
        echo " $(free -m | awk 'NR==2{printf "RAM: %.2f%% (%.2fGB/%.2fGB)", $3*100/$2, $3/1024, $2/1024}') "

    else
        # 󱤓 🧩
        echo " $(free -m | awk 'NR==2{printf "[🚑 %.2fGB/%.2fGB]", $3/1024, $2/1024}') "
        #echo " $(free -h | grep -Ei '^Mem' | awk '{print "󱤓 " $3 "|" $2}') "
        exit 0
    fi
}

uptime_filter() {
    #echo "$(awk '{print int($1/3600)":"int(($1%3600)/60)}' /proc/uptime)" #
    echo " $(uptime | awk '{print $3}' | tr -d ',') ﴻ "
}

numlock_status() {
    echo " (N): $(xset q | grep -Ei 'Num Lock:    on' | cut -c46-47)$(xset q | grep -Ei 'Num Lock:    off' | cut -c46-48) "
}

capslock_status() {
    #🅰  🄐
    echo " (C): $(xset q | grep -Ei 'Caps Lock:   on' | cut -c22-23)$(xset q | grep -Ei 'Caps Lock:   off' | cut -c22-24) " 
}

nvidia_or_intel() {
    #🌀🏧💠🆙🆒🆓💎🏁☑️®️
    #"👁️🖥️" #  👁️‍🗨️
    #"\xf0\x9f\x92\xbb" # 

    echo " $( 
        if glxinfo -B | grep -i 'NVIDIA' >/dev/null; then 
            echo -e "🏁"
        else 
            echo -e "🖥️"
        fi
        ) "
}

volume_status() {
    MUTE=$(LC_ALL=c pactl list sinks | grep -Ei yes | head -n 9)
    FONE=$(LC_ALL=c pactl list sinks | grep -i 'Active Port: analog-output-headphones')
    VOLUME=$(pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( "$SINK" + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')

    ## ☊ 奄   婢  
    echo " $(
        if [ "$MUTE" ]; then 
            echo 🔇 
        else 
            if [ "$FONE" ]; then
                echo 🎧
            else
                if (("$VOLUME" > 70)); then
                    echo 🔊
                elif (("$VOLUME" <= 70)) && (("$VOLUME" >= 40)); then
                    echo 🔉
                else
                    echo 🔈
                fi
            fi
        fi
        ):${VOLUME}% " 
}

pac_status() {
    #  #📦 #  
    echo " 📦$(pacman -Qq | wc -l) "
}

if [[ -z $1 ]] || [[ $1 == "-h" || $1 == "--help" ]]; then
    help
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -c)
            cpu_all
            shift
            continue
            ;;
        -cp)
            cpu_percent "$2"
            shift 2
            continue
            ;;
        -f)
            cpu_freq
            shift
            continue
            ;;
        -m)
            memory "$2"
            shift 2
            continue
            ;;
        -t)
            cpu_temp
            shift 
            continue
            ;;
        -num)
            numlock_status
            shift
            continue
            ;;
        -caps)
            capslock_status
            shift
            continue
            ;;
        -gpu)
            nvidia_or_intel
            shift
            continue
            ;;
        -up)
            uptime_filter
            shift
            continue
            ;;
        -vol)
            volume_status
            shift
            continue
            ;;
        -pac)
            pac_status
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