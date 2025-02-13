#!/bin/bash

tput bold
tput setaf 3
echo -e "xrandr --setprovideroutputsource modesetting modesetting\n"
tput sgr0
xrandr --setprovideroutputsource modesetting modesetting