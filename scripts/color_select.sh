#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script is a powerful tool designed to manage text and background colors in the terminal, 
enabling users to fully customize the appearance of their command-line interfaces. 
By providing an extensive color palette, the script allows users to select from a wide range of colors, 
enhancing the visual appeal and readability of terminal output. It caters to both novice and experienced 
users by offering an interactive interface that simplifies the process of color selection. 
This customization not only improves user experience but also allows for better organization and differentiation of command outputs, 
making it an essential utility for anyone looking to personalize their terminal environment.

Strengths:
1. Interactivity: The script provides an interactive interface for selecting colors and backgrounds, making customization easy.
2. Extensive color palette: Supports a wide range of colors (from 1 to 2989), allowing for detailed personalization.
3. Dependency checking: Verifies if the 'less' command is installed, ensuring the script functions correctly.
4. Usage examples: Provides clear examples of how to apply selected colors, helping users understand how to use them.
5. Intuitive commands: Offers simple and descriptive commands to list and set colors and backgrounds, enhancing user experience.

Capabilities:
- List available colors and their ASCII representations.
- Set text and background colors based on user input.
- Provide a dialog for color and background selection.
- Display clear error messages for invalid inputs. This Bash script is a tool for managing text and background colors in the terminal, 
  allowing users to customize the appearance of their command-line interfaces.

Strengths:
1. Interactivity: The script provides an interactive interface for selecting colors and backgrounds, making customization easy.
2. Extensive color palette: Supports a wide range of colors (from 1 to 2989), allowing for detailed personalization.
3. Dependency checking: Verifies if the 'less' command is installed, ensuring the script functions correctly.
4. Usage examples: Provides clear examples of how to apply selected colors, helping users understand how to use them.
5. Intuitive commands: Offers simple and descriptive commands to list and set colors and backgrounds, enhancing user experience.

Capabilities:
- List available colors and their ASCII representations.
- Set text and background colors based on user input.
- Provide a dialog for color and background selection.
- Display clear error messages for invalid inputs.
DOCUMENTATION

# Color Reset 1
# Colors 2 .. 365
# Backgrounds 366 .. 2989

set -e

source ~/.shell_utils/variables/shell_colors.sh
source ~/.shell_utils/variables/shell_colors_indexed_array.sh

if [ "${shell_color_palette_index[1]}" ]; then
    export color_shell="${shell_color_palette_index[1]}"
fi
if [ "${shell_color_palette_index[1]}" ]; then
    export background_color="${shell_color_palette_index[1]}"
fi

if ! command -v less &> /dev/null; then
    clear -T "${TERM}"
    echo -e "Error: The 'less' command is not installed. Please install 'less' for this script to function properly."
    exit 1
fi

leng_color_index(){
    number=0
    for list in "${shell_color_palette_index[@]}";
        do
            (( number++ )) || true
            echo "${number}"
    done
}

number=0
leng_color=$(leng_color_index | wc -l)

color_list() {
    echo -e "${shell_color_palette[byellow]}Usage:${shell_color_palette[color_off]}\n"
    echo -e "${shell_color_palette[cyan]}Example:${shell_color_palette[color_off]}"
    echo -e "${shell_color_palette[bgreen_on_black]}${0##*/} color 7${shell_color_palette[color_off]}\n"

    for list in "${shell_color_palette_index[@]}";
        do
            (( number++ )) || true
            if [ "${number}" -le "${leng_color}" ]; then
                echo -e "${number})    Color: ${list}'\\${shell_color_palette_index[${number}]}'"
            fi
    done

    echo -e "\n"'Enter "q" for exit'"\n"
}

hex2ansi() {
    ~/.shell_utils/scripts/hex2ansi.sh -h
}

background_list() {
    echo -e "${shell_color_palette[byellow]}Usage:${shell_color_palette[color_off]}\n"
    echo -e "${shell_color_palette[cyan]}Example:${shell_color_palette[color_off]}"
    echo -e "${shell_color_palette[bgreen_on_black]}${0##*/} background 370${shell_color_palette[color_off]}\n"
    for list in "${shell_color_palette_index[@]}";
        do
            (( number++ )) || true
            if [ "${number}" -ge 366 ]; then
                echo -e "${number})    Background: ${list}'\\${shell_color_palette_index[${number}]}'"
            fi
    done

    echo -e "\n"'Enter "q" for exit'"\n"
}

