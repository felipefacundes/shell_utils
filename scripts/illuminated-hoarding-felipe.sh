#!/bin/bash

From: http://wiki.bash-hackers.org/scripting/terminalcodes
DATA[0]='$$$$$$$$\        $$\ $$\                           $$$$$$$$\                                           $$\                       '
DATA[1]='$$  _____|       $$ |\__|                          $$  _____|                                          $$ |                        '
DATA[2]='$$ |    $$$$$$\  $$ |$$\  $$$$$$\   $$$$$$\        $$ |   $$$$$$\   $$$$$$$\ $$\   $$\ $$$$$$$\   $$$$$$$ | $$$$$$\   $$$$$$$\                       '
DATA[3]='$$$$$\ $$  __$$\ $$ |$$ |$$  __$$\ $$  __$$\       $$$$$\ \____$$\ $$  _____|$$ |  $$ |$$  __$$\ $$  __$$ |$$  __$$\ $$  _____|                        '
DATA[4]='$$  __|$$$$$$$$ |$$ |$$ |$$ /  $$ |$$$$$$$$ |      $$  __|$$$$$$$ |$$ /      $$ |  $$ |$$ |  $$ |$$ /  $$ |$$$$$$$$ |\$$$$$$\                        '
DATA[5]='$$ |   $$   ____|$$ |$$ |$$ |  $$ |$$   ____|      $$ |  $$  __$$ |$$ |      $$ |  $$ |$$ |  $$ |$$ |  $$ |$$   ____| \____$$\                       '
DATA[6]='$$ |   \$$$$$$$\ $$ |$$ |$$$$$$$  |\$$$$$$$\       $$ |  \$$$$$$$ |\$$$$$$$\ \$$$$$$  |$$ |  $$ |\$$$$$$$ |\$$$$$$$\ $$$$$$$  |                        '
DATA[7]='\__|    \_______|\__|\__|$$  ____/  \_______|      \__|   \_______| \_______| \______/ \__|  \__| \_______| \_______|\_______/                     '
DATA[8]='                         $$ |'
DATA[9]='                         $$ |'
DATA[10]='                         \__|'
DATAY=10

# virtual coordinate system is X*Y ${#DATA} * 5

REAL_OFFSET_X=0
REAL_OFFSET_Y=0

draw_char() {
  V_COORD_X=$1
  V_COORD_Y=$2

  tput cup $((REAL_OFFSET_Y + V_COORD_Y)) $((REAL_OFFSET_X + V_COORD_X))

  printf %c ${DATA[V_COORD_Y]:V_COORD_X:1}
}


trap 'exit 1' INT TERM
trap 'tput setaf 9; tput cvvis; clear' EXIT

tput civis
clear

while :; do

for ((c=1; c <= 7; c++)); do
  tput setaf $c
  for ((x=0; x<${#DATA[0]}; x++)); do
    for ((y=0; y<=$DATAY; y++)); do
      draw_char $x $y
    done
  done
done

done