#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
The script is a versatile bilingual (Portuguese and English) file renaming utility designed 
to remove specified parts from filenames in the current directory. Its key strengths include:

Multilingual Support: Automatically detects system language (Portuguese or English) and provides 
localized error messages and usage instructions, enhancing user experience across different language environments.
Flexible Renaming Mechanism: Allows users to specify a substring to remove from filenames, 
executing batch renaming operations with a single command. The script iterates through all files, 
identifying and renaming those containing the specified substring.
Robust Error Handling: Implements comprehensive error checking, including:

- Detecting missing parameters
- Providing detailed help instructions
- Supporting a help flag (-h) for user guidance
- Preventing accidental operations with insufficient input

The script demonstrates advanced bash scripting techniques like associative arrays, conditional language detection, 
and dynamic file manipulation, making it a powerful and user-friendly command-line tool for file management.
DOCUMENTATION

# Associative array for bilingual messages
declare -A MESSAGES

# Detect language
if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        ["usage"]="Uso: ${0##*/} [-h] parte_remover"
        ["help_option"]="  -h                Exibe esta ajuda."
        ["help_parameter"]="  parte_remover    Parte do nome a ser removida dos arquivos."
        ["error_no_param"]="Erro: Nenhuma parte para remover foi informada."
        ["error_missing_param"]="Erro: Parte para remover não informada."
        ["renaming"]="Renomeando"
    )
else
    MESSAGES=(
        ["usage"]="Usage: ${0##*/} [-h] part_to_remove"
        ["help_option"]="  -h                Displays this help."
        ["help_parameter"]="  part_to_remove    Part of the filename to be removed."
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

# Iterate over files in the current directory
for file in *; do
    # Check if it is a regular file
    if [[ -f "$file" ]]; then
        # Check if the filename contains the part to be removed
        if [[ "$file" == *"$part_to_remove"* ]]; then
            # Replace the part to be removed with an empty string
            new_name="${file//"$part_to_remove"/}"

            # Rename the file
            echo "${MESSAGES["renaming"]}: $file -> $new_name"
            mv -v "$file" "$new_name"
        fi
    fi
done
