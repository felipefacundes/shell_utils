#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Script to format clipboard text and convert to PDF
Uses DejaVu-Sans as font in size 26 for portrait and 30 for landscape
DOCUMENTATION

# Function to show help menu
show_help() {
    cat <<EOF
Usage: ${0##*/} [OPTION]

This script formats clipboard text and generates a PDF with:
- Full UTF-8 support
- DejaVu-Sans font in size 30
- Landscape mode (horizontal orientation)
- Formatting that preserves paragraphs and prevents word breaks

Options:
  -h, --help    Show this help message
  -v, --version Show script version
  -l, --landscape Generate PDF in landscape mode (default)
  -p, --portrait  Generate PDF in portrait mode

Examples:
  ${0##*/}              Process clipboard text
  ${0##*/} --help       Show this help
  ${0##*/} --portrait   Generate PDF in portrait mode

Requirements:
  - xclip (to access clipboard)
  - enscript (to generate PostScript)
  - ps2pdf (to convert PostScript to PDF)
  - DejaVu-Sans font installed on system

Tips:
  - Text is automatically formatted to prevent word breaks
  - Original paragraphs are preserved
  - Margins are automatically adjusted for better readability

EOF
}

# Optimized function to format text
format_text() {
    local input="$1"
    local result=""
    local current_line=""
    local paragraph=""
    
    # First normalize spaces and preserve paragraphs
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/[[:space:]]\+/ /g; s/^[[:space:]]*//; s/[[:space:]]*$//')
        
        if [[ -z "$line" ]]; then
            # Empty line indicates new paragraph
            if [[ -n "$paragraph" ]]; then
                result+="$paragraph\n\n"
                paragraph=""
            fi
        else
            if [[ -n "$paragraph" ]]; then
                paragraph+=" $line"
            else
                paragraph="$line"
            fi
        fi
    done <<< "$input"
    
    # Add last paragraph if it exists
    [[ -n "$paragraph" ]] && result+="$paragraph"
    
    # Now process each paragraph to break lines correctly
    local formatted_result=""
    while IFS= read -r para; do
        [[ -z "$para" ]] && { formatted_result+="\n"; continue; }
        
        local words=()
        IFS=' ' read -ra words <<< "$para"
        local current_line=""
        
        for word in "${words[@]}"; do
            # If word doesn't fit in current line, start new line
            if [[ ${#current_line} -gt 0 && $((${#current_line} + ${#word} + 1)) -gt $max_length ]]; then
                formatted_result+="$current_line\n"
                current_line="$word"
            else
                if [[ -z "$current_line" ]]; then
                    current_line="$word"
                else
                    current_line+=" $word"
                fi
            fi
        done
        
        # Add last line of paragraph
        formatted_result+="$current_line\n"
    done <<< "$(echo -e "$result")"
    
    # Remove extra trailing newline
    echo -e "${formatted_result%\\n}"
}

max_length=40  # Ideal for font size 40 in landscape mode
font="DejaVu-Sans30"
orientation="--landscape"

# Check arguments
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
elif [ "$1" = "-v" ] || [ "$1" = "--version" ]; then
    echo "clipboard_to_pdf v1.3 (UTF-8 encoding fixed)"
    exit 0
elif [ "$1" = "-l" ] || [ "$1" = "--landscape" ]; then
	max_length=40 
	font="DejaVu-Sans30"
	orientation="--landscape"
elif [ "$1" = "-p" ] || [ "$1" = "--portrait" ]; then
	max_length=29
	font="DejaVu-Sans26"
	orientation="--portrait"
fi

# Check dependencies
for cmd in xclip enscript ps2pdf; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed."
        echo "Install on Arch with: sudo pacman -S $cmd"
        echo "Install on Ubuntu with: sudo apt install $cmd"
        exit 1
    fi
done

# Get and format text
clipboard_text=$(xclip -o -selection clipboard 2>/dev/null)
[ -z "$clipboard_text" ] && { echo "Error: No text in clipboard."; exit 1; }

formatted_text=$(format_text "$clipboard_text")

# Create temporary file with guaranteed UTF-8 encoding
temp_file=$(mktemp /tmp/clipboard_text.XXXXXX)
echo -e "$formatted_text" > "$temp_file"

# Convert to ISO-8859-1 temporarily for enscript
temp_file_iso=$(mktemp /tmp/clipboard_text_iso.XXXXXX)
iconv -f UTF-8 -t ISO-8859-1//TRANSLIT "$temp_file" > "$temp_file_iso"

# Output PDF filename
output_pdf="clipboard_output_$(date +%Y%m%d_%H%M%S).pdf"

# Generate PDF ensuring correct encoding
enscript $orientation -B -f "$font" --margins=50:50:50:50 -p - "$temp_file_iso" \
    | ps2pdf -dPDFA - - > "$output_pdf"

# Cleanup
rm "$temp_file" "$temp_file_iso"

echo "PDF successfully generated: $(realpath "$output_pdf")"
evince "$output_pdf" & disown
exit 0