zsh_history=~/.zsh_history
bash_history=~/.bash_history
shell_utils=~/.shell_utils
shell_utils_users=~/.local/share/shell_utils
shell_utils_configs=~/.shell_utils_configs

# DEBUG log on/off
# exec 2>/tmp/shell_utils_debug

if [[ -n "$TERMUX_VERSION" ]]; then
    USER=$(id -un); export USER
fi

# Path to your shell_utils installation.
if [ ! -d "$shell_utils" ]; then
    git clone --depth 1 https://github.com/felipefacundes/shell_utils "$shell_utils" \
        || { echo "shell_utils: clone error — pulando carga" >&2; return 1 2>/dev/null || exit 1; }
fi

# Path to your shell_utils configs
if [ ! -d "$shell_utils_configs" ]; then
    mkdir -p "$shell_utils_configs"
fi

for d in priority variables functions aliases scripts/helps/markdowns scripts/utils; do
    [[ -d "$shell_utils_users/$d" ]] || mkdir -p "$shell_utils_users/$d"
done

# Loops through all .sh files in the source directory and its subdirectories
sourced() {
    local source_dir="$1"
    local output_file="${source_dir}.sh"
    local tmp
    tmp=$(mktemp "${TMPDIR:-/tmp}/sourced.XXXXXX") || return

    [[ -d "$source_dir" ]] || { rm -f -- "$output_file" "$tmp"; return; }

    find "$source_dir" -type f -name '*.sh' -exec printf '. %q\n' {} + > "$tmp" 2>>"${TMPDIR:-/tmp}/shell_utils_sourced.log"

    if [[ -s "$tmp" ]]; then
        cmp -s "$tmp" "$output_file" || { rm -f -- "$output_file" && cp -f -- "$tmp" "$output_file" 2>>"${TMPDIR:-/tmp}/shell_utils_sourced.log"; }
    else
        rm -f -- "$output_file"
    fi
    rm -f -- "$tmp"
}

load_path() {
    local name="$1"
    sourced "${shell_utils}/${name}"
    # shellcheck source=/dev/null
    [[ -f "${shell_utils}/${name}.sh" ]] && . "${shell_utils}/${name}.sh"

    [[ -d "${shell_utils_users}/${name}" ]] || mkdir -p "${shell_utils_users}/${name}"
    sourced "${shell_utils_users}/${name}"
    # shellcheck source=/dev/null
    [[ -f "${shell_utils_users}/${name}.sh" ]] && . "${shell_utils_users}/${name}.sh"
}

# Priority
# What should be started before
load_path priority
load_path variables
load_path functions
########################################
############### ALIASES ###############
# Example aliases:
# alias bashconfig="vim ~/.bashrc"
# alias zshconfig="vim ~/.zshrc"
load_path aliases

##### History
[[ ! -f "$zsh_history" ]] && touch "$zsh_history"
[[ ! -f "$bash_history" ]] && touch "$bash_history"

##### SECURITY
_history_security() {
    local f="$1"
    [[ -f "$f" ]] || return 0
    sed -i -e 's#;rm #;rm_locked #g' \
           -e 's#^rm #rm_locked #g' \
           -e 's#^sudo rm #rm_locked #g' \
           -e 's#^doas rm #rm_locked #g' \
           -e 's#;sudo rm #;rm_locked #g' \
           -e 's#;doas rm #;rm_locked #g' \
           -e 's#^mv #mv_locked #g' \
           -e 's#^sudo mv #mv_locked #g' \
           -e 's#^doas mv #mv_locked #g' \
           -e 's#;mv #;mv_locked #g' \
           -e 's#;sudo mv #;mv_locked #g' \
           -e 's#;doas mv #;mv_locked #g' \
           -e 's|/dev/sd[abcdefghij][123456789]|/dev/sdX|g' \
           -e 's|/dev/sd[abcdefghij]|/dev/sdX|g' \
           "$f"
}

#[[ -f "$shell_utils_configs/security.conf" ]] && . "$shell_utils_configs/security.conf"
#if [[ "${SANITIZE_HISTORY_ON_EXIT:-0}" == 1 ]]; then
#    if [[ -n "$ZSH_VERSION" ]]; then
#        zshexit() { _history_security "$zsh_history"; _history_security "$bash_history"; }
#    elif [[ -n "$BASH_VERSION" ]]; then
#        trap '_history_security "$zsh_history"; _history_security "$bash_history"' EXIT
#    fi
#fi

_history_security "$zsh_history"
_history_security "$bash_history"

if [[ $- == *i* ]]; then
    # Load ASCII Theme Art
    "$shell_utils/scripts/ascii-theme-select"

    # SHELL_UTILS AUTO UPDATE
    "$shell_utils/scripts/shell-utils-update"
fi

########################################
unset -f sourced load_path 2>/dev/null
unset shell_utils shell_utils_users shell_utils_configs 2>/dev/null

#shellcheck source=/dev/null
if [[ -n "$BASH_VERSION" ]]; then
	source ~/.shell_utils/scripts/utils/install-bash-smartcd
fi

if [[ -n "$TERMUX_VERSION" ]]; then
   [[ -d /sdcard ]] && { cd /sdcard || true; }
fi