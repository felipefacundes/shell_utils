#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script is designed to display ASCII art in various directions on the terminal. It takes two arguments: 
the direction of the display (top-down, left-right, right-left, bottom-up) and the path to an ASCII art file. 
The script checks for the existence of the file and reads its content into an array for processing. 

Strengths:
1. Flexible Direction Options: Supports multiple display directions for versatility.
2. Error Handling: Validates input arguments and checks for file existence, providing user-friendly error messages.
3. Dynamic Display: Utilizes terminal control commands to render ASCII art smoothly.
4. Customizable Colors: Changes text color dynamically while displaying the art.
5. Continuous Loop: Keeps displaying the art in a loop, enhancing user engagement.

Capabilities:
- Reads and processes ASCII art files.
- Displays art in specified directions with color variations.
- Handles interruptions gracefully and restores terminal settings upon exit.
DOCUMENTATION

# Check if sufficient arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: ${0##*/} <direction> <ascii-art-file>"
    echo "Direction options: top-down, left-right, right-left, bottom-up"
    exit 1
fi

DIRECTION="$1"
ASCII_FILE="$2"

# Check if the file exists
if [ ! -f "$ASCII_FILE" ]; then
    echo "Error: File '$ASCII_FILE' not found!"
    exit 1
fi

# Read the ASCII art into an array
mapfile -t DATA < "$ASCII_FILE"

DATAY=$(( ${#DATA[@]} - 1 ))
DATA_WIDTH=${#DATA[0]}

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
        case "$DIRECTION" in
            top-down)
                for ((y=0; y<=$DATAY; y++)); do
                    for ((x=0; x<DATA_WIDTH; x++)); do
                        draw_char $x $y
                    done
                done
                ;;
            left-right)
                for ((x=0; x<DATA_WIDTH; x++)); do
                    for ((y=0; y<=$DATAY; y++)); do
                        draw_char $x $y
                    done
                done
                ;;
            right-left)
                for ((x=DATA_WIDTH-1; x>=0; x--)); do
                    for ((y=0; y<=$DATAY; y++)); do
                        draw_char $x $y
                    done
                done
                ;;
            bottom-up)
                for ((y=DATAY; y>=0; y--)); do
                    for ((x=0; x<DATA_WIDTH; x++)); do
                        draw_char $x $y
                    done
                done
                ;;
            *)
                echo "Invalid direction! Use top-down, left-right, right-left, or bottom-up."
                exit 1
                ;;
        esac
    done
done
