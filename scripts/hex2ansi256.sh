#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Converts hex or RGB colors to ANSI 256 color codes.

- Function rgb_to_ansi256: Converts RGB values to the nearest ANSI 256 color code by calculating the Euclidean distance between the provided color 
and the available colors in the ANSI 256 color space (considering the 6x6x6 color cube for colors and the grayscale range from 232 to 255).

- Function convert_color: Converts hexadecimal or RGB color values to RGB values, performing format and value validation.

- ANSI 256 Code Generation: After conversion, the script generates the corresponding ANSI 256 color code and displays the color in the terminal.
DOCUMENTATION

# Function to convert RGB to nearest ANSI 256 color code
rgb_to_ansi256() {
    local r=$1 g=$2 b=$3

    # Define the color space for ANSI 256 (6x6x6 cube and grayscale)
    # Create the ANSI 256 color palette (6x6x6 color cube + grayscale)
    local min_distance=999999
    local closest_color=0

    # Loop through 6x6x6 color cube
    for r2 in {0..5}; do
        for g2 in {0..5}; do
            for b2 in {0..5}; do
                # Calculate the RGB values for this cube point
                local cube_r=$((r2 * 51))
                local cube_g=$((g2 * 51))
                local cube_b=$((b2 * 51))

                # Calculate the Euclidean distance between the two colors
                local distance=$(( (cube_r - r) ** 2 + (cube_g - g) ** 2 + (cube_b - b) ** 2 ))

                # If this is the closest color, update the closest color
                if (( distance < min_distance )); then
                    min_distance=$distance
                    closest_color=$((16 + r2 * 36 + g2 * 6 + b2))
                fi
            done
        done
    done

    # Loop through grayscale colors (232-255)
    for i in {0..23}; do
        local gray=$((i * 10 + 8))
        local distance=$(( (gray - r) ** 2 + (gray - g) ** 2 + (gray - b) ** 2 ))

        if (( distance < min_distance )); then
            min_distance=$distance
            closest_color=$((232 + i))
        fi
    done

    echo "$closest_color"
}

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
  -t, --text       Set text color
  -b, --background Set background color
  -h, --help       Show this help message

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
        -t|--text)
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

# Convert RGB to ANSI 256
if [[ -n "$text_color" && -n "$background_color" ]]; then
    # Both text and background colors
    read -r tr tg tb <<< "$text_color"
    read -r br bg bb <<< "$background_color"
    text_color_256=$(rgb_to_ansi256 "$tr" "$tg" "$tb")
    background_color_256=$(rgb_to_ansi256 "$br" "$bg" "$bb")
    echo -e "\033[38;5;${text_color_256};48;5;${background_color_256}mHere is your ANSI foreground and background color:\033[0m\n"
    echo -e "\\\033[38;5;${text_color_256};48;5;${background_color_256}m"
elif [[ -n "$text_color" ]]; then
    # Text color only
    read -r tr tg tb <<< "$text_color"
    text_color_256=$(rgb_to_ansi256 "$tr" "$tg" "$tb")
    echo -e "\033[38;5;${text_color_256}mHere is your ANSI foreground color:\033[0m\n"
    echo -e "\\\033[38;5;${text_color_256}m"
elif [[ -n "$background_color" ]]; then
    # Background color only
    read -r br bg bb <<< "$background_color"
    background_color_256=$(rgb_to_ansi256 "$br" "$bg" "$bb")
    echo -e "\033[48;5;${background_color_256}mHere is your ANSI background color:\033[0m\n"
    echo -e "\\\033[48;5;${background_color_256}m"
else
    echo -e "\033[1;31mError: No color specified\033[0m" >&2
    show_help
    exit 1
fi
