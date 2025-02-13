# Function to forcefully kill wine processes
alias kill_wine='~/.shell_utils/scripts/wine_helper.sh -k'
alias kwine='kill_wine'
alias mwine='kill_wine'

# Function to renice wine processes with different priority levels
alias renicewine='~/.shell_utils/scripts/wine_helper.sh -r'

# Functions for reniceuser with different priority levels
alias reniceuser='~/.shell_utils/scripts/wine_helper.sh -u'

# Shortcuts for reniceuser functions
alias r1='~/.shell_utils/scripts/wine_helper.sh -r1'
alias r2='~/.shell_utils/scripts/wine_helper.sh -r2'
alias r3='~/.shell_utils/scripts/wine_helper.sh -r3'
alias r4='~/.shell_utils/scripts/wine_helper.sh -r4'

alias game_performance_cpu='~/.shell_utils/scripts/wine_helper.sh -p'
alias performance_cpu='game_performance_cpu'

# For PlayOnGit Project
alias playongit_review='bash <(curl -s https://raw.githubusercontent.com/felipefacundes/PS/master/other_scripts/base/base_for_create_installation_script.sh)'
alias playongit_create_new_script='playongit_review'