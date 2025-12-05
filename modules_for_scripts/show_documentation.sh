# License: GPLv3
# Credits: Felipe Facundes

# Searches for content delimited by : <<'DOCUMENTATION' and DOCUMENTATION in the running script.

# With sed
show_documentation() {
    sed -n '/^: <<.DOCUMENTATION./,/^DOCUMENTATION/p' "$0" | sed '1d;$d'
}

# With awk
show_documentation() {
    awk '
    BEGIN { inside_block = 0 }

    # Check the beginning of the DOCUMENTATION block
    /: <<'\''DOCUMENTATION'\''/ { inside_block = 1; next }

    # Check the end of the DOCUMENTATION block
    inside_block && $0 == "DOCUMENTATION" { inside_block = 0; exit }

    # Print lines within the DOCUMENTATION block
    inside_block { print }
    ' "$0"
}
