# Getting the current shell name
set shell (ps -p $fish_pid | tail -1 | awk '{print $4}')

# Setting variables
set shell_current $shell
set shell_default $SHELL