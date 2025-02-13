#!/bin/bash

tput setaf 11
echo -e "ssh -p 22 user@192.168.X.X\n\n"
tput sgr0
[[ -z "$1" ]] && ssh --help && exit 1
ssh "$@"