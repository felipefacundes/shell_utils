#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
The provided script is a Bash script designed to manage and display ASCII art themes in a terminal environment. 
Its primary purpose is to allow users to select and customize ASCII art themes and colors for better visual representation in the terminal. 

Key Features:
1. Configuration Management: Automatically creates a configuration file if it doesn't exist, allowing users to set their preferred theme and color.
2. Dynamic Theme Loading: Loads and displays ASCII art themes based on user selection, with support for different display methods (less, ccat, lolcat).
3. User  Interaction: Provides a user-friendly interface for selecting themes and colors, including error handling for invalid inputs.
4. Color Customization: Allows users to choose foreground and background colors from a wide range of options.
5. Help and Documentation: Includes a help command that provides usage instructions and available commands for user guidance.

Capabilities:
- Supports multiple ASCII art themes and color configurations.
- Validates user input to ensure correct theme and color selections.
- Provides feedback and error messages to enhance user experience.
DOCUMENTATION

source ~/.shell_utils/variables/shell_colors.sh
source ~/.shell_utils/variables/shell_colors_indexed_array.sh

config_file="${HOME}/.ascii_themes_select.conf"

create_config_file() {
    if [ ! -f "${config_file}" ]; then
        touch "${config_file}"
        echo "# Choose a theme number or 'n' for no theme." | tee "${config_file}"
        echo 'ASCII Theme Index = 339' | tee -a "${config_file}"
        echo '# Choose a theme color.' | tee -a "${config_file}"
        echo 'Empty' | tee -a "${config_file}"
        sed -i -r '4 cASCII Theme Color Index = 41' "${config_file}" #Theme Color
        echo '# Use 0 for less, 1 for ccat, and 2 for lolcat to display.' | tee -a "${config_file}"
        echo 'READER = 0' | tee -a "${config_file}"
    fi
}
create_config_file >/dev/null 2>&1

update_variables() {
    # default_read=$(less -FX "${config_file}" | head -6 | tail -1 | sed '/^$/d' | cut -f2 -d'=' | sed '/^$/d'); export default_read
    # list_index=$(less -FX "${config_file}" | head -2 | tail -1 | sed '/^$/d' | cut -f2 -d'=' | sed '/^$/d'); export list_index
    # color=$(less -FX "${config_file}" | head -4 | tail -1 | sed '/^$/d' | cut -f2 -d'=' | sed '/^$/d'); export color
    default_read=$(sed -n '6s/.*=\s*\(.*\)/\1/p' "${config_file}"); export default_read
    list_index=$(sed -n '2s/.*=\s*\(.*\)/\1/p' "${config_file}"); export list_index
    color_index=$(sed -n '4s/.*=\s*\(.*\)/\1/p' "${config_file}"); export color
    return 0
}

[[ "${list_index}" == "n" ]] && echo >/dev/null && exit 0
[[ "${list_index}" =~ ^[[:alpha:]]+$ ]] && sed -i "2 cASCII Theme Index = 339" "${config_file}" && echo >/dev/null && exit 0
[[ "${color_index}" =~ ^[[:alpha:]]+$ ]] && sed -i -r '4 cASCII Theme Color Index = 41' "${config_file}"
[[ "${default_read}" =~ ^[[:alpha:]]+$ ]] && sed -i "6 cREADER = 0" "${config_file}"
(( "${default_read}" > 2 )) && sed -i "6 cREADER = 0" "${config_file}"

update_variables

if ! command -v lolcat &> /dev/null && (( "${default_read}" == 2 )); then
    clear -T "${TERM}"
    echo -e "Error: lolcat is not installed. Please install lolcat for this script to work."
    exit 1
elif ! command -v ccat &> /dev/null && (( "${default_read}" == 1 )); then
    clear -T "${TERM}"
    echo -e "Error: ccat is not installed. Please install ccat for this script to work."
    exit 1
elif ! command -v less &> /dev/null; then
    clear -T "${TERM}"
    echo -e "Error: less is not installed. Please install less for this script to work."
    exit 1
fi

export ascii_arts_folder="${HOME}/.shell_utils/ascii_arts_themes"
cd "${ascii_arts_folder}" || exit
ascii_theme_list=(*.[tT][xX][tT])
cd - >/dev/null || exit

