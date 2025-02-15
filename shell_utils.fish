set shell_utils ~/.shell_utils
set shell_utils_configs ~/.shell_utils_configs

# Path to your shell_utils installation.
if not test -d "$shell_utils"
    git clone https://github.com/felipefacundes/shell_utils "$shell_utils"
end

# Path to your shell_utils configs
if not test -d "$shell_utils_configs"
    mkdir -p "$shell_utils_configs"
end

# Loops through all .fish files in the source directory and its subdirectories
function sourced
    set source_file "$shell_utils/$source_path.fish"
    if test -f "$source_file"
        rm "$source_file"
    end

    for file in (find "$shell_utils/$source_path" -name '*.fish' 2>/dev/null)
        set file (string replace $HOME "\$HOME" -- $file)
        echo ". $file" >> "$shell_utils/$source_path.fish"
    end
end

# Priority
# What should be started before
set source_path priority
sourced
if test -f "$shell_utils/$source_path.fish"
    . "$shell_utils/$source_path.fish"
end

########################################
############# MY VARIABLES #############
set source_path variables
sourced
if test -f "$shell_utils/$source_path.fish"
    . "$shell_utils/$source_path.fish"
end

########################################
############# MY FUNCTIONS #############
set source_path functions
sourced
if test -f "$shell_utils/$source_path.fish"
    . "$shell_utils/$source_path.fish"
end

########################################
############### ALIASES ###############
# Example aliases:
# alias bashconfig="vim ~/.bashrc"
# alias zshconfig="vim ~/.zshrc"
set source_path aliases
sourced
if test -f "$shell_utils/$source_path.fish"
    . "$shell_utils/$source_path.fish"
end

##### History
if not test -f ~/.local/share/fish/fish_history
    touch ~/.local/share/fish/fish_history
end

##### SECURITY
sed -i 's#cmd: rm #cmd: rm_locked #g' ~/.local/share/fish/fish_history
sed -i 's#cmd: sudo rm #cmd: rm_locked #g' ~/.local/share/fish/fish_history
sed -i 's#cmd: doas rm #cmd: rm_locked #g' ~/.local/share/fish/fish_history
sed -i 's#cmd: mv #cmd: mv_locked #g' ~/.local/share/fish/fish_history
sed -i 's#cmd: sudo mv #cmd: mv_locked #g' ~/.local/share/fish/fish_history
sed -i 's#cmd: doas mv #cmd: mv_locked #g' ~/.local/share/fish/fish_history
sed -i 's|/dev/sd[abcdefghij][123456789]|/dev/sdX|g' ~/.local/share/fish/fish_history
sed -i 's|/dev/sd[abcdefghij]|/dev/sdX|g' ~/.local/share/fish/fish_history

# Load ASCII Theme Art
"$shell_utils/scripts/ascii_theme_select.sh"

# SHELL_UTILS AUTO UPDATE
"$shell_utils/scripts/shell_utils_update.sh"

########################################
set -e source_file
set -e shell_utils
set -e source_path
set -e sourced