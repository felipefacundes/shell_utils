#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Script: cmd - Fuzzy finder for PATH binary commands without external dependencies.

✓ Substring case-insensitive search in PATH commands
✓ Real-time updating while typing/deleting
✓ Colorful and intuitive interface
✓ Navigation with arrow keys
✓ Direct execution with Enter
✓ Usage modes: interactive, initial search, simple list

Usage modes:
  cmd                     # Empty interactive interface
  cmd [term]              # Interface with initial search
  cmd --list, -l [term]   # Non-interactive list
  cmd --docs, -d          # Print this documentation
  cmd --history, -H       # Exibir histórico de comandos"
  cmd --help, -h          # Help

Examples:
  cmd snap                # Search for commands with "snap"
  cmd --list fire         # List commands with "fire"
DOCUMENTATION

# Colors for the interface
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Internationalization messages
declare -A MESSAGES

if [[ "${LANG,,}" =~ pt_ ]]; then
    # Portuguese messages
    MESSAGES=(
        [title]="=== Buscador Fuzzy de Comandos ==="
        [search]="Busca: "
        [commands_found]="Comandos encontrados: "
        [instructions]="Use ↑↓ para navegar, Enter para executar, Backspace para editar, Ctrl+C para sair"
        [no_commands]="Nenhum comando encontrado."
        [position]="[%d/%d]"
        [executing]="Executando: "
        [history_title]="Histórico de comandos executados:"
        [no_history]="Nenhum histórico disponível."
        [usage_title]="Uso: cmd [termo_de_busca]"
        [usage1]="     cmd                      - Interface interativa"
        [usage2]="     cmd [termo]              - Iniciar com termo de busca"
        [usage3]="     cmd --list, -l [termo]   - Listar comandos sem interface"
        [usage4]="     cmd --docs, -d           - Mostrar documentação"
        [usage5]="     cmd --history, -H        - Exibir histórico de comandos"
        [usage6]="     cmd --help, -h           - Mostrar esta ajuda"
        # Novas mensagens para funcionalidade de clipboard
        [copy_to_clipboard]="Copiar para área de transferência: "
        [clipboard_copied]="Comando copiado para a área de transferência"
        [clipboard_error]="Erro ao copiar para a área de transferência"
        [clipboard_not_supported]="Área de transferência não suportada neste ambiente"
        [termux_not_installed]="termux-clipboard-set não está instalado. Não é possível copiar para a área de transferência no Termux."
        [wl_copy_not_installed]="wl-copy não está instalado. Não é possível copiar para a área de transferência no Wayland."
        [xclip_not_installed]="xclip não está instalado. Não é possível copiar para a área de transferência no X11."
        [pbcopy_not_available]="pbcopy não está disponível. Não é possível copiar para a área de transferência."
        [install_termux]="Instale com: pkg install termux-api"
        [install_wl_copy]="Instale com:"
        [install_wl_copy_debian]="  Debian/Ubuntu: sudo apt install wl-clipboard"
        [install_wl_copy_arch]="  Arch: sudo pacman -S wl-clipboard"
        [install_wl_copy_fedora]="  Fedora: sudo dnf install wl-clipboard"
        [install_xclip]="Instale com:"
        [install_xclip_debian]="  Debian/Ubuntu: sudo apt install xclip"
        [install_xclip_arch]="  Arch: sudo pacman -S xclip"
        [install_xclip_fedora]="  Fedora: sudo dnf install xclip"
        [install_xclip_macos]="  macOS (via Homebrew): brew install xclip"
        [no_clipboard_util]="Nenhum utilitário de área de transferência encontrado para este ambiente."
        [supported_utils]="Utilitários suportados:"
        [util_wl_copy]="  - wl-copy (Wayland)"
        [util_xclip]="  - xclip (X11)"
        [util_termux]="  - termux-clipboard-set (Termux/Android)"
        [util_pbcopy]="  - pbcopy (macOS)"
    )
