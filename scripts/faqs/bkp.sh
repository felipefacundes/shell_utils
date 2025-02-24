#!/usr/bin/env bash

cat <<'EOF'
This command renames files in the current directory by appending their line number (from a sorted list) to each filename, 
creating a backup with a numbered suffix.

ls -v | cat -n | while read -r n f; do mv "$f" "$f.$n"; done
EOF