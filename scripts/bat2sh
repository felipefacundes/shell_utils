#!/usr/bin/env bash 
# Credits: BRAVO68WEB
# Font: https://gist.github.com/BRAVO68WEB/3487b43662793f8d20890d9f36fc9a78
#
# Converts Windows batch script to Linux shell script
#
# Invocation:
#     ./bat2sh script.bat
#

OUTFILE=${2:-${1%%.bat}.sh}

cat "$1" | \
    sed \
        -e 's/\bset\b/export/g'     \
        -e 's/%\([^/]\+\)%/${\1}/g' \
        -e 's/^call.*$//g'          \
        -e 's/\r//'                 \
        -e 's#del /q#rm#g'          \
    > "$OUTFILE"

chmod a+x "$OUTFILE"