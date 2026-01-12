zsh_history=~/.zsh_history
bash_history=~/.bash_history
shell_utils=~/.shell_utils
shell_utils_users=~/.local/shell_utils
shell_utils_configs=~/.shell_utils_configs

# DEBUG log on/off
# exec 2>/tmp/shell_utils_debug

# Path to your shell_utils installation.
if [ ! -d "$shell_utils" ]; then
    git clone https://github.com/felipefacundes/shell_utils "$shell_utils"
fi

# Path to your shell_utils configs
if [ ! -d "$shell_utils_configs" ]; then
    mkdir -p "$shell_utils_configs"
fi

# Loops through all .sh files in the source directory and its subdirectories
sourced() {
    local source_dir="$1"
    local output_file="${source_dir}.sh"
    
    # If directory does not exist, remove file and exit
    if [[ ! -d "$source_dir" ]]; then
        [[ -f "$output_file" ]] && rm -f "$output_file"
        return
    fi
    
    # Generate new content and overwrite with tee
    find "$source_dir" -name "*.sh" -type f 2>/dev/null | \
        while IFS= read -r file; do
            [[ -f "$file" ]] && echo ". \"$file\""
        done | tee "$output_file" >/dev/null
    
    # If tee didn't write anything (empty pipe), remove empty file
    [[ ! -s "$output_file" ]] && rm -f "$output_file"
}

# Priority
# What should be started before
source_path=priority
sourced "${shell_utils}/${source_path}"
#shellcheck source=/dev/null
if test -f "${shell_utils}/${source_path}.sh"; then
    . "${shell_utils}/${source_path}.sh"
fi

if [[ ! -d "${shell_utils_users}/${source_path}" ]]; then
	mkdir -p "${shell_utils_users}/${source_path}"
fi

sourced "${shell_utils_users}/${source_path}"
#shellcheck source=/dev/null
if test -f "${shell_utils_users}/${source_path}.sh"; then
    . "${shell_utils_users}/${source_path}.sh"
fi
########################################
############# MY VARIABLES #############
source_path=variables
sourced "${shell_utils}/${source_path}"
#shellcheck source=/dev/null
if test -f "${shell_utils}/${source_path}.sh"; then
    . "${shell_utils}/${source_path}.sh"
fi

if [[ ! -d "${shell_utils_users}/${source_path}" ]]; then
	mkdir -p "${shell_utils_users}/${source_path}"
fi

sourced "${shell_utils_users}/${source_path}"
#shellcheck source=/dev/null
if test -f "${shell_utils_users}/${source_path}.sh"; then
    . "${shell_utils_users}/${source_path}.sh"
fi
########################################
############# MY FUNCTIONS #############
source_path=functions
sourced "${shell_utils}/${source_path}"
#shellcheck source=/dev/null
if test -f "${shell_utils}/${source_path}.sh"; then
    . "${shell_utils}/${source_path}.sh"
fi

if [[ ! -d "${shell_utils_users}/${source_path}" ]]; then
	mkdir -p "${shell_utils_users}/${source_path}"
fi

sourced "${shell_utils_users}/${source_path}"
#shellcheck source=/dev/null
if test -f "${shell_utils_users}/${source_path}.sh"; then
    . "${shell_utils_users}/${source_path}.sh"
fi
########################################
############### ALIASES ###############
# Example aliases:
# alias bashconfig="vim ~/.bashrc"
# alias zshconfig="vim ~/.zshrc"
source_path=aliases
sourced "${shell_utils}/${source_path}"
#shellcheck source=/dev/null
if test -f "${shell_utils}/${source_path}.sh"; then
    . "${shell_utils}/${source_path}.sh"
fi

if [[ ! -d "${shell_utils_users}/${source_path}" ]]; then
	mkdir -p "${shell_utils_users}/${source_path}"
fi

sourced "${shell_utils_users}/${source_path}"
#shellcheck source=/dev/null
if test -f "${shell_utils_users}/${source_path}.sh"; then
    . "${shell_utils_users}/${source_path}.sh"
fi

########################################
### USER SCRIPTS / HELPS / MARKDOWNS ###
[[ ! -d "${shell_utils_users}/scripts/helps/markdowns" ]] && mkdir -p "${shell_utils_users}/scripts/helps/markdowns"
[[ ! -d "${shell_utils_users}/scripts/utils" ]] && mkdir -p "${shell_utils_users}/scripts/utils"

##### History
[[ ! -f "$zsh_history" ]] && touch "$zsh_history"
[[ ! -f "$bash_history" ]] && touch "$bash_history"

##### SECURITY
sed -i 's#;rm #;rm_locked #g' "$zsh_history"
sed -i 's#;rm #;rm_locked #g' "$bash_history"
sed -i 's#;sudo rm #;rm_locked #g' "$zsh_history"
sed -i 's#;doas rm #;rm_locked #g' "$zsh_history"
sed -i 's#;sudo rm #;rm_locked #g' "$bash_history"
sed -i 's#;doas rm #;rm_locked #g' "$bash_history"
sed -i 's#^rm #rm_locked #g' "$zsh_history"
sed -i 's#^rm #rm_locked #g' "$bash_history"
sed -i 's#^sudo rm #rm_locked #g' "$bash_history"
sed -i 's#^doas rm #rm_locked #g' "$bash_history"
sed -i 's#^sudo rm #rm_locked #g' "$zsh_history"
sed -i 's#^doas rm #rm_locked #g' "$zsh_history"
sed -i 's#^mv #mv_locked #g' "$zsh_history"
sed -i 's#^mv #mv_locked #g' "$bash_history"
sed -i 's#^sudo mv #mv_locked #g' "$bash_history"
sed -i 's#^doas mv #mv_locked #g' "$bash_history"
sed -i 's#^sudo mv #mv_locked #g' "$zsh_history"
sed -i 's#^doas mv #mv_locked #g' "$zsh_history"
sed -i 's#;mv #;mv_locked #g' "$zsh_history"
sed -i 's#;mv #;mv_locked #g' "$bash_history"
sed -i 's#;sudo mv #;mv_locked #g' "$zsh_history"
sed -i 's#;doas mv #;mv_locked #g' "$zsh_history"
sed -i 's#;sudo mv #;mv_locked #g' "$bash_history"
sed -i 's#;doas mv #;mv_locked #g' "$bash_history"
sed -i 's|/dev/sd[abcdefghij][123456789]|/dev/sdX|g' "$zsh_history"
sed -i 's|/dev/sd[abcdefghij][123456789]|/dev/sdX|g' "$bash_history"
sed -i 's|/dev/sd[abcdefghij]|/dev/sdX|g' "$zsh_history"
sed -i 's|/dev/sd[abcdefghij]|/dev/sdX|g' "$bash_history"

# Load ASCII Theme Art
"$shell_utils/scripts/ascii-theme-select"

# SHELL_UTILS AUTO UPDATE
"$shell_utils/scripts/shell-utils-update"

########################################
unset shell_utils_configs
unset shell_utils_users
unset shell_utils
unset source_file
unset source_path
unset sourced

#shellcheck source=/dev/null
if [[ -n "$BASH_VERSION" ]]; then
	source ~/.shell_utils/scripts/utils/install-bash-smartcd
fi