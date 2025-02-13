# Remove duplicate lines
duplicate_lines()
{
    sort "$@" | uniq
}

delete_duplicate_bash_history()
{
    duplicate_lines ~/.bash_history > ~/.bash_history_temp;
    rm ~/.bash_history;
    mv ~/.bash_history_temp ~/.bash_history >/dev/null
}