load_ascii_art_theme() {
    clear -T "${TERM}"
    update_variables && update_variables

    if (( "${list_index}" >= 0 )); then
        if (( "${default_read}" == 2 )); then
echo -e "
$(lolcat -ft "${ascii_arts_folder}/${ascii_theme_list[${list_index}]}")"

        elif (( "${default_read}" == 1 )); then
echo
ccat "${ascii_arts_folder}/${ascii_theme_list[${list_index}]}"
        else
            echo -e "${shell_color_palette_index[${color_index}]}
$(cat "${ascii_arts_folder}/${ascii_theme_list[${list_index}]}")${shell_color_palette[color_off]}"
        fi
    fi
    return 0
}
# It was a way I found to fix the color leakage from some color theme combinations.
# Example: theme 2 (Abacus) with color 366
if [[ "${color_index}" -ge 366 ]] && [[ "${default_read}" -lt 1 ]]; then
    load_ascii_art_theme && sleep 0.2 && load_ascii_art_theme
else
    load_ascii_art_theme
fi

leng_theme_list(){
    number=0
    for list in "${ascii_theme_list[@]}";
        do
            (( number++ )) || true
            echo "${number}"
    done
}

print_theme_list() {
    number=0
    echo -e "${shell_color_palette[byellow]}Usage:${shell_color_palette[color_off]}\n"
    echo -e "${shell_color_palette[cyan]}Example:${shell_color_palette[color_off]}"
    echo -e "${shell_color_palette[bwhite_on_black]}ascii_theme_select theme 1${shell_color_palette[color_off]}\n"

    echo 'n)    Without theme'

    for list in "${ascii_theme_list[@]}";
        do
            echo -e "\n\n"
            cat "${ascii_arts_folder}/${ascii_theme_list[${number}]}"
            echo -e "\n\n${number})    ${list}\n\n"
            (( number++ )) || true
    done

    echo -e "\n"'Enter "q" for exit'"\n"
    return 0
}

leng=$(($(leng_theme_list | wc -l)-1))

color_shell_select(){
    number=0

    color_list(){
        echo -e "${shell_color_palette[byellow]}Usage:${shell_color_palette[color_off]}\n"
        echo -e "${shell_color_palette[cyan]}Example:${shell_color_palette[color_off]}"
        echo -e "${shell_color_palette[bgreen_on_black]}${0##*/} color 41${shell_color_palette[color_off]}\n"

        for list in "${shell_color_palette_index[@]}";
            do
                (( number++ )) || true
                if [ "${number}" -le 2989 ]; then
                    echo -e "${number})    Color: ${list}'\\${shell_color_palette_index[${number}]}'"
                fi
        done

        echo -e "\n"'Enter "q" for exit'"\n"
        return 0
    }
    background_list(){
        echo -e "${shell_color_palette[byellow]}Usage:${shell_color_palette[color_off]}\n"
        echo -e "${shell_color_palette[cyan]}Example:${shell_color_palette[color_off]}"
        echo -e "${shell_color_palette[bgreen_on_black]}${0##*/} background 367${shell_color_palette[color_off]}\n"

        for list in "${shell_color_palette_index[@]}";
            do
                (( number++ )) || true
                if [ "${number}" -ge 366 ]; then
                    echo -e "${number})    Background: ${list}'\\${shell_color_palette_index[${number}]}'"
                fi
        done

        echo -e "\n"'Enter "q" for exit'"\n"
        return 0
    }
    case "${1}" in

        "background")
            if [ -z "${2}" ]; then
                background_list | less -Ri
                return 0
            elif [[ "${2}" -le 2989 && "${2}" -ge 366 ]]; then
                export background_color="${shell_color_palette_index["${2}"]}"
                echo -e "${shell_color_palette[bblack_on_cyan]}Example of use:${shell_color_palette[color_off]}"
                echo -e "${shell_color_palette[bblack_on_white]}echo -e \"\${background_color}\" Text${shell_color_palette[color_off]}"
                return 0
            else
                echo -e "${shell_color_palette[bred]}\"${2}\" is an invalid background choice! Enter a number from 366 to 2989.\n"
                echo -e "${shell_color_palette[byellow]}Or use \"set\" option to set colors directly!"
                return 0
            fi
            ;;
        "color")
            if [ -z "${2}" ]; then
                color_list | less -Ri
                return 0
            elif [[ "${2}" -le 2989 && "${2}" -gt 0 ]]; then
                export color_shell="${shell_color_palette_index[${2}]}"
                return 0
            else
                echo -e "${shell_color_palette[bred]}\"${2}\" is an invalid color choice! Enter a number from 1 to 2989.\n"
                echo -e "${shell_color_palette[byellow]}Or use \"set\" option to set colors directly!"
                return 1
            fi
            ;;
    esac
}

