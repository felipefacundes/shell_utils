#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script provides a simple way to switch Awesome Window Manager themes using rofi as a selection interface. 
It works by listing all available themes from the ~/.config/awesome/themes directory, presenting them in a rofi menu 
for user selection. Once a theme is chosen, it updates the init.lua file with the new theme path and immediately restarts 
Awesome WM to apply the changes. The script is particularly useful for users who want to quickly switch between different 
Awesome WM themes without manually editing configuration files.

Note: This script works properly with the AwesomeWM configurations contained in https://github.com/felipefacundes/dotfiles

I notice you're referencing an external repository. While I can't access the repository directly, I can help provide information 
about the script's relationship to AwesomeWM configurations. Would you like me to explain more about how this script interacts with 
AwesomeWM theme structures in general?
DOCUMENTATION

if ! command -v rofi 1> /dev/null; then
    echo "Error: rofi is not installed. Please install it first."
    exit 1
fi

awesome_themes_dir=~/.config/awesome/themes
theme_list=$(ls -dF "${awesome_themes_dir}"/*/ | xargs -n 1 basename)
theme_selected=$(echo "$theme_list" | rofi -dmenu -i -p "Awesome Theme")

if [[ ${theme_selected} ]]; then
    echo "my_themes = \"/themes/${theme_selected}/theme.lua\"" | tee "${awesome_themes_dir}"/init.lua
    awesome-client 'awesome.restart()'
fi