else
    # English messages (default)
    MESSAGES=(
        [title]="=== Command Fuzzy Finder ==="
        [search]="Search: "
        [commands_found]="Commands found: "
        [instructions]="Use ↑↓ to navigate, Enter to execute, Backspace to edit, Ctrl+C to exit"
        [no_commands]="No commands found."
        [position]="[%d/%d]"
        [executing]="Executing: "
        [history_title]="Executed commands history:"
        [no_history]="No history available."
        [usage_title]="Usage: cmd [search_term]"
        [usage1]="     cmd                      - Interactive interface"
        [usage2]="     cmd [term]               - Start with search term"
        [usage3]="     cmd --list, -l [term]    - List commands without interface"
        [usage4]="     cmd --docs, -d           - Show documentation"
        [usage5]="     cmd --history, -H        - Display command history"
        [usage6]="     cmd --help, -h           - Print this help"
        # New messages for clipboard functionality
        [copy_to_clipboard]="Copy to clipboard: "
        [clipboard_copied]="Command copied to clipboard"
        [clipboard_error]="Error copying to clipboard"
        [clipboard_not_supported]="Clipboard not supported in this environment"
        [termux_not_installed]="termux-clipboard-set is not installed. Cannot copy to clipboard in Termux."
        [wl_copy_not_installed]="wl-copy is not installed. Cannot copy to clipboard in Wayland."
        [xclip_not_installed]="xclip is not installed. Cannot copy to clipboard in X11."
        [pbcopy_not_available]="pbcopy is not available. Cannot copy to clipboard."
        [install_termux]="Install with: pkg install termux-api"
        [install_wl_copy]="Install with:"
        [install_wl_copy_debian]="  Debian/Ubuntu: sudo apt install wl-clipboard"
        [install_wl_copy_arch]="  Arch: sudo pacman -S wl-clipboard"
        [install_wl_copy_fedora]="  Fedora: sudo dnf install wl-clipboard"
        [install_xclip]="Install with:"
        [install_xclip_debian]="  Debian/Ubuntu: sudo apt install xclip"
        [install_xclip_arch]="  Arch: sudo pacman -S xclip"
        [install_xclip_fedora]="  Fedora: sudo dnf install xclip"
        [install_xclip_macos]="  macOS (via Homebrew): brew install xclip"
        [no_clipboard_util]="No clipboard utility found for this environment."
        [supported_utils]="Supported clipboard utilities:"
        [util_wl_copy]="  - wl-copy (Wayland)"
        [util_xclip]="  - xclip (X11)"
        [util_termux]="  - termux-clipboard-set (Termux/Android)"
        [util_pbcopy]="  - pbcopy (macOS)"
    )
fi

