#!/usr/bin/env bash

tput setaf 11
echo -e "curl -O URL\nor: curl -o file URL\n\n"
tput sgr0
[[ -z "$2" ]] && curl --help && exit 1
curl -O "$@"