#!/bin/bash
tput setaf 11
echo -e "install python binaries isolated:\n"
tput setaf 2
echo -e "python -m venv ~/.python/venv\nsource ~/.python/venv/bin/activate\n"
tput setaf 11
echo -e "Checking the desire from the virtual environment:\n"
tput setaf 2
echo 'echo "$VIRTUAL_ENV"'
tput sgr0
