#!/bin/fish
# License: GPLv3
# Credits: Felipe Facundes

# : <<'DOCUMENTATION'
# This Fish shell script checks for the installation of Fish and Oh My Fish, and allows the user to select and apply a theme from the installed 
# themes using an interactive menu. It ensures a smooth user experience by providing navigation and selection functionality within the terminal.
# DOCUMENTATION

clear

set on_blue "\033[4;1;44m"
set highlight "\033[4;34;42m"
set nc "\033[0m"

# Check if fish is installed
if not command -v fish > /dev/null
    echo "Fish shell is not installed. Please install it first."
    exit 1
end

# Check if rofi is installed
# if not command -v rofi > /dev/null
#     echo "Rofi is not installed. Please install it first."
#     exit 1
# end

# Check if the current shell is fish
if not set -q FISH_VERSION
    echo "This script must be run in the Fish shell."
    exit 1
end

# Check if omf is installed
if not test -d ~/.local/share/omf
    echo "Oh My Fish is not installed. Installing..."
    curl -s https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish &
    wait $last_pid
end

# Remove existing fish_prompt.fish if it exists
if test -f ~/.config/fish/functions/fish_prompt.fish
    rm ~/.config/fish/functions/fish_prompt.fish
end

# Get installed themes, ensuring one theme per line
set installed_themes (omf theme | awk '/Installed:/ {found=1; next} found && /Available:/ {exit} found {for (i=1; i<=NF; i++) print $i}')

# Check if there are installed themes
if test (count $installed_themes) -eq 0
    echo "No installed themes found."
    exit 1
end

# Use rofi to select a theme
#set selected_theme (printf "%s\n" $installed_themes | rofi -dmenu -p "Select a theme:")

# Function to display the menu
function display_menu
    clear
    echo "Use w/s to navigate, enter to select:"
    for i in (seq (count $installed_themes))
        if test $i -eq $selected
            echo -e "$i) $highlight$installed_themes[$i]$nc"
        else
            echo "$i) $installed_themes[$i]"
        end
    end
end

# Interactive selection
set selected 1
set key ""

while true
    display_menu
    read -n 1 -s key

    switch $key
        case w W  # W key to climb
            if test $selected -gt 1
                set selected (math "$selected - 1")
            end
        case s S  # S key to descend
            if test $selected -lt (count $installed_themes)
                set selected (math "$selected + 1")
            end
        case ""  # Enter to select
            break
    end
end

clear

# Applies the selected theme
set chosen_theme $installed_themes[$selected]
echo "You selected: $chosen_theme"
omf theme $chosen_theme
omf reload
