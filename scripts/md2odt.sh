#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Converts Markdown to ODT/DOCX via pandoc
Can use clipboard content as input
Usage: md2odt.sh [OPTIONS] [INPUT.md] [OUTPUT.odt/.docx]
DOCUMENTATION

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Checks if pandoc is installed
check_pandoc() {
    if ! command -v pandoc &> /dev/null; then
        echo -e "${RED}Error: pandoc is not installed.${NC}"
        echo -e "Install with:"
        echo -e "  Debian/Ubuntu: ${YELLOW}sudo apt install pandoc${NC}"
        echo -e "  Fedora:        ${YELLOW}sudo dnf install pandoc${NC}"
        echo -e "  Arch:          ${YELLOW}sudo pacman -S pandoc${NC}"
        exit 1
    fi
}

# Shows help
show_help() {
    echo -e "${GREEN}Usage:${NC}"
    echo "  ${0##*/} [OPTIONS] [INPUT.md] [OUTPUT.odt/.docx]"
    echo "  ${0##*/} -c|--clipboard [OUTPUT.odt/.docx]"
    echo ""
    echo -e "${GREEN}Options:${NC}"
    echo "  -h, --help      Show this help"
    echo "  -c, --clipboard Use clipboard content as input"
    echo ""
    echo -e "${GREEN}Examples:${NC}"
    echo "  ${0##*/} document.md document.odt"
    echo "  ${0##*/} -c /path/to/document.docx"
    echo "  ${0##*/} --clipboard"
    exit 0
}

# Processes arguments
process_args() {
    if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        show_help
    fi

    use_clipboard=false
    input_file=""
    output_file=""

    if [[ "$1" == "-c" ]] || [[ "$1" == "--clipboard" ]]; then
        use_clipboard=true
        shift
        if [[ $# -gt 0 ]]; then
            output_file="$1"
        fi
    else
        if [[ $# -lt 2 ]]; then
            echo -e "${RED}Error: Missing arguments.${NC}"
            show_help
            exit 1
        fi
        input_file="$1"
        output_file="$2"
    fi

    # If output file not specified in clipboard mode
    if [[ "$use_clipboard" == true ]] && [[ -z "$output_file" ]]; then
        output_file="output_$(date +%Y%m%d_%H%M%S).odt"
        echo -e "${YELLOW}Using default output name: $output_file${NC}"
    fi

    # Checks output extension
    if [[ -n "$output_file" ]]; then
        output_ext="${output_file##*.}"
        if [[ "$output_ext" != "odt" ]] && [[ "$output_ext" != "docx" ]]; then
            echo -e "${RED}Error: Output extension must be .odt or .docx${NC}"
            exit 1
        fi
    fi
}

# Main function
main() {
    check_pandoc
    process_args "$@"

    pwd="$PWD"
    temp_file=""
    cd /tmp || true

    if [[ "$use_clipboard" == true ]]; then
        temp_file=$(mktemp clipboard_content_XXXXXX.md)
        echo -e "${GREEN}Copying clipboard content to $temp_file${NC}"
        
        # Tries different clipboard methods
        if command -v xclip &> /dev/null; then
            xclip -o -selection clipboard > "$temp_file"
        elif command -v xsel &> /dev/null; then
            xsel --clipboard --output > "$temp_file"
        elif command -v wl-copy &> /dev/null; then
            wl-paste > "$temp_file"
        else
            echo -e "${RED}Error: No clipboard utility found (xclip, xsel or wl-clipboard)${NC}"
            exit 1
        fi

        input_file="$temp_file"
    fi

    # Checks if input file exists
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}Error: Input file '$input_file' not found${NC}"
        exit 1
    fi

    # Performs the conversion
    echo -e "${GREEN}Converting $input_file to $output_file${NC}"
    
    if [[ "$output_file" =~ / ]]; then
        pandoc -s -o "$output_file" "$input_file"
    else
        pandoc -s -o "$pwd"/"$output_file" "$input_file"
    fi

    # Cleans up temp file if it exists
    if [[ -n "$temp_file" ]] && [[ -f "$temp_file" ]]; then
        rm "$temp_file"
    fi

    cd "$pwd" || true

    echo -e "${GREEN}Conversion complete!${NC}"
}

main "$@"