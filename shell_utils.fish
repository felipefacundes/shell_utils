# shell_utils.fish

set shell_utils ~/.shell_utils
set shell_utils_users ~/.local/shell_utils
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
    set -l source_dir $argv[1]
    
    if test -f "$source_dir.fish"
        rm "$source_dir.fish"
    end

    # Checks if the directory exists and has .fish files
    if not test -d "$source_dir"
        return
    end
    
    if not find "$source_dir" -name "*.fish" -type f -print -quit >/dev/null
        return
    end
        
    for file in (find "$source_dir" -name '*.fish' 2>/dev/null)
        set file (string replace $HOME "\$HOME" -- $file)
        echo "source $file" >> "$source_dir.fish"
    end
end

# Priority - What should be started before
set source_path priority
sourced "$shell_utils/$source_path"
if test -f "$shell_utils/$source_path.fish"
    source "$shell_utils/$source_path.fish"
end

if not test -d "$shell_utils_users/$source_path"
    mkdir -p "$shell_utils_users/$source_path"
end

sourced "$shell_utils_users/$source_path"

if test -f "$shell_utils_users/$source_path.fish"
    source "$shell_utils_users/$source_path.fish"
end

########################################
############# MY VARIABLES #############
set source_path variables
sourced "$shell_utils/$source_path"
if test -f "$shell_utils/$source_path.fish"
    source "$shell_utils/$source_path.fish"
end

if not test -d "$shell_utils_users/$source_path"
    mkdir -p "$shell_utils_users/$source_path"
end

sourced "$shell_utils_users/$source_path"

if test -f "$shell_utils_users/$source_path.fish"
    source "$shell_utils_users/$source_path.fish"
end

########################################
############# MY FUNCTIONS #############
set source_path functions
sourced "$shell_utils/$source_path"
if test -f "$shell_utils/$source_path.fish"
    source "$shell_utils/$source_path.fish"
end

if not test -d "$shell_utils_users/$source_path"
    mkdir -p "$shell_utils_users/$source_path"
end

sourced "$shell_utils_users/$source_path"

if test -f "$shell_utils_users/$source_path.fish"
    source "$shell_utils_users/$source_path.fish"
end

########################################
############### ALIASES ###############
# Example aliases:
# alias bashconfig="vim ~/.bashrc"
# alias zshconfig="vim ~/.zshrc"
set source_path aliases
sourced "$shell_utils/$source_path"
if test -f "$shell_utils/$source_path.fish"
    source "$shell_utils/$source_path.fish"
end

if not test -d "$shell_utils_users/$source_path"
    mkdir -p "$shell_utils_users/$source_path"
end

sourced "$shell_utils_users/$source_path"

if test -f "$shell_utils_users/$source_path.fish"
    source "$shell_utils_users/$source_path.fish"
end

########################################
### USER SCRIPTS / HELPS / MARKDOWNS ###
if not test -d "$shell_utils_users/scripts/helps/markdowns"
    mkdir -p "$shell_utils_users/scripts/helps/markdowns"
end

if not test -d "$shell_utils_users/scripts/utils"
    mkdir -p "$shell_utils_users/scripts/utils"
end

##### History
if not test -f ~/.local/share/fish/fish_history
    touch ~/.local/share/fish/fish_history
end

##### SECURITY - Note: Fish doesn't use these history files, but we'll keep for compatibility
# These sed commands are kept for bash/zsh users but won't affect Fish
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
set -e shell_utils_configs
set -e shell_utils_users
set -e shell_utils
set -e source_file
set -e source_path

# Clean up functions
functions -e sourced