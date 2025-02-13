#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Creates a new file with execution permission and opens it in VS Code or VSCodium, ensuring one of them is installed.
DOCUMENTATION

file="$1"

[[ -z "$file" ]] && echo "Usage: ${0##*/} new_file" && exit 1
[[ -f "$file" ]] && [[ ! -x "$file" ]] && echo 'File is not executable!' && exit 1
[[ -e "$file" ]] && echo 'File exists!' && exit 1

if ! command -v code &>/dev/null && ! command -v codium &>/dev/null; then
    echo 'Install code or codium, then run this script again.'
    exit 1
fi

if command -v codium &>/dev/null; then
    mycode=$(command -v codium); export mycode
else
    mycode=$(command -v code); export mycode
fi

touch "$file" && chmod +x "$file" && "$mycode" "$file"
