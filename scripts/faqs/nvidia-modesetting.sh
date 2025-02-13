#!/bin/bash

tput bold
tput setaf 3
echo -e "xrandr --setprovideroutputsource modesetting NVIDIA-0\n"
tput sgr0
xrandr --setprovideroutputsource modesetting NVIDIA-0