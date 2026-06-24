#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

############################################################################
if ! command -v fzf &>/dev/null; then
    return
fi

# _fzf_bash() {
#     file=~/.fzf.bash
#     if ! test -f "$file" && command -v fzf &>/dev/null; then
#         fzf --bash | tee "$file" &>/dev/null
#     fi
#     # shellcheck source=/dev/null
#     test -f "$file" && source "$file"
#     return 0
# }

# Ctrl+A: Complete anything with fzf (FZF dominates, uses native completions as data source)
_fzf_complete_all_dbg() {
    echo "[$(date +%H:%M:%S.%3N)] $*" | tee -a /tmp/fzf_complete_debug.log &>/dev/null
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

    # Determine if this is a "file operation" command where substring search makes sense.
    local is_file_cmd=false
    local is_path_substring=false

    if [[ "$clean_word" != -* ]]; then
        if [[ "$prefix" != *"|"* ]]; then
            case "$clean_cmd" in
                ls|cat|rm|cp|mv|less|more|head|tail|file|stat|du|xdg-open|open|vim|nvim|vi|nano|emacs|code|gedit|evince|okular|zathura|mupdf|gimp|inkscape|eog|feh|mpv|vlc|totem|bat|exa|eza|fd|rg|tar|gzip|gunzip|zip|unzip|7z|rar|unrar|xz|bzip2|bunzip2|zst|unzst|pdfinfo|pdftotext|ffmpeg|ffprobe|imagemagick|convert|mogrify)
                    is_file_cmd=true

                    if [[ "$clean_word" == */* || "$clean_word" == ~* ]]; then
                        local expanded_full
                        expanded_full=$(eval echo "$clean_word" 2>/dev/null)

                        if [[ ! -e "$expanded_full" && ! -d "$expanded_full" ]]; then
                            local valid_dir="$expanded_full"
                            local search_term=""

                            while [[ -n "$valid_dir" && ! -d "$valid_dir" ]]; do
                                search_term="$(basename "$valid_dir")/$search_term"
                                valid_dir=$(dirname "$valid_dir")
                            done

                            search_term="${search_term%/}"

                            if [[ -d "$valid_dir" && -n "$search_term" ]]; then
                                is_path_substring=true
                            fi
                        fi
                    fi
                    ;;
            esac
        fi
    fi

    # Only load native completions for NON-file commands
    if ! $is_file_cmd || $is_path_substring; then
        if ! $is_path_substring; then
            if type _completion_loader &>/dev/null; then
                _completion_loader "$clean_cmd" 2>/dev/null
            elif type _comp_load &>/dev/null; then
                _comp_load "$clean_cmd" 2>/dev/null
            fi
        fi
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

    if ! $is_file_cmd && ! $want_dir_content && ! $is_path_substring; then
        local comp_spec
        comp_spec=$(complete -p "$clean_cmd" 2>/dev/null)

        if [[ -n "$comp_spec" ]]; then
            local comp_func
            comp_func=$(echo "$comp_spec" | sed -n 's/.*-F \([^ ]*\).*/\1/p')

            if [[ -n "$comp_func" ]] && type -t "$comp_func" >/dev/null 2>&1; then
                local prev_word="${COMP_WORDS[$((COMP_CWORD - 1))]:-}"
                "$comp_func" "$clean_cmd" "$last_word" "$prev_word" 2>/dev/null
                if [[ ${#COMPREPLY[@]} -gt 0 ]]; then
                    if [[ "$last_word" == ~* ]]; then
                        native_candidates=$(printf '%s\n' "${COMPREPLY[@]}" \
                            | sed "s|^$HOME/|~/|; s|^$HOME\$|~|")
                    else
                        native_candidates=$(printf '%s\n' "${COMPREPLY[@]}")
                    fi
                fi
            fi
        fi
    fi

    local candidates

    if [[ -n "$native_candidates" ]]; then
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
                elif $is_path_substring; then
                    local expanded_full
                    expanded_full=$(eval echo "$clean_word" 2>/dev/null)

                    local valid_dir="$expanded_full"
                    local search_term=""

                    while [[ -n "$valid_dir" && ! -d "$valid_dir" ]]; do
                        search_term="$(basename "$valid_dir")/$search_term"
                        valid_dir=$(dirname "$valid_dir")
                    done

                    search_term="${search_term%/}"

                    if [[ -d "$valid_dir" && -n "$search_term" ]]; then
                        local output_prefix
                        if [[ "$valid_dir" == "/" ]]; then
                            output_prefix="/"
                        elif [[ "$clean_word" == ~* ]]; then
                            output_prefix="$(echo "$valid_dir" | sed "s|^$HOME|~|")/"
                        else
                            output_prefix="$valid_dir/"
                        fi

                        local grep_pattern
                        grep_pattern=$(printf '%s' "$search_term" | sed 's/[.[\*^$()+?{|]/\\&/g')

                        ls -1A "$valid_dir" 2>/dev/null | grep -i "$grep_pattern" | while read -r item; do
                            echo "${output_prefix}${item}"
                        done
                    fi
                elif $is_file_cmd; then
                    local grep_pattern
                    grep_pattern=$(printf '%s' "$clean_word" | sed 's/[.[\*^$()+?{|]/\\&/g')
                    ls -1A 2>/dev/null | grep -i "$grep_pattern"
                elif [[ -n "$expanded_word" ]]; then
                    if [[ "$clean_word" == ~* ]]; then
                        compgen -f -- "$expanded_word" 2>/dev/null \
                            | sed "s|^$HOME/|~/|; s|^$HOME\$|~|"
                    else
                        compgen -f -- "$expanded_word" 2>/dev/null
                    fi
                fi

                if ! $is_file_cmd && [[ "$clean_word" != */* && "$clean_word" != ~* ]]; then
                    compgen -c -- "$clean_word" 2>/dev/null
                    compgen -b -- "$clean_word" 2>/dev/null
                    alias | cut -d' ' -f2 | cut -d'=' -f1 | grep "^$clean_word" 2>/dev/null
                    declare -F | cut -d' ' -f3 | grep "^$clean_word" 2>/dev/null
                    compgen -v -- "$clean_word" 2>/dev/null
                fi
            } | sort -u
        )
    fi

    [[ -z "$candidates" ]] && return 1

    local escaped_candidates
    escaped_candidates=$(printf '%s\n' "$candidates" | while read -r line; do
        [[ -z "$line" ]] && continue
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
    local fzf_extra_opts="--ignore-case"

    $want_dir_content && fzf_query=""

    if $is_path_substring; then
        fzf_query=$(basename "$clean_word")
    fi

    selected=$(printf '%s\n' "$escaped_candidates" |
        FZF_DEFAULT_OPTS="--height 40% --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-}" \
        fzf $fzf_extra_opts --query "$fzf_query" --select-1 --exit-0)

    [[ -z "$selected" ]] && return 0

    local check_path
    check_path=$(printf '%b' "$selected" 2>/dev/null)
    [[ "$check_path" == "~"* ]] && check_path="${HOME}${check_path:1}"

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

# Ctrl+A: Complete anything with fzf (FZF dominates, uses native completions as data source)
_fzf_complete_all_top() {
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

    # Determine if this is a "file operation" command where substring search makes sense.
    # Conditions for file command:
    # 1. Word doesn't start with - (not an option)
    # 2. There's no pipe in the prefix (if there's a pipe, we're completing commands)
    # 3. The command is a known file operation command
    # 4. Either: word has no path (substring in current dir)
    #    OR: word has path AND the full path is NOT a valid directory (substring in parent dir)
    local is_file_cmd=false
    local is_path_substring=false

    if [[ "$clean_word" != -* ]]; then
        if [[ "$prefix" != *"|"* ]]; then
            case "$clean_cmd" in
                ls|cat|rm|cp|mv|less|more|head|tail|file|stat|du|xdg-open|open|vim|nvim|vi|nano|emacs|code|gedit|evince|okular|zathura|mupdf|gimp|inkscape|eog|feh|mpv|vlc|totem|bat|exa|eza|fd|rg)
                    is_file_cmd=true

                    if [[ "$clean_word" == */* || "$clean_word" == ~* ]]; then
                        local expanded_full
                        expanded_full=$(eval echo "$clean_word" 2>/dev/null)

                        # Only activate path substring if the full path does NOT exist
                        if [[ ! -e "$expanded_full" && ! -d "$expanded_full" ]]; then
                            local valid_dir="$expanded_full"
                            local search_term=""

                            while [[ -n "$valid_dir" && ! -d "$valid_dir" ]]; do
                                search_term="$(basename "$valid_dir")/$search_term"
                                valid_dir=$(dirname "$valid_dir")
                            done

                            search_term="${search_term%/}"

                            if [[ -d "$valid_dir" && -n "$search_term" ]]; then
                                is_path_substring=true
                            fi
                        fi
                    fi
                    ;;
            esac
        fi
    fi

    # Only load native completions for NON-file commands
    if ! $is_file_cmd || $is_path_substring; then
        if ! $is_path_substring; then
            if type _completion_loader &>/dev/null; then
                _completion_loader "$clean_cmd" 2>/dev/null
            elif type _comp_load &>/dev/null; then
                _comp_load "$clean_cmd" 2>/dev/null
            fi
        fi
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

    if ! $is_file_cmd && ! $want_dir_content && ! $is_path_substring; then
        local comp_spec
        comp_spec=$(complete -p "$clean_cmd" 2>/dev/null)

        if [[ -n "$comp_spec" ]]; then
            local comp_func
            comp_func=$(echo "$comp_spec" | sed -n 's/.*-F \([^ ]*\).*/\1/p')

            if [[ -n "$comp_func" ]] && type -t "$comp_func" >/dev/null 2>&1; then
                local prev_word="${COMP_WORDS[$((COMP_CWORD - 1))]:-}"
                "$comp_func" "$clean_cmd" "$last_word" "$prev_word" 2>/dev/null
                if [[ ${#COMPREPLY[@]} -gt 0 ]]; then
                    # Convert HOME paths to ~ ONLY if the original query starts with ~
                    if [[ "$last_word" == ~* ]]; then
                        native_candidates=$(printf '%s\n' "${COMPREPLY[@]}" \
                            | sed "s|^$HOME/|~/|; s|^$HOME\$|~|")
                    else
                        native_candidates=$(printf '%s\n' "${COMPREPLY[@]}")
                    fi
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
                elif $is_path_substring; then
                    local expanded_full
                    expanded_full=$(eval echo "$clean_word" 2>/dev/null)

                    local valid_dir="$expanded_full"
                    local search_term=""

                    while [[ -n "$valid_dir" && ! -d "$valid_dir" ]]; do
                        search_term="$(basename "$valid_dir")/$search_term"
                        valid_dir=$(dirname "$valid_dir")
                    done

                    search_term="${search_term%/}"

                    if [[ -d "$valid_dir" && -n "$search_term" ]]; then
                        local output_prefix
                        if [[ "$valid_dir" == "/" ]]; then
                            output_prefix="/"
                        elif [[ "$clean_word" == ~* ]]; then
                            output_prefix="$(echo "$valid_dir" | sed "s|^$HOME|~|")/"
                        else
                            output_prefix="$valid_dir/"
                        fi

                        local grep_pattern
                        grep_pattern=$(printf '%s' "$search_term" | sed 's/[.[\*^$()+?{|]/\\&/g')

                        ls -1A "$valid_dir" 2>/dev/null | grep -i "$grep_pattern" | while read -r item; do
                            echo "${output_prefix}${item}"
                        done
                    fi
                elif $is_file_cmd; then
                    # For file commands with plain word (no path), use substring search in current dir
                    local grep_pattern
                    grep_pattern=$(printf '%s' "$clean_word" | sed 's/[.[\*^$()+?{|]/\\&/g')
                    ls -1A 2>/dev/null | grep -i "$grep_pattern"
                elif [[ -n "$expanded_word" ]]; then
                    # Use expanded_word so that tilde paths like ~/Doc are resolved
                    # correctly by compgen, then restore ~ in results to preserve
                    # what the user typed.
                    if [[ "$clean_word" == ~* ]]; then
                        compgen -f -- "$expanded_word" 2>/dev/null \
                            | sed "s|^$HOME/|~/|; s|^$HOME\$|~|"
                    else
                        compgen -f -- "$expanded_word" 2>/dev/null
                    fi
                fi

                # Only add commands/variables for non-file commands
                if ! $is_file_cmd && [[ "$clean_word" != */* && "$clean_word" != ~* ]]; then
                    compgen -c -- "$clean_word" 2>/dev/null
                    compgen -b -- "$clean_word" 2>/dev/null
                    alias | cut -d' ' -f2 | cut -d'=' -f1 | grep "^$clean_word" 2>/dev/null
                    declare -F | cut -d' ' -f3 | grep "^$clean_word" 2>/dev/null
                    compgen -v -- "$clean_word" 2>/dev/null
                fi
            } | sort -u
        )
    fi

    [[ -z "$candidates" ]] && return 1

    local escaped_candidates
    escaped_candidates=$(printf '%s\n' "$candidates" | while read -r line; do
        [[ -z "$line" ]] && continue
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
    local fzf_extra_opts="--ignore-case"  # always on for files and directories

    $want_dir_content && fzf_query=""

    # For path substring search, use just the basename as query
    if $is_path_substring; then
        fzf_query=$(basename "$clean_word")
    fi

    selected=$(printf '%s\n' "$escaped_candidates" |
        FZF_DEFAULT_OPTS="--height 40% --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-}" \
        fzf $fzf_extra_opts --query "$fzf_query" --select-1 --exit-0)

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

# Ctrl+A: Complete anything with fzf (FZF dominates, uses native completions as data source)
_fzf_complete_all_substring_local() {
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

    # Determine if this is a "file operation" command where substring search makes sense.
    # Conditions for file command:
    # 1. Word has no path separators and no tilde
    # 2. Word doesn't start with - (not an option)
    # 3. There's no pipe in the prefix (if there's a pipe, we're completing commands for the next pipe stage)
    # 4. The command is a known file operation command
    local is_file_cmd=false
    if [[ "$clean_word" != */* && "$clean_word" != ~* && "$clean_word" != -* ]]; then
        # Check if prefix contains a pipe — if so, we're not in a file cmd context
        if [[ "$prefix" != *"|"* ]]; then
            case "$clean_cmd" in
                ls|cat|rm|cp|mv|less|more|head|tail|file|stat|du|xdg-open|open|vim|nvim|vi|nano|emacs|code|gedit|evince|okular|zathura|mupdf|gimp|inkscape|eog|feh|mpv|vlc|totem|bat|exa|eza|fd|rg)
                    is_file_cmd=true
                    ;;
            esac
        fi
    fi

    # Only load native completions for NON-file commands
    if ! $is_file_cmd; then
        if type _completion_loader &>/dev/null; then
            _completion_loader "$clean_cmd" 2>/dev/null
        elif type _comp_load &>/dev/null; then
            _comp_load "$clean_cmd" 2>/dev/null
        fi
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

    # Only use native completions for NON-file commands
    if ! $is_file_cmd && ! $want_dir_content; then
        local comp_spec
        comp_spec=$(complete -p "$clean_cmd" 2>/dev/null)

        if [[ -n "$comp_spec" ]]; then
            local comp_func
            comp_func=$(echo "$comp_spec" | sed -n 's/.*-F \([^ ]*\).*/\1/p')

            if [[ -n "$comp_func" ]] && type -t "$comp_func" >/dev/null 2>&1; then
                local prev_word="${COMP_WORDS[$((COMP_CWORD - 1))]:-}"
                "$comp_func" "$clean_cmd" "$last_word" "$prev_word" 2>/dev/null
                if [[ ${#COMPREPLY[@]} -gt 0 ]]; then
                    # Native completion functions receive the raw word (e.g. ~/Doc) but
                    # may return expanded paths (e.g. /home/user/Documents). Restore ~
                    # so the fzf query (which still has ~) matches the candidates.
                    native_candidates=$(printf '%s\n' "${COMPREPLY[@]}" \
                        | sed "s|^$HOME/|~/|; s|^$HOME\$|~|")
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
                elif $is_file_cmd; then
                    # For file commands with plain word, use substring search
                    local grep_pattern
                    grep_pattern=$(printf '%s' "$clean_word" | sed 's/[.[\*^$()+?{|]/\\&/g')
                    ls -1A 2>/dev/null | grep -i "$grep_pattern"
                elif [[ -n "$expanded_word" ]]; then
                    # Use expanded_word so that tilde paths like ~/Doc are resolved
                    # correctly by compgen, then restore ~ in results to preserve
                    # what the user typed.
                    compgen -f -- "$expanded_word" 2>/dev/null \
                        | sed "s|^$HOME/|~/|; s|^$HOME\$|~|"
                fi

                # Only add commands/variables for non-file commands
                if ! $is_file_cmd && [[ "$clean_word" != */* && "$clean_word" != ~* ]]; then
                    compgen -c -- "$clean_word" 2>/dev/null
                    compgen -b -- "$clean_word" 2>/dev/null
                    alias | cut -d' ' -f2 | cut -d'=' -f1 | grep "^$clean_word" 2>/dev/null
                    declare -F | cut -d' ' -f3 | grep "^$clean_word" 2>/dev/null
                    compgen -v -- "$clean_word" 2>/dev/null
                fi
            } | sort -u
        )
    fi

    [[ -z "$candidates" ]] && return 1

    local escaped_candidates
    escaped_candidates=$(printf '%s\n' "$candidates" | while read -r line; do
        [[ -z "$line" ]] && continue
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

    # Determine which fzf flags and query to use based on what the candidates contain.
    #
    # Case-insensitive matching (--ignore-case) — applies to BOTH files and
    # directories, so "rm doc" can match "Documents/".
    #
    # Substring search for FILES only is already done above by rebuilding the
    # candidates list with ls -1A | grep -i before passing to fzf.

    local fzf_query="$last_word"
    local fzf_extra_opts="--ignore-case"  # always on for files and directories

    $want_dir_content && fzf_query=""

    selected=$(printf '%s\n' "$escaped_candidates" |
        FZF_DEFAULT_OPTS="--height 40% --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-}" \
        fzf $fzf_extra_opts --query "$fzf_query" --select-1 --exit-0)

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


# Ctrl+A: Complete anything with fzf (FZF dominates, uses native completions as data source)
_fzf_complete_all_default() {
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
                    # Native completion functions receive the raw word (e.g. ~/Doc) but
                    # may return expanded paths (e.g. /home/user/Documents). Restore ~
                    # so the fzf query (which still has ~) matches the candidates.
                    native_candidates=$(printf '%s\n' "${COMPREPLY[@]}" \
                        | sed "s|^$HOME/|~/|; s|^$HOME\$|~|")
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
                    # Use expanded_word so that tilde paths like ~/Doc are resolved
                    # correctly by compgen, then restore ~ in results to preserve
                    # what the user typed.
                    compgen -f -- "$expanded_word" 2>/dev/null \
                        | sed "s|^$HOME/|~/|; s|^$HOME\$|~|"
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