# Complete var without echo or print
_complete_env_var_bind() {
    local line="$READLINE_LINE"
    local point="$READLINE_POINT"
    local before="${line:0:$point}"
    local _ENV_COLOR_HIGHLIGHT='\e[1;35m'
    local _ENV_COLOR_RESET='\e[0m'
    
    # Extract the word before the cursor
    local current_word="${before##*[^a-zA-Z0-9_]}"
    local word_start=$(( point - ${#current_word} ))
    local after="${line:$point}"
    
    # If it's a new word, rebuild
    if [[ -z "$_ENV_ORIGINAL_WORD" ]] || [[ "$current_word" != "$_ENV_ORIGINAL_WORD"* && "$_ENV_ORIGINAL_WORD" != "$current_word"* ]]; then
        _ENV_ORIGINAL_WORD="$current_word"
        _ENV_MATCHES=()
        _ENV_INDEX=-1
        
        # Search for matches
        while IFS= read -r var; do
            _ENV_MATCHES+=("$var")
        done < <(compgen -v -- "$current_word")
        
        # Case-insensitive fallback
        if [[ ${#_ENV_MATCHES[@]} -eq 0 && -n "$current_word" ]]; then
            while IFS= read -r var; do
                if [[ "${var,,}" == "${current_word,,}"* ]]; then
                    _ENV_MATCHES+=("$var")
                fi
            done < <(compgen -v)
        fi
        
        if [[ ${#_ENV_MATCHES[@]} -eq 0 ]]; then
            _ENV_ORIGINAL_WORD=""
            return 1
        fi
        
        # Show options with colored highlighting
        echo
        local match
        for match in "${_ENV_MATCHES[@]}"; do
            # Separate the matching part from the rest
            local prefix="${match:0:${#_ENV_ORIGINAL_WORD}}"
            local suffix="${match:${#_ENV_ORIGINAL_WORD}}"
            
            # If case-insensitive, highlight the matching part
            if [[ "${match,,}" == "${_ENV_ORIGINAL_WORD,,}"* ]]; then
                # Get the actual prefix (preserving original case)
                printf "${_ENV_COLOR_HIGHLIGHT}%s${_ENV_COLOR_RESET}%s  " "$prefix" "$suffix"
            else
                printf '%s  ' "$match"
            fi
        done
        echo
    fi
    
    # Advance to the next match (cycles through)
    _ENV_INDEX=$(( (_ENV_INDEX + 1) % ${#_ENV_MATCHES[@]} ))
    
    # Apply the match
    local selected="${_ENV_MATCHES[$_ENV_INDEX]}"
    READLINE_LINE="${line:0:$word_start}${selected}${after}"
    READLINE_POINT=$(( word_start + ${#selected} ))
}