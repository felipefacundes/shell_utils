commands() {
    # Clear the temporary file before starting
    if [[ -z $TMPDIR ]]; then
        TMPDIR="/tmp"
    fi
    : tee "$TMPDIR/cmd_selected"
    
    # Execute cmd in print mode
    command commands
    
    # Read the selected command
    local selected


    selected=$(cat "$TMPDIR/cmd_selected" 2>/dev/null)
    
    # If nothing was selected, return
    [[ -z "$selected" ]] && return 0
    
    # Add to history (compatible with bash and zsh)
    if [[ -n "$ZSH_VERSION" ]]; then
        print -s "$selected"
    else
        history -s "$selected"
    fi
}