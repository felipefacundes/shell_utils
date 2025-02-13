#!/bin/bash

cat <<'EOF'
reflector -c Brazil --save /etc/pacman.d/mirrorlist

reflector --verbose --age 8 --fastest 128 --latest 64 --number 32 --sort rate --save /etc/pacman.d/mirrorlist
EOF