setup_clipboard() {
    # Termux (Android)
    if [[ -n "$TERMUX_VERSION" ]]; then
        if command -v termux-clipboard-set &> /dev/null; then
            clipboard_copy() {
                if echo -ne "$1" | termux-clipboard-set 2>/dev/null; then
                    echo -e "${MESSAGES[clipboard_copied]}\n"
                else
                    echo -e "${MESSAGES[clipboard_error]}\n" >&2
                    return 1
                fi
            }
        else
            clipboard_copy() {
                echo -e "${MESSAGES[termux_not_installed]}\n" >&2
                echo -e "${MESSAGES[install_termux]}\n" >&2
                return 1
            }
        fi
    
    # Wayland
    elif [[ ${XDG_SESSION_TYPE,,} == "wayland" ]]; then
        if command -v wl-copy &> /dev/null; then
            clipboard_copy() {
                if echo -ne "$1" | wl-copy 2>/dev/null; then
                    echo -e "${MESSAGES[clipboard_copied]}\n"
                else
                    echo -e "${MESSAGES[clipboard_error]}\n" >&2
                    return 1
                fi
            }
        else
            clipboard_copy() {
                echo "${MESSAGES[wl_copy_not_installed]}" >&2
                echo "${MESSAGES[install_wl_copy]}" >&2
                echo "${MESSAGES[install_wl_copy_debian]}" >&2
                echo "${MESSAGES[install_wl_copy_arch]}" >&2
                echo -e "${MESSAGES[install_wl_copy_fedora]}\n" >&2
                return 1
            }
        fi
    
    # X11
    elif [[ ${XDG_SESSION_TYPE,,} == "x11" ]] || [[ -n "$DISPLAY" ]]; then
        if command -v xclip &> /dev/null; then
            clipboard_copy() {
                if echo -ne "$1" | xclip -selection clipboard 2>/dev/null; then
                    echo -e "${MESSAGES[clipboard_copied]}\n"
                else
                    echo -e "${MESSAGES[clipboard_error]}\n" >&2
                    return 1
                fi
            }
        else
            clipboard_copy() {
                echo "${MESSAGES[xclip_not_installed]}" >&2
                echo "${MESSAGES[install_xclip]}" >&2
                echo "${MESSAGES[install_xclip_debian]}" >&2
                echo "${MESSAGES[install_xclip_arch]}" >&2
                echo "${MESSAGES[install_xclip_fedora]}" >&2
                echo -e "${MESSAGES[install_xclip_macos]}\n" >&2
                return 1
            }
        fi
    
    # Outros ambientes (macOS, etc)
    else
        if command -v pbcopy &> /dev/null; then  # macOS
            clipboard_copy() {
                if echo -ne "$1" | pbcopy 2>/dev/null; then
                    echo -e "${MESSAGES[clipboard_copied]}\n"
                else
                    echo -e "${MESSAGES[clipboard_error]}\n" >&2
                    return 1
                fi
            }
        else
            clipboard_copy() {
                echo "${MESSAGES[pbcopy_not_available]}" >&2
                echo "${MESSAGES[no_clipboard_util]}" >&2
                echo "${MESSAGES[supported_utils]}" >&2
                echo "${MESSAGES[util_wl_copy]}" >&2
                echo "${MESSAGES[util_xclip]}" >&2
                echo "${MESSAGES[util_termux]}" >&2
                echo -e "${MESSAGES[util_pbcopy]}\n" >&2
                return 1
            }
        fi
    fi
}

# Global variables
declare -a commands
declare -a filtered_commands
current_index=0
search_term=""

# Configuration
MAX_RESULTS=35
SHOW_COUNT=10

# Configuration
HISTORY_FILE="$HOME/.cmd_history"
HISTORY_MAX=1000

add_to_history() {
    local cmd="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    [[ ! -f "$HISTORY_FILE" ]] && touch "$HISTORY_FILE"
    
    # Remove existing entries for this command
    if grep -q "| $cmd$" "$HISTORY_FILE"; then
        grep -v "| $cmd$" "$HISTORY_FILE" > "${HISTORY_FILE}.tmp"
        mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
    fi
    
    # Add with timestamp
    echo "$timestamp | $cmd" >> "$HISTORY_FILE"
    
    # Limit size
    if [[ $(wc -l < "$HISTORY_FILE") -gt $HISTORY_MAX ]]; then
        tail -n "$HISTORY_MAX" "$HISTORY_FILE" > "${HISTORY_FILE}.tmp"
        mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
    fi
}

# To show formatted history:
show_history() {
    if [[ -f "$HISTORY_FILE" ]]; then
        clear
        echo -e "${CYAN}${MESSAGES[history_title]}${NC}\n"
        cat "$HISTORY_FILE" | tail -30
    else
        echo "${MESSAGES[no_history]}"
    fi
}

# Function to get all commands from PATH
get_all_commands() {
    local path_dirs
    IFS=':' read -ra path_dirs <<< "$PATH"
    
    local -a unique_commands
    local -A seen
    
    for dir in "${path_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            for file in "$dir"/*; do
                if [[ -x "$file" && -f "$file" ]]; then
                    local cmd_name="${file##*/}"
                    if [[ ! ${seen["$cmd_name"]} ]]; then
                        unique_commands+=("$cmd_name")
                        seen["$cmd_name"]=1
                    fi
                fi
            done
        fi
    done
    
    # Sort commands
    mapfile -t commands < <(printf "%s\n" "${unique_commands[@]}" | sort)
    filtered_commands=("${commands[@]}")
}

