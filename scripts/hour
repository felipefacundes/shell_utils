#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script continuously displays the current time in a stylized ASCII format using the 
Figlet command with a specific font, updating every second.
DOCUMENTATION

if ! command -v figlet >/dev/null; then
    echo 'Command: figlet, not found!'
    exit 1
elif ! ls /usr/share/figlet/bigmono9.tlf 2>/dev/null; then
    echo 'Font: bigmono9.tlf, not found! Install: toilet-fonts'
    exit 1
fi

while true
do
	tput setaf 2 
	figlet -f /usr/share/figlet/bigmono9.tlf "$(date +%T)"
	sleep 1 && clear
done