case "${1}" in
    "c"|"color"|"list_color"|"palette_color")
        if [ -z "${2}" ]; then
            clear -T "${TERM}"
            color_list | less -i -R
            echo -e "${shell_color_palette[byellow]}Which color was chosen, from 1 to ${leng_color}?\n"
            read -r set_color_shell
            export color_shell="${shell_color_palette_index["${set_color_shell}"]}"
            echo -e "${shell_color_palette[bblack_on_cyan]}Example of use:${shell_color_palette[color_off]}"
            echo -e "${shell_color_palette[bgreen_on_black]}echo -e \"\\${color_shell}\"${shell_color_palette[color_off]}${color_shell}Text${shell_color_palette[color_off]}${shell_color_palette[bgreen_on_black]}${shell_color_palette[color_off]}"
            exit 0
        elif [[ "${2}" -le "${leng_color}" && "${2}" -gt 0 ]]; then
            export color_shell="${shell_color_palette_index["${2}"]}"
            echo -e "${shell_color_palette[bblack_on_cyan]}Example of use:${shell_color_palette[color_off]}"
            echo -e "${shell_color_palette[bgreen_on_black]}echo -e \"\\${color_shell}\"${shell_color_palette[color_off]}${color_shell}Text${shell_color_palette[color_off]}${shell_color_palette[bgreen_on_black]}${shell_color_palette[color_off]}"
            exit 0
        else
            echo -e "${shell_color_palette[bred]}\"${2}\" is an invalid color choice! Enter a number from 1 to ${leng_color}.\n"
            echo -e "${shell_color_palette[byellow]}Or use \"set\" option to set colors directly!"
            exit 1
        fi

        ;;

    "b"|"background"|"list_background"|"background_color"|"background_palette_color")
        if [ -z "${2}" ]; then
            clear -T "${TERM}"
            background_list | less -i -R
            echo -e "${shell_color_palette[byellow]}Which color was chosen, from 366 to ${leng_color}?\n"
            read -r set_background_shell
            if [[ "${set_background_shell}" -gt "${leng_color}" || "${set_background_shell}" -lt 366 ]]; then
                clear
                echo -e "${shell_color_palette[bred]}\"${set_background_shell}\" is an invalid background choice! Enter a number from 366 to ${leng_color}.\n"
                sleep 3
                clear
                exit 1
            fi
            export background_color="${shell_color_palette_index["${set_background_shell}"]}"
            echo -e "${shell_color_palette[bblack_on_cyan]}Example of use:${shell_color_palette[color_off]}"
            echo -e "${shell_color_palette[bgreen_on_black]}echo -e \"\\${background_color}\"${shell_color_palette[color_off]}${background_color}Text${shell_color_palette[color_off]}${shell_color_palette[bgreen_on_black]}${shell_color_palette[color_off]}"
            exit 0
        elif [[ "${2}" -le "${leng_color}" && "${2}" -ge 366 ]]; then
            export background_color="${shell_color_palette_index["${2}"]}"
            echo -e "${shell_color_palette[bblack_on_cyan]}Example of use:${shell_color_palette[color_off]}"
            echo -e "${shell_color_palette[bgreen_on_black]}echo -e \"\\${background_color}\"${shell_color_palette[color_off]}${background_color}Text${shell_color_palette[color_off]}${shell_color_palette[bgreen_on_black]}${shell_color_palette[color_off]}"
            exit 0
        else
            echo -e "${shell_color_palette[bred]}\"${2}\" is an invalid background choice! Enter a number from 366 to ${leng_color}.\n"
            echo -e "${shell_color_palette[byellow]}Or use \"set\" option to set colors directly!"
            exit 1
        fi

        ;;

    "p"|"prompt"|"dialog")

        if [ -z "${2}" ]; then
            while true; do
                clear -T "${TERM}"
                color_list | less -i -R
                echo -e "${shell_color_palette[byellow]}Which color was chosen, from 1 to ${leng_color}?\n"
                read -r set_color_shell

                if [[ "${set_color_shell}" -le "${leng_color}" && "${set_color_shell}" -gt 0 ]]; then
                    export color_shell="${shell_color_palette_index["${set_color_shell}"]}"
                    break
                else
                    echo -e "${shell_color_palette[bred]}\"${2}\" is an invalid color choice! Enter a number from 1 to ${leng_color}.\n"
                    sleep 1.5
                    clear
                fi
            done
            while true; do
                clear -T "${TERM}"
                background_list | less -i -R
                echo -e "${shell_color_palette[byellow]}Which background was chosen, from 366 to ${leng_color}?\n"
                echo -e "${shell_color_palette[byellow]}Or enter 1 for NO background\n"
                read -r set_background_color

                if [[ "${set_background_color}" -ge 366 && "${set_background_color}" -le "${leng_color}" ]] || [ "${set_background_color}" = 1 ]; then
                    export background_color="${shell_color_palette_index["${set_background_color}"]}"
                    echo -e "${shell_color_palette[bblack_on_cyan]}Example of use:${shell_color_palette[color_off]}"
                    echo -e "${shell_color_palette[bgreen_on_black]}echo -e \"\\${color_shell}\"\"\\${background_color}\"${shell_color_palette[color_off]}${color_shell}${background_color}Text${shell_color_palette[color_off]}${shell_color_palette[bgreen_on_black]}${shell_color_palette[color_off]}"
                    break
                else
                    echo -e "${shell_color_palette[bred]}\"${2}\" is an invalid background choice! Enter a number from 366 to ${leng_color}.\n"
                    sleep 1.5
                    clear
                fi
            done
        else
            echo -e "${shell_color_palette[byellow]}Use \"set\" option to set colors directly!"
            exit 0
        fi
        ;;

    "a"|"ansi"|"ascii"|"color_convert")
        clear -T "${TERM}"
        hex2ansi
        ;;

    "s"|"set")

        if [[ "${2}" && -z "${3}" ]] > /dev/null 2>&1; then
            echo -e "${shell_color_palette[bred]}Usage: ${0##*/} color [from 1 to ${leng_color}]"
            exit 1
        elif [[ "${2}" && "${3}" ]] > /dev/null 2>&1; then

            if [[ "${2}" -le "${leng_color}" && "${2}" -gt 0 ]] > /dev/null 2>&1; then
                export color_shell="${shell_color_palette_index["${2}"]}"
            else
                echo -e "${shell_color_palette[bred]}\"${2}\" is an invalid color choice! Enter a number from 1 to ${leng_color}."
                exit 1
            fi

            if [[ "${3}" -ge 366 && "${3}" -le "${leng_color}" ]] > /dev/null 2>&1; then
                clear -T "${TERM}"
                export background_color="${shell_color_palette_index["${3}"]}"
                echo -e "${shell_color_palette[bblack_on_cyan]}Example of use:${shell_color_palette[color_off]}"
                echo -e "${shell_color_palette[bgreen_on_black]}echo -e \"\\${color_shell}\"\"\\${background_color}\"${shell_color_palette[color_off]}${color_shell}${background_color}Text${shell_color_palette[color_off]}"
            else
                echo -e "${shell_color_palette[bred]}\"${3}\" is an invalid background choice! Enter a number from 366 to ${leng_color}."
                exit 1
            fi
        else
            echo -e "${shell_color_palette[bred]}Usage: ${0##*/} set color background"
            exit 1
        fi

        ;;
    *)
        echo -e "
