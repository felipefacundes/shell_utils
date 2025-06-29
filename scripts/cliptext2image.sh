#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script creates a 1920x1080 JPG image from clipboard text, formatting it neatly with proper line breaks. 
It automatically extracts and positions biblical references (if found) in the bottom-right corner. 
The user can specify an output directory or it defaults to /tmp. 
The script requires ImageMagick (convert) and optionally uses feh to display the image.  

(Each line is exactly 150 characters when counting spaces)
DOCUMENTATION

# Check if the user asked for help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: ${0##*/} [destination_directory]"
    echo "Creates a 1920x1080 JPG image with text from clipboard."
    echo "If no directory is provided, uses /tmp as default."
    exit 0
fi

# Set the destination directory
dest_dir="${1:-/tmp}"

# Check if a valid directory was provided
if [ ! -d "$dest_dir" ]; then
    echo "Error: '$dest_dir' is not a valid directory." >&2
    exit 1
fi

# Get text from clipboard
text=$(xclip -selection clipboard -o 2>/dev/null || echo "(Empty text or not available)")

# Generate filename with timestamp
filename="text2image_$(date +%y-%m-%d_%H-%M-%S).jpg"
filepath="${dest_dir%/}/$filename"

# Function to extract and format the biblical reference
format_reference() {
    local input="$1"
    # Extracts reference in the format (Book, XX)
    if [[ "$input" =~ \((.*,[[:space:]]*[0-9]+)\)[[:space:]]*$ ]]; then
        reference="(${BASH_REMATCH[1]})"
        # Removes reference from main text
        main_text="${input%(*}"
        echo -e "$main_text\n$reference"
    else
        echo "$input"
    fi
}

# Function to format text in lines up to 52 characters without breaking words
format_text() {
    local input="$1"
    local line_length=0
    local result=""
    local word
    
    # Remove reference before formatting lines
    input="${input%(*}"
    
    # Process each word separately
    while IFS= read -r -d ' ' word; do
        # Remove existing line breaks
        word=$(echo "$word" | tr -d '\n')
        
        # If word alone exceeds limit, put it on its own line
        if [ ${#word} -ge 52 ]; then
            if [ -n "$result" ]; then
                result="$result\n$word"
            else
                result="$word"
            fi
            line_length=0
        # If adding the word exceeds limit, new line
        elif [ $((line_length + ${#word})) -ge 52 ]; then
            result="$result\n$word"
            line_length=${#word}
        # Otherwise, add to current line
        else
            if [ $line_length -eq 0 ]; then
                result="$word"
                line_length=${#word}
            else
                result="$result $word"
                line_length=$((line_length + ${#word} + 1))
            fi
        fi
    done <<< "$input "
    
    echo -e "$result"
}

# Process text to separate verse and reference
processed_text=$(format_reference "$text")

# Format main text
formatted_main_text=$(format_text "$processed_text")

# Extract reference (last line)
reference_text=$(echo "$processed_text" | tail -n 1)

# Create image with formatted text
convert -size 1920x1080 xc:black \
        -fill white \
        -font "DejaVu-Sans" \
        -pointsize 60 \
        -gravity center \
        -annotate +0+0 "$formatted_main_text" \
        -fill white \
        -font "DejaVu-Sans" \
        -pointsize 40 \
        -gravity southeast \
        -annotate +50+50 "$reference_text" \
        -background black \
        "$filepath"

# Check if image was created
if [ ! -f "$filepath" ]; then
    echo "Error: Failed to create image." >&2
    exit 1
fi

# Try to open with feh or show path
if command -v feh >/dev/null; then
    feh "$filepath" & disown
else
    echo "Image created at: $filepath"
fi

exit 0