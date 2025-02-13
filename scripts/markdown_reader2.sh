#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This is a beta version of this shell script capable of reading markdown, formatting it, coloring, and highlighting.
DOCUMENTATION

# ANSI color variables
color_title_bg='\033[48;2;0;128;255m'  # Light blue background
color_title_fg='\033[1;38;2;255;255;255m'  # White text
color_bullet='\033[1;38;2;255;0;0m'  # Red text for bullets
color_code_bg='\033[48;2;50;50;50m'  # Dark background for code
color_code_fg='\033[1;38;2;200;200;200m'  # Light gray text for code
color_reset='\033[0m'  # Reset color

# Function to display help
function show_help {
    echo "Markdown Reader"
    echo "Usage: ${0##*/} <markdown_file>"
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo "This script reads a Markdown file and formats it with ANSI colors."
}

# Check for help option
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Check if file is provided
if [ -z "$1" ]; then
    echo "Error: No file provided."
    show_help
    exit 1
fi

# Check if file exists
if [ ! -f "$1" ]; then
    echo "Error: File not found."
    exit 1
fi

# Read the markdown file
while IFS= read -r line; do
    # Handle titles
    if [[ $line =~ ^(#+)\ (.*) ]]; then
        level=${#BASH_REMATCH[1]}
        title=${BASH_REMATCH[2]}
        echo -e "${color_title_bg}${color_title_fg}$(printf '%*s' $((level * 2)) '' | tr ' ' ' ')$title${color_reset}"
    
    # Handle bullet points
    elif [[ $line =~ ^- ]]; then
        bullet=${line:0:1}
        text=${line:2}
        echo -e "${color_bullet}● $text${color_reset}"
    
    # Handle inline code
    elif [[ $line =~ \`(.*)\` ]]; then
        code=${BASH_REMATCH[1]}
        echo -e "${color_code_bg}${color_code_fg}$code${color_reset}"
    
    # Handle code blocks
    elif [[ $line =~ ^\`\`\` ]]; then
        # Read until the next code block end
        code_block=""
        while IFS= read -r code_line; do
            if [[ $code_line =~ ^\`\`\` ]]; then
                break
            fi
            code_block+="$code_line"$'\n'
        done
        echo -e "${color_code_bg}$(source-highlight -f esc -i <(echo "$code_block"))${color_reset}"
    
    # Handle tables (basic)
    elif [[ $line =~ ^\| ]]; then
        echo -e "${color_title_bg}${color_title_fg}$line${color_reset}"
    
    # Default case
    else
        echo "$line"
    fi
done < "$1"