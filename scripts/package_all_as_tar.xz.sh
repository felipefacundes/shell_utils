#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script packages all directories in the current folder into compressed '.tar.xz' files. 
The loop iterates over each item in the current directory, checking if it is a directory, 
and then creates a compressed archive using 'tar', optionally piping the output through 'pv'
for progress visualization if available.
DOCUMENTATION

for dir in *; do
    if [[ -d "$dir" ]]; then
        echo -e "\npackaging directory $dir"
        if command -v pv >/dev/null; then
            tar -cJf "${dir}.tar.xz" "$dir" | pv
        else
            tar -cJf "${dir}.tar.xz" "$dir"
        fi
    fi
done