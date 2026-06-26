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

    # ---- Parse the current word and prefix ----
    # Walk through the line up to cursor, splitting on unescaped spaces.
    # Inside double or single quotes, spaces are literal and don't split words.
    # Backslash escapes are preserved for shell evaluation.
    # last_word = the token under the cursor
    # prefix = everything before it (command + previous arguments)
    local last_word=""
    local prefix=""
    local i=0
    local len=${#cur}
    local current_word=""
    local prev_char=""
    local in_quote=""  # Track which quote we're inside: '"', "'", or empty

    while ((i < len)); do
        local char="${cur:$i:1}"

        # Keep backslash-escaped sequences intact (e.g., "\ " stays as "\ ")
        if [[ "$prev_char" == '\' ]]; then
            current_word+="\\$char"
            prev_char="$char"
            ((i++))
            continue
        fi

        # Toggle quote state when we see an unescaped quote.
        # Inside quotes, spaces are literal characters, not word separators.
        if [[ "$char" == '"' || "$char" == "'" ]]; then
            if [[ -z "$in_quote" ]]; then
                in_quote="$char"        # Opening quote
                current_word+="$char"
            elif [[ "$char" == "$in_quote" ]]; then
                in_quote=""             # Closing matching quote
                current_word+="$char"
            else
                current_word+="$char"   # Different quote inside another quote
            fi
            prev_char="$char"
            ((i++))
            continue
        fi

        # Space handling: split only if NOT inside quotes
        if [[ "$char" == ' ' && -z "$in_quote" ]]; then
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

    # ---- Handle empty word under cursor ----
    # If the word is empty but there's a command before the cursor
    # (e.g., "ls " + TAB), list the current directory contents.
    # If completely empty (no command), return silently to avoid errors.
    local list_current_dir=false
    if [[ -z "$last_word" ]]; then
        if [[ -n "$prefix" ]]; then
            list_current_dir=true
        else
            return 0
        fi
    fi

    # ---- Detect quote mode ----
    # If the word starts with a single or double quote, the user is manually
    # quoting the argument. We strip the opening quote for filesystem matching
    # and skip character escaping in the final result (quotes handle that).
    # The closing quote is the user's responsibility.
    local quote_char=""
    if [[ -n "$last_word" ]]; then
        if [[ "$last_word" == '"'* ]]; then
            quote_char='"'
        elif [[ "$last_word" == "'"* ]]; then
            quote_char="'"
        fi
    fi

    # Work with the unquoted version for filesystem operations
    local search_word="$last_word"
    if [[ -n "$quote_char" ]]; then
        search_word="${last_word#$quote_char}"
    fi

    # Extract the command (first word of the line)
    local cmd="${cur%% *}"
    local clean_cmd
    clean_cmd=$(printf '%b' "$cmd" 2>/dev/null)

    # ====================================================================
    # VAR MODE — handles $VAR, ${VAR}, $(subshell), $VAR/path, $VAR1:$VAR2
    # Skip if quoted (variables inside quotes are literal) or if listing
    # the current directory (no word to complete).
    # ====================================================================
    if ! $list_current_dir && [[ -z "$quote_char" && "$last_word" == *'$'* ]]; then
        # Everything after the last dollar sign determines the mode
        local after_last_dollar="${last_word##*\$}"

        # -- Brace mode: ${VAR} or ${VAR with open brace --
        if [[ "$after_last_dollar" == '{'* ]]; then
            local brace_content="${after_last_dollar#\{}"

            # ${VAR} — brace is closed with }, expand to the variable's value
            # Example: cat ${HISTFILE} → expands to /home/user/.bash_history
            if [[ "$brace_content" == *'}'* ]]; then
                local var_name="${brace_content%%\}*}"
                var_name="${var_name%%[^a-zA-Z0-9_]*}"
                local after_brace="${brace_content#*\}}"

                if [[ -n "$var_name" ]]; then
                    local var_value
                    var_value=$(eval echo "\${$var_name}" 2>/dev/null)

                    if [[ -n "$var_value" ]]; then
                        local before_dollar="${last_word%\$\{*}"
                        local new_last="${before_dollar}${var_value}${after_brace}"

                        if [[ -n "$prefix" ]]; then
                            READLINE_LINE="${prefix} ${new_last}${after_cursor}"
                            READLINE_POINT=$((${#prefix} + 1 + ${#new_last}))
                        else
                            READLINE_LINE="${new_last}${after_cursor}"
                            READLINE_POINT=${#new_last}
                        fi
                        return 0
                    fi
                fi
                return 1
            else
                # ${VAR — brace is open, complete variable names inside braces
                # Example: cat ${HIST → shows ${HISTFILE}, ${HISTFILESIZE}, etc.
                local var_prefix="$brace_content"
                local var_candidates
                var_candidates=$(compgen -v -- "$var_prefix" | sed 's/^/\${/; s/$/}/')

                [[ -z "$var_candidates" ]] && return 1

                local before_dollar="${last_word%\$\{*}"

                selected=$(printf '%s\n' "$var_candidates" |
                    FZF_DEFAULT_OPTS="--height 40% --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-}" \
                    fzf --query "\${$var_prefix" --select-1 --exit-0)

                [[ -z "$selected" ]] && return 0

                local new_last="${before_dollar}${selected}"
                if [[ -n "$prefix" ]]; then
                    READLINE_LINE="${prefix} ${new_last}${after_cursor}"
                    READLINE_POINT=$((${#prefix} + 1 + ${#new_last}))
                else
                    READLINE_LINE="${new_last}${after_cursor}"
                    READLINE_POINT=${#new_last}
                fi
                return 0
            fi
        fi

        # -- Subshell mode: $( — complete the command inside $( --
        # Example: echo $(dat → completes to date
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

        # -- $VAR/path — variable followed by a path segment: expand and complete --
        # Example: ls $HOME/Doc → expands $HOME and completes Documents, Downloads
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

        # -- Plain $VAR — complete variable names --
        # Example: echo $USER:$HO → completes $HOME (only the last $VAR after colon)
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

    # ====================================================================
    # ASSIGNMENT MODE — VAR=value: complete the value after =
    # Skip if quoted (assignments inside quotes are literal) or if listing
    # the current directory.
    # Example: EDITOR=vi → completes to vim, nvim, etc.
    # ====================================================================
    if ! $list_current_dir && [[ -z "$quote_char" && "$last_word" == *'='* && "$last_word" != -* ]]; then
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

    # ====================================================================
    # PATH / NATIVE COMPLETION MODE
    # Handles: file paths, directories, commands, native completions (git, ssh, etc.)
    # This is the main completion logic for most cases.
    # ====================================================================

    # Remove all backslashes to get the clean filesystem path.
    # Escaped characters like "\(" become "(" so we can match real filenames.
    local clean_word="${search_word//\\/}"

    # Build an eval-safe version of the word:
    # - In quote mode, use printf '%q' to escape all special chars for eval.
    # - In unquoted mode, just escape "!" to prevent bash history expansion.
    # This is needed because eval uses spaces as argument separators.
    local eval_safe_word
    if [[ -n "$quote_char" ]]; then
        eval_safe_word=$(printf '%q' "$clean_word")
    else
        eval_safe_word="${clean_word//!/\\!}"
    fi

    # Try to expand tilde (~) and variables via eval.
    # If that fails or produces nothing useful, fall back to compgen -f.
    # expanded_word_for_test is used ONLY to check if the path exists.
    local expanded_word_for_test=""
    if [[ -n "$clean_word" ]]; then
        expanded_word_for_test=$(eval echo "$eval_safe_word" 2>/dev/null)

        if [[ -z "$expanded_word_for_test" || "$expanded_word_for_test" == "$eval_safe_word" || ! -e "$expanded_word_for_test" ]]; then
            local compgen_result
            compgen_result=$(compgen -f -- "$clean_word" 2>/dev/null | head -1)
            if [[ -n "$compgen_result" ]]; then
                expanded_word_for_test="$compgen_result"
            elif [[ -z "$expanded_word_for_test" ]]; then
                expanded_word_for_test="$clean_word"
            fi
        fi
    fi

    # If the word ends with "/", we want to list the directory's contents.
    local want_dir_content=false
    [[ "$clean_word" == */ ]] && want_dir_content=true

    # For cd and rmdir, only complete directories (not files).
    local dirs_only=false
    case "$clean_cmd" in
        cd|rmdir) dirs_only=true ;;
    esac

    if [[ -z "$expanded_word_for_test" && -z "$clean_cmd" && ! $list_current_dir ]]; then
        return 1
    fi

    # ---- Classification flags ----
    # is_file_cmd: the command is a known file operation (ls, cat, vim, etc.).
    #   These use substring search instead of native bash completions.
    # is_path_substring: the path has an invalid final component, so we do
    #   substring search in the last valid directory (e.g., ~/Documents/pdf).
    # is_tilde_user: the word is "~" followed by a username prefix (e.g., ~ro).
    #   This completes system usernames instead of files.
    # is_arg_completion: the word starts with - or -- (command arguments).
    local is_file_cmd=false
    local is_path_substring=false
    local valid_dir=""
    local search_term=""
    local is_tilde_user=false
    local is_arg_completion=false
    [[ "$clean_word" == -* ]] && is_arg_completion=true

    if $list_current_dir; then
        # Empty word after a command: list current directory contents.
        is_file_cmd=true
        want_dir_content=true
        clean_word=""
    elif $is_arg_completion; then
        # Argument completion: use native completions, not file completion
        is_file_cmd=false
    else
        # Detect ~user without path (e.g., ~ro, ~rf) — complete the username
        if [[ "$clean_word" == ~* && "$clean_word" != */* ]]; then
            is_tilde_user=true
            is_file_cmd=true
        fi

        # Detect if this is a file operation command.
        # Skip if the prefix contains a pipe "|" (completing commands for next stage).
        if [[ "$clean_word" != -* && "$is_tilde_user" == false ]]; then
            if [[ "$prefix" != *"|"* ]]; then
                case "$clean_cmd" in
                    # Commands that operate on files — substring search makes sense here.
                    # This includes viewers, editors, archivers, media players, etc.
                    ls|cat|rm|cp|mv|less|more|head|tail|file|stat|du|xdg-open|open|vim|nvim|vi|nano|emacs|code|gedit|evince|okular|zathura|mupdf|gimp|inkscape|eog|feh|mpv|vlc|totem|bat|exa|eza|fd|rg|tar|gzip|gunzip|zip|unzip|7z|rar|unrar|xz|bzip2|bunzip2|zst|unzst|pdfinfo|pdftotext|ffmpeg|ffprobe|imagemagick|convert|mogrify|cd|rmdir)
                        is_file_cmd=true

                        # Check if the word contains path separators or tilde
                        if [[ "$clean_word" == */* || "$clean_word" == ~* ]]; then
                            # If the expanded path already exists (file or directory),
                            # use normal prefix completion via ls + grep.
                            if [[ -e "$expanded_word_for_test" || -d "$expanded_word_for_test" ]]; then
                                is_path_substring=false
                            else
                                # The full path doesn't exist. Walk up the directory tree
                                # until we find a valid directory, then use the remaining
                                # part as a substring search term.
                                # Example: ~/Documents/pdf → valid_dir=~/Documents, search_term=pdf
                                # Example: ~/Projects/Godot4/Scripts/gd → valid_dir=.../Scripts, search_term=gd
                                local expanded_full
                                expanded_full=$(eval echo "$eval_safe_word" 2>/dev/null)
                                [[ -z "$expanded_full" ]] && expanded_full="$clean_word"

                                valid_dir="$expanded_full"
                                search_term=""

                                # Walk up until we find a directory that actually exists
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
    fi

    # Save the original completion spec BEFORE loading anything.
    # _completion_loader may overwrite specific completions with generic ones.
    local orig_comp_spec
    orig_comp_spec=$(complete -p "$clean_cmd" 2>/dev/null)

    # Load native bash completions for commands that are NOT file operations
    # (git, systemctl, pacman, ssh, kill, etc.). File commands skip this to use
    # our custom substring/path completion logic.
    if ! $is_file_cmd || $is_path_substring || $is_tilde_user; then
        if ! $is_path_substring && ! $is_tilde_user; then
            if type _completion_loader &>/dev/null; then
                _completion_loader "$clean_cmd" 2>/dev/null
            elif type _comp_load &>/dev/null; then
                _comp_load "$clean_cmd" 2>/dev/null
            fi
        fi
    fi

    # Set up COMP_* variables so native completion functions can read them.
    # We build COMP_WORDS from the parsed prefix + last_word to avoid issues
    # with special characters (trailing \, unmatched parens, etc.) in READLINE_LINE.
    COMP_LINE="$READLINE_LINE"
    COMP_POINT=$READLINE_POINT
    IFS=' ' read -ra COMP_WORDS <<< "${prefix} ${last_word}"
    COMP_CWORD=$((${#COMP_WORDS[@]} - 1))
    [[ "$READLINE_LINE" =~ [[:space:]]$ ]] && (( COMP_CWORD++ ))
    if [[ "${COMP_WORDS[$COMP_CWORD]:-}" != "$last_word" ]]; then
        COMP_WORDS[$COMP_CWORD]="$last_word"
    fi
    COMPREPLY=()

    local native_candidates=""

    # Run native completion function for non-file commands AND argument completion.
    # Convert $HOME paths back to ~ ONLY if the original query used ~.
    # Trailing spaces are trimmed (some completions add them like "stash ").
    if (! $is_file_cmd && ! $want_dir_content && ! $is_path_substring && ! $is_tilde_user) || $is_arg_completion; then
        local comp_spec
        comp_spec=$(complete -p "$clean_cmd" 2>/dev/null)

        # If the loader replaced the original spec with _comp_complete_minimal,
        # restore the original (which may be _comp_complete_longopt, _pacman, etc.)
        if [[ "$comp_spec" == *"_comp_complete_minimal"* && -n "$orig_comp_spec" && "$orig_comp_spec" != "$comp_spec" ]]; then
            comp_spec="$orig_comp_spec"
        fi

        if [[ -n "$comp_spec" ]]; then
            local comp_func
            comp_func=$(echo "$comp_spec" | sed -n 's/.*-F \([^ ]*\).*/\1/p')

            # If the registered function is the generic _comp_complete_minimal,
            # try _comp_complete_longopt for better argument completion.
            if [[ "$comp_func" == "_comp_complete_minimal" ]] && type -t _comp_complete_longopt >/dev/null 2>&1; then
                comp_func="_comp_complete_longopt"
            fi

            if [[ -n "$comp_func" ]] && type -t "$comp_func" >/dev/null 2>&1; then
                local prev_word="${COMP_WORDS[$((COMP_CWORD - 1))]:-}"
                "$comp_func" "$clean_cmd" "$last_word" "$prev_word" 2>/dev/null

                # For _comp_complete_longopt, supplement with all options from --help.
                # Uses the robust extraction from helpargs v3:
                # - Strips ANSI escapes and OSC8 hyperlinks before processing
                # - awk for short options (-X), grep -oP for long options (--long)
                # - Combines everything into a deduplicated array to avoid losses
                if $is_arg_completion && [[ "$comp_func" == "_comp_complete_longopt" ]]; then
                    local help_raw; help_raw=$("$clean_cmd" --help 2>/dev/null)
                    if [[ -n "$help_raw" ]]; then
                        # Strip ANSI escapes (colors/bold: ESC[...m) and OSC8 hyperlinks
                        local help_clean
                        help_clean=$(echo "$help_raw" \
                            | sed 's/\x1b\[[0-9;]*m//g' \
                            | sed 's/\x1b]8;;[^\x1b]*\x1b\\//g')

                        # Extract short options (-X) using awk (helpargs v3 logic)
                        local short_opts
                        short_opts=$(awk '{
                            line = $0
                            while (match(line, /[^-]-[a-zA-Z0-9]([[:space:],=]|$)/)) {
                                pos   = RSTART + RLENGTH
                                chunk = substr(line, RSTART, RLENGTH)
                                match(chunk, /-[a-zA-Z0-9]/)
                                print substr(chunk, RSTART, RLENGTH)
                                line  = substr(line, pos)
                            }
                        }' <<< "$help_clean" | sort -u)

                        # Extract long options (--long) using grep -oP
                        local long_opts
                        long_opts=$(grep -oP '\-\-[a-zA-Z][a-zA-Z0-9-]*' <<< "$help_clean" | sort -u)

                        # Combine all options into a deduplicated array
                        local all_opts
                        all_opts=$(printf '%s\n' "${COMPREPLY[@]}" "$short_opts" "$long_opts" | sort -u | grep -v '^$')
                        COMPREPLY=()
                        while IFS= read -r opt; do
                            [[ -n "$opt" ]] && COMPREPLY+=("$opt")
                        done <<< "$all_opts"
                    fi
                fi

                if [[ ${#COMPREPLY[@]} -gt 0 ]]; then
                    if [[ "$last_word" == ~* ]]; then
                        native_candidates=$(printf '%s\n' "${COMPREPLY[@]}" \
                            | sed 's/ *$//' \
                            | sed "s|^$HOME/|~/|; s|^$HOME\$|~|")
                    else
                        native_candidates=$(printf '%s\n' "${COMPREPLY[@]}" | sed 's/ *$//')
                    fi
                fi
            fi
        fi
    fi

    local candidates

    # ---- Build the candidate list ----
    if [[ -n "$native_candidates" ]]; then
        # Filter out the current word if it's the only match.
        local filtered
        filtered=$(printf '%s\n' "$native_candidates" | grep -v "^${last_word}$")
        [[ -z "$filtered" ]] && return 1
        candidates="$native_candidates"
    else
        # set +H disables bash history expansion (!) inside the subshell.
        # This is critical for completing filenames with "!" in them.
        candidates=$(set +H; {
            if $is_tilde_user; then
                # ~user completion: list matching system users with ~ prefix.
                # Remove ~ from clean_word, query compgen -u, strip any ~ it may add,
                # then re-add exactly one ~ prefix.
                local user_prefix="${clean_word#\~}"
                local matching_users
                matching_users=$(compgen -u -- "$user_prefix" 2>/dev/null | sed 's/^~//' | sort -u)

                if [[ -n "$matching_users" ]]; then
                    while read -r user; do
                        [[ -z "$user" ]] && continue
                        echo "~${user}"
                    done <<< "$matching_users"
                fi
            elif $want_dir_content; then
                # Word ends with "/" (or we're listing current dir) — list directory contents.
                # For cd/rmdir, only include subdirectories.
                local dir_to_list="$clean_word"
                if [[ -z "$dir_to_list" ]]; then
                    dir_to_list="."  # Empty word: list current directory
                fi
                if [[ "$dir_to_list" == ~* ]]; then
                    dir_to_list=$(eval echo "$eval_safe_word" 2>/dev/null)
                fi

                if [[ -d "$dir_to_list" ]]; then
                    ls -1A "$dir_to_list" 2>/dev/null | while read -r item; do
                        local full_path
                        if [[ -n "$clean_word" ]]; then
                            full_path="${clean_word}${item}"
                        else
                            full_path="${item}"
                        fi
                        # For cd/rmdir, only include directories
                        if $dirs_only; then
                            local item_path="${dir_to_list}/${item}"
                            [[ -d "$item_path" ]] && echo "$full_path"
                        else
                            echo "$full_path"
                        fi
                    done
                fi
            elif $is_path_substring; then
                # Substring search inside a valid parent directory.
                # Uses ls + grep -F (fixed string, not regex) to avoid issues
                # with special characters like (, ), !, etc.
                # --ignore-case is handled by grep -i.
                if [[ -d "$valid_dir" && -n "$search_term" ]]; then
                    local output_prefix
                    # Preserve the original path notation (absolute, relative, or tilde)
                    if [[ "$valid_dir" == "/" ]]; then
                        output_prefix="/"
                    elif [[ "$clean_word" == ~* ]]; then
                        output_prefix="$(echo "$valid_dir" | sed "s|^$HOME|~|")/"
                    else
                        output_prefix="$valid_dir/"
                    fi

                    ls -1A "$valid_dir" 2>/dev/null | grep -iF -- "$search_term" | while read -r item; do
                        local full_path="${output_prefix}${item}"
                        # For cd/rmdir, only include directories
                        if $dirs_only; then
                            local item_path="${valid_dir}/${item}"
                            [[ -d "$item_path" ]] && echo "$full_path"
                        else
                            echo "$full_path"
                        fi
                    done
                fi
            elif [[ "$clean_word" == */* || "$clean_word" == ~* ]] && [[ -n "$expanded_word_for_test" ]]; then
                # Path exists (file or directory). Use ls + grep -F for reliable
                # prefix matching. This handles special characters better than
                # compgen -f, which can choke on !, (, etc.
                local prefix_for_ls
                prefix_for_ls=$(eval echo "$eval_safe_word" 2>/dev/null)
                [[ -z "$prefix_for_ls" ]] && prefix_for_ls="$clean_word"

                local path_dir
                local path_prefix
                path_dir=$(dirname "$prefix_for_ls")
                path_prefix=$(basename "$prefix_for_ls")

                if [[ -d "$path_dir" ]]; then
                    ls -1A "$path_dir" 2>/dev/null | grep -iF -- "$path_prefix" | while read -r item; do
                        local output_dir
                        if [[ "$clean_word" == ~* ]]; then
                            output_dir="$(echo "$path_dir" | sed "s|^$HOME|~|")"
                        else
                            output_dir="$path_dir"
                        fi

                        local full_path
                        if [[ "$output_dir" == "/" ]]; then
                            full_path="/${item}"
                        else
                            full_path="${output_dir}/${item}"
                        fi

                        # For cd/rmdir, only include directories
                        if $dirs_only; then
                            local item_path="${path_dir}/${item}"
                            [[ -d "$item_path" ]] && echo "$full_path"
                        else
                            echo "$full_path"
                        fi
                    done
                fi
            elif $is_file_cmd; then
                # Plain word (no path separators) with a file command.
                # Substring search in the current directory: match the term
                # anywhere in the filename, not just at the beginning.
                # Example: ls pdf → finds meuarquivo.pdf, pdfs_para_organizar, etc.
                if $dirs_only; then
                    # For cd/rmdir, only show directories
                    ls -1A 2>/dev/null | grep -iF -- "$clean_word" | while read -r item; do
                        [[ -d "$item" ]] && echo "$item"
                    done
                else
                    ls -1A 2>/dev/null | grep -iF -- "$clean_word"
                fi
            elif [[ -n "$expanded_word_for_test" ]]; then
                # Fallback: use compgen -f for normal prefix completion.
                # Convert HOME to ~ only if the user typed ~.
                if [[ "$clean_word" == ~* ]]; then
                    compgen -f -- "$expanded_word_for_test" 2>/dev/null \
                        | sed "s|^$HOME/|~/|; s|^$HOME\$|~|"
                else
                    compgen -f -- "$expanded_word_for_test" 2>/dev/null
                fi
            elif $list_current_dir; then
                # List current directory when word is empty (e.g., "ls " + TAB)
                if $dirs_only; then
                    ls -1A 2>/dev/null | while read -r item; do
                        [[ -d "$item" ]] && echo "$item"
                    done
                else
                    ls -1A 2>/dev/null
                fi
            fi

            # For non-file commands with plain words (no path), also include
            # commands, builtins, aliases, functions, and variables.
            # Example: typing "ex" should show exit, export, exec, etc.
            if ! $is_file_cmd && [[ "$clean_word" != */* && "$clean_word" != ~* ]]; then
                compgen -c -- "$clean_word" 2>/dev/null
                compgen -b -- "$clean_word" 2>/dev/null
                alias | cut -d' ' -f2 | cut -d'=' -f1 | grep "^$clean_word" 2>/dev/null
                declare -F | cut -d' ' -f3 | grep "^$clean_word" 2>/dev/null
                compgen -v -- "$clean_word" 2>/dev/null
            fi
        } | sort -u)
    fi

    [[ -z "$candidates" ]] && return 1

    # ---- Escape/format candidates for fzf ----
    # Uses here-string to avoid printf/pipe issues that can lose candidates
    # or add trailing spaces.
    # If the user opened a quote, just prefix with the quote character.
    # Otherwise, escape shell metacharacters with backslash.
    # "!" is NOT escaped because history expansion is disabled with set +H.
    local escaped_candidates=""
    if [[ -n "$quote_char" ]]; then
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            escaped_candidates+="${quote_char}${line}"$'\n'
        done <<< "$candidates"
    else
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            local out=""
            local j char
            for ((j = 0; j < ${#line}; j++)); do
                char="${line:$j:1}"
                case "$char" in
                    ' '|'('|')'|'&'|';'|'<'|'>'|'|'|'"'|"'"|'#'|'['|']')
                        out+="\\$char"
                        ;;
                    *)
                        out+="$char"
                        ;;
                esac
            done
            escaped_candidates+="$out"$'\n'
        done <<< "$candidates"
    fi
    escaped_candidates="${escaped_candidates%$'\n'}"

    # ---- fzf query and options ----
    # clean_word is used instead of last_word because fzf doesn't need shell escapes.
    # --ignore-case is always on for case-insensitive matching of files and directories.
    local fzf_query="$clean_word"
    local fzf_extra_opts="--ignore-case"

    # For directory listing, use an empty query to show all contents.
    $want_dir_content && fzf_query=""

    # For path substring, use only the basename as the fzf query.
    if $is_path_substring; then
        fzf_query=$(basename "$clean_word")
    fi

    # --select-1 --exit-0: auto-select if only one match, exit silently if none.
    selected=$(printf '%s\n' "$escaped_candidates" |
        FZF_DEFAULT_OPTS="--height 40% --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-}" \
        fzf $fzf_extra_opts --query "$fzf_query" --select-1 --exit-0)

    [[ -z "$selected" ]] && return 0

    # ---- Post-selection processing ----
    # Convert escape sequences back to real characters for filesystem checks.
    local check_path
    local check_selected="$selected"
    if [[ -n "$quote_char" ]]; then
        check_selected="${selected#$quote_char}"
    fi
    check_path=$(printf '%b' "$check_selected" 2>/dev/null)
    [[ "$check_path" == "~"* ]] && check_path="${HOME}${check_path:1}"

    # Add trailing slash for directories (but not for bare numbers, which are likely PIDs).
    # Example: cd ~/Documents → becomes cd ~/Documents/ so next TAB lists contents.
    if [[ -d "$check_path" && "$check_selected" != */ && ! "$check_path" =~ ^[0-9]+$ ]]; then
        if [[ -n "$quote_char" ]]; then
            selected="${quote_char}${check_selected}/"
        else
            selected="${check_selected}/"
        fi
    fi

    # Reconstruct the full READLINE_LINE with the selected item,
    # preserving everything after the cursor.
    if [[ -n "$prefix" ]]; then
        READLINE_LINE="${prefix} ${selected}${after_cursor}"
        READLINE_POINT=$((${#prefix} + 1 + ${#selected}))
    else
        READLINE_LINE="${selected}${after_cursor}"
        READLINE_POINT=${#selected}
    fi
}







# Ctrl+A: Complete anything with fzf (FZF dominates, uses native completions as data source)
_fzf_complete_all__working() {
    local selected
    local cur="${READLINE_LINE:0:$READLINE_POINT}"
    local after_cursor="${READLINE_LINE:$READLINE_POINT}"

    # ---- Parse the current word and prefix ----
    # Walk through the line up to cursor, splitting on unescaped spaces.
    # Inside double or single quotes, spaces are literal and don't split words.
    # Backslash escapes are preserved for shell evaluation.
    # last_word = the token under the cursor
    # prefix = everything before it (command + previous arguments)
    local last_word=""
    local prefix=""
    local i=0
    local len=${#cur}
    local current_word=""
    local prev_char=""
    local in_quote=""  # Track which quote we're inside: '"', "'", or empty

    while ((i < len)); do
        local char="${cur:$i:1}"

        # Keep backslash-escaped sequences intact (e.g., "\ " stays as "\ ")
        if [[ "$prev_char" == '\' ]]; then
            current_word+="\\$char"
            prev_char="$char"
            ((i++))
            continue
        fi

        # Toggle quote state when we see an unescaped quote.
        # Inside quotes, spaces are literal characters, not word separators.
        if [[ "$char" == '"' || "$char" == "'" ]]; then
            if [[ -z "$in_quote" ]]; then
                in_quote="$char"        # Opening quote
                current_word+="$char"
            elif [[ "$char" == "$in_quote" ]]; then
                in_quote=""             # Closing matching quote
                current_word+="$char"
            else
                current_word+="$char"   # Different quote inside another quote
            fi
            prev_char="$char"
            ((i++))
            continue
        fi

        # Space handling: split only if NOT inside quotes
        if [[ "$char" == ' ' && -z "$in_quote" ]]; then
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

    # ---- Handle empty word under cursor ----
    # If the word is empty but there's a command before the cursor
    # (e.g., "ls " + TAB), list the current directory contents.
    # If completely empty (no command), return silently to avoid errors.
    local list_current_dir=false
    if [[ -z "$last_word" ]]; then
        if [[ -n "$prefix" ]]; then
            list_current_dir=true
        else
            return 0
        fi
    fi

    # ---- Detect quote mode ----
    # If the word starts with a single or double quote, the user is manually
    # quoting the argument. We strip the opening quote for filesystem matching
    # and skip character escaping in the final result (quotes handle that).
    # The closing quote is the user's responsibility.
    local quote_char=""
    if [[ -n "$last_word" ]]; then
        if [[ "$last_word" == '"'* ]]; then
            quote_char='"'
        elif [[ "$last_word" == "'"* ]]; then
            quote_char="'"
        fi
    fi

    # Work with the unquoted version for filesystem operations
    local search_word="$last_word"
    if [[ -n "$quote_char" ]]; then
        search_word="${last_word#$quote_char}"
    fi

    # Extract the command (first word of the line)
    local cmd="${cur%% *}"
    local clean_cmd
    clean_cmd=$(printf '%b' "$cmd" 2>/dev/null)

    # ====================================================================
    # VAR MODE — handles $VAR, ${VAR}, $(subshell), $VAR/path, $VAR1:$VAR2
    # Skip if quoted (variables inside quotes are literal) or if listing
    # the current directory (no word to complete).
    # ====================================================================
    if ! $list_current_dir && [[ -z "$quote_char" && "$last_word" == *'$'* ]]; then
        # Everything after the last dollar sign determines the mode
        local after_last_dollar="${last_word##*\$}"

        # -- Brace mode: ${VAR} or ${VAR with open brace --
        if [[ "$after_last_dollar" == '{'* ]]; then
            local brace_content="${after_last_dollar#\{}"

            # ${VAR} — brace is closed with }, expand to the variable's value
            # Example: cat ${HISTFILE} → expands to /home/user/.bash_history
            if [[ "$brace_content" == *'}'* ]]; then
                local var_name="${brace_content%%\}*}"
                var_name="${var_name%%[^a-zA-Z0-9_]*}"
                local after_brace="${brace_content#*\}}"

                if [[ -n "$var_name" ]]; then
                    local var_value
                    var_value=$(eval echo "\${$var_name}" 2>/dev/null)

                    if [[ -n "$var_value" ]]; then
                        local before_dollar="${last_word%\$\{*}"
                        local new_last="${before_dollar}${var_value}${after_brace}"

                        if [[ -n "$prefix" ]]; then
                            READLINE_LINE="${prefix} ${new_last}${after_cursor}"
                            READLINE_POINT=$((${#prefix} + 1 + ${#new_last}))
                        else
                            READLINE_LINE="${new_last}${after_cursor}"
                            READLINE_POINT=${#new_last}
                        fi
                        return 0
                    fi
                fi
                return 1
            else
                # ${VAR — brace is open, complete variable names inside braces
                # Example: cat ${HIST → shows ${HISTFILE}, ${HISTFILESIZE}, etc.
                local var_prefix="$brace_content"
                local var_candidates
                var_candidates=$(compgen -v -- "$var_prefix" | sed 's/^/\${/; s/$/}/')

                [[ -z "$var_candidates" ]] && return 1

                local before_dollar="${last_word%\$\{*}"

                selected=$(printf '%s\n' "$var_candidates" |
                    FZF_DEFAULT_OPTS="--height 40% --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-}" \
                    fzf --query "\${$var_prefix" --select-1 --exit-0)

                [[ -z "$selected" ]] && return 0

                local new_last="${before_dollar}${selected}"
                if [[ -n "$prefix" ]]; then
                    READLINE_LINE="${prefix} ${new_last}${after_cursor}"
                    READLINE_POINT=$((${#prefix} + 1 + ${#new_last}))
                else
                    READLINE_LINE="${new_last}${after_cursor}"
                    READLINE_POINT=${#new_last}
                fi
                return 0
            fi
        fi

        # -- Subshell mode: $( — complete the command inside $( --
        # Example: echo $(dat → completes to date
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

        # -- $VAR/path — variable followed by a path segment: expand and complete --
        # Example: ls $HOME/Doc → expands $HOME and completes Documents, Downloads
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

        # -- Plain $VAR — complete variable names --
        # Example: echo $USER:$HO → completes $HOME (only the last $VAR after colon)
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

    # ====================================================================
    # ASSIGNMENT MODE — VAR=value: complete the value after =
    # Skip if quoted (assignments inside quotes are literal) or if listing
    # the current directory.
    # Example: EDITOR=vi → completes to vim, nvim, etc.
    # ====================================================================
    if ! $list_current_dir && [[ -z "$quote_char" && "$last_word" == *'='* && "$last_word" != -* ]]; then
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

    # ====================================================================
    # PATH / NATIVE COMPLETION MODE
    # Handles: file paths, directories, commands, native completions (git, ssh, etc.)
    # This is the main completion logic for most cases.
    # ====================================================================

    # Remove all backslashes to get the clean filesystem path.
    # Escaped characters like "\(" become "(" so we can match real filenames.
    local clean_word="${search_word//\\/}"

    # Build an eval-safe version of the word:
    # - In quote mode, use printf '%q' to escape all special chars for eval.
    # - In unquoted mode, just escape "!" to prevent bash history expansion.
    # This is needed because eval uses spaces as argument separators.
    local eval_safe_word
    if [[ -n "$quote_char" ]]; then
        eval_safe_word=$(printf '%q' "$clean_word")
    else
        eval_safe_word="${clean_word//!/\\!}"
    fi

    # Try to expand tilde (~) and variables via eval.
    # If that fails or produces nothing useful, fall back to compgen -f.
    # expanded_word_for_test is used ONLY to check if the path exists.
    local expanded_word_for_test=""
    if [[ -n "$clean_word" ]]; then
        expanded_word_for_test=$(eval echo "$eval_safe_word" 2>/dev/null)

        if [[ -z "$expanded_word_for_test" || "$expanded_word_for_test" == "$eval_safe_word" || ! -e "$expanded_word_for_test" ]]; then
            local compgen_result
            compgen_result=$(compgen -f -- "$clean_word" 2>/dev/null | head -1)
            if [[ -n "$compgen_result" ]]; then
                expanded_word_for_test="$compgen_result"
            elif [[ -z "$expanded_word_for_test" ]]; then
                expanded_word_for_test="$clean_word"
            fi
        fi
    fi

    # If the word ends with "/", we want to list the directory's contents.
    local want_dir_content=false
    [[ "$clean_word" == */ ]] && want_dir_content=true

    # For cd and rmdir, only complete directories (not files).
    local dirs_only=false
    case "$clean_cmd" in
        cd|rmdir) dirs_only=true ;;
    esac

    if [[ -z "$expanded_word_for_test" && -z "$clean_cmd" && ! $list_current_dir ]]; then
        return 1
    fi

    # ---- Classification flags ----
    # is_file_cmd: the command is a known file operation (ls, cat, vim, etc.).
    #   These use substring search instead of native bash completions.
    # is_path_substring: the path has an invalid final component, so we do
    #   substring search in the last valid directory (e.g., ~/Documents/pdf).
    # is_tilde_user: the word is "~" followed by a username prefix (e.g., ~ro).
    #   This completes system usernames instead of files.
    local is_file_cmd=false
    local is_path_substring=false
    local valid_dir=""
    local search_term=""
    local is_tilde_user=false

    if $list_current_dir; then
        # Empty word after a command: list current directory contents.
        is_file_cmd=true
        want_dir_content=true
        clean_word=""
    else
        # Detect ~user without path (e.g., ~ro, ~rf) — complete the username
        if [[ "$clean_word" == ~* && "$clean_word" != */* ]]; then
            is_tilde_user=true
            is_file_cmd=true
        fi

        # Detect if this is a file operation command.
        # Skip if the prefix contains a pipe "|" (completing commands for next stage).
        if [[ "$clean_word" != -* && "$is_tilde_user" == false ]]; then
            if [[ "$prefix" != *"|"* ]]; then
                case "$clean_cmd" in
                    # Commands that operate on files — substring search makes sense here.
                    # This includes viewers, editors, archivers, media players, etc.
                    ls|cat|rm|cp|mv|less|more|head|tail|file|stat|du|xdg-open|open|vim|nvim|vi|nano|emacs|code|gedit|evince|okular|zathura|mupdf|gimp|inkscape|eog|feh|mpv|vlc|totem|bat|exa|eza|fd|rg|tar|gzip|gunzip|zip|unzip|7z|rar|unrar|xz|bzip2|bunzip2|zst|unzst|pdfinfo|pdftotext|ffmpeg|ffprobe|imagemagick|convert|mogrify|cd|rmdir)
                        is_file_cmd=true

                        # Check if the word contains path separators or tilde
                        if [[ "$clean_word" == */* || "$clean_word" == ~* ]]; then
                            # If the expanded path already exists (file or directory),
                            # use normal prefix completion via ls + grep.
                            if [[ -e "$expanded_word_for_test" || -d "$expanded_word_for_test" ]]; then
                                is_path_substring=false
                            else
                                # The full path doesn't exist. Walk up the directory tree
                                # until we find a valid directory, then use the remaining
                                # part as a substring search term.
                                # Example: ~/Documents/pdf → valid_dir=~/Documents, search_term=pdf
                                # Example: ~/Projects/Godot4/Scripts/gd → valid_dir=.../Scripts, search_term=gd
                                local expanded_full
                                expanded_full=$(eval echo "$eval_safe_word" 2>/dev/null)
                                [[ -z "$expanded_full" ]] && expanded_full="$clean_word"

                                valid_dir="$expanded_full"
                                search_term=""

                                # Walk up until we find a directory that actually exists
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
    fi

    # Load native bash completions for commands that are NOT file operations
    # (git, systemctl, pacman, ssh, kill, etc.). File commands skip this to use
    # our custom substring/path completion logic.
    if ! $is_file_cmd || $is_path_substring || $is_tilde_user; then
        if ! $is_path_substring && ! $is_tilde_user; then
            if type _completion_loader &>/dev/null; then
                _completion_loader "$clean_cmd" 2>/dev/null
            elif type _comp_load &>/dev/null; then
                _comp_load "$clean_cmd" 2>/dev/null
            fi
        fi
    fi

    # Set up COMP_* variables so native completion functions can read them.
    # We build COMP_WORDS from the parsed prefix + last_word to avoid issues
    # with special characters (trailing \, unmatched parens, etc.) in READLINE_LINE.
    COMP_LINE="$READLINE_LINE"
    COMP_POINT=$READLINE_POINT
    IFS=' ' read -ra COMP_WORDS <<< "${prefix} ${last_word}"
    COMP_CWORD=$((${#COMP_WORDS[@]} - 1))
    [[ "$READLINE_LINE" =~ [[:space:]]$ ]] && (( COMP_CWORD++ ))
    if [[ "${COMP_WORDS[$COMP_CWORD]:-}" != "$last_word" ]]; then
        COMP_WORDS[$COMP_CWORD]="$last_word"
    fi
    COMPREPLY=()

    local native_candidates=""

    # Run native completion function for non-file commands.
    # Convert $HOME paths back to ~ ONLY if the original query used ~.
    # This prevents ~ from appearing when the user typed an absolute path.
    if ! $is_file_cmd && ! $want_dir_content && ! $is_path_substring && ! $is_tilde_user; then
        local comp_spec
        comp_spec=$(complete -p "$clean_cmd" 2>/dev/null)

        if [[ -n "$comp_spec" ]]; then
            local comp_func
            comp_func=$(echo "$comp_spec" | sed -n 's/.*-F \([^ ]*\).*/\1/p')

            if [[ -n "$comp_func" ]] && type -t "$comp_func" >/dev/null 2>&1; then
                local prev_word="${COMP_WORDS[$((COMP_CWORD - 1))]:-}"
                "$comp_func" "$clean_cmd" "$last_word" "$prev_word" 2>/dev/null
                if [[ ${#COMPREPLY[@]} -gt 0 ]]; then
                    # Only convert HOME to ~ if the user originally typed ~
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

    # ---- Build the candidate list ----
    if [[ -n "$native_candidates" ]]; then
        # Filter out the current word if it's the only match.
        local filtered
        filtered=$(printf '%s\n' "$native_candidates" | grep -v "^${last_word}$")
        [[ -z "$filtered" ]] && return 1
        candidates="$native_candidates"
    else
        # set +H disables bash history expansion (!) inside the subshell.
        # This is critical for completing filenames with "!" in them.
        candidates=$(set +H; {
            if $is_tilde_user; then
                # ~user completion: list matching system users with ~ prefix.
                # Remove ~ from clean_word, query compgen -u, strip any ~ it may add,
                # then re-add exactly one ~ prefix.
                local user_prefix="${clean_word#\~}"
                local matching_users
                matching_users=$(compgen -u -- "$user_prefix" 2>/dev/null | sed 's/^~//' | sort -u)

                if [[ -n "$matching_users" ]]; then
                    while read -r user; do
                        [[ -z "$user" ]] && continue
                        echo "~${user}"
                    done <<< "$matching_users"
                fi
            elif $want_dir_content; then
                # Word ends with "/" (or we're listing current dir) — list directory contents.
                # For cd/rmdir, only include subdirectories.
                local dir_to_list="$clean_word"
                if [[ -z "$dir_to_list" ]]; then
                    dir_to_list="."  # Empty word: list current directory
                fi
                if [[ "$dir_to_list" == ~* ]]; then
                    dir_to_list=$(eval echo "$eval_safe_word" 2>/dev/null)
                fi

                if [[ -d "$dir_to_list" ]]; then
                    ls -1A "$dir_to_list" 2>/dev/null | while read -r item; do
                        local full_path
                        if [[ -n "$clean_word" ]]; then
                            full_path="${clean_word}${item}"
                        else
                            full_path="${item}"
                        fi
                        # For cd/rmdir, only include directories
                        if $dirs_only; then
                            local item_path="${dir_to_list}/${item}"
                            [[ -d "$item_path" ]] && echo "$full_path"
                        else
                            echo "$full_path"
                        fi
                    done
                fi
            elif $is_path_substring; then
                # Substring search inside a valid parent directory.
                # Uses ls + grep -F (fixed string, not regex) to avoid issues
                # with special characters like (, ), !, etc.
                # --ignore-case is handled by grep -i.
                if [[ -d "$valid_dir" && -n "$search_term" ]]; then
                    local output_prefix
                    # Preserve the original path notation (absolute, relative, or tilde)
                    if [[ "$valid_dir" == "/" ]]; then
                        output_prefix="/"
                    elif [[ "$clean_word" == ~* ]]; then
                        output_prefix="$(echo "$valid_dir" | sed "s|^$HOME|~|")/"
                    else
                        output_prefix="$valid_dir/"
                    fi

                    ls -1A "$valid_dir" 2>/dev/null | grep -iF -- "$search_term" | while read -r item; do
                        local full_path="${output_prefix}${item}"
                        # For cd/rmdir, only include directories
                        if $dirs_only; then
                            local item_path="${valid_dir}/${item}"
                            [[ -d "$item_path" ]] && echo "$full_path"
                        else
                            echo "$full_path"
                        fi
                    done
                fi
            elif [[ "$clean_word" == */* || "$clean_word" == ~* ]] && [[ -n "$expanded_word_for_test" ]]; then
                # Path exists (file or directory). Use ls + grep -F for reliable
                # prefix matching. This handles special characters better than
                # compgen -f, which can choke on !, (, etc.
                local prefix_for_ls
                prefix_for_ls=$(eval echo "$eval_safe_word" 2>/dev/null)
                [[ -z "$prefix_for_ls" ]] && prefix_for_ls="$clean_word"

                local path_dir
                local path_prefix
                path_dir=$(dirname "$prefix_for_ls")
                path_prefix=$(basename "$prefix_for_ls")

                if [[ -d "$path_dir" ]]; then
                    ls -1A "$path_dir" 2>/dev/null | grep -iF -- "$path_prefix" | while read -r item; do
                        local output_dir
                        if [[ "$clean_word" == ~* ]]; then
                            output_dir="$(echo "$path_dir" | sed "s|^$HOME|~|")"
                        else
                            output_dir="$path_dir"
                        fi

                        local full_path
                        if [[ "$output_dir" == "/" ]]; then
                            full_path="/${item}"
                        else
                            full_path="${output_dir}/${item}"
                        fi

                        # For cd/rmdir, only include directories
                        if $dirs_only; then
                            local item_path="${path_dir}/${item}"
                            [[ -d "$item_path" ]] && echo "$full_path"
                        else
                            echo "$full_path"
                        fi
                    done
                fi
            elif $is_file_cmd; then
                # Plain word (no path separators) with a file command.
                # Substring search in the current directory: match the term
                # anywhere in the filename, not just at the beginning.
                # Example: ls pdf → finds meuarquivo.pdf, pdfs_para_organizar, etc.
                if $dirs_only; then
                    # For cd/rmdir, only show directories
                    ls -1A 2>/dev/null | grep -iF -- "$clean_word" | while read -r item; do
                        [[ -d "$item" ]] && echo "$item"
                    done
                else
                    ls -1A 2>/dev/null | grep -iF -- "$clean_word"
                fi
            elif [[ -n "$expanded_word_for_test" ]]; then
                # Fallback: use compgen -f for normal prefix completion.
                # Convert HOME to ~ only if the user typed ~.
                if [[ "$clean_word" == ~* ]]; then
                    compgen -f -- "$expanded_word_for_test" 2>/dev/null \
                        | sed "s|^$HOME/|~/|; s|^$HOME\$|~|"
                else
                    compgen -f -- "$expanded_word_for_test" 2>/dev/null
                fi
            elif $list_current_dir; then
                # List current directory when word is empty (e.g., "ls " + TAB)
                if $dirs_only; then
                    ls -1A 2>/dev/null | while read -r item; do
                        [[ -d "$item" ]] && echo "$item"
                    done
                else
                    ls -1A 2>/dev/null
                fi
            fi

            # For non-file commands with plain words (no path), also include
            # commands, builtins, aliases, functions, and variables.
            # Example: typing "ex" should show exit, export, exec, etc.
            if ! $is_file_cmd && [[ "$clean_word" != */* && "$clean_word" != ~* ]]; then
                compgen -c -- "$clean_word" 2>/dev/null
                compgen -b -- "$clean_word" 2>/dev/null
                alias | cut -d' ' -f2 | cut -d'=' -f1 | grep "^$clean_word" 2>/dev/null
                declare -F | cut -d' ' -f3 | grep "^$clean_word" 2>/dev/null
                compgen -v -- "$clean_word" 2>/dev/null
            fi
        } | sort -u)
    fi

    [[ -z "$candidates" ]] && return 1

    # ---- Escape/format candidates for fzf ----
    # If the user opened a quote, we DON'T escape anything — the quote protects
    # special characters. We just prefix each candidate with the quote character.
    # Otherwise, escape shell metacharacters with backslash.
    local escaped_candidates
    if [[ -n "$quote_char" ]]; then
        # Quoted mode: pass candidates as-is (with quote prefix restored)
        escaped_candidates=$(printf '%s\n' "$candidates" | while read -r line; do
            [[ -z "$line" ]] && continue
            echo "${quote_char}${line}"
        done)
    else
        # Unquoted mode: escape shell metacharacters.
        # Note: "!" is NOT escaped here because we already disabled history
        # expansion with set +H in the subshell above.
        escaped_candidates=$(printf '%s\n' "$candidates" | while read -r line; do
            [[ -z "$line" ]] && continue
            local out=""
            local j char
            for ((j = 0; j < ${#line}; j++)); do
                char="${line:$j:1}"
                case "$char" in
                    ' '|'('|')'|'&'|';'|'<'|'>'|'|'|'"'|"'"|'#'|'['|']')
                        out+="\\$char"
                        ;;
                    *)
                        out+="$char"
                        ;;
                esac
            done
            echo "$out"
        done)
    fi

    # ---- fzf query and options ----
    # clean_word is used instead of last_word because fzf doesn't need shell escapes.
    # --ignore-case is always on for case-insensitive matching of files and directories.
    local fzf_query="$clean_word"
    local fzf_extra_opts="--ignore-case"

    # For directory listing, use an empty query to show all contents.
    $want_dir_content && fzf_query=""

    # For path substring, use only the basename as the fzf query.
    if $is_path_substring; then
        fzf_query=$(basename "$clean_word")
    fi

    # --select-1 --exit-0: auto-select if only one match, exit silently if none.
    selected=$(printf '%s\n' "$escaped_candidates" |
        FZF_DEFAULT_OPTS="--height 40% --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-}" \
        fzf $fzf_extra_opts --query "$fzf_query" --select-1 --exit-0)

    [[ -z "$selected" ]] && return 0

    # ---- Post-selection processing ----
    # Convert escape sequences back to real characters for filesystem checks.
    local check_path
    local check_selected="$selected"
    if [[ -n "$quote_char" ]]; then
        check_selected="${selected#$quote_char}"
    fi
    check_path=$(printf '%b' "$check_selected" 2>/dev/null)
    [[ "$check_path" == "~"* ]] && check_path="${HOME}${check_path:1}"

    # Add trailing slash for directories (but not for bare numbers, which are likely PIDs).
    # Example: cd ~/Documents → becomes cd ~/Documents/ so next TAB lists contents.
    if [[ -d "$check_path" && "$check_selected" != */ && ! "$check_path" =~ ^[0-9]+$ ]]; then
        if [[ -n "$quote_char" ]]; then
            selected="${quote_char}${check_selected}/"
        else
            selected="${check_selected}/"
        fi
    fi

    # Reconstruct the full READLINE_LINE with the selected item,
    # preserving everything after the cursor.
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