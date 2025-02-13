# Getting the current shell name
shell="$(ps -p $$ | tail -1 | awk '{print $4}')"

# Setting variables
shell_current="${shell}"
shell_default="${SHELL}"