update_variables && update_variables

[[ "${2}" != "n" ]] && [[ "${2}" =~ ^[[:alpha:]]+$ ]] && clear -T "${TERM}" \
&& echo -e "${shell_color_palette[bred]}\"${2}\" is an invalid option! Use only numbers or ...\n${0##*/} theme n (for no theme)!" \
&& sleep 2 && load_ascii_art_theme && exit 1

case "${1}" in
    "l"|"t"|"theme"|"themes"|"list"|"list_themes")
        if [ -z "${2}" ]; then
            while true; do
                print_theme_list | less -Ri
                clear -T "${TERM}"
                echo -e "${shell_color_palette[byellow]}Choose an ASCII theme from 1 to ${leng} or 'n' for none:\n"
                read -r read_select_ascii_theme
                if [[ "${read_select_ascii_theme}" == "n" ]]; then
                    sed -i "2 cASCII Theme Index = ${read_select_ascii_theme}" "${config_file}"
                    load_ascii_art_theme && load_ascii_art_theme
                    break
                elif [ "${read_select_ascii_theme}" -le "${leng}" ]; then
                    sed -i "2 cASCII Theme Index = ${read_select_ascii_theme}" "${config_file}"
                    load_ascii_art_theme && load_ascii_art_theme
                    break
                else
                    clear -T "${TERM}"
                    echo -e "${shell_color_palette[bred]}\"${read_select_ascii_theme}\" is an invalid choice! Enter a number from 0 to ${leng} or 'n' for none!"
                    sleep 2
                    clear
                fi
            done
        elif [[ "${2}" == "n" ]]; then
            sed -i "2 cASCII Theme Index = ${2}" "${config_file}"
            load_ascii_art_theme
            exit 0
        elif [ "${2}" -le "${leng}" ]; then
            clear -T "${TERM}"
            echo -e "Theme ${2} selected: ${ascii_theme_list[${2}]}\n"
            sed -i "2 cASCII Theme Index = ${2}" "${config_file}"
            load_ascii_art_theme
            exit 0
        else
            clear -T "${TERM}"
            echo -e "${shell_color_palette[bred]}\"${2}\" is an invalid choice! Enter a number from 0 to ${leng} or 'n' for none!"
            sleep 2
            load_ascii_art_theme && load_ascii_art_theme
            exit 0
        fi
        ;;
    "c"|"color")
        if [ -z "${2}" ]; then
            while true; do
                clear -T "${TERM}"
                color_shell_select color
                echo -e "${shell_color_palette[byellow]}Which color theme was chosen, from 2 to 2989?\n"
                echo -e "${shell_color_palette[byellow]}Or enter 1 for NO color\n"
                read -r read_select_color
                if [[ "${read_select_color}" -le 2989 && "${read_select_color}" -gt 0 ]]; then
                    color_shell_select color "${read_select_color}"
                    sleep 0.2
                    sed -i "4 cASCII Theme Color Index = ${read_select_color}" "${config_file}" #Theme Color
                    load_ascii_art_theme && load_ascii_art_theme
                    break
                else
                    clear -T "${TERM}"
                    echo -e "${shell_color_palette[bred]}\"${read_select_color}\" is an invalid choice! Enter a number from 1 to 2989!"
                    sleep 2
                    clear
                fi
            done
        elif [[ "${2}" -le 2989 && "${2}" -gt 0 ]]; then
            color_shell_select color "${2}"
            sleep 0.2
            sed -i "4 cASCII Theme Color Index = ${2}" "${config_file}" #Theme Color
            load_ascii_art_theme
            exit 0
        else
            clear -T "${TERM}"
            echo -e "${shell_color_palette[bred]}\"${2}\" is an invalid choice! Enter a number from 1 to 2989!"
            sleep 2
            load_ascii_art_theme && load_ascii_art_theme
            exit 0
        fi
        ;;
    "b"|"background")
        if [ -z "${2}" ]; then
            while true; do
                clear -T "${TERM}"
                color_shell_select background
                echo -e "${shell_color_palette[byellow]}Which color theme was chosen, from 1 to 2989?\n"
                echo -e "${shell_color_palette[byellow]}Or enter 1 for NO color\n"
                read -r read_select_background
                if [[ "${read_select_background}" == 1 ]]; then
                    sed -i "4 cASCII Theme Color Index = ${read_select_background}" "${config_file}" #Theme Color
                    load_ascii_art_theme && load_ascii_art_theme
                    break
                elif [[ "${read_select_background}" -le 2989 && "${read_select_background}" -ge 366 ]]; then
                    color_shell_select color "${read_select_background}"
                    sleep 0.2
                    sed -i "4 cASCII Theme Color Index = ${read_select_background}" "${config_file}" #Theme Color
                    load_ascii_art_theme && load_ascii_art_theme
                    break
                else
                    clear -T "${TERM}"
                    echo -e "${shell_color_palette[bred]}\"${read_select_background}\" is an invalid choice! Enter a number from 366 to 2989!"
                    sleep 2
                    clear
                fi
            done

        elif [[ "${2}" == 1 ]]; then
            sed -i "4 cASCII Theme Color Index = ${read_select_background}" "${config_file}" #Theme Color
            load_ascii_art_theme
            exit 0
        elif [[ "${2}" -le 2989 && "${2}" -ge 366 ]]; then
            color_shell_select color "${2}"
            sleep 0.2
            sed -i "4 cASCII Theme Color Index = ${read_select_background}" "${config_file}" #Theme Color
            load_ascii_art_theme
            exit 0
        else
            clear -T "${TERM}"
            echo -e "${shell_color_palette[bred]}\"${2}\" is an invalid choice! Enter a number from 366 to 2989!"
            sleep 2
            load_ascii_art_theme && load_ascii_art_theme
            exit 0
        fi
        ;;
    "read"|"reader")
        if [ -z "${2}" ]; then
            while true; do
                clear -T "${TERM}"
                echo -e "${shell_color_palette[byellow]}Enter 0 for less, 1 for ccat, and 2 for lolcat.\n"
                read -r reader_default
                if (( "${reader_default}" <= 2 )); then
                    sed -i "6 cREADER = ${reader_default}" "${config_file}"
                    load_ascii_art_theme && load_ascii_art_theme
                    break
                else
                    clear -T "${TERM}"
                    echo -e "${shell_color_palette[bred]}\"${reader_default}\" is an invalid choice! Enter 0, 1, or 2!"
                    sleep 2
                    clear
                fi
            done

        elif (( "${2}" <= 2 )); then
            sed -i "6 cREADER = ${2}" "${config_file}"
            load_ascii_art_theme
            exit 0
        else
            clear -T "${TERM}"
            echo -e "${shell_color_palette[bred]}\"${2}\" is an invalid choice! Enter 0, 1, or 2!"
            sleep 2
            load_ascii_art_theme && load_ascii_art_theme
            exit 1
        fi
        ;;
    "r"|"reload")
        load_ascii_art_theme
        ;;
    "-h"|"--help"|"h"|"help")
        clear -T "${TERM}"
        echo -e "
