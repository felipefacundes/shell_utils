#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script is designed to execute a specified module file while ensuring proper input validation and error handling. 
It first checks if a module file argument is provided and whether the file exists. If the file is valid, it runs the module 
in a subshell with tracing enabled to display the execution process. After execution, it checks the exit status to determine 
if any errors occurred during the module's execution. Finally, it outputs a message indicating the completion of the module's processing.
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

# Perform the module on a subshell with activated trace
bash -x "$module_file"

# Check the module output code
if [[ $? -ne 0 ]]; then
    echo "An error occurred in the module: $module_file"
fi

echo "Clearance of the completed module: $module_file"
