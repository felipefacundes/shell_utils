#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

local_keyring="${HOME}"/.local/share/keyrings

# see https://unix.stackexchange.com/a/295652/332452
source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh

# see https://wiki.archlinux.org/title/GNOME/Keyring#xinitrc
/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh
eval "$(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)"
export SSH_AUTH_SOCK
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# see https://github.com/NixOS/nixpkgs/issues/14966#issuecomment-520083836
[[ ! -d "${local_keyring}" ]] && mkdir -p "${local_keyring}"