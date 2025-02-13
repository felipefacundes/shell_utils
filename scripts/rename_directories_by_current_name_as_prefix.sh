#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script is a bilingual directory renaming utility that automatically prepends 
the current directory name to all subdirectories. Its key strengths include:

1. Multilingual Support: Automatically detects system language (Portuguese or English) and provides 
localized success and error messages, enhancing user experience across different language environments.

2. Automated Renaming Process: Systematically renames all subdirectories by adding the current 
directory's name as a prefix, facilitating organized and consistent directory naming conventions.

3. Robust Error Handling: Implements comprehensive error management, including:
- Silent error suppression for renaming failures
- Detailed bilingual messaging for successful and failed rename operations
- Graceful handling of permission or naming conflict issues

The script demonstrates advanced bash scripting techniques like associative arrays, dynamic directory manipulation, 
and intelligent error reporting, making it a powerful and user-friendly command-line tool for directory management.
DOCUMENTATION

# Associative array for bilingual messages
declare -A MESSAGES

# Detect language
if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        ["renaming_success"]="Diretório '%s' renomeado para '%s'."
        ["renaming_failure"]="Falha ao renomear '%s'. Verifique permissões ou conflitos."
    )
else
    MESSAGES=(
        ["renaming_success"]="Directory '%s' renamed to '%s'."
        ["renaming_failure"]="Failed to rename '%s'. Check permissions or conflicts."
    )
fi

# Check if the script is executed in the correct directory
current_dir=$(basename "$PWD")

# List directories in the current directory
for dir in */; do
    # Remove the trailing slash from the directory name
    dir_name=${dir%/}

    # Generate the new name with the prefix
    new_name="${current_dir}-${dir_name}"

    # Rename the directory
    mv "$dir_name" "$new_name" 2>/dev/null

    if [[ $? -eq 0 ]]; then
        # On success, print a success message
        printf "${MESSAGES["renaming_success"]}\n" "$dir_name" "$new_name"
    else
        # On failure, print an error message
        printf "${MESSAGES["renaming_failure"]}\n" "$dir_name"
    fi
done