${shell_color_palette[bblack_on_cyan]}Usage:${shell_color_palette[color_off]}

${shell_color_palette[bblack_on_white]}ascii_theme_select <command> [options]${shell_color_palette[color_off]}

${shell_color_palette[bblack_on_cyan]}Available commands:${shell_color_palette[color_off]}

${shell_color_palette[bblack_on_white]}h or help ..................... Print this help message               ${shell_color_palette[color_off]}
${shell_color_palette[bblack_on_white]}t or theme .................... List themes                           ${shell_color_palette[color_off]}
${shell_color_palette[bblack_on_white]}t or theme [number] ........... Manage ascii themes                   ${shell_color_palette[color_off]}
${shell_color_palette[bblack_on_white]}c or color .................... Prompt to Define color theme          ${shell_color_palette[color_off]}
${shell_color_palette[bblack_on_white]}c or color [number] ........... Define color theme                    ${shell_color_palette[color_off]}
${shell_color_palette[bblack_on_white]}b or background ............... Prompt to Defines a background color  ${shell_color_palette[color_off]}
${shell_color_palette[bblack_on_white]}b or background [number] ...... Defines a background color            ${shell_color_palette[color_off]}
${shell_color_palette[bblack_on_white]}reader ........................ Prompt to reader default              ${shell_color_palette[color_off]}
${shell_color_palette[bblack_on_white]}reader [number] ............... Choose 0, 1 or 2. Default is 0.       ${shell_color_palette[color_off]}
${shell_color_palette[bblack_on_white]}r or reload ................... Reload theme                          ${shell_color_palette[color_off]}

${shell_color_palette[bblack_on_cyan]}Example:${shell_color_palette[color_off]}

${shell_color_palette[bblack_on_white]}ascii_theme_select theme 12${shell_color_palette[color_off]}
"
        exit 0
        ;;
esac