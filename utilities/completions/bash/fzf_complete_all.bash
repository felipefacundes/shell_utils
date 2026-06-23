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
_fzf_complete_all() {
    local selected
    local cur="${READLINE_LINE:0:$READLINE_POINT}"
    local after_cursor="${READLINE_LINE:$READLINE_POINT}"

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

    local cmd="${cur%% *}"
    local clean_cmd
    clean_cmd=$(printf '%b' "$cmd" 2>/dev/null)

    # VAR MODE — handles $VAR, $VAR/path, $VAR1:$VAR2
    if [[ "$last_word" == *'$'* ]]; then
        local after_last_dollar="${last_word##*\$}"

        # Subshell mode: $( — complete the command inside $(
        if [[ "$after_last_dollar" == '('* ]]; then
            local subcmd="${after_last_dollar#(}"
            local sub_candidates
            sub_candidates=$(
                compgen -c -- "$subcmd"
                compgen -b -- "$subcmd"
                compgen -a -- "$subcmd"
                compgen -A function -- "$subcmd"
            )

            [[ -z "$sub_candidates" ]] && return 1

            selected=$(printf '%s\n' "$sub_candidates" |
                FZF_DEFAULT_OPTS="--height 40% --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-}" \
                fzf --query "$subcmd" --select-1 --exit-0)

            [[ -z "$selected" ]] && return 0

            local base_without_subcmd="${last_word%$subcmd}"
            if [[ -n "$prefix" ]]; then
                READLINE_LINE="${prefix} ${base_without_subcmd}${selected}${after_cursor}"
                READLINE_POINT=$((${#prefix} + 1 + ${#base_without_subcmd} + ${#selected}))
            else
                READLINE_LINE="${base_without_subcmd}${selected}${after_cursor}"
                READLINE_POINT=$((${#base_without_subcmd} + ${#selected}))
            fi
            return 0
        fi

        # $VAR/path — variable followed by a path segment: expand and complete
        if [[ "$after_last_dollar" == */* ]]; then
            local clean_word_var="${last_word//\\ / }"
            local expanded_var
            expanded_var=$(eval echo "$clean_word_var" 2>/dev/null)

            [[ -z "$expanded_var" ]] && return 1

            local var_path_candidates
            var_path_candidates=$(compgen -f -- "$expanded_var" 2>/dev/null)

            [[ -z "$var_path_candidates" ]] && return 1

            selected=$(printf '%s\n' "$var_path_candidates" |
                FZF_DEFAULT_OPTS="--height 40% --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-}" \
                fzf --query "$expanded_var" --select-1 --exit-0)

            [[ -z "$selected" ]] && return 0

            if [[ -d "$selected" && "$selected" != */ ]]; then
                selected="$selected/"
            fi

            if [[ -n "$prefix" ]]; then
                READLINE_LINE="${prefix} ${selected}${after_cursor}"
                READLINE_POINT=$((${#prefix} + 1 + ${#selected}))
            else
                READLINE_LINE="${selected}${after_cursor}"
                READLINE_POINT=${#selected}
            fi
            return 0
        fi

        # Plain $VAR — may have a prefix like $USER:$HO → complete only the last $VAR
        local var_prefix="$after_last_dollar"
        local before_last_dollar="${last_word%\$*}"
        local var_candidates
        var_candidates=$(compgen -v -- "$var_prefix" | sed 's/^/\$/')

        [[ -z "$var_candidates" ]] && return 1

        selected=$(printf '%s\n' "$var_candidates" |
            FZF_DEFAULT_OPTS="--height 40% --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-}" \
            fzf --query "\$$var_prefix" --select-1 --exit-0)

        [[ -z "$selected" ]] && return 0

        local new_last="${before_last_dollar}${selected}"
        if [[ -n "$prefix" ]]; then
            READLINE_LINE="${prefix} ${new_last}${after_cursor}"
            READLINE_POINT=$((${#prefix} + 1 + ${#new_last}))
        else
            READLINE_LINE="${new_last}${after_cursor}"
            READLINE_POINT=${#new_last}
        fi
        return 0
    fi

    # ASSIGNMENT MODE — VAR=value: complete the value after =
    if [[ "$last_word" == *'='* && "$last_word" != -* ]]; then
        local var_name="${last_word%%=*}"
        local val_prefix="${last_word#*=}"

        local assign_candidates
        assign_candidates=$(
            compgen -c -- "$val_prefix"
            compgen -f -- "$val_prefix"
        )

        [[ -z "$assign_candidates" ]] && return 1

        selected=$(printf '%s\n' "$assign_candidates" | sort -u |
            FZF_DEFAULT_OPTS="--height 40% --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-}" \
            fzf --query "$val_prefix" --select-1 --exit-0)

        [[ -z "$selected" ]] && return 0

        local new_last="${var_name}=${selected}"
        if [[ -n "$prefix" ]]; then
            READLINE_LINE="${prefix} ${new_last}${after_cursor}"
            READLINE_POINT=$((${#prefix} + 1 + ${#new_last}))
        else
            READLINE_LINE="${new_last}${after_cursor}"
            READLINE_POINT=${#new_last}
        fi
        return 0
    fi

    # PATH / NATIVE COMPLETION MODE
    local clean_word="${last_word//\\ / }"
    clean_word="${clean_word//\\\(/\(}"
    clean_word="${clean_word//\\\)/\)}"
    clean_word="${clean_word//\\\[/\[}"
    clean_word="${clean_word//\\\]/\]}"

    local expanded_word
    expanded_word=$(eval echo "$clean_word" 2>/dev/null)

    local want_dir_content=false
    [[ "$clean_word" == */ ]] && want_dir_content=true

    if [[ -z "$expanded_word" && -z "$clean_cmd" ]]; then
        return 1
    fi

    if type _completion_loader &>/dev/null; then
        _completion_loader "$clean_cmd" 2>/dev/null
    elif type _comp_load &>/dev/null; then
        _comp_load "$clean_cmd" 2>/dev/null
    fi

    # COMP_* must be global — completion functions like git's read them directly
    COMP_LINE="$READLINE_LINE"
    COMP_POINT=$READLINE_POINT
    COMP_WORDS=()
    read -ra COMP_WORDS <<< "$READLINE_LINE"
    COMP_CWORD=$((${#COMP_WORDS[@]} - 1))
    [[ "$READLINE_LINE" =~ [[:space:]]$ ]] && (( COMP_CWORD++ ))
    if [[ "${COMP_WORDS[$COMP_CWORD]:-}" != "$last_word" ]]; then
        COMP_WORDS[$COMP_CWORD]="$last_word"
    fi
    COMPREPLY=()

    local native_candidates=""

    if ! $want_dir_content; then
        local comp_spec
        comp_spec=$(complete -p "$clean_cmd" 2>/dev/null)

        if [[ -n "$comp_spec" ]]; then
            local comp_func
            comp_func=$(echo "$comp_spec" | sed -n 's/.*-F \([^ ]*\).*/\1/p')

            if [[ -n "$comp_func" ]] && type -t "$comp_func" >/dev/null 2>&1; then
                local prev_word="${COMP_WORDS[$((COMP_CWORD - 1))]:-}"
                "$comp_func" "$clean_cmd" "$last_word" "$prev_word" 2>/dev/null
                if [[ ${#COMPREPLY[@]} -gt 0 ]]; then
                    native_candidates=$(printf '%s\n' "${COMPREPLY[@]}")
                fi
            fi
        fi
    fi

    local candidates

    if [[ -n "$native_candidates" ]]; then
        # If the only candidate is identical to the current word, nothing to complete
        local filtered
        filtered=$(printf '%s\n' "$native_candidates" | grep -v "^${last_word}$")
        [[ -z "$filtered" ]] && return 1
        candidates="$native_candidates"
    else
        candidates=$(
            {
                if $want_dir_content && [[ -d "$expanded_word" ]]; then
                    ls -1A "$expanded_word" 2>/dev/null | while read -r item; do
                        echo "${clean_word}${item}"
                    done
                else
                    compgen -f -- "$clean_word" 2>/dev/null
                fi

                if [[ "$clean_word" != */* && "$clean_word" != ~* ]]; then
                    compgen -c -- "$clean_word" 2>/dev/null
                    compgen -b -- "$clean_word" 2>/dev/null
                    alias | cut -d' ' -f2 | cut -d'=' -f1 | grep "^$clean_word" 2>/dev/null
                    declare -F | cut -d' ' -f3 | grep "^$clean_word" 2>/dev/null
                fi

                if [[ "$clean_word" != */* && "$clean_word" != ~* ]]; then
                    compgen -v -- "$clean_word" 2>/dev/null
                fi
            } | sort -u
        )
    fi

    [[ -z "$candidates" ]] && return 1

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

    [[ -z "$selected" ]] && return 0

    local check_path
    check_path=$(printf '%b' "$selected" 2>/dev/null)
    [[ "$check_path" == "~"* ]] && check_path="${HOME}${check_path:1}"

    # Add trailing slash for directories — but not for bare numbers (PIDs)
    if [[ -d "$check_path" && "$selected" != */ && ! "$check_path" =~ ^[0-9]+$ ]]; then
        selected="$selected/"
    fi

    if [[ -n "$prefix" ]]; then
        READLINE_LINE="${prefix} ${selected}${after_cursor}"
        READLINE_POINT=$((${#prefix} + 1 + ${#selected}))
    else
        READLINE_LINE="${selected}${after_cursor}"
        READLINE_POINT=${#selected}
    fi
}
