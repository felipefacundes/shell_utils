#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Converts hex or RGB colors to ANSI terminal color codes
DOCUMENTATION

# Function to validate and convert color input
convert_color() {
    local color="$1"
    local r g b

    # Check if input is valid RGB format with comma or semicolon
    if echo "$color" | awk '/^[0-9]+[,;][0-9]+[,;][0-9]+$/ {exit 0} {exit 1}'; then
        # Replace semicolon with comma if needed
        color=$(echo "$color" | tr ';' ',')
        IFS=',' read -r r g b <<< "$color"
    else
        # Remove # if present
        color="${color#\#}"

        # Validate hex color length
        if [[ ${#color} -ne 6 ]]; then
            echo -e "\033[1;31mError: Invalid hex color. Must be 6 characters long.\033[0m" >&2
            exit 1
        fi

        # Convert hex to RGB
        r=$(printf "%d" 0x"${color:0:2}")
        g=$(printf "%d" 0x"${color:2:2}")
        b=$(printf "%d" 0x"${color:4:2}")
    fi

    # Validate RGB values
    for val in "$r" "$g" "$b"; do
        if [[ $val -lt 0 || $val -gt 255 ]]; then
            echo -e "\033[1;31mError: RGB values must be between 0 and 255.\033[0m" >&2
            exit 1
        fi
    done

    echo "$r" "$g" "$b"
}

# Help function
show_help() {
    cat <<EOF
Usage: ${0##*/} [OPTIONS] <color>

Options:
  -f, -t, --text    Set text color
  -b, --background  Set background color
  -h, --help        Show this help message

Color formats:
  Hexadecimal: 5B7E7E or '#5B7E7E'
  RGB: 91,126,126 or '91;126;126'

Examples:
  ${0##*/} -t 5B7E7E           # Text color
  ${0##*/} -b 5B7E7E           # Background color
  ${0##*/} -t 5B7E7E -b FFFFFF # Text and background colors
EOF
}

# Parse arguments
text_color=""
background_color=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--text| -f|--foreground)
            shift
            text_color=$(convert_color "$1")
            ;;
        -b|--background)
            shift
            background_color=$(convert_color "$1")
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "\033[1;31mUnknown option:\033[0m $1" >&2
            show_help
            exit 1
            ;;
    esac
    shift
done

# Generate ANSI color code
if [[ -n "$text_color" && -n "$background_color" ]]; then
    # Both text and background colors
    read -r tr tg tb <<< "$text_color"
    read -r br bg bb <<< "$background_color"
    echo -e "\033[38;2;$tr;$tg;$tb;48;2;$br;$bg;${bb}mHere is your ANSI foreground and background color:\033[0m\n"
    echo -e "\\\033[38;2;$tr;$tg;$tb;48;2;$br;$bg;${bb}m"
elif [[ -n "$text_color" ]]; then
    # Text color only
    read -r tr tg tb <<< "$text_color"
    echo -e "\033[38;2;$tr;$tg;${tb}mHere is your ANSI foreground color:\033[0m\n"
    echo -e "\\\033[38;2;$tr;$tg;${tb}m"
elif [[ -n "$background_color" ]]; then
    # Background color only
    read -r br bg bb <<< "$background_color"
    echo -e "\033[48;2;$br;$bg;${bb}mHere is your ANSI background color:\033[0m\n"
    echo -e "\\\033[48;2;$br;$bg;${bb}m"
else
    echo -e "\033[1;31mError: No color specified\033[0m" >&2
    show_help
    exit 1
fi