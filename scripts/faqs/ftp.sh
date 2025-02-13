#!/bin/bash
tput setaf 11
echo -e "ftp 192.168.X.X 2121\n\n"
tput sgr0
[[ -z "$1" ]] && ftp --help && exit 1
ftp "$@"