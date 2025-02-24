#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes
# An enhanced markdown reader combining clean formatting with optional syntax highlighting

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
- Interpret and Remove HTML tags.
- Handles different Markdown syntaxes efficiently.
- Generates a clean and colorful terminal output.
DOCUMENTATION

# Capture Ctrl+C and end children processes
trap 'kill -- -$$; clear; exit 1' SIGINT SIGHUP SIGQUIT SIGABRT SIGALRM

# Color definitions with fallback for TTY sessions
if [[ "${XDG_SESSION_TYPE}" != [Tt][Tt][Yy] ]]; then
    readonly COLOR_TITLE1='\033[1;38;2;255;128;0;48;2;40;40;40m'        # Orange text on dark gray
    readonly COLOR_TITLE2='\033[1;38;2;255;192;0;48;2;35;35;35m'        # Yellow text on dark gray
    readonly COLOR_TITLE3='\033[1;38;2;0;255;127;48;2;30;30;30m'        # Spring green on dark gray
    readonly COLOR_TITLE4='\033[1;38;2;135;206;250;48;2;25;25;25m'      # Light blue on dark gray
    readonly COLOR_TITLE5='\033[1;38;2;255;105;180;48;2;20;20;20m'      # Hot pink on dark gray
    readonly COLOR_TITLE6='\033[1;38;2;147;112;219;48;2;15;15;15m'      # Purple on dark gray
    #readonly COLOR_CODE='\033[1;38;2;173;216;230m'                     # Light blue for inline code
    #readonly COLOR_CODE='\033[38;2;212;229;16;48;2;114;99;96m'               
    readonly COLOR_CODE='\033[38;2;129;250;72;48;2;108;94;87m'               
    #readonly COLOR_BULLET='\033[1;38;2;50;205;50m'                     # Lime green for bullets
    readonly COLOR_BULLET='\033[1;3;38;2;201;215;176m'                      
    readonly COLOR_TABLE_HEADER='\033[1;38;2;0;191;255;48;2;50;50;50m'  # Sky blue for table headers
    readonly COLOR_LINK='\033[1;38;2;0;255;255m'                        # Cyan for links
    readonly GRAY='\033[1;38;2;156;156;156m'                            # Fill line
    readonly COLOR_BOLD='\033[1;38;2;255;215;0m'
    #readonly INLINE='\033[38;2;0;243;255;48;2;14;69;77m'
else
    readonly COLOR_TITLE1='\033[1;38;5;214;48;2;40;40;40m'              # Orange text on dark gray
    readonly COLOR_TITLE2='\033[1;38;5;226;48;2;35;35;35m'              # Yellow text on dark gray
    readonly COLOR_TITLE3='\033[1;38;5;82;48;2;30;30;30m'               # Spring green on dark gray
    readonly COLOR_TITLE4='\033[1;38;5;153;48;2;25;25;25m'              # Light blue on dark gray
    readonly COLOR_TITLE5='\033[1;38;5;213;48;2;20;20;20m'              # Hot pink on dark gray
    readonly COLOR_TITLE6='\033[1;38;5;99;48;2;15;15;15m'               # Purple on dark gray
    #readonly COLOR_CODE='\033[1;38;5;153m'                             # Light blue for inline code
    #readonly COLOR_CODE='\033[38;5;184;48;5;102m'                        
    readonly COLOR_CODE='\033[38;5;155;48;5;241m'                        
    #readonly COLOR_BULLET='\033[1;38;5;46m'                            # Lime green for bullets
    readonly COLOR_BULLET='\033[1;3;38;5;187m'                             
    readonly COLOR_TABLE_HEADER='\033[1;38;5;81;48;2;50;50;50m'         # Sky blue for table headers
    readonly COLOR_LINK='\033[1;38;5;51m'                               # Cyan for links
    readonly GRAY='\033[1;38;5;244m'                                    # Fill line
    readonly COLOR_BOLD='\033[1;38;5;220m'
    #readonly INLINE='\033[38;5;51;48;5;24m'
fi

readonly RED='\033[1;31m'                                               # Red color
readonly YELLOW='\033[1;33m'                                            # Yellow color
readonly UNDERLINE='\033[1;4;38;5;187m'                                 # Underline
readonly COLOR_RESET='\033[0m'                                          # Reset color

declare -A MESSAGES

