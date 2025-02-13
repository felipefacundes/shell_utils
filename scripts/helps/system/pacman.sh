pacman_remove_debug() {
    cat <<'EOF'
# remover pacotes de debug instalado via yay com -debug
$ pacman -Q | grep -E '\-debug' | awk '{print $1}'
$ sudo pacman -Rcs $(pacman -Qq | grep -E '\-debug')
EOF
}

pacman_fix() {
    echo -e "
# shows how to fix pacman errors
    ${shell_color_palette[bgreen]}sudo${shell_color_palette[yellow]} rm ${shell_color_palette[yellow]}/var/lib/pacman/db.lck
    ${shell_color_palette[bgreen]}sudo${shell_color_palette[yellow]} rm /var/lib/pacman/sync/${shell_color_palette[purple]}*
    ${shell_color_palette[bgreen]}sudo${shell_color_palette[yellow]} rm ${shell_color_palette[purple]}-R ${shell_color_palette[yellow]}/etc/pacman.d/gnupg

    ${shell_color_palette[bgreen]}sudo${shell_color_palette[yellow]} pacman ${shell_color_palette[purple]}-Sc
    ${shell_color_palette[bgreen]}sudo${shell_color_palette[yellow]} haveged ${shell_color_palette[purple]}-w ${shell_color_palette[yellow]}1024
    ${shell_color_palette[bgreen]}sudo${shell_color_palette[yellow]} pacman-key ${shell_color_palette[purple]}--init
    ${shell_color_palette[bgreen]}sudo${shell_color_palette[yellow]} pacman-key ${shell_color_palette[purple]}--populate ${shell_color_palette[yellow]}archlinux
    ${shell_color_palette[bgreen]}sudo${shell_color_palette[yellow]} pacman ${shell_color_palette[purple]}-Sy ${shell_color_palette[yellow]}gnupg archlinux-keyring
    ${shell_color_palette[bgreen]}sudo${shell_color_palette[yellow]} pacman-key ${shell_color_palette[purple]}--refresh-keys
    ${shell_color_palette[bgreen]}sudo${shell_color_palette[yellow]} pkill haveged

    ${shell_color_palette[bgreen]}sudo${shell_color_palette[yellow]} cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bkp

    ${shell_color_palette[bgreen]}sudo${shell_color_palette[yellow]} reflector ${shell_color_palette[purple]}--verbose --age 8 --fastest 128 --latest 64 --number 32 --sort ${shell_color_palette[yellow]}rate ${shell_color_palette[purple]}--save ${shell_color_palette[yellow]}/etc/pacman.d/mirrorlist

    ${shell_color_palette[bgreen]}sudo${shell_color_palette[yellow]} pacman ${shell_color_palette[purple]}-Syyu

    ${shell_color_palette[bgreen]}gpg${shell_color_palette[purple]} --keyserver pgp.mit.edu ${shell_color_palette[purple]}--recv-keys ${shell_color_palette[yellow]}10000001
"
}