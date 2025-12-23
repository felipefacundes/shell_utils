#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script displays ASCII art in a terminal with a color cycling effect. 
It requires a single argument, which is the path to an ASCII art file, and checks 
for its existence before proceeding. The script reads the ASCII art into an array 
and uses terminal control commands to manipulate cursor position and color. It continuously 
loops through a set of colors, redrawing the ASCII art in each color to create a dynamic visual effect. 
The script also handles interruptions gracefully, restoring the terminal state upon exit.
DOCUMENTATION

# Check if an argument (ASCII art file) is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: ${0##*/} <ascii-art-file>"
    exit 1
fi

ASCII_FILE="$1"

# Check if the file exists
if [ ! -f "$ASCII_FILE" ]; then
    echo "Error: File '$ASCII_FILE' not found!"
    exit 1
fi

# Read the ASCII art into an array
mapfile -t DATA < "$ASCII_FILE"

DATAY=$(( ${#DATA[@]} - 1 ))

REAL_OFFSET_X=0
REAL_OFFSET_Y=0

draw_char() {
  V_COORD_X=$1
  V_COORD_Y=$2

  tput cup $((REAL_OFFSET_Y + V_COORD_Y)) $((REAL_OFFSET_X + V_COORD_X))
  printf %c "${DATA[V_COORD_Y]:V_COORD_X:1}"
}

trap 'exit 1' INT TERM
trap 'tput setaf 9; tput cvvis; clear' EXIT

tput civis
clear

while :; do
    for ((c=1; c <= 7; c++)); do
        tput setaf $c
        for ((y=0; y<=$DATAY; y++)); do
            for ((x=0; x<${#DATA[y]}; x++)); do
                draw_char $x $y
            done
        done
    done
done
