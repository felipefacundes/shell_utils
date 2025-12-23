#!/usr/bin/env bash
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script installs the specified desktop environment along with some common applications.
DOCUMENTATION

declare -A MESSAGES

if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        ["usage"]="Uso: ${0##*/} [ambiente_de_trabalho]"
        ["available"]="Ambientes de trabalho disponíveis:"
        ["kde"]="  kde       - Instalar o ambiente de trabalho KDE Plasma."
        ["cinnamon"]="  cinnamon  - Instalar o ambiente de trabalho Cinnamon."
        ["gnome"]="  gnome     - Instalar o ambiente de trabalho GNOME."
        ["deepin"]="  deepin    - Instalar o ambiente de trabalho Deepin."
        ["xfce"]="  xfce      - Instalar o ambiente de trabalho XFCE."
        ["mate"]="  mate      - Instalar o ambiente de trabalho MATE."
        ["description"]="Este script instala o ambiente de trabalho especificado junto com alguns aplicativos comuns."
        ["examples"]="Exemplos:"
        ["example_kde"]="  ${0##*/} kde       # Instalar KDE Plasma"
        ["example_gnome"]="  ${0##*/} gnome     # Instalar GNOME"
        ["example_xfce"]="  ${0##*/} xfce      # Instalar XFCE"
    )
else
    MESSAGES=(
        ["usage"]="Usage: ${0##*/} [desktop_environment]"
        ["available"]="Available desktop environments:"
        ["kde"]="  kde       - Install KDE Plasma desktop environment."
        ["cinnamon"]="  cinnamon  - Install Cinnamon desktop environment."
        ["gnome"]="  gnome     - Install GNOME desktop environment."
        ["deepin"]="  deepin    - Install Deepin desktop environment."
        ["xfce"]="  xfce      - Install XFCE desktop environment."
        ["mate"]="  mate      - Install MATE desktop environment."
        ["description"]="This script installs the specified desktop environment along with some common applications."
        ["examples"]="Examples:"
        ["example_kde"]="  ${0##*/} kde       # Install KDE Plasma"
        ["example_gnome"]="  ${0##*/} gnome     # Install GNOME"
        ["example_xfce"]="  ${0##*/} xfce      # Install XFCE"
    )
fi

help() {
    echo "${MESSAGES[usage]}"
    echo
    echo "${MESSAGES[available]}"
    echo "${MESSAGES[kde]}"
    echo "${MESSAGES[cinnamon]}"
    echo "${MESSAGES[gnome]}"
    echo "${MESSAGES[deepin]}"
    echo "${MESSAGES[xfce]}"
    echo "${MESSAGES[mate]}"
    echo
    echo "${MESSAGES[description]}"
    echo
    echo "${MESSAGES[examples]}"
    echo "${MESSAGES[example_kde]}"
    echo "${MESSAGES[example_gnome]}"
    echo "${MESSAGES[example_xfce]}"
}

case $1 in
    kde|plasma)
        sudo pacman -S plasma-meta gimp krita packagekit packagekit-qt6 okular mpv yt-dlp firefox xdg-user-dirs
        sudo systemctl enable sddm
    ;;
    cinnamon)
        sudo pacman -S cinnamon cinnamon-desktop cinnamon-translations nemo evince mpv yt-dlp lightdm-gtk-greeter lightdm gimp viewnior firefox xdg-user-dirs xdg-desktop-portal-xapp
        sudo systemctl enable lightdm
    ;;
    gnome)
        sudo pacman -S gnome gnome-extra gnome-shell gdm mpv yt-dlp gimp viewnior firefox xdg-user-dirs
        sudo systemctl enable gdm
    ;;
    deepin)
        sudo pacman -S deepin deepin-extra lightdm-gtk-greeter lightdm gimp viewnior firefox xdg-user-dirs
        sudo systemctl enable lightdm
    ;;
    xfce)
        sudo pacman -S xfce4 xfce4-goodies lightdm-gtk-greeter lightdm gimp mpv yt-dlp viewnior firefox xdg-user-dirs
        sudo systemctl enable lightdm
    ;;
    mate)
        sudo pacman -S mate mate-extra lightdm-gtk-greeter lightdm gimp mpv yt-dlp viewnior firefox xdg-user-dirs
        sudo systemctl enable lightdm
    ;;
    *)
        help
    ;;
esac