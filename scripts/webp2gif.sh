#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Convert all webp files to gif
DOCUMENTATION

for i in *.[Ww][Ee][Bb][Pp]
    do 
    magick "${i}" "${i%.*}".gif
done