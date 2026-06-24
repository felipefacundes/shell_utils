_remove_timestamp_in_single_line_format_from_bash_history() {
    [[ ! -f "$HISTFILE" ]] && touch "$HISTFILE"
    [[ -f "$HISTFILE" ]] && sed -i 's/^:[[:space:]][0-9]\{10\}:0;//g' "$HISTFILE" >/dev/null 2>&1
    return 0
}

_remove_unused_timestamps_from_bash_history() {
    [[ ! -f "$HISTFILE" ]] && touch "$HISTFILE"
    local history_file="${HISTFILE}"
    local temp_file="${HISTFILE}.tmp"
    [[ -f "${temp_file}" ]] && rm -f "${temp_file}"

    # Filter history lines with timestamps and associated commands
    awk '/^#[0-9]+$/ { if (getline c && c !~ /^#[0-9]+$/) { print $0 ORS c } } !/^#[0-9]+$/ { print }' "$history_file" > "$temp_file"

    # Replace history
    mv -f "$temp_file" "$history_file" >/dev/null 2>&1
    return 0
}

_include_timestamp_in_bash_history() {
    [[ ! -f "$HISTFILE" ]] && touch "$HISTFILE"
    local history_file="${HISTFILE}"
    local temp_file="${HISTFILE}.tmp"
    [[ -f "${temp_file}" ]] && rm -f "${temp_file}"

    # Filter history lines with timestamps and associated commands
    awk '/^#[0-9]+$/ { if (getline c && c !~ /^#[0-9]+$/) { print $0 ORS c } } !/^#[0-9]+$/ { print strftime("#%s") ORS $0 }' "$history_file" > "$temp_file"

    # Replace history
    mv -f "$temp_file" "$history_file" >/dev/null 2>&1
    return 0
}

##########################################################################################################

# https://www.baeldung.com/linux/history-remove-avoid-duplicates
# remove_duplicate_commands_from_bash_history() {
#     [[ ! -f "$HISTFILE" ]] && touch "$HISTFILE"
#     local history_file="${HISTFILE}"
#     local temp_file="${HISTFILE}.tmp"
#     [[ -f "${temp_file}" ]] && rm -f "${temp_file}"

#     # Filter duplicate commads
#     awk '!a[$0]++' "$history_file" > "$temp_file"

#     # Replace history
#     mv -f "$temp_file" "$history_file" >/dev/null 2>&1
#     return 0
# }

history_clean_duplicate_commands() {
    # Determine the history file
    local hist_file="${HISTFILE:-$HOME/.bash_history}"
    
    # Check if the file exists
    if [[ ! -f "$hist_file" ]]; then
        echo "Error: History file not found: $hist_file" >&2
        return 1
    fi
    
    # Create backup of the original history
    cp "$hist_file" "$hist_file.bak.$(date +%Y%m%d_%H%M%S)"
    
    # Temporary file for processing
    local temp_file; temp_file=$(mktemp)
    
    # Read the history file and process
    local lines=()
    mapfile -t lines < "$hist_file"
    
    # Arrays to track commands and their timestamps
    local seen_commands=()
    local result_timestamps=()
    local result_commands=()
    
    # Iterate through lines in reverse order (from newest to oldest)
    local current_timestamp=""
    
    for (( i=${#lines[@]}-1; i>=0; i-- )); do
        local line="${lines[$i]}"
        
        # Check if it's a timestamp
        if [[ "$line" =~ ^#[0-9]{10,}$ ]]; then
            current_timestamp="$line"
            continue
        fi
        
        # It's a command line
        local command_line="$line"
        local is_duplicate=0
        
        # Check if this command has already been seen
        for (( j=0; j<${#seen_commands[@]}; j++ )); do
            if [[ "${seen_commands[$j]}" == "$command_line" ]]; then
                is_duplicate=1
                break
            fi
        done
        
        # If not a duplicate, add to result arrays
        if [[ $is_duplicate -eq 0 ]]; then
            seen_commands+=("$command_line")
            result_timestamps+=("$current_timestamp")
            result_commands+=("$command_line")
        fi
    done
    
    # Write the result to the temporary file in correct chronological order
    : | tee "$temp_file" > /dev/null  # Clear the temporary file
    for (( i=${#result_timestamps[@]}-1; i>=0; i-- )); do
        echo "${result_timestamps[$i]}" | tee -a "$temp_file" > /dev/null
        echo "${result_commands[$i]}" | tee -a "$temp_file" > /dev/null
    done
    
    # Replace the original file
    mv "$temp_file" "$hist_file"
    
    echo "History cleaned successfully!"
    echo "Backup created at: $hist_file.bak.$(date +%Y%m%d_%H%M%S)"
    echo "Unique commands kept: ${#seen_commands[@]}"
    
    # Reload history in the current session
    history -c
    history -r "$hist_file"
}

history_clean_duplicate_commands_awk() {
    # Determine the history file
    local hist_file="${HISTFILE:-$HOME/.bash_history}"
    
    # Check if the file exists
    if [[ ! -f "$hist_file" ]]; then
        echo "Error: History file not found: $hist_file" >&2
        return 1
    fi
    
    # Create backup of the original history
    cp "$hist_file" "$hist_file.bak.$(date +%Y%m%d_%H%M%S)"
    
    # Temporary file for processing
    local temp_file="${hist_file}.tmp"
    
    # Use awk to process the history
    awk '
    BEGIN { 
        # Read the file backwards
        cmd = "tac " ARGV[1]
        while ((cmd | getline) > 0) {
            lines[++n] = $0
        }
        close(cmd)
        
        # Process lines in reverse order (which is the original backwards order)
        seen_count = 0
        result_count = 0
    }
    END {
        for (i = 1; i <= n; i++) {
            line = lines[i]
            
            # Verifica se é timestamp
            if (line ~ /^#[0-9]{10,}$/) {
                current_ts = line
                continue
            }
            
            # Check if the command has already been seen
            is_dup = 0
            for (j = 0; j < seen_count; j++) {
                if (seen[j] == line) {
                    is_dup = 1
                    break
                }
            }
            
            if (!is_dup) {
                seen[seen_count++] = line
                timestamps[result_count] = current_ts
                commands[result_count] = line
                result_count++
            }
        }
        
        # Write in correct chronological order
        for (i = result_count - 1; i >= 0; i--) {
            print timestamps[i]
            print commands[i]
        }
    }' "$hist_file" | tee "$temp_file" > /dev/null && mv "$temp_file" "$hist_file"
    
    echo "History cleaned successfully!"
    echo "Backup created at: $hist_file.bak.$(date +%Y%m%d_%H%M%S)"
    
    # Reload history in the current session
    history -c
    history -r "$hist_file"
}