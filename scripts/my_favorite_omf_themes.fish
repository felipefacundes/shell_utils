#!/bin/fish
# License: GPLv3
# Credits: Felipe Facundes

# Check if fish is installed
if not command -v fish > /dev/null
    echo "Fish shell is not installed. Please install it first."
    exit 1
end

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
function remove_fish_prompt
    if test -f ~/.config/fish/functions/fish_prompt.fish
        rm ~/.config/fish/functions/fish_prompt.fish
    end
end

function install_theme
    set -l theme $argv[1]  # Get the first argument passed to the function

    if test -z "$theme"  # Check if no argument was provided
        return 1
    end

    if not test -d ~/.local/share/omf/themes/$theme
        remove_fish_prompt
        omf install $theme &
        wait $last_pid
    else
        echo "The theme '$theme' is already installed."
    end
end

install_theme anchor
install_theme batman
install_theme bobthefish
install_theme doughsay
install_theme easy-eel
install_theme fishbone
install_theme harleen
install_theme heartsteal
install_theme kawasaki
install_theme lavender
install_theme nelsonjchen
install_theme pastfish
install_theme plain
install_theme pure
install_theme scorphish
install_theme simple-ass-prompt
install_theme sushi
install_theme tweetjay
install_theme ultrafish
install_theme zephyr

echo "
Select my favorite omf themes with:

omf theme anchor
omf theme batman
omf theme bobthefish
omf theme doughsay
omf theme easy-eel
omf theme fishbone
omf theme harleen
omf theme heartsteal
omf theme kawasaki
omf theme lavender
omf theme nelsonjchen
omf theme pastfish
omf theme plain
omf theme pure
omf theme scorphish
omf theme simple-ass-prompt
omf theme sushi
omf theme tweetjay
omf theme ultrafish
omf theme zephyr
"