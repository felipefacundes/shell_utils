#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script defines three functions that print messages when executed. 
It includes a dynamic help feature that displays usage instructions and available functions with their descriptions. 
The script checks for a help option and allows users to call specified functions by passing their names as arguments. 
If a function is not found, it notifies the user accordingly.
DOCUMENTATION

# Define your functions below
# Add as many functions as you like in a similar manner

function1() {
    # This function displays a printout of function 1
    echo "Executing function 1"
}

function2() {
    # This function displays a printout of function 2
    echo "Executing function 2"
}

function3() {
    # This function displays a printout of function 3
    echo "Executing function 3"
}

# Display help dynamically
help() {
    echo "Usage: ${0##*/} [function1 function2 ...]"
    echo -e "\n     -h, --help,\n                Display this help message.\n"
    echo -e "Available functions:\n"
 
    declare -F | awk '{print $3}' | while read -r func_name; do
        IFS= read -r line
        # Check if the line contains a comment and extract the description
        if [[ $line =~ ^[[:space:]]*#[[:space:]]*(.*)$ ]]; then
            description="${BASH_REMATCH[1]}"
            # Display only if it is a valid description
            if [[ -n "$description" ]]; then
                func_name=$(echo "$func_name" | sed 's/(//;s/)//;s/{//;s/ //')
                echo "  $func_name - $description"
            fi
        fi
    done < <(awk '/^function[0-9]*\(\)/,/^\}/' "$0")

    echo -e "\nEnter q to quit this help.\n"
}

# Check if help option was provided
if [[ -z "$1" || "$1" == "-h" || "$1" == "--help" ]]; then
    help | less -i -R
    exit 0
fi

# Iterate over the passed arguments
for func_name in "$@"; do
    # Check if the function exists
    if declare -f "$func_name" > /dev/null; then
        # Call the function
        "$func_name"
    else
        echo "Function '$func_name' not found."
    fi
done

# Example script invocation:
# ./your_script.sh function1 function2
