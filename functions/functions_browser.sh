#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

# Pure Shell Function Browser with Fuzzy Search and Preview
# Compatible with both Bash and Zsh
# No external dependencies required - Optimized version with minimal flicker
#
# Usage:
#   source script.sh
#   functions_browser

# Main entry point - the only global function exposed
functions_browser() {
    DEBUG_LOG="/tmp/functions_browser_debug.log"
    echo "=== Debug start: $(date) ===" > "$DEBUG_LOG"
    
    local SHELL_TYPE
    if [[ -n "$BASH_VERSION" ]]; then
        SHELL_TYPE="bash"
    elif [[ -n "$ZSH_VERSION" ]]; then
        SHELL_TYPE="zsh"
    else
        echo "Unsupported shell. Please use Bash or Zsh."
        return 1
    fi
    echo "Shell: $SHELL_TYPE" >> "$DEBUG_LOG"

    local HIGHLIGHTER=""
    if command -v pygmentize &> /dev/null; then
        HIGHLIGHTER="pygmentize"
    elif command -v highlight &> /dev/null; then
        HIGHLIGHTER="highlight"
    elif command -v bat &> /dev/null; then
        HIGHLIGHTER="bat"
    fi
    echo "Highlighter: ${HIGHLIGHTER:-none}" >> "$DEBUG_LOG"

    local BOLD=$'\033[1m' CYAN=$'\033[0;36m' GREEN=$'\033[0;32m'
    local YELLOW=$'\033[0;33m' RESET=$'\033[0m'
    local HIDE_CURSOR=$'\033[?25l' SHOW_CURSOR=$'\033[?25h'

    # Flag to break the main loop
    local EXIT_FLAG=false

    __cleanup() {
        echo "Cleanup called" >> "$DEBUG_LOG"
        printf '\e[?7h\e[?25h\e[2J\e[;r\e[?1049l'
        printf "%s" "$SHOW_CURSOR"
        stty echo icanon </dev/tty >/dev/null 2>/dev/null
        clear
        echo "Goodbye!"
        EXIT_FLAG=true
    }

    # Trap just sets the flag - doesn't try to return
    trap '__cleanup;' SIGINT SIGTERM

    __get_functions() {
        if [[ "$SHELL_TYPE" == "zsh" ]]; then
            typeset -f + | grep -E '^[a-zA-Z_]' | awk '{print $1}' | sed 's/()//' | grep -v '^$'
        else
            declare -F | awk '{print $3}'
        fi
    }

    __get_def() {
        local n="$1"
        if [[ "$SHELL_TYPE" == "zsh" ]]; then
            typeset -f "$n" 2>/dev/null
        else
            declare -f "$n" 2>/dev/null
        fi
    }

    __hl() {
        case "$HIGHLIGHTER" in
            bat) bat --language=bash --style=plain --paging=never --color=always 2>/dev/null ;;
            pygmentize) pygmentize -l bash 2>/dev/null ;;
            highlight) highlight --syntax=bash --out-format=ansi 2>/dev/null ;;
            *) cat ;;
        esac
    }

    __fuzzy() {
        local p="$1" s="$2"
        [[ -z "$s" ]] && return 1
        if [[ "$SHELL_TYPE" == "zsh" ]]; then
            [[ "${s:l}" == *"${p:l}"* ]]
        else
            [[ "${s,,}" == *"${p,,}"* ]]
        fi
    }

    local all_funcs
    if [[ "$SHELL_TYPE" == "zsh" ]]; then
        all_funcs=("${(@f)$(__get_functions)}")
        all_funcs=(${all_funcs:#})
        setopt localoptions ksharrays 2>/dev/null || true
    else
        IFS=$'\n' read -r -d '' -a all_funcs <<< "$(__get_functions)"
    fi
    
    echo "Total functions: ${#all_funcs[@]}" >> "$DEBUG_LOG"

    local filtered=("${all_funcs[@]}")
    local total=${#filtered[@]}
    local sel=0 search="" prev_search=""
    local max_list=10

    printf '\e[?1049h\e[?7l\e[?25l\e[2J\e[H'
    stty -echo -icanon time 0 min 0

    __draw() {
        printf '\e[2J\e[H'
        
        printf "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}\n"
        printf "${BOLD}${CYAN}║         Shell Function Browser (${SHELL_TYPE})             ║${RESET}\n"
        printf "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════╝${RESET}\n"
        printf "${GREEN}Type to search | ↑↓: Navigate | Enter: Full view | q: Quit"
        [[ -n "$HIGHLIGHTER" ]] && printf " | Syntax: ${HIGHLIGHTER}"
        printf "${RESET}\n\n"
        
        printf "${BOLD}Search: ${RESET}%s ${GREEN}[%d matches]${RESET}\n\n" "$search" "$total"
        
        printf "${BOLD}Functions:${RESET}\n"
        printf "${CYAN}────────────────────────────────────────────────────────────────${RESET}\n"
        
        local start=0
        if [[ $sel -ge $max_list ]]; then
            start=$((sel - max_list + 1))
        fi
        
        for ((i=start; i<start+max_list && i<total; i++)); do
            if [[ $i -eq $sel ]]; then
                printf "${BOLD}${CYAN}> ${RESET}%s\n" "${filtered[$i]}"
            else
                printf "  %s\n" "${filtered[$i]}"
            fi
        done
        
        local shown=$((total - start))
        [[ $shown -gt $max_list ]] && shown=$max_list
        for ((i=shown; i<max_list; i++)); do printf "\n"; done
        
        printf "\n${BOLD}Preview:${RESET}\n"
        printf "${CYAN}────────────────────────────────────────────────────────────────${RESET}\n"
        
        if [[ $total -gt 0 ]] && [[ $sel -lt $total ]]; then
            __get_def "${filtered[$sel]}" | head -n 20 | __hl
        fi
        
        printf '\e[J'
    }

    __draw

    while true; do
        # Check exit flag before reading
        if $EXIT_FLAG; then
            break
        fi
        
        local key=""
        read -r -k 1 key 2>/dev/null || read -r -n 1 key
        
        # Check exit flag after reading (in case Ctrl+C interrupted the read)
        if $EXIT_FLAG; then
            break
        fi
        
        case "$key" in
            $'\x1b')
                local k2=""
                read -r -k 2 -t 0.001 k2 2>/dev/null || read -r -n 2 -t 0.001 k2
                
                case "$k2" in
                    '[A')
                        if [[ $sel -gt 0 ]]; then
                            ((sel--))
                            __draw
                        fi
                        ;;
                    '[B')
                        if [[ $sel -lt $((total - 1)) ]]; then
                            ((sel++))
                            __draw
                        fi
                        ;;
                esac
                ;;
            $'\x7f'|$'\b')
                if [[ -n "$search" ]]; then
                    search="${search%?}"
                    __draw
                fi
                ;;
            '')
                if [[ $total -gt 0 ]] && [[ -n "${filtered[$sel]}" ]]; then
                    printf '\e[?1049l'
                    stty echo icanon
                    printf "%s" "$SHOW_CURSOR"
                    clear
                    printf "${BOLD}${CYAN}Full definition: ${YELLOW}%s${RESET}\n" "${filtered[$sel]}"
                    printf "${CYAN}════════════════════════════════════════════════════════════════${RESET}\n"
                    __get_def "${filtered[$sel]}" | __hl
                    printf "\n${GREEN}Press Enter to continue...${RESET}"
                    read -r
                    printf '\e[?1049h\e[?7l\e[?25l'
                    stty -echo -icanon
                    __draw
                fi
                ;;
            q|Q)
                __cleanup
                break
                ;;
            [[:print:]])
                search="${search}${key}"
                __draw
                ;;
        esac
        
        if [[ "$search" != "$prev_search" ]]; then
            filtered=()
            if [[ -z "$search" ]]; then
                filtered=("${all_funcs[@]}")
            else
                for f in "${all_funcs[@]}"; do
                    [[ -n "$f" ]] && __fuzzy "$search" "$f" && filtered+=("$f")
                done
            fi
            total=${#filtered[@]}
            sel=0
            prev_search="$search"
            __draw
        fi
    done

    stty sane
    trap - SIGINT SIGTERM
    echo "=== Debug end: $(date) ===" >> "$DEBUG_LOG"
}

