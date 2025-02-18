#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script is a Markdown reader that processes and displays the content of a Markdown file with syntax highlighting and color 
formatting in the terminal. It is designed to handle various Markdown elements, including headers, lists, blockquotes, 
inline code, code blocks, tables, hyperlinks, and horizontal rules. 

Key strengths:
1. Supports multiple header levels with different colors.
2. Highlights inline code and code blocks for readability.
3. Supports both bullet and numbered lists with color formatting.
4. Processes Markdown tables with color for headers.
5. Provides hyperlink rendering, showing only the link in cyan.
6. Replaces horizontal rule indicators with a visual line.

Capacities:
- Removes <br>, <code> and <pre> tags.
- Handles different Markdown syntaxes efficiently.
- Generates a clean and colorful terminal output.
DOCUMENTATION

# Color variables for markdown formatting
if [[ "${XDG_SESSION_TYPE}" != [Tt][Tt][Yy] ]]; then
    readonly COLOR_TITLE1='\033[1;38;2;255;128;0;48;2;40;40;40m'        # Orange text on dark gray
    readonly COLOR_TITLE2='\033[1;38;2;255;192;0;48;2;35;35;35m'        # Yellow text on dark gray
    readonly COLOR_TITLE3='\033[1;38;2;0;255;127;48;2;30;30;30m'        # Spring green on dark gray
    readonly COLOR_TITLE4='\033[1;38;2;135;206;250;48;2;25;25;25m'      # Light blue on dark gray
    readonly COLOR_TITLE5='\033[1;38;2;255;105;180;48;2;20;20;20m'      # Hot pink on dark gray
    readonly COLOR_TITLE6='\033[1;38;2;147;112;219;48;2;15;15;15m'      # Purple on dark gray
    readonly COLOR_CODE='\033[1;38;2;173;216;230m'                      # Light blue for inline code
    readonly COLOR_BULLET='\033[1;38;2;50;205;50m'                      # Lime green for bullets
    readonly COLOR_TABLE_HEADER='\033[1;38;2;0;191;255;48;2;50;50;50m'  # Sky blue for table headers
    readonly COLOR_LINK='\033[1;38;2;0;255;255m'                        # Cyan for links
    readonly GRAY='\033[1;38;2;156;156;156m'                            # Fill line
    readonly COLOR_RESET='\033[0m'                                      # Reset color
else
    readonly COLOR_TITLE1='\033[1;38;5;214;48;2;40;40;40m'              # Orange text on dark gray
    readonly COLOR_TITLE2='\033[1;38;5;226;48;2;35;35;35m'              # Yellow text on dark gray
    readonly COLOR_TITLE3='\033[1;38;5;82;48;2;30;30;30m'               # Spring green on dark gray
    readonly COLOR_TITLE4='\033[1;38;5;153;48;2;25;25;25m'              # Light blue on dark gray
    readonly COLOR_TITLE5='\033[1;38;5;213;48;2;20;20;20m'              # Hot pink on dark gray
    readonly COLOR_TITLE6='\033[1;38;5;99;48;2;15;15;15m'               # Purple on dark gray
    readonly COLOR_CODE='\033[1;38;5;153m'                              # Light blue for inline code
    readonly COLOR_BULLET='\033[1;38;5;46m'                             # Lime green for bullets
    readonly COLOR_TABLE_HEADER='\033[1;38;5;81;48;2;50;50;50m'         # Sky blue for table headers
    readonly COLOR_LINK='\033[1;38;5;51m'                               # Cyan for links
    readonly GRAY='\033[1;38;5;244m'                                    # Fill line
    readonly COLOR_RESET='\033[0m'                                      # Reset color
fi


# Function for syntax highlighting using source-highlight
highlight_code() {
    echo "$1" | source-highlight -oSTDOUT -s bash -i -
}

# Function to generate line separator
function line_shell {
    echo -e "${GRAY}$(seq -s '━' "$(tput cols)" | tr -d '[:digit:]')"
}

function fill_background {
    local color="$1"
    local text="$2"
    local cols=$(tput cols)    # Get the width of the terminal

    # Build the line with colorful background
    printf "${color}%-*s\033[0m\n" "$cols" "$text"
}

