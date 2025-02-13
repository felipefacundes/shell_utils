#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This is a beta version of this shell script capable of reading markdown, formatting it, coloring, and highlighting.
DOCUMENTATION

# ANSI Color definitions
readonly COLOR_TITLE1='\033[1;38;2;255;128;0;48;2;40;40;40m'    # Orange text on dark gray
readonly COLOR_TITLE2='\033[1;38;2;255;192;0;48;2;35;35;35m'    # Yellow text on dark gray
readonly COLOR_TITLE3='\033[1;38;2;0;255;127;48;2;30;30;30m'    # Spring green on dark gray
readonly COLOR_TITLE4='\033[1;38;2;135;206;250;48;2;25;25;25m'  # Light blue on dark gray
readonly COLOR_TITLE5='\033[1;38;2;255;105;180;48;2;20;20;20m'  # Hot pink on dark gray
readonly COLOR_TITLE6='\033[1;38;2;147;112;219;48;2;15;15;15m'  # Purple on dark gray
readonly COLOR_CODE='\033[1;38;2;173;216;230m'                   # Light blue for inline code
readonly COLOR_BULLET='\033[1;38;2;50;205;50m'                   # Lime green for bullets
readonly COLOR_RESET='\033[0m'
readonly COLOR_HR='\033[1;38;2;100;100;100m'                     # Gray for horizontal rules

check_dependencies() {
    local missing_deps=()
    for cmd in awk sed source-highlight; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Error: Missing dependencies: ${missing_deps[*]}"
        echo "Please install the required packages and try again."
        exit 1
    fi
}

clean_ansi_escapes() {
    local text="$1"
    # Remove any existing ANSI escape sequences
    echo "$text" | sed -E 's/(\x1B|\\\e|\\\033)\[[0-9;]*[mK]//g' | sed -E 's/\\e\[[0-9;]*[mK]//g'
}

format_headers() {
    local line="$1"
    local level=$(echo "$line" | grep -o '^#\+' | wc -c)
    local text=$(echo "$line" | sed 's/^#\+[[:space:]]*//')
    text=$(clean_ansi_escapes "$text")
    
    case $level in
        1) printf "${COLOR_TITLE1}%s${COLOR_RESET}\n" "$text" ;;
        2) printf "${COLOR_TITLE2}%s${COLOR_RESET}\n" "$text" ;;
        3) printf "${COLOR_TITLE3}%s${COLOR_RESET}\n" "$text" ;;
        4) printf "${COLOR_TITLE4}%s${COLOR_RESET}\n" "$text" ;;
        5) printf "${COLOR_TITLE5}%s${COLOR_RESET}\n" "$text" ;;
        6) printf "${COLOR_TITLE6}%s${COLOR_RESET}\n" "$text" ;;
    esac
}

format_inline_code() {
    local line="$1"
    line=$(clean_ansi_escapes "$line")
    
    # Process inline code blocks
    while [[ "$line" =~ (.*)(\`)([^\`]+)(\`)(.*) ]]; do
        local prefix="${BASH_REMATCH[1]}"
        local code="${BASH_REMATCH[3]}"
        local suffix="${BASH_REMATCH[5]}"
        line="${prefix}${COLOR_CODE}${code}${COLOR_RESET}${suffix}"
    done
    echo "$line"
}

format_list() {
    local line="$1"
    line=$(clean_ansi_escapes "$line")
    
    # Extract the list marker and content
    if [[ "$line" =~ ^([[:space:]]*-[[:space:]])(.*)$ ]]; then
        local marker="${BASH_REMATCH[1]}"
        local content="${BASH_REMATCH[2]}"
        
        # Format any inline code in the content
        content=$(format_inline_code "$content")
        printf "${COLOR_BULLET}•${COLOR_RESET} %s\n" "$content"
    else
        echo "$line"
    fi
}

format_horizontal_rule() {
    printf "${COLOR_HR}%s${COLOR_RESET}\n" "$(printf '─%.0s' {1..80})"
}

format_code_block() {
    local content="$1"
    local lang="$2"
    
    content=$(clean_ansi_escapes "$content")
    
    if [ -n "$NO_HIGHLIGHT" ] || [ -z "$lang" ]; then
        printf "${COLOR_CODE}%s${COLOR_RESET}\n" "$content"
    else
        # Create temporary file for source-highlight
        local temp_file=$(mktemp)
        echo "$content" > "$temp_file"
        source-highlight -f esc -s "$lang" -i "$temp_file" 2>/dev/null || \
            printf "${COLOR_CODE}%s${COLOR_RESET}\n" "$content"
        rm -f "$temp_file"
    fi
}

process_markdown() {
    local file="$1"
    local in_code_block=0
    local code_block_content=""
    local code_block_lang=""
    
    while IFS= read -r line || [ -n "$line" ]; do
        # Clean any existing ANSI escapes from the input line
        line=$(clean_ansi_escapes "$line")
        
        # Handle HTML tags
        if echo "$line" | grep -q "^[[:space:]]*<br>"; then
            echo ""
            continue
        fi
        
        # Handle horizontal rules
        if [[ "$line" =~ ^[[:space:]]*---[[:space:]]*$ ]]; then
            format_horizontal_rule
            continue
        fi
        
        # Handle code blocks
        if [[ "$line" =~ ^(\`\`\`) ]]; then
            if [ $in_code_block -eq 0 ]; then
                in_code_block=1
                code_block_lang=$(echo "$line" | sed 's/^```//')
            else
                format_code_block "$code_block_content" "$code_block_lang"
                in_code_block=0
                code_block_content=""
                code_block_lang=""
            fi
            continue
        fi
        
        if [ $in_code_block -eq 1 ]; then
            [ -n "$code_block_content" ] && code_block_content+=$'\n'
            code_block_content+="$line"
            continue
        fi
        
        # Process normal lines
        case "$line" in
            \#*) format_headers "$line" ;;
            [[:space:]]*-[[:space:]]*) format_list "$line" ;;
            "") echo "" ;;  # Preserve empty lines
            *) format_inline_code "$line" ;;
        esac
    done < "$file"
}

show_help() {
    cat << EOF
Markdown Reader - A comprehensive markdown parser and formatter

Usage: ${0##*/} [OPTIONS] file

Options:
  -h, --help     Show this help message
  -n, --no-hl    Disable syntax highlighting for code blocks
  -d, --debug    Show debugging information

Examples:
  ${0##*/} document.md
  ${0##*/} --no-hl README.md

Supported Markdown Features:
• Headers (level 1-6)
• Code blocks with syntax highlighting
• Inline code
• Unordered lists
• Horizontal rules
• HTML line breaks
EOF
    exit 0
}

main() {
    local MARKDOWN_FILE=""
    local NO_HIGHLIGHT=""
    local DEBUG=""
    
    # Parse command line options
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) show_help ;;
            -n|--no-hl) NO_HIGHLIGHT=1 ;;
            -d|--debug) DEBUG=1 ;;
            *) MARKDOWN_FILE="$1" ;;
        esac
        shift
    done
    
    if [ -z "$MARKDOWN_FILE" ]; then
        echo "Error: No input file specified"
        show_help
    fi
    
    if [ ! -f "$MARKDOWN_FILE" ]; then
        echo "Error: File '$MARKDOWN_FILE' not found"
        exit 1
    fi
    
    [ -n "$DEBUG" ] && set -x
    check_dependencies
    process_markdown "$MARKDOWN_FILE"
    [ -n "$DEBUG" ] && set +x
}

main "$@"