# Check the system language and assign messages accordingly
update_variables() {
    if [[ "${LANG,,}" =~ pt_ ]]; then
        MESSAGES=(
            ["please_install"]="${RED}Erro: Dependências ausentes: ${YELLOW}${missing_deps[*]}\n${RED}Por favor, instale os pacotes necessários e tente novamente.${COLOR_RESET}"
            ["not_found"]="${RED}Arquivo não encontrado: ${input_file}${COLOR_RESET}\n"
            ["no_input"]="${RED}Erro: Nenhum arquivo de entrada especificado${COLOR_RESET}\n"
            ["help"]=$(
        cat << EOF
Leitor de Markdown - Um analisador e formatador de Markdown completo

Uso: ${0##*/} [OPÇÕES] arquivo

Opções:
-h, --help             Exibir esta mensagem de ajuda
-nl, --no-less         Desativar o modo de paginação com less
-nh, --no-hl           Desativar realce de sintaxe para blocos de código
-ic, --invert-color    Ativa a inversão de cores

Exemplos:
${0##*/} documento.md
${0##*/} --no-hl README.md

Recursos do Markdown suportados:
• Títulos (níveis 1-6)
• Blocos de código com realce de sintaxe
• Código inline
• Listas não ordenadas
• Regras horizontais
• Quebras de linha em HTML
• HTML underline e mais
EOF
            )
        )
    elif [[ "${LANG,,}" =~ es_ ]]; then
        MESSAGES=(
            ["please_install"]="${RED}Error: Dependencias faltantes: ${YELLOW}${missing_deps[*]}\n${RED}Por favor, instala los paquetes necesarios e inténtalo de nuevo.${COLOR_RESET}"
            ["not_found"]="${RED}Archivo no encontrado: ${input_file}${COLOR_RESET}\n"
            ["no_input"]="${RED}Error: Ningún archivo de entrada especificado${COLOR_RESET}\n"
            ["help"]=$(
        cat << EOF
Lector de Markdown - Un analizador y formateador de Markdown completo

Uso: ${0##*/} [OPCIONES] archivo

Opciones:
-h, --help             Mostrar este mensaje de ayuda
-nl, --no-less         Desactivar el modo de paginación con less
-nh, --no-hl           Desactivar resaltado de sintaxis para bloques de código
-ic, --invert-color    Activa la inversión de colores

Ejemplos:
${0##*/} documento.md
${0##*/} --no-hl README.md

Características de Markdown compatibles:
• Encabezados (niveles 1-6)
• Bloques de código con resaltado de sintaxis
• Código en línea
• Listas no ordenadas
• Reglas horizontales
• Saltos de línea en HTML
• Subrayado en HTML y más
EOF
            )
        )
    else
        MESSAGES=(
            ["please_install"]="${RED}Error: Missing dependencies: ${YELLOW}${missing_deps[*]}\n${RED}Please install the required packages and try again.${COLOR_RESET}"
            ["not_found"]="${RED}File not found: $input_file${COLOR_RESET}\n"
            ["no_input"]="${RED}Error: No input file specified${COLOR_RESET}\n"
            ["help"]=$(
        cat << EOF
Markdown Reader - A comprehensive markdown parser and formatter

Usage: ${0##*/} [OPTIONS] file

Options:
-h, --help             Show this help message
-nl, --no-less         Disable pager mode with less
-nh, --no-hl           Disable syntax highlighting for code blocks
-ic, --invert-color    Enables color inversion

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
• HTML underline and more
EOF
            )
        )
    fi
}


# Check for required dependencies
check_dependencies() {
    local os=$(uname -o)
    local missing_deps=()
    local count=0
    for cmd in source-highlight less; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
            [[ ${missing_deps[count]} == "source-highlight" ]] && [[ -n "$TERMUX_VERSION" ]] && \
            [[ "$os" =~ "Android" ]] && unset 'missing_deps[-1]' && export NO_HIGHLIGHT=1
            ((count++)) || true
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        update_variables
        echo -e "${MESSAGES[please_install]}"
        exit 1
    fi
}

# Function for syntax highlighting using source-highlight
highlight_code() {
    local content="$1"
    local lang="$2"
    
    if [ -n "$NO_HIGHLIGHT" ]; then
        printf "${COLOR_CODE}%s${COLOR_RESET}\n" "$content"
        return
    fi
    
    if [ -z "$lang" ]; then
        lang="bash"  # Default language
    fi
    
    # Create temporary file for source-highlight
    local temp_file=$(mktemp)
    echo "$content" > "$temp_file"
    
    # Attempt syntax highlighting with specified language
    source-highlight -f esc -s "$lang" -i "$temp_file" 2>/dev/null || \
        printf "${COLOR_CODE}%s${COLOR_RESET}\n" "$content"
    
    rm -f "$temp_file"
}

# Function to generate line separator
line_shell() {
    echo -e "${GRAY}${line//\-\-\-/}$(seq -s '━' "$(tput cols)" | tr -d '[:digit:]')"
}

# Function to fill background with text
fill_background() {
    local color="$1"
    local text="$2"
    local cols=$(tput cols)
    printf "${color}%-*s${COLOR_RESET}\n" "$cols" "$text"
}

# Function to centralize text
centralize_text() {
    local color="$1"   
    local text="$2"
    local cols=$(tput cols)
    local text_len=${#text}
    local padding=$(( (cols - text_len) / 2 ))
    printf "${color}%*s%s%*s${COLOR_RESET}\n" "$padding" "" "$text" "$padding" ""
}

detect_first_color() {
    # Using AWK to capture any sequence anxe that starts with \ 033
    first_color=$(echo -e "$line" | awk '{match($0, /\033\[[0-9;]*m/, arr); print arr[0]}')
    export first_color="${COLOR_RESET}${first_color}"
}


# Improved help function
show_help() {
    update_variables
    printf '%s\n' "${MESSAGES[help]}"
    exit 0
}

# 🎯 When a command like 'less' is called directly in the script, it can become the foreground process, 
# making it harder for the 'trap' to control it. However, when the command is inside a function, 
# the script maintains the correct process hierarchy, allowing the 'trap' to control everything with 'pkill -P $$' or 'kill -- -$$'.
pid_less() {
    less "$@" &
    LESS_PID=$!
    wait $LESS_PID
}

# Process the markdown file
process_markdown() {
    local input_file="$1"
    local in_code_block=false
    local code_block_content=""
    local code_block_lang=""

    [[ "$NO_LESS" != 1 ]] && pipe='pid_less -R -i'
    [[ "$NO_LESS" == 1 ]] && pipe='cat'
    read -r -a cmd <<< "$pipe"
    
    # Check if file exists
    if [[ ! -f "$input_file" ]]; then
        update_variables
        echo -e "${MESSAGES[not_found]}"
        show_help
    fi
    
    # Read and process the markdown file line by line
    while IFS= read -r line || [ -n "$line" ]; do

        # Italic HTML tag
        if [[ "$line" =~ \<i\>([^<]+)\<\/i\> ]]; then #[[ "$line" =~ \<i\>.*\<\/i\> ]] || 
            detect_first_color
            line=$(echo -e "$line" | awk -v highlight="${COLOR_BULLET}" -v reset="${first_color}" '{gsub(/<i>([^<]*)<\/i>/, "<i>" highlight "&" reset "</i>")}1')
        elif [[ "$line" =~ \<em\>([^<]+)\<\/em\> ]]; then #[[ "$line" =~ \<em\>.*\<\/em\> ]] ||
            detect_first_color
            line=$(echo -e "$line" | awk -v highlight="${COLOR_BULLET}" -v reset="${first_color}" '{gsub(/<em>([^<]*)<\/em>/, "<em>" highlight "&" reset "</em>")}1')
        fi

        # Underline HTML tag
        if [[ "$line" =~ \<u\>([^<]+)\<\/u\> ]]; then #[[ "$line" =~ \<u\>.*\<\/u\> ]] ||
            detect_first_color
            line=$(echo -e "$line" | awk -v highlight="${UNDERLINE}" -v reset="${first_color}" '{gsub(/<u>([^<]*)<\/u>/, "<u>" highlight "&" reset "</u>")}1')
        fi

        # Remove HTML tags
        if [[ "$line" =~ \*\*\<[^*]+\>\*\* ]] || [[ "$line" =~ \"\<[^*]+\>\" ]] || [[ "$line" =~ \'\<[^*]+\>\' ]] || [[ "$line" =~ \`\<[^*]+\>\` ]]; then
            true
        elif [[ "$line" =~ (.*)\<[^*]+\>(.*) ]]; then
            line=$(echo -e "$line" | sed 's/<[^>]*>//g')
            # line="${line//<br>/}"
            # line="${line//<\/br>/}"
        fi

        # Handle code blocks
        if [[ "$line" =~ \`\`\`([^\`]+)\`\`\` ]]; then
            detect_first_color
            line=$(echo -e "$line" | sed -E "s/\`\`\`/'/g")
            line=$(echo -e "$line" | awk -v highlight="${COLOR_CODE}" -v reset="${first_color}" '{gsub(/'\''([^'\'']*)'\''/, highlight "&" reset)}1')
        elif [[ "$line" =~ ^(\`\`\`) ]]; then
            if [ "$in_code_block" = false ]; then
                in_code_block=true
                code_block_lang=$(echo -e "$line" | sed 's/^```//')
            else
                highlight_code "$code_block_content" "$code_block_lang"
                in_code_block=false
                code_block_content=""
                code_block_lang=""
            fi
            continue
        fi
        
        if [ "$in_code_block" = true ]; then
            [ -n "$code_block_content" ] && code_block_content+=$'\n'
            code_block_content+="$line"
            continue
        fi

        # Handle Links
        if [[ "$line" =~ \[([^\]]+)\]\(([^\)]+)\) ]]; then
            detect_first_color
            line=$(echo -e "$line" | sed -e 's/\[[^]]*\]//g' -e 's/\!(//g' -e 's/(//g' -e 's/)//g' -e 's/\[//g' -e 's/\]//g')
            line=$(echo -e "$line" | awk -v link_color="${COLOR_LINK}" -v reset="${first_color}" '{gsub(/https?:\/\/[^ ]+/, link_color "&" reset); print $0}')
        fi

        # Bold Text
        if [[ "$line" =~ \*\*([^*]+)\*\* ]]; then
            detect_first_color
            line=$(echo -e "$line" | awk -v bold="${COLOR_BOLD}" -v reset="${first_color}" '{gsub(/\*\*([^*]+)\*\*/, bold "&" reset)}1' | sed -E "s/\*\*//g")
        fi

        # Handle Lists (bullets or numbered)
        if [[ "$line" =~ ^\* ]]; then
            detect_first_color
            line=$(echo -e "${COLOR_BULLET}${line}${first_color}")
        elif [[ "$line" =~ ^\-\  ]]; then
            detect_first_color
            line=$(echo -e "${COLOR_BULLET}${line}${first_color}")
        elif [[ "$line" =~ ^[0-9]+\.\  ]]; then
            detect_first_color
            line=$(echo -e "${COLOR_BULLET}${line}${first_color}")
        elif [[ "$line" =~ ^\ \* ]]; then
            detect_first_color
            line=$(echo -e "${COLOR_BULLET}${line}${first_color}")
        elif [[ "$line" =~ ^\ \-\  ]]; then
            detect_first_color
            line=$(echo -e "${COLOR_BULLET}${line}${first_color}")
        elif [[ "$line" =~ ^\ [0-9]+\.\  ]]; then
            detect_first_color
            line=$(echo -e "${COLOR_BULLET}${line}${first_color}")
        fi

        # Handle Inline Code
        if [[ "$line" =~ \`.*\` ]] || [[ "$line" =~ (.*)(\`[^\`]+\`)(.*) ]]; then
            detect_first_color
            line=$(echo -e "$line" | awk -v highlight="${COLOR_CODE}" -v reset="${first_color}" '{gsub(/`([^`]+)`/, highlight "&" reset)}1' | sed -E "s/\`/'/g")
        fi

        # Handle Inline Code
        if [[ "$line" =~ \*([^*]+)\.\* ]] || [[ "$line" =~ \*\.([^*]+)\.\* ]] || [[ "$line" =~ \*\.([^*]+)\* ]]; then
            true
        elif [[ "$line" =~ \*([^*]+)\* ]]; then
            detect_first_color
            line=$(echo -e "$line" | awk -v bold="${COLOR_BULLET}" -v reset="${first_color}" '{gsub(/\*([^*]+)\*/, bold "&" reset)}1') #| sed -E "s/\*//g")
        fi

        # Handle Titles (Headers)
        if [[ "$line" =~ ^######[^#](.+)$ ]]; then
            detect_first_color
            line=$(echo -e "${COLOR_TITLE6}${BASH_REMATCH[1]}${first_color}")   # Title level 6
        elif [[ "$line" =~ ^#####[^#](.+)$ ]]; then
            detect_first_color
            line=$(echo -e "${COLOR_TITLE5}${BASH_REMATCH[1]}${first_color}")   # Title level 5
        elif [[ "$line" =~ ^####[^#](.+)$ ]]; then
            detect_first_color
            line=$(echo -e "${COLOR_TITLE4}${BASH_REMATCH[1]}${first_color}")   # Title level 4
        elif [[ "$line" =~ ^###[^#](.+)$ ]]; then
            detect_first_color
            line=$(echo -e "${COLOR_TITLE3}${BASH_REMATCH[1]}${first_color}")   # Title level 3
        elif [[ "$line" =~ ^##[^#](.+)$ ]]; then
            line=$(fill_background "${COLOR_TITLE2}" "${BASH_REMATCH[1]}")      # Title level 2
        elif [[ "$line" =~ ^#[^#](.+)$ ]]; then
            line=$(centralize_text "${COLOR_TITLE1}" "${BASH_REMATCH[1]}")      # Title level 1
        fi

        #if [[ "$line" =~ (.+)######[^#](.+)$ ]]; then
        if [[ "$line" =~ (.*)######(.*) ]]; then
            detect_first_color
            line=$(echo -e "$line" | awk -v bold="${COLOR_TITLE6}" -v reset="${first_color}" '{gsub(/######([^#]+)/, bold "&" reset)}1' | sed -E "s/######//g")
        elif [[ "$line" =~ (.*)#####(.*) ]]; then
            detect_first_color
            line=$(echo -e "$line" | awk -v bold="${COLOR_TITLE5}" -v reset="${first_color}" '{gsub(/#####([^#]+)/, bold "&" reset)}1' | sed -E "s/#####//g")
        elif [[ "$line" =~ (.*)####(.*) ]]; then
            detect_first_color
            line=$(echo -e "$line" | awk -v bold="${COLOR_TITLE4}" -v reset="${first_color}" '{gsub(/####([^#]+)/, bold "&" reset)}1' | sed -E "s/####//g")
        elif [[ "$line" =~ (.*)###(.*) ]]; then
            detect_first_color
            line=$(echo -e "$line" | awk -v bold="${COLOR_TITLE3}" -v reset="${first_color}" '{gsub(/###([^#]+)/, bold "&" reset)}1' | sed -E "s/###//g")
        fi

        # Handle Horizontal Rule
        if [[ "$line" =~ ^\-\-\- ]]; then
            line_shell  # Call line generation function
        # Handle Blockquotes
        elif [[ "$line" =~ ^\> ]]; then
            echo -e "${COLOR_TITLE3}${line}${COLOR_RESET}"
        # Block code
        elif [[ "$line" =~ ^\ {3} ]]; then
            echo -e "${COLOR_CODE}${line//\   /}${COLOR_RESET}"
        # Handle Tables
        elif [[ "$line" =~ ^\| ]]; then
            echo -e "${COLOR_TABLE_HEADER}${line}${COLOR_RESET}"
        else
            echo -e "$line"    # Regular text
        fi

    done < "$input_file" | "${cmd[@]}"
}

# Main function
main() {
    local MARKDOWN_FILE=""
    export NO_HIGHLIGHT=${NO_HIGHLIGHT:-""}
    export NO_LESS
    
    # Parse command line options
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                ;;
            -nl|--no-less)
                NO_LESS=${NO_LESS:-1}
                shift
                ;;
            -ic|--invert-color)
                export LESS='-p .*'
                NO_LESS=0
                shift
                ;;
            -nh|--no-hl)
                NO_HIGHLIGHT=1
                shift
                ;;
            *)
                MARKDOWN_FILE="$1"
                shift
                ;;
        esac
    done
    
    # Check if file is provided
    if [ -z "$MARKDOWN_FILE" ]; then
        update_variables
        echo -e "${MESSAGES[no_input]}"
        show_help
    fi
    
    # Check dependencies if syntax highlighting is enabled
    if [ -z "$NO_HIGHLIGHT" ]; then
        check_dependencies
    fi
    
    # Process the markdown file
    process_markdown "$MARKDOWN_FILE"
}

# Call main with all arguments and pipe to less with raw output
main "$@"