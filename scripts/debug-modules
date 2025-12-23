#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
The provided Bash script is designed to "purify" a specified module file by executing its functions and aliases in a controlled manner. 
The script ensures that the module file exists and is valid before proceeding with the purification process. 

Key strengths of the script include:

1. Input Validation: Checks if the correct number of arguments is provided and verifies the existence of the module file.
2. Function and Alias Handling: Identifies and executes functions and aliases defined in the module file, providing feedback on their execution status.
3. Error Handling: Captures and reports errors that occur during the execution of functions and aliases, enhancing reliability.
4. User  Feedback: Provides clear output messages to inform the user about the progress and completion of the purification process.
5. Modular Design: The script is structured to handle different components of the module file separately, making it easier to maintain and extend.

Overall, this script serves as a useful tool for managing and executing Bash module files efficiently.
DOCUMENTATION

# Check if the module file argument was provided
if [[ $# -ne 1 ]]; then
    echo "Usage: ${0##*/} <file_module>"
    exit 1
fi

module_file="$1"

# Check if the module file exists
if [[ ! -f "$module_file" ]]; then
    echo "The module file does not exist: $module_file"
    exit 1
fi

echo "Purifying module: $module_file"
echo

# Loads the module file on a subshell to extract functions and aliases
while IFS= read -r line; do
    if [[ $line =~ ^function[[:space:]]+([[:alnum:]_]+) ]]; then
        echo "Purifying function: ${BASH_REMATCH[1]}"
        echo
        bash -xc "$line"
        if [[ $? -ne 0 ]]; then
            echo "An error occurred in the function: ${BASH_REMATCH[1]}"
        fi
        echo
        echo "Clearance of the function completed: ${BASH_REMATCH[1]}"
        echo
    elif [[ $line =~ ^alias[[:space:]]+([[:alnum:]_]+) ]]; then
        echo "Purifying alias: ${BASH_REMATCH[1]}"
        echo
        alias_cmd=$(alias "${BASH_REMATCH[1]}" 2>/dev/null)
        bash -xc "$alias_cmd"
        if [[ $? -ne 0 ]]; then
            echo "An error occurred in the alias: ${BASH_REMATCH[1]}"
        fi
        echo
        echo "Clearance of the completed alias:${BASH_REMATCH[1]}"
        echo
    fi
done < "$module_file"

echo "Clearance of the completed module: $module_file"
