#!/bin/bash

# File to check
BASHRC_FILE="$HOME/.bashrc"

# Line to look for
TARGET_LINE="source ~/.shell_utils/scripts/utils/bash_smartcd.sh"

# Check if the line already exists in the file
if ! grep -Fxq "$TARGET_LINE" "$BASHRC_FILE"; then
    echo "Adding the line 'smartcd' to ~/.bashrc"
    echo " " >> "$BASHRC_FILE"
    echo "$TARGET_LINE" >> "$BASHRC_FILE"
    echo "Line added successfully!"
fi