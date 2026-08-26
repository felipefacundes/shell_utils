[[ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/ ]] && return

if grep -q _zsh_autosuggest_strategy_smart ~/.zshrc; then
    rm -f ~/.zshrc
    cp -f ~/.shell_utils/utilities/dotfiles/zshrc ~/.zshrc &>/dev/null
fi

# Smart Ghost-Text
# Optimized version that caches PATH
# _zsh_autosuggest_strategy_smart() {
#     local prefix="$1"
#     local suggestion=""
#     local escaped_prefix

#     # Escapes the prefix for safe use in regex (ERE)
#     escaped_prefix=$(printf "%s" "$prefix" | sed 's/[.[\*^$()+?{|]/\\&/g')

#     # 1. History - gets only commands, ignores timestamps and numbers
#     suggestion=$(fc -ln -50 2>/dev/null | grep -E "^[[:space:]]*${escaped_prefix}" | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' | head -1)
#     suggestion=$(printf "%s" "$suggestion" | head -1 | xargs)
#     [[ -n "$suggestion" ]] && printf "%s" "$suggestion" && return

#     # 2. PATH commands (with cache) — grep -E here too, for consistency with the escape above
#     if [[ -z "$_cached_commands" ]]; then
#         _cached_commands=$(compgen -c 2>/dev/null)
#     fi
#     suggestion=$(printf "%s" "$_cached_commands" | grep -E "^${escaped_prefix}" | head -1)
#     [[ -n "$suggestion" ]] && printf "%s" "$suggestion" && return

#     # 3. Local directories
#     suggestion=$(find . -maxdepth 1 -type d -name "${prefix}*" 2>/dev/null | head -1 | sed 's|^\./||')
#     [[ -n "$suggestion" ]] && printf "%s" "${suggestion}/" && return

#     # 4. Local files
#     suggestion=$(find . -maxdepth 1 -type f -name "${prefix}*" 2>/dev/null | head -1 | sed 's|^\./||')
#     [[ -n "$suggestion" ]] && printf "%s" "$suggestion" && return
# }

_zsh_autosuggest_strategy_smart() {
    local prefix="$1"
    local escaped_prefix
    local cmd

    # Do NOT declare "local suggestion" here — the plugin already controls this
    # variable in the caller's scope; due to zsh's dynamic scoping,
    # assigning without "local" propagates the value outward correctly.

    escaped_prefix=$(printf "%s" "$prefix" | sed 's/[.[\*^$()+?{|]/\\&/g')

    # 1. History
    suggestion=$(fc -ln -50 2>/dev/null \
        | grep -E "^[[:space:]]*${escaped_prefix}" \
        | sed -E 's/^[[:space:]]*[0-9]*[[:space:]]*//' \
        | head -1 | xargs)
    [[ -n "$suggestion" ]] && return

    # 2. PATH commands (with cache) — without regex, no escaping risk
    if [[ -z "$_cached_commands" ]]; then
        _cached_commands=$(compgen -c 2>/dev/null)
    fi
    for cmd in ${(f)_cached_commands}; do
        if [[ "$cmd" == "$prefix"* ]]; then
            suggestion="$cmd"
            return
        fi
    done

    # 3. Local directories
    suggestion=$(command find . -maxdepth 1 -type d -name "${prefix}*" 2>/dev/null | head -1 | sed 's|^\./||')
    if [[ -n "$suggestion" ]]; then
        suggestion="${suggestion}/"
        return
    fi

    # 4. Local files
    suggestion=$(command find . -maxdepth 1 -type f -name "${prefix}*" 2>/dev/null | head -1 | sed 's|^\./||')
}

# Simplified and safe cache management
if type add-zsh-hook &>/dev/null; then
    autoload -U add-zsh-hook
    (add-zsh-hook precmd 'unset _cached_commands') &>/dev/null
fi

ZSH_AUTOSUGGEST_STRATEGY=smart

bindkey -s '\ex' 'commands\n'