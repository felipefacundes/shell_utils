#!/bin/bash
# Credits: Felipe Facundes

# Get the current volume of TV

~/.shell_utils/scripts/lgtv \
    --name MyTV --ssl audioStatus \
    | awk -F'"volume":[ ]*' '{if (NF>1) print "\"volume\":" $2}' \
    | awk -F'[,}]' '{print $1}' \
    | cut -d':' -f 2