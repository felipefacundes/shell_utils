alias resolve_pacman='~/.shell_utils/scripts/pacman_resolve'
alias pacman_error='resolve_pacman'
alias pac_his='pacman_history'
alias pachis_ins='pacman_history_installed_log'
alias pachis_rem='pacman_history_removed_log'
alias pacman_remove_debug='help pacman_remove_debug'
alias last_update='ls -lt --time-style=+%Y-%m-%d /var/cache/pacman/pkg/*.zst | grep $(date +%Y-%m-%d)'
alias last_update2="ls -ltr --time-style=+%Y-%m-%d /var/cache/pacman/pkg/*.zst | grep -E '\b[0-9]{4}-[0-9]{2}-[0-9]{2}\b'"