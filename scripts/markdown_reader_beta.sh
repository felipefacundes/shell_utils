#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This is a beta version of this shell script capable of reading markdown, formatting it, coloring, and highlighting.
DOCUMENTATION

# Color definitions
readonly COLOR_TITLE1='\033[1;38;2;255;128;0;48;2;40;40;40m'  # Orange text on dark gray
readonly COLOR_TITLE2='\033[1;38;2;255;192;0;48;2;35;35;35m'  # Yellow text on dark gray
readonly COLOR_TITLE3='\033[1;38;2;0;255;127;48;2;30;30;30m'  # Spring green on dark gray
readonly COLOR_TITLE4='\033[1;38;2;135;206;250;48;2;25;25;25m'  # Light blue on dark gray
readonly COLOR_TITLE5='\033[1;38;2;255;105;180;48;2;20;20;20m'  # Hot pink on dark gray
readonly COLOR_TITLE6='\033[1;38;2;147;112;219;48;2;15;15;15m'  # Purple on dark gray
readonly COLOR_CODE='\033[1;38;2;173;216;230m'  # Light blue for inline code
readonly COLOR_BULLET='\033[1;38;2;50;205;50m'  # Lime green for bullets
readonly COLOR_LINK='\033[1;38;2;64;224;208m'  # Turquoise for links
readonly COLOR_BOLD='\033[1;38;2;255;215;0m'  # Gold for bold text
readonly COLOR_ITALIC='\033[3;38;2;216;191;216m'  # Plum for italic text
readonly COLOR_BLOCKQUOTE='\033[1;38;2;169;169;169;48;2;45;45;45m'  # Gray text on darker gray
readonly COLOR_TABLE_HEADER='\033[1;38;2;255;182;193;48;2;40;40;40m'  # Light pink on dark gray
readonly COLOR_TABLE_CELL='\033[38;2;176;196;222m'  # Light steel blue
readonly COLOR_RESET='\033[0m'

show_help() {
    echo "Usage: $0 [OPTIONS] <markdown_file>"
    echo
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo "  -p, --plain      Disable colors in output"
    echo "  -s, --style      Specify custom style (dark/light)"
    echo "  -o, --output     Specify output file"
    echo
    echo "Example:"
    echo "  $0 document.md"
    echo "  $0 --style dark document.md"
    exit 0
}

check_dependencies() {
    local missing_deps=()
    
    # Check for required commands
    for cmd in awk sed source-highlight; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Error: Missing dependencies: ${missing_deps[*]}"
        echo "Please install the required packages and try again."
        exit 1
    fi
}