# IMPROVED function for fuzzy matching (case-insensitive substring search)
fuzzy_match() {
    local pattern="$1"
    local string="$2"
    
    # If no pattern, return success
    [[ -z "$pattern" ]] && return 0
    
    local pattern_lower="${pattern,,}"
    local string_lower="${string,,}"
    
    # Check if pattern is contained in string (substring search)
    [[ "$string_lower" == *"$pattern_lower"* ]]
}

# Function to filter commands based on search term
filter_commands() {
    filtered_commands=()
    
    if [[ -z "$search_term" ]]; then
        filtered_commands=("${commands[@]}")
        return
    fi
    
    for cmd in "${commands[@]}"; do
        if fuzzy_match "$search_term" "$cmd"; then
            filtered_commands+=("$cmd")
        fi
    done
}

# Function to highlight search term in command
highlight_match() {
    local cmd="$1"
    local pattern="$2"
    
    if [[ -z "$pattern" ]]; then
        echo "$cmd"
        return
    fi
    
    local pattern_lower="${pattern,,}"
    local cmd_lower="${cmd,,}"
    
    # Find pattern position
    local pos="${cmd_lower%%$pattern_lower*}"
    local pos_len=${#pos}
    
    if [[ "$cmd_lower" == *"$pattern_lower"* ]]; then
        local before="${cmd:0:$pos_len}"
        local match="${cmd:$pos_len:${#pattern}}"
        local after="${cmd:$((pos_len + ${#pattern}))}"
        echo -e "${before}${BOLD}${GREEN}${match}${NC}${after}"
    else
        echo "$cmd"
    fi
}

# Function to clear screen
clear_screen() {
    printf "\033[2J\033[H"
}

# Function to display interface
display_interface() {
    clear_screen
    
    # Title
    echo -e "${BOLD}${CYAN}${MESSAGES[title]}${NC}"
    echo -e "${YELLOW}${MESSAGES[search]}${BOLD}${search_term}${NC}\033[5m_\033[0m"
    echo -e "${BLUE}${MESSAGES[commands_found]}${#filtered_commands[@]}${NC}"
    echo -e "${MAGENTA}${MESSAGES[instructions]}${NC}"
    echo "----------------------------------------"
    
    # Calculate indices for display
    local start_index=$((current_index - SHOW_COUNT/2))
    [[ $start_index -lt 0 ]] && start_index=0
    
    local end_index=$((start_index + SHOW_COUNT))
    [[ $end_index -gt ${#filtered_commands[@]} ]] && end_index=${#filtered_commands[@]}
    
    # Adjust start_index if needed
    if [[ $((end_index - start_index)) -lt $SHOW_COUNT && $start_index -gt 0 ]]; then
        start_index=$((end_index - SHOW_COUNT))
        [[ $start_index -lt 0 ]] && start_index=0
    fi
    
    # Display commands
    for ((i=start_index; i<end_index; i++)); do
        local cmd="${filtered_commands[$i]}"
        
        if [[ $i -eq $current_index ]]; then
            echo -e "${BOLD}${RED}❯ ${NC}$(highlight_match "$cmd" "$search_term")"
        else
            echo -e "  $(highlight_match "$cmd" "$search_term")"
        fi
    done
    
    # Additional information
    if [[ ${#filtered_commands[@]} -eq 0 ]]; then
        echo -e "\n${YELLOW}${MESSAGES[no_commands]}${NC}"
    else
        printf "\n${BLUE}${MESSAGES[position]}${NC}\n" "$((current_index + 1))" "${#filtered_commands[@]}"
    fi
}

# Main fuzzy finder function
run_fuzzy_finder() {
    get_all_commands
    
    # If received an argument, use as initial term
    if [[ -n "$1" ]]; then
        search_term="$1"
        filter_commands
    fi
    
    # Set up terminal for key reading
    local old_stty
    old_stty=$(stty -g)
    stty -icanon -echo min 1 time 0
    
    # Trap to restore terminal settings
    trap 'stty "$old_stty"; clear_screen; exit 0' INT TERM EXIT
    
    while true; do
        display_interface
        
        # Read character by character
        local char
        IFS= read -r -n1 char
        
        # Detect escape sequences (special keys)
        if [[ "$char" == $'\x1b' ]]; then
            # Read next 2 characters for escape sequences
            local seq1 seq2
            read -r -n1 -t 0.01 seq1
            read -r -n1 -t 0.01 seq2
            
            if [[ "$seq1" == '[' ]]; then
                case "$seq2" in
                    'A') # Up arrow
                        if [[ $current_index -gt 0 ]]; then
                            ((current_index--))
                        fi
                        ;;
                    'B') # Down arrow
                        if [[ $current_index -lt $((${#filtered_commands[@]} - 1)) ]]; then
                            ((current_index++))
                        fi
                        ;;
                    'H') # Home
                        current_index=0
                        ;;
                    'F') # End
                        current_index=$((${#filtered_commands[@]} - 1))
                        [[ $current_index -lt 0 ]] && current_index=0
                        ;;
                esac
            fi
        elif [[ "$char" == $'\x7f' || "$char" == $'\x08' ]]; then
            # Backspace or Delete
            if [[ ${#search_term} -gt 0 ]]; then
                search_term="${search_term:0:$((${#search_term}-1))}"
                filter_commands
                current_index=0
            fi
        elif [[ "$char" == $'\x0a' || "$char" == $'\x0d' || "$char" == '' ]]; then
            # Enter (Line Feed or Carriage Return or empty)
            if [[ ${#filtered_commands[@]} -gt 0 && $current_index -ge 0 ]]; then
                local selected_cmd="${filtered_commands[$current_index]}"
                stty "$old_stty"
                clear_screen
                
                # Execute command
                echo -e "${GREEN}${MESSAGES[executing]}${BOLD}$selected_cmd${NC}\n"
                add_to_history "$selected_cmd"
                setup_clipboard
                clipboard_copy "$selected_cmd"
                exec "$selected_cmd"
            fi
        elif [[ "$char" == $'\x03' ]]; then
            # Ctrl+C
            stty "$old_stty"
            clear_screen
            exit 0
        elif [[ -n "$char" && "$char" =~ [[:print:]] ]]; then
            # Normal printable characters
            search_term+="$char"
            filter_commands
            current_index=0
        fi
    done
}

# Function for simple search mode (without interactive interface)
simple_search() {
    get_all_commands
    local search="$1"
    
    for cmd in "${commands[@]}"; do
        if fuzzy_match "$search" "$cmd"; then
            echo "$cmd"
        fi
    done | head -$MAX_RESULTS
}

# Main entry point
main() {
    # Check if in an interactive terminal
    if [[ -t 0 && -t 1 ]]; then
        # Interactive mode
        if [[ "$1" == "--history" || "$1" == "-H" ]]; then
            show_history
        elif [[ "$1" == "--docs" || "$1" == "-d" ]]; then
            sed -n '/^: <<.DOCUMENTATION./,/^DOCUMENTATION/p' "$0" | sed '1d;$d'
            exit 0
        elif [[ "$1" == "--help" || "$1" == "-h" ]]; then
            echo "${MESSAGES[usage_title]}"
            echo "${MESSAGES[usage1]}"
            echo "${MESSAGES[usage2]}"
            echo "${MESSAGES[usage3]}"
            echo "${MESSAGES[usage4]}"
            echo "${MESSAGES[usage5]}"
            echo "${MESSAGES[usage6]}"
            exit 0
        elif [[ "$1" == "--list" || "$1" == "-l" ]]; then
            # Simple list mode
            simple_search "${2:-}"
            exit 0
        else
            # Interactive fuzzy finder mode
            run_fuzzy_finder "${1:-}"
        fi
    else
        # Non-interactive mode (pipe, etc)
        simple_search "${1:-}"
    fi
}

# Execute
main "$@"