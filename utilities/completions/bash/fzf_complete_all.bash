############################################################################

_fzf_bash() {
    file=~/.fzf.bash
    if ! test -f "$file" && command -v fzf &>/dev/null; then
        fzf --bash | tee "$file" &>/dev/null
    fi
    # shellcheck source=/dev/null
    test -f "$file" && source "$file"
    return 0
}

# Ctrl+A: Complete anything with fzf (FZF dominates, uses native completions as data source)
_fzf_complete_all_all() {
    local selected
    local cur="${READLINE_LINE:0:$READLINE_POINT}"
    local after_cursor="${READLINE_LINE:$READLINE_POINT}"

    # Extract the last word respecting spaces escaped with \
    local last_word=""
    local prefix=""
    local i=0
    local len=${#cur}
    local current_word=""
    local prev_char=""

    while ((i < len)); do
        local char="${cur:$i:1}"

        if [[ "$char" == ' ' && "$prev_char" != '\' ]]; then
            prefix="${prefix}${current_word} "
            current_word=""
        else
            current_word+="$char"
        fi

        prev_char="$char"
        ((i++))
    done

    last_word="$current_word"
    prefix="${prefix% }"

    # Extract the command (first word of the line)
    local cmd="${cur%% *}"
    local clean_cmd
    clean_cmd=$(printf '%b' "$cmd" 2>/dev/null)

    # Unescape the last word to get the real path
    local clean_word
    clean_word=$(printf '%b' "$last_word" 2>/dev/null)

    # Expand ~
    local expanded_word="$clean_word"
    [[ "$clean_word" == "~"* ]] && expanded_word="${HOME}${clean_word:1}"

    # Detect if it ends with / (want to see directory contents)
    local want_dir_content=false
    [[ "$clean_word" == */ ]] && want_dir_content=true

    # ============================================================
    # PREPARE THE BASH COMPLETION ENVIRONMENT
    # ============================================================
    
    # Try to load completion for the command if not already loaded
    if type _completion_loader &>/dev/null; then
        _completion_loader "$clean_cmd" 2>/dev/null
    elif type _comp_load &>/dev/null; then
        _comp_load "$clean_cmd" 2>/dev/null
    fi

    # Set up Bash completion environment variables
    local COMP_LINE="$READLINE_LINE"
    local COMP_WORDS
    read -ra COMP_WORDS <<< "$READLINE_LINE"
    local COMP_CWORD
    COMP_CWORD=$((${#COMP_WORDS[@]} - 1))
    local COMP_POINT=$READLINE_POINT
    COMPREPLY=()

    # ============================================================
    # TRY TO GET NATIVE COMPLETIONS VIA compgen
    # ============================================================
    
    # Method 1: Use compgen with the command's completion
    local native_candidates=""
    
    # Check if a specific completion function exists
    local comp_spec
    comp_spec=$(complete -p "$clean_cmd" 2>/dev/null)
    
    if [[ -n "$comp_spec" ]]; then
        local comp_func
        comp_func=$(echo "$comp_spec" | sed -n 's/.*-F \([^ ]*\).*/\1/p')
        
        if [[ -n "$comp_func" ]] && type -t "$comp_func" >/dev/null 2>&1; then
            # Execute the native completion function
            "$comp_func" "$clean_cmd" "$last_word" "${COMP_WORDS[$((COMP_CWORD - 1))]:-}" 2>/dev/null
            if [[ ${#COMPREPLY[@]} -gt 0 ]]; then
                native_candidates=$(printf '%s\n' "${COMPREPLY[@]}")
            fi
        fi
    fi

    # ============================================================
    # BUILD THE FINAL CANDIDATE LIST (FZF DOMINATES EVERYTHING)
    # ============================================================
    
    local candidates
    
    if [[ -n "$native_candidates" ]]; then
        # Use native completions as the primary source
        candidates="$native_candidates"
    else
        # Fallback: generate generic candidates
        candidates=$(
            {
                if $want_dir_content && [[ -d "$expanded_word" ]]; then
                    ls -1A "$expanded_word" 2>/dev/null | while read -r item; do
                        echo "${clean_word}${item}"
                    done
                else
                    compgen -f -- "$clean_word" 2>/dev/null
                fi

                # Only search for commands/functions/etc if it's not a path
                if [[ "$clean_word" != */* && "$clean_word" != ~* ]]; then
                    compgen -c -- "$clean_word" 2>/dev/null
                    compgen -b -- "$clean_word" 2>/dev/null
                    alias | cut -d' ' -f2 | cut -d'=' -f1 | grep "^$clean_word" 2>/dev/null
                    declare -F | cut -d' ' -f3 | grep "^$clean_word" 2>/dev/null
                fi

                # Variables
                if [[ "$clean_word" == '$'* ]]; then
                    compgen -v -- "${clean_word#$}" 2>/dev/null | sed 's/^/$/'
                elif [[ "$clean_word" != */* && "$clean_word" != ~* ]]; then
                    compgen -v -- "$clean_word" 2>/dev/null
                fi
            } | sort -u
        )
    fi

    [[ -z "$candidates" ]] && return 1

    # ============================================================
    # FZF DOMINATES: always use fzf to select
    # ============================================================
    
    # Escape candidates for display
    local escaped_candidates
    escaped_candidates=$(printf '%s\n' "$candidates" | while read -r line; do
        local out=""
        local j char
        for ((j = 0; j < ${#line}; j++)); do
            char="${line:$j:1}"
            case "$char" in
                ' '|'('|')'|'&'|';'|'<'|'>'|'|'|'"'|"'"|'!'|'#'|'['|']')
                    out+="\\$char"
                    ;;
                *)
                    out+="$char"
                    ;;
            esac
        done
        echo "$out"
    done)

    local fzf_query="$last_word"
    $want_dir_content && fzf_query=""

    selected=$(printf '%s\n' "$escaped_candidates" |
        FZF_DEFAULT_OPTS="--height 40% --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-}" \
        fzf --query "$fzf_query" --select-1 --exit-0)

    if [[ -n "$selected" ]]; then
        local check_path
        check_path=$(printf '%b' "$selected" 2>/dev/null)
        [[ "$check_path" == "~"* ]] && check_path="${HOME}${check_path:1}"

        if [[ -d "$check_path" && "$selected" != */ ]]; then
            selected="$selected/"
        fi

        if [[ -n "$prefix" ]]; then
            READLINE_LINE="${prefix} ${selected}${after_cursor}"
            READLINE_POINT=$((${#prefix} + 1 + ${#selected}))
        else
            READLINE_LINE="${selected}${after_cursor}"
            READLINE_POINT=${#selected}
        fi
    fi
}

# Ctrl+A: Complete anything with fzf (FZF dominates, uses native completions as data source)
_fzf_complete_all() {
    local selected
    local cur="${READLINE_LINE:0:$READLINE_POINT}"
    local after_cursor="${READLINE_LINE:$READLINE_POINT}"

    # Extract the last word respecting backslash-escaped spaces
    local last_word=""
    local prefix=""
    local i=0
    local len=${#cur}
    local current_word=""
    local prev_char=""

    while ((i < len)); do
        local char="${cur:$i:1}"

        if [[ "$char" == ' ' && "$prev_char" != '\' ]]; then
            prefix="${prefix}${current_word} "
            current_word=""
        else
            current_word+="$char"
        fi

        prev_char="$char"
        ((i++))
    done

    last_word="$current_word"
    prefix="${prefix% }"

    # Extract the command (first word of the line)
    local cmd="${cur%% *}"
    local clean_cmd
    clean_cmd=$(printf '%b' "$cmd" 2>/dev/null)

    # Unescape the last word to get the real path
    local clean_word
    clean_word=$(printf '%b' "$last_word" 2>/dev/null)

    # Require at least one character to avoid listing everything (performance)
    if [[ -z "$clean_word" ]]; then
        return 1
    fi

    # Expand tilde
    local expanded_word="$clean_word"
    [[ "$clean_word" == "~"* ]] && expanded_word="${HOME}${clean_word:1}"

    # Detect if it ends with / (user wants to see inside the directory)
    local want_dir_content=false
    [[ "$clean_word" == */ ]] && want_dir_content=true

    # ============================================================
    # PREPARE BASH COMPLETION ENVIRONMENT
    # ============================================================
    
    # Try to load completion for the command if not already loaded
    if type _completion_loader &>/dev/null; then
        _completion_loader "$clean_cmd" 2>/dev/null
    elif type _comp_load &>/dev/null; then
        _comp_load "$clean_cmd" 2>/dev/null
    fi

    # Set up Bash completion environment variables
    local COMP_LINE="$READLINE_LINE"
    local COMP_WORDS
    read -ra COMP_WORDS <<< "$READLINE_LINE"
    local COMP_CWORD
    COMP_CWORD=$((${#COMP_WORDS[@]} - 1))
    local COMP_POINT=$READLINE_POINT
    COMPREPLY=()

    # ============================================================
    # TRY TO GET NATIVE COMPLETIONS VIA compgen
    # ============================================================
    
    # Method 1: Use compgen with the command's completion
    local native_candidates=""
    
    # Check if there is a specific completion function
    local comp_spec
    comp_spec=$(complete -p "$clean_cmd" 2>/dev/null)
    
    if [[ -n "$comp_spec" ]]; then
        local comp_func
        comp_func=$(echo "$comp_spec" | sed -n 's/.*-F \([^ ]*\).*/\1/p')
        
        if [[ -n "$comp_func" ]] && type -t "$comp_func" >/dev/null 2>&1; then
            # Execute the native completion function
            "$comp_func" "$clean_cmd" "$last_word" "${COMP_WORDS[$((COMP_CWORD - 1))]:-}" 2>/dev/null
            if [[ ${#COMPREPLY[@]} -gt 0 ]]; then
                native_candidates=$(printf '%s\n' "${COMPREPLY[@]}")
            fi
        fi
    fi

    # ============================================================
    # BUILD THE FINAL CANDIDATE LIST (FZF DOMINATES EVERYTHING)
    # ============================================================
    
    local candidates
    
    if [[ -n "$native_candidates" ]]; then
        # Use native completions as the main source
        candidates="$native_candidates"
    else
        # Fallback: generate generic candidates
        candidates=$(
            {
                if $want_dir_content && [[ -d "$expanded_word" ]]; then
                    ls -1A "$expanded_word" 2>/dev/null | while read -r item; do
                        echo "${clean_word}${item}"
                    done
                else
                    compgen -f -- "$clean_word" 2>/dev/null
                fi

                # Only search commands/functions/etc if not a path
                if [[ "$clean_word" != */* && "$clean_word" != ~* ]]; then
                    compgen -c -- "$clean_word" 2>/dev/null
                    compgen -b -- "$clean_word" 2>/dev/null
                    alias | cut -d' ' -f2 | cut -d'=' -f1 | grep "^$clean_word" 2>/dev/null
                    declare -F | cut -d' ' -f3 | grep "^$clean_word" 2>/dev/null
                fi

                # Variables
                if [[ "$clean_word" == '$'* ]]; then
                    compgen -v -- "${clean_word#$}" 2>/dev/null | sed 's/^/$/'
                elif [[ "$clean_word" != */* && "$clean_word" != ~* ]]; then
                    compgen -v -- "$clean_word" 2>/dev/null
                fi
            } | sort -u
        )
    fi

    [[ -z "$candidates" ]] && return 1

    # ============================================================
    # FZF DOMINATES: always use fzf to select
    # ============================================================
    
    # Escape candidates for display
    local escaped_candidates
    escaped_candidates=$(printf '%s\n' "$candidates" | while read -r line; do
        local out=""
        local j char
        for ((j = 0; j < ${#line}; j++)); do
            char="${line:$j:1}"
            case "$char" in
                ' '|'('|')'|'&'|';'|'<'|'>'|'|'|'"'|"'"|'!'|'#'|'['|']')
                    out+="\\$char"
                    ;;
                *)
                    out+="$char"
                    ;;
            esac
        done
        echo "$out"
    done)

    local fzf_query="$last_word"
    $want_dir_content && fzf_query=""

    selected=$(printf '%s\n' "$escaped_candidates" |
        FZF_DEFAULT_OPTS="--height 40% --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-}" \
        fzf --query "$fzf_query" --select-1 --exit-0)

    if [[ -n "$selected" ]]; then
        local check_path
        check_path=$(printf '%b' "$selected" 2>/dev/null)
        [[ "$check_path" == "~"* ]] && check_path="${HOME}${check_path:1}"

        if [[ -d "$check_path" && "$selected" != */ ]]; then
            selected="$selected/"
        fi

        if [[ -n "$prefix" ]]; then
            READLINE_LINE="${prefix} ${selected}${after_cursor}"
            READLINE_POINT=$((${#prefix} + 1 + ${#selected}))
        else
            READLINE_LINE="${selected}${after_cursor}"
            READLINE_POINT=${#selected}
        fi
    fi
}