process_headers() {
    local line="$1"
    if [[ $line =~ ^#[^#](.+)$ ]]; then
        echo -e "${COLOR_TITLE1}${BASH_REMATCH[1]}${COLOR_RESET}"
    elif [[ $line =~ ^##[^#](.+)$ ]]; then
        echo -e "${COLOR_TITLE2}${BASH_REMATCH[1]}${COLOR_RESET}"
    elif [[ $line =~ ^###[^#](.+)$ ]]; then
        echo -e "${COLOR_TITLE3}${BASH_REMATCH[1]}${COLOR_RESET}"
    elif [[ $line =~ ^####[^#](.+)$ ]]; then
        echo -e "${COLOR_TITLE4}${BASH_REMATCH[1]}${COLOR_RESET}"
    elif [[ $line =~ ^#####[^#](.+)$ ]]; then
        echo -e "${COLOR_TITLE5}${BASH_REMATCH[1]}${COLOR_RESET}"
    elif [[ $line =~ ^######[^#](.+)$ ]]; then
        echo -e "${COLOR_TITLE6}${BASH_REMATCH[1]}${COLOR_RESET}"
    else
        echo "$line"
    fi
}

process_inline_formatting() {
    local line="$1"
    # Process bold text
    line=$(echo "$line" | sed "s/\*\*\([^*]*\)\*\*/${COLOR_BOLD}\1${COLOR_RESET}/g")
    line=$(echo "$line" | sed "s/__\([^_]*\)__/${COLOR_BOLD}\1${COLOR_RESET}/g")
    
    # Process italic text
    line=$(echo "$line" | sed "s/\*\([^*]*\)\*/${COLOR_ITALIC}\1${COLOR_RESET}/g")
    line=$(echo "$line" | sed "s/_\([^_]*\)_/${COLOR_ITALIC}\1${COLOR_RESET}/g")
    
    # Process inline code
    line=$(echo "$line" | sed 's/\`\([^`]*\)\`/'"${COLOR_CODE}"'\1'"${COLOR_RESET}"'/g')
    
    # Process links
    line=$(echo "$line" | sed "s/\[\([^]]*\)\](\([^)]*\))/${COLOR_LINK}\1${COLOR_RESET} (${COLOR_LINK}\2${COLOR_RESET})/g")
    
    echo "$line"
}

process_code_blocks() {
    local in_code_block=0
    local code_buffer=""
    local language=""
    
    while IFS= read -r line; do
        if [[ $line =~ ^(\`\`\`)(.*)$ ]]; then
            if [ $in_code_block -eq 0 ]; then
                in_code_block=1
                language="${BASH_REMATCH[2]}"
                continue
            else
                # Process the code block with syntax highlighting
                if [ -n "$code_buffer" ]; then
                    echo -e "${COLOR_CODE}"
                    echo "$code_buffer" | source-highlight --src-lang="${language:-txt}" --out-format=esc
                    echo -e "${COLOR_RESET}"
                fi
                in_code_block=0
                code_buffer=""
                continue
            fi
        fi
        
        if [ $in_code_block -eq 1 ]; then
            code_buffer+="$line"$'\n'
        else
            process_inline_formatting "$(process_headers "$line")"
        fi
    done
}

process_tables() {
    local in_table=0
    local header_processed=0
    
    while IFS= read -r line; do
        if [[ $line =~ ^[\|].*[\|]$ ]]; then
            # Table row detected
            if [ $in_table -eq 0 ]; then
                in_table=1
                # Process header row
                echo -e "${COLOR_TABLE_HEADER}$(echo "$line" | sed 's/|/│/g')${COLOR_RESET}"
            elif [[ $line =~ ^[\|][-:|\s]+[\|]$ ]]; then
                # Separator row - skip processing
                continue
            else
                # Process regular row
                echo -e "${COLOR_TABLE_CELL}$(echo "$line" | sed 's/|/│/g')${COLOR_RESET}"
            fi
        else
            if [ $in_table -eq 1 ]; then
                in_table=0
            fi
            process_code_blocks <<< "$line"
        fi
    done
}

process_lists() {
    while IFS= read -r line; do
        if [[ $line =~ ^[[:space:]]*[-*+][[:space:]](.+)$ ]]; then
            # Unordered list item
            local indent=$((${#BASH_REMATCH[0]} - ${#BASH_REMATCH[1]} - 1))
            local spaces=$(printf "%*s" $indent "")
            echo -e "${spaces}${COLOR_BULLET}•${COLOR_RESET} $(process_inline_formatting "${BASH_REMATCH[1]}")"
        elif [[ $line =~ ^[[:space:]]*[0-9]+\.[[:space:]](.+)$ ]]; then
            # Ordered list item
            local indent=$((${#BASH_REMATCH[0]} - ${#BASH_REMATCH[1]} - 1))
            local spaces=$(printf "%*s" $indent "")
            echo -e "${spaces}${COLOR_BULLET}${BASH_REMATCH[0]%.*}.${COLOR_RESET} $(process_inline_formatting "${BASH_REMATCH[1]}")"
        else
            process_tables <<< "$line"
        fi
    done
}

main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                ;;
            -p|--plain)
                # Disable colors
                for color in $(compgen -v COLOR_); do
                    declare $color=''
                done
                shift
                ;;
            -s|--style)
                # TODO: Implement different color schemes
                shift 2
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            *)
                input_file="$1"
                shift
                ;;
        esac
    done
    
    # Check if input file is provided
    if [ -z "$input_file" ]; then
        echo "Error: No input file specified"
        show_help
    fi
    
    # Check if input file exists
    if [ ! -f "$input_file" ]; then
        echo "Error: File '$input_file' not found"
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    
    # Process the markdown file
    if [ -n "$output_file" ]; then
        process_lists < "$input_file" > "$output_file"
    else
        process_lists < "$input_file"
    fi
}

main "$@"