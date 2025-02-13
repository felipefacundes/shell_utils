#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
The script is designed to rename PNG and JPG images in a directory sequentially, ensuring a consistent naming format. 

Strengths:
1. Automatically tracks the last used number to avoid naming conflicts.
2. Supports both PNG and JPG file formats.
3. Provides user feedback by displaying renamed files.

Capabilities:
- Reads and updates a file to maintain the last used number.
- Renames images in a specified format (000xxx).
- Handles the absence of target files gracefully.
DOCUMENTATION

# File path that stores the last number used
LAST_FILE_NUMBER="$HOME/.last_names_named.txt"

# Check if the file exists, otherwise it creates with value 0
if [ ! -f "$LAST_FILE_NUMBER" ]; then
    echo 0 > "$LAST_FILE_NUMBER"
fi

# Read the last number saved
FIRST_NUMBER=$(cat "$LAST_FILE_NUMBER")

# Rename accountant
COUNTER=$FIRST_NUMBER

# Rename PNG and JPG images in the current folder
for IMAGE in *.[JjPp][NnPp][Gg]; do
    # Check if the file exists (to avoid errors if there are no files of the type)
    if [ -e "$IMAGE" ]; then
        # Increases the accountant
        COUNTER=$((COUNTER + 1))

        # Defines the new name with 000xxx format (Example: 000001, 000002)
        NEW_NAME=$(printf "000%03d.${IMAGE##*.}" "$COUNTER")

        # Rename the image
        mv "$IMAGE" "$NEW_NAME"
        echo "Renamed: $IMAGE -> $NEW_NAME"
    fi
done

# Update the file with the last number used
echo "$COUNTER" > "$LAST_FILE_NUMBER"
