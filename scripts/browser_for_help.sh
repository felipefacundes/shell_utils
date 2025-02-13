#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

# BROWSER=www-browser:links2:elinks:links:lynx:w3m
# BROWSER=$(echo $BROWSER | sed -e 's|:xdg-open||g' -e 's|xdg-open:||g')
# BROWSER=x-www-browser:firefox:iceweasel:seamonkey:mozilla:epiphany:konqueror:chromium:chromium-browser:google-chrome:microsoft-edge:$BROWSER
BROWSER=${BROWSER:=BROWSER}
url="$@"

if ! test -d ~/.fred_site_offline; then
     git clone https://github.com/felipefacundes/fred_site_offline.git ~/.fred_site_offline
     rm -rf ~/.fred_site_offline/.git
fi

if [[ -z "${BROWSER}" ]]; then
    if command -v qutebrowser >/dev/null 2>&1; then
        qutebrowser "$url" >/dev/null 2>&1
    elif command -v falkon >/dev/null 2>&1; then
        falkon "$url" >/dev/null 2>&1
    elif command -v xlinks >/dev/null 2>&1; then
        xlinks -g "$url" >/dev/null 2>&1
    elif command -v dillo >/dev/null 2>&1; then 
        dillo "$url" >/dev/null 2>&1
    elif command -v netsurf >/dev/null 2>&1; then
        netsurf "$url" >/dev/null 2>&1
    elif command -v w3m >/dev/null 2>&1; then
        w3m "$url" >/dev/null 2>&1
    elif command -v elinks >/dev/null 2>&1; then
        elinks "$url" >/dev/null 2>&1
    elif command -v links >/dev/null 2>&1; then
        links "$url" >/dev/null 2>&1
    elif command -v lynx >/dev/null 2>&1; then
        lynx "$url" >/dev/null 2>&1
    else
        xdg-open "$url" >/dev/null 2>&1
    fi
else
    ${BROWSER} "$url" >/dev/null 2>&1
fi

echo -e "\n\033[1;33mOpened \033[1;31m$url \033[1;33mwith \033[1;32m${BROWSER}\033[0m\n"