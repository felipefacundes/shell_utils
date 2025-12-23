#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script iterates through all items in the current directory, compressing each subdirectory 
into a tar file and then further compressing it with zstd. It removes the intermediate tar file 
after the compression for each directory processed in the loop.
DOCUMENTATION

for dir in *; do
    if [[ -d "$dir" ]]; then
        echo -e "\npackaging directory $dir"
        tar -cf "${dir}.tar" "$dir"
        wait $!
        zstd "${dir}.tar" --ultra -22 -o "${dir}.tar.zst"
        wait $!
        rm "${dir}.tar"
    fi
done