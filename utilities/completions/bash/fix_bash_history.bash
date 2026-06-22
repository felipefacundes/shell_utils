_remove_timestamp_in_single_line_format_from_bash_history() {
    [[ ! -f "$HISTFILE" ]] && touch "$HISTFILE"
    [[ -f "$HISTFILE" ]] && sed -i 's/^:[[:space:]][0-9]\{10\}:0;//g' "$HISTFILE" >/dev/null 2>&1
    return 0
}

# https://www.baeldung.com/linux/history-remove-avoid-duplicates
remove_duplicate_commands_from_bash_history() {
    [[ ! -f "$HISTFILE" ]] && touch "$HISTFILE"
    local history_file="${HISTFILE}"
    local temp_file="${HISTFILE}.tmp"
    [[ -f "${temp_file}" ]] && rm -f "${temp_file}"

    # Filter duplicate commads
    awk '!a[$0]++' "$history_file" > "$temp_file"

    # Replace history
    mv -f "$temp_file" "$history_file" >/dev/null 2>&1
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