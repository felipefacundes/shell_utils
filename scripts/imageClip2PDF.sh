#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script converts an image from the clipboard into a PDF file. 
It first detects the display system (either X11 or Wayland) to fetch the clipboard content accordingly. 
The script checks for the presence of the 'imagemagick' package, which is required for the conversion process. 
If there is no image in the clipboard, it notifies the user and exits. Finally, it attempts to convert 
the clipboard image to a PDF file named "output.pdf" and reports the success or failure of the conversion.
DOCUMENTATION

# Detect the display system (X11 or Wayland)
# Function to fetch clipboard content based on the display system
get_clipboard_content() {
    if [ "$XDG_SESSION_TYPE" == "x11" ]; then
        xclip -selection clipboard -o
    elif [ "$XDG_SESSION_TYPE" == "wayland" ]; then
        wl-paste
    else
        echo "Display system not supported."
        exit 1
    fi
}

# Check if imagemagick is installed
if ! command -v convert &> /dev/null; then
    echo "'imagemagick' package is not installed. Please install it first."
    exit 1
fi

# Check if there is data in the clipboard
if ! get_clipboard_content &> /dev/null; then
    echo "There is no image in the clipboard."
    exit 1
fi

# Output file name
output_file="output.pdf"

# Convert the clipboard image to PDF
get_clipboard_content | magick - "$output_file"

# Check if the conversion was successful
if [ $? -eq 0 ]; then
    echo "Image successfully converted to $output_file"
else
    echo "Error converting the image."
fi
