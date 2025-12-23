#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script converts a binary string into its ASCII character representation, 
showcasing its purpose of binary-to-text decoding.
DOCUMENTATION

b="01010011 01001000 01000101 01001100 01001100 00100000 01010101 01010100 01001001 01001100 01010011"
IFS=' ' read -ra binaries <<< "$b"
for bin in "${binaries[@]}"; do
  decimal=$((2#$bin))
  printf "\\$(printf '%03o' "$decimal")"
done
echo
