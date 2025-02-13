#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script compresses a specified directory into a tar file and then further compresses it using zstd, 
removing the intermediate tar file afterward. It checks if the provided argument is a valid directory before 
proceeding with the compression.
DOCUMENTATION

dir="$1"

[[ ! -d "$dir" ]] && echo 'It is not a directory' && exit 1

tar -cf "${dir}.tar" "${dir}" && zstd "${dir}.tar" --ultra -22 -o "${dir}.tar.zst" && rm "${dir}.tar"

echo -e "\nCommand used:\ntar -cf ${dir}.tar ${dir} && zstd ${dir}.tar --ultra -22 -o ${dir}.tar.zst && rm ${dir}.tar"