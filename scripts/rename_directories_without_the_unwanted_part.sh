#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
The script is a versatile bilingual (Portuguese and English) directory renaming utility designed to 
remove specified parts from directory names in the current directory. Its key strengths include:

1. Multilingual Support: Automatically detects system language (Portuguese or English) and provides 
localized error messages and usage instructions, enhancing user experience across different language environments.

2. Flexible Renaming Mechanism: Allows users to specify a substring to remove from directory names, 
executing batch renaming operations with a single command. The script iterates through all directories, 
identifying and renaming those containing the specified substring.

3. Robust Error Handling: Implements comprehensive error checking, including:
- Detecting missing parameters
- Providing detailed help instructions
- Supporting a help flag (-h) for user guidance
- Preventing accidental operations with insufficient input

The script demonstrates advanced bash scripting techniques like associative arrays, conditional language detection, 
and dynamic directory manipulation, making it a powerful and user-friendly command-line tool for directory management.
DOCUMENTATION

# Associative array for bilingual messages
declare -A MESSAGES

# Detect language
if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        ["usage"]="Uso: ${0##*/} [-h] parte_remover"
        ["help_option"]="  -h               Exibe esta ajuda."
        ["help_parameter"]="  parte_remover    Parte do nome a ser removida dos diretórios."
        ["error_no_param"]="Erro: Nenhuma parte para remover foi informada."
        ["error_missing_param"]="Erro: Parte para remover não informada."
        ["renaming"]="Renomeando"
    )
else
    MESSAGES=(
        ["usage"]="Usage: ${0##*/} [-h] part_to_remove"
        ["help_option"]="  -h               Displays this help."
        ["help_parameter"]="  part_to_remove    Part of the directory name to be removed."
        ["error_no_param"]="Error: No part to remove was provided."
        ["error_missing_param"]="Error: Part to remove not provided."
        ["renaming"]="Renaming"
    )
fi

# Help function
usage() {
    echo "${MESSAGES["usage"]}"
    echo "${MESSAGES["help_option"]}"
    echo "${MESSAGES["help_parameter"]}"
    exit 1
}

# Check if any parameter was provided
if [ "$#" -eq 0 ]; then
    echo "${MESSAGES["error_no_param"]}"
    usage
fi

# Get the part to remove
part_to_remove="$*"

if [[ "$part_to_remove" == -h ]]; then
    usage
fi

if [ -z "$part_to_remove" ]; then
    echo "${MESSAGES["error_missing_param"]}"
    usage
fi

# Iterate over directories in the current directory
for dir in */; do
    # Remove the trailing slash from the directory name
    dir_name="${dir%/}"

    # Check if the directory name contains the part to be removed
    if [[ "$dir_name" == *"$part_to_remove"* ]]; then
        # Replace the part to be removed with an empty string
        new_name="${dir_name//"$part_to_remove"/}"

        # Rename the directory
        echo "${MESSAGES["renaming"]}: $dir_name -> $new_name"
        mv -v "$dir_name" "$new_name"
    fi
done
