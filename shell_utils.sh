zsh_history=~/.zsh_history
bash_history=~/.bash_history
shell_utils=~/.shell_utils
shell_utils_configs=~/.shell_utils_configs

# Path to your shell_utils installation.
if [ ! -d "$shell_utils" ]; then
    git clone https://github.com/felipefacundes/shell_utils "$shell_utils"
fi

# Path to your shell_utils configs
if [ ! -d "$shell_utils" ]; then
    mkdir -p "$shell_utils_configs"
fi

# Loops through all .sh files in the source directory and its subdirectories
sourced() {
    source_file="${shell_utils}/${source_path}.sh"
    [[ -f "${source_file}" ]] && rm "${source_file}"
    for file in "${shell_utils}/${source_path}"/**/*.sh; do
        if [[ "$file" ]]; then
            file="${file/#$HOME/\"\${HOME\}\"}"
            echo ". $file" >> "${shell_utils}/${source_path}".sh
        fi
    done >/dev/null 2>&1
}

# Priority
# What should be started before
source_path=priority
sourced
if test -f "${shell_utils}/${source_path}.sh"; then
    . "${shell_utils}/${source_path}.sh"
fi

########################################
############# MY VARIABLES #############
source_path=variables
sourced
if test -f "${shell_utils}/${source_path}.sh"; then
    . "${shell_utils}/${source_path}.sh"
fi

########################################
############# MY FUNCTIONS #############
source_path=functions
sourced
if test -f "${shell_utils}/${source_path}.sh"; then
    . "${shell_utils}/${source_path}.sh"
fi

########################################
############### ALIASES ###############
# Example aliases:
# alias bashconfig="vim ~/.bashrc"
# alias zshconfig="vim ~/.zshrc"
source_path=aliases
sourced
if test -f "${shell_utils}/${source_path}.sh"; then
    . "${shell_utils}/${source_path}.sh"
fi

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
"$shell_utils/scripts/ascii_theme_select.sh"

# SHELL_UTILS AUTO UPDATE
"$shell_utils/scripts/shell_utils_update.sh"

########################################
unset bash_history
unset shell_utils
unset source_file
unset source_path
unset sourced

if [[ -n "$BASH_VERSION" ]]; then
	source ~/.shell_utils/scripts/utils/install_bash_smartcd.sh
fi