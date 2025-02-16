#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

# A Dynamic Collection of Shell Scripts with an Educational Purpose

shell_utils_configs=~/.shell_utils_configs
backup_date=$(date +"%Y%m%d%H%M%S")
shell_utils_dir=~/.shell_utils
byellow_on_blue='\033[33;1;44m'
os=$(uname -o)
my_dir="$PWD"
nc='\033[0m'
delay=2.5

# Detects the shell that called the script
parent_shell=$(ps -p $PPID -o comm=)

if [[ -n "$TERMUX_VERSION" ]] && [[ "$os" =~ "Android" ]]; then
    apt update && apt upgrade && apt install git ncurses-utils
fi

if ! test -d "${shell_utils_dir}"; then
    git clone https://github.com/felipefacundes/shell_utils "${shell_utils_dir}"
fi

# Path to your shell_utils configs
if [ ! -d "$shell_utils_configs" ]; then
    mkdir -p "$shell_utils_configs"
fi

oh_my_zsh_defaults() {
    # Path to your oh-my-zsh installation.
    if [ ! -d "${HOME}"/.oh-my-zsh ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    # GIT CLONE PLUGINS:
    # SEE REPOS:
    # https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md#manual-git-clone
    if [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi
    # https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md#oh-my-zsh
    if [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi
    # https://github.com/marzocchi/zsh-notify#oh-my-zsh # Work only X11
    if [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/notify ]; then
        git clone https://github.com/marzocchi/zsh-notify.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/notify
    fi
    # https://github.com/MichaelAquilina/zsh-auto-notify # Work X11 and Wayland
    #plugins=(history archlinux zsh-autosuggestions zsh-syntax-highlighting auto-notify)
    if [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/auto-notify ]; then
        git clone https://github.com/MichaelAquilina/zsh-auto-notify.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/auto-notify
    fi

    # See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
    # https://github.com/spaceship-prompt/spaceship-prompt
    if [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/spaceship-prompt ]; then
        git clone https://github.com/spaceship-prompt/spaceship-prompt.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/spaceship-prompt --depth=1
        ln -s ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/spaceship-prompt/spaceship.zsh-theme ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/spaceship.zsh-theme
    fi

    #ZSH_THEME="spaceship"
}

zsh_install() {
    test -f ~/.zshrc && mv -v --backup=t ~/.zshrc ~/.zshrc.shell_utils-backup-"$backup_date"
    cp -f "${shell_utils_dir}/zshrc" ~/.zshrc
    echo -e "\n${byellow_on_blue}The SHELL_UTILS has been successfully installed! Destination: ${shell_utils_dir}${nc}"
    sleep "$delay" && zsh
}

oh_my_bash_defaults() {
    if ! test -d ~/.oh-my-bash/; then
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
    fi
}

bash_install() {
    test -f ~/.bashrc && mv -v --backup=t ~/.bashrc ~/.bashrc.shell_utils-backup-"$backup_date"
    cp -f "${shell_utils_dir}/bashrc" ~/.bashrc
    echo -e "\n${byellow_on_blue}The SHELL_UTILS has been successfully installed! Destination: ${shell_utils_dir}${nc}"
    sleep "$delay" && bash
}

fish_install() {
    test ! -d ~/.config/fish/conf.d && mkdir -p ~/.config/fish/conf.d
    test -f ~/.config/fish/conf.d/shell_utils.fish && rm ~/.config/fish/conf.d/shell_utils.fish
    ln -s "${shell_utils_dir}/shell_utils.fish" ~/.config/fish/conf.d/shell_utils.fish
    echo -e "\n${byellow_on_blue}The SHELL_UTILS has been successfully installed! Destination: ${shell_utils_dir}${nc}"
    sleep "$delay" && fish
}

enable_permissions() {
    for file in *; do
        # Check if it's a regular file
        if [[ -f "$file" ]]; then
            # Read the first line of the file
            IFS= read -r first_line < "$file"
            
            # Check if the first line contains a shebang (#!)
            if [[ $first_line == "#!"* ]]; then
                # Check if it's executable
                if [[ ! -x "$file" ]]; then
                    chmod +x "$file"
                fi
            fi
        fi
    done
}

cd "${shell_utils_dir}/scripts" || exit
enable_permissions
cd "${shell_utils_dir}/scripts/faqs" || exit
enable_permissions
cd "$my_dir" || exit

case "$parent_shell" in
    zsh)
        echo "The script was called from ZSH."
        oh_my_zsh_defaults &
        pid=$!
        wait $pid
        zsh_install
        exit 0
        ;;
    bash)
        echo "The script was called from BASH."
        oh_my_bash_defaults &
        pid=$!
        wait $pid
        bash_install
        exit 0
        ;;
    fish)
        echo "The script was called from FISH."
        fish_install
        exit 0
        ;;
    *)
        echo "The script was called from an unknown shell: $parent_shell"
        exit 1
        ;;
esac