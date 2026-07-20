
[[ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/ ]] && return

if grep -q _zsh_autosuggest_strategy_smart ~/.zshrc; then
    rm -f ~/.zshrc
    cp -f ~/.shell_utils/utilities/dotfiles/zshrc ~/.zshrc &>/dev/null
fi

# Smart Ghost-Text
# Versão otimizada que faz cache do PATH
_zsh_autosuggest_strategy_smart() {
    local prefix="$1"
    local suggestion=""
    local escaped_prefix
    
    # Escapa o prefixo para uso seguro em regex
    escaped_prefix=$(printf "%s" "$prefix" | sed 's/[.[\*^$()+?{|]/\\&/g')
    
    # 1. Histórico - pega apenas comandos, ignora timestamps e números
    suggestion=$(fc -ln -50 2>/dev/null | grep -E "^[[:space:]]*${escaped_prefix}" | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' | head -1)
    # Garante que é uma linha única sem caracteres especiais
    suggestion=$(printf "%s" "$suggestion" | head -1 | xargs)
    [[ -n "$suggestion" ]] && printf "%s" "$suggestion" && return
    
    # 2. Comandos do PATH (com cache)
    if [[ -z "$_cached_commands" ]]; then
        _cached_commands=$(compgen -c 2>/dev/null)
    fi
    suggestion=$(printf "%s" "$_cached_commands" | grep "^${escaped_prefix}" | head -1)
    [[ -n "$suggestion" ]] && printf "%s" "$suggestion" && return
    
    # 3. Diretórios locais
    suggestion=$(find . -maxdepth 1 -type d -name "${prefix}*" 2>/dev/null | head -1 | sed 's|^\./||')
    [[ -n "$suggestion" ]] && printf "%s" "${suggestion}/" && return
    
    # 4. Arquivos locais
    suggestion=$(find . -maxdepth 1 -type f -name "${prefix}*" 2>/dev/null | head -1 | sed 's|^\./||')
    [[ -n "$suggestion" ]] && printf "%s" "$suggestion" && return
}

# Cache management simplificado e seguro
if type add-zsh-hook &>/dev/null; then
    autoload -U add-zsh-hook
    (add-zsh-hook precmd 'unset _cached_commands') &>/dev/null
fi

ZSH_AUTOSUGGEST_STRATEGY=smart

bindkey -s '\ex' 'commands\n'