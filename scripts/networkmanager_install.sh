#!/bin/bash
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script installs essential NetworkManager packages on a Linux system and enables the NetworkManager service to start immediately.
DOCUMENTATION

cat <<'EOF' | sudo pacman -S -
lib32-libnm
libnm
libnma
libnma-common
networkmanager
networkmanager-openconnect
networkmanager-openvpn
nm-connection-editor
network-manager-applet
EOF

sudo systemctl enable --now NetworkManager.service