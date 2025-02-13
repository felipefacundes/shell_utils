#!/bin/bash
tput setaf 11
echo -e "sftp -P 2222 user@192.168.X.X\n\nDownload directories with: get -r\n\n"
tput sgr0
[[ -z "$1" ]] && sftp --help && exit 1
sftp "$@"