function centralize_text {
    local color="$1"   
    local text="$2"
    local cols=$(tput cols)                        # Get the width of the terminal
    local text_len=${#text}                        # Text length
    local padding=$(( (cols - text_len) / 2 ))     # Calculate spaces to centralize

    # Build the line with colorful background and centralized text
    printf "${color}%*s%s%*s\033[0m\n" "$padding" "" "$text" "$padding" ""
}

# Process the markdown file
process_markdown() {
    local input_file="$1"
    
    # Check if file exists
    if [[ ! -f "$input_file" ]]; then
        echo "File not found: $input_file"
        exit 1
    fi
    
    # Read and process the markdown file line by line
    while IFS= read -r line; do
        # Remove <br> and </br> tags
        line="${line//<br>/}"
        line="${line//<\/br>/}"
        line="${line//<br\/>/}"
        
        # Remove <pre> and </pre> tags
        line="${line//<pre>/}"
        line="${line//<\/pre>/}"
        line="${line//<pre\/>/}"

        # Remove <code> and </code> tags
        line="${line//<code>/}"
        line="${line//<\/code>/}"
        line="${line//<code\/>/}"
        
        # Handle Titles (Headers)
        if [[ $line =~ ^#[^#](.+)$ ]]; then
            #echo -e "${COLOR_TITLE1}${BASH_REMATCH[1]}${COLOR_RESET}"  # Title level 1
            centralize_text "${COLOR_TITLE1}" "${BASH_REMATCH[1]}"      # Title level 1
        elif [[ $line =~ ^##[^#](.+)$ ]]; then
            #echo -e "${COLOR_TITLE2}${BASH_REMATCH[1]}${COLOR_RESET}"  # Title level 2
            fill_background "${COLOR_TITLE2}" "${BASH_REMATCH[1]}"      # Title level 2
        elif [[ $line =~ ^###[^#](.+)$ ]]; then
            echo -e "${COLOR_TITLE3}${BASH_REMATCH[1]}${COLOR_RESET}"   # Title level 3
        elif [[ $line =~ ^####[^#](.+)$ ]]; then
            echo -e "${COLOR_TITLE4}${BASH_REMATCH[1]}${COLOR_RESET}"   # Title level 4
        elif [[ $line =~ ^#####[^#](.+)$ ]]; then
            echo -e "${COLOR_TITLE5}${BASH_REMATCH[1]}${COLOR_RESET}"   # Title level 5
        elif [[ $line =~ ^######[^#](.+)$ ]]; then
            echo -e "${COLOR_TITLE6}${BASH_REMATCH[1]}${COLOR_RESET}"   # Title level 6
        # Handle Lists (bullets or numbered)
        elif [[ "$line" =~ ^\* ]]; then
            echo -e "${COLOR_BULLET}${line//* /} ${COLOR_RESET}"   # Bullet points
        elif [[ "$line" =~ ^[0-9]+\.\  ]]; then
            echo -e "${COLOR_BULLET}${line//\./} ${COLOR_RESET}"   # Numbered list
        # Handle Blockquotes
        elif [[ "$line" =~ ^\> ]]; then
            echo -e "${COLOR_TITLE3}> ${line//\> /}${COLOR_RESET}" # Blockquote
        # Handle Inline Code
        elif [[ "$line" =~ \`.*\` ]]; then
            echo -e "${COLOR_CODE}${line//\`/}${COLOR_RESET}"      # Inline code
        # Handle Code Blocks
        elif [[ "$line" =~ ^\`\`\` ]]; then
            code_block=true
            echo -n "${COLOR_RESET}"
        elif [[ "$code_block" == true && "$line" =~ ^\`\`\` ]]; then
            code_block=false
            echo -e "${COLOR_RESET}"
        elif [[ "$code_block" == true ]]; then
            highlight_code "$line"  # Call function for syntax highlighting
        # Handle Tables
        elif [[ "$line" =~ ^\| ]]; then
            # Color table header
            echo -e "${COLOR_TABLE_HEADER}${line}${COLOR_RESET}"
        # Handle Links
        elif [[ "$line" =~ \[([^\]]+)\]\(([^\)]+)\) ]]; then
            echo -e "${COLOR_LINK}${BASH_REMATCH[2]}${COLOR_RESET}"  # Print only link in cyan
        # Handle Horizontal Rule
        elif [[ "$line" =~ ^\-\-\- ]]; then
            line_shell  # Call line generation function
        else
            echo "$line"   # Regular text
        fi
    done < "$input_file"
}

# Help function
show_help() {
    echo -e "${COLOR_TITLE3}Markdown Reader Help${COLOR_RESET}"
    echo "Usage: $0 <file>"
    echo
    echo "This script reads a markdown file and displays it with syntax highlighting and proper color formatting."
    echo
    echo "Markdown Formatting Supported:"
    echo " - Headers: #, ##, ###, ####, #####"
    echo " - Lists: Bullet points (*), Numbered lists"
    echo " - Blockquotes (>)"
    echo " - Inline code (e.g. \`code\`)"
    echo " - Code blocks (e.g. \`\`\`)"
    echo " - Tables (|)"
    echo " - Links: [text](link)"
    echo " - Horizontal rule (---)"
    echo
    echo "Options:"
    echo " -h, --help  Show this help message"
}

# Main function
main() {
    # If no file is provided or help option is given
    if [[ $# -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then
        show_help
        exit 0
    fi

    # Process the given markdown file
    process_markdown "$1"
}

# Call main
main "$@" | less -R -i