# Usage:
#   source script.sh
#   functions_browser
# [[ "$0" =~ "bash" || "$0" =~ "zsh" ]] && return
# ! [[ "$0" =~ "bash" || "$0" =~ "zsh" ]] && {
#     cat << 'EOF'

# Usage example:

# source ~/.shell_utils/scripts/functions-browser && functions_browser

# Or define a function in your bashrc or zshrc:

# functions_browser() {
#     if [[ -z "$_FZF_FUNCTIONS_BROWSER" ]]; then
#         # shellcheck source=/dev/null
#         source ~/.shell_utils/scripts/functions-browser && functions_browser
#         export _FZF_FUNCTIONS_BROWSER=true
#         return 0
#     fi
#     functions_browser
# }

# EOF
# }

if [[ -n $BASH_VERSION ]]; then
    functions() {
        local func_name
        local list_only=false
        
        # Parse options
        while [[ $# -gt 0 ]]; do
            case "$1" in
                -n|--names)
                    list_only=true
                    shift
                    ;;
                -h|--help)
                    echo "Usage: functions [-n|--names] [function_name]"
                    echo ""
                    echo "Options:"
                    echo "  -n, --names    List all function names only"
                    echo "  -h, --help     Show this help message"
                    echo ""
                    echo "If a function name is provided, shows its definition."
                    echo "If no arguments, lists all functions with their definitions."
                    return 0
                    ;;
                -*)
                    echo "functions: Unknown option: $1" >&2
                    return 1
                    ;;
                *)
                    func_name="$1"
                    shift
                    ;;
            esac
        done
        
        # If -n flag, list names only
        if $list_only; then
            declare -F | awk '{print $3}' | sort
            return 0
        fi
        
        # If function name provided, show its definition
        if [[ -n "$func_name" ]]; then
            if declare -F "$func_name" &> /dev/null; then
                declare -f "$func_name"
                return 0
            else
                echo "functions: Function '$func_name' not found" >&2
                return 1
            fi
        fi
        
        ! command -v less && echo "Install less" && return 1
        # No arguments: list all functions with their definitions
        local all_functions=($(declare -F | awk '{print $3}' | sort))
        
        for func in "${all_functions[@]}"; do
            echo "────────────────────────────────────────"
            echo "function $func"
            declare -f "$func" | tail -n +2 | sed 's/^/  /'
            echo
        done | less -R
    }
fi