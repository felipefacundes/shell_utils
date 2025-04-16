#!/usr/bin/env bash

cat <<'EOF'
sudo reflector -c Brazil --save /etc/pacman.d/mirrorlist

sudo reflector --verbose -c Brazil --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
sudo reflector --verbose -c Brazil --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

sudo reflector --verbose -c Brazil --age 8 --fastest 128 --latest 64 --number 32 --sort rate --save /etc/pacman.d/mirrorlist
sudo reflector --verbose -c Brazil --age 8 --fastest 128 --latest 64 --protocol https --number 32 --sort rate --save /etc/pacman.d/mirrorlist
EOF