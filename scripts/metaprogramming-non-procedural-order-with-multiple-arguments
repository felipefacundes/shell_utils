#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

# The DOCUMENTATION is at the end of the script.

# Array to store the commands to be executed
declare -a COMMANDS=()

# Pre-processing function to validate arguments
_pre_process() {
    # If there are no arguments, show help
    if [ $# -eq 0 ]; then
        echo "Usage: ${0##*/} {func1|func2|show_vars} [func1|func2|show_vars...]"
        exit 1
    fi

    # Process all arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            func1|func2|show_vars)
                COMMANDS+=("$1")
                ;;
            *)
                echo "Error: Invalid command '$1'"
                echo "Valid commands: func1, func2, show_vars"
                exit 1
                ;;
        esac
        shift
    done
}

# Execute the pre-processing with all arguments
_pre_process "$@"

# Define the functions
func1() {
    echo "=== Executing func1 ==="
    echo "$VAR1"
    echo "----------------------"
}

func2() {
    echo "=== Executing func2 ==="
    echo "$VAR2"
    echo "----------------------"
}

show_vars() {
    echo "=== Showing variables ==="
    echo "VAR1=$VAR1"
    echo "VAR2=$VAR2"
    echo "-------------------------"
}

# Defines the variables after the functions
VAR1="Value of variable 1"
VAR2="Value of variable 2"

# Execute all commands stored in the order they were passed
for cmd in "${COMMANDS[@]}"; do
    "$cmd"
done

: <<'DOCUMENTATION'
This script is not exactly "reverse programming," but rather a design pattern known as "Command Pattern" adapted for shell scripting. 

In the broader context of programming, there are some related concepts:

1. "Lazy Evaluation" - where processing is delayed until it is actually needed
2. "Deferred Execution" - where we store a command to execute later

It is closer to a "Command Dispatcher," where:
1. First, we validate the command
2. Then we prepare the environment (variables and functions)
3. Finally, we dispatch (execute) the command

Bash still executes everything sequentially. What has been done is to reorganize the logic to validate first and execute later, 
maintaining the natural flow of the shell.

This is a practical application of the "Fail Fast" principle in programming, where we validate inputs as early as possible, 
before doing any significant processing.
DOCUMENTATION