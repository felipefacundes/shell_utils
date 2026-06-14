function commands
    # Configure TMPDIR for Termux
    if test -z "$TMPDIR"
        set -g TMPDIR "$PREFIX/tmp"
    end
    
    set -l temp_file "$TMPDIR/cmd_selected"
    
    # Clear and execute
    echo -n > "$temp_file"
    command commands
    
    # Read and verify
    set -l selected (cat "$temp_file" 2>/dev/null | string trim)
    
    if test -n "$selected"
        # Save to history file
        echo -e "- cmd: $selected\n  when: $(date +%s)" >> $HOME/.local/share/fish/fish_history
        
        # Force history reload IN REAL TIME
        history merge        
    end
end