${shell_color_palette[bblack_on_cyan]}Usage:${shell_color_palette[color_off]}

${shell_color_palette[bgreen_on_black]}${0##*/} <command> [options]${shell_color_palette[color_off]}

${shell_color_palette[bblack_on_cyan]}Available commands:${shell_color_palette[color_off]}

${shell_color_palette[bblack_on_white]}h or help .................. Print this help message.                            ${shell_color_palette[color_off]}
${shell_color_palette[bblack_on_white]}c or color ................. List available colors for shell.                    ${shell_color_palette[color_off]}
${shell_color_palette[bblack_on_white]}c or color [number] ........ Set color of available colors for shell.            ${shell_color_palette[color_off]}
${shell_color_palette[bblack_on_white]}a or ansi .................. Convert RGB or HEX to ANSI Colors with hex2ansi.sh  ${shell_color_palette[color_off]}
${shell_color_palette[bblack_on_white]}b or background ............ List available backgrounds for shell.               ${shell_color_palette[color_off]}
${shell_color_palette[bblack_on_white]}b or background [number] ... Set background of available backgrounds for shell.  ${shell_color_palette[color_off]}
${shell_color_palette[bblack_on_white]}s or set [number] [number] . Set color and background respectively.              ${shell_color_palette[color_off]}
${shell_color_palette[bblack_on_white]}p or prompt ................ Enter the dialog to define the color and background.${shell_color_palette[color_off]}

${shell_color_palette[bblack_on_cyan]}Example:${shell_color_palette[color_off]}
${shell_color_palette[bgreen_on_black]}${0##*/} set 22 367${shell_color_palette[color_off]}

${shell_color_palette[bblack_on_cyan]}After selecting the color, just use:${shell_color_palette[color_off]}
${shell_color_palette[bgreen_on_black]}echo -e \"\\\033[0;35m\" Text${shell_color_palette[color_off]}
"
        exit 0
        ;;
esac

