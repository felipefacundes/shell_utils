#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script converts an image to an ICO file with multiple sizes.

    Requirements:
                    - ImageMagick must be installed.
                    - The 'file' command must be available.
DOCUMENTATION

doc() {
    less -FX "$0" | head -n10 | tail -n5
}

help() {
    cat <<EOF 

    $(doc)

    Usage: ${0##*/} <path_to_image>

    Options:
    <path_to_image>   Path to the input image file.
    
    Example:
    ${0##*/} path/to/image.png
EOF
}

if [[ -z $1 ]] || [[ $1 == "-h" || $1 == "--help" ]]; then
    help
    exit 0
fi

# Check if ImageMagick is installed
if ! command -v magick &> /dev/null; then
    echo "ImageMagick is not installed. Please install it before continuing."
    exit 1
fi

# Check if the 'file' command is available
if ! command -v file &> /dev/null; then
    echo "The 'file' command is not available. Please install it before continuing."
    exit 1
fi

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_image>"
    exit 1
fi

input_image="$1"

# Check if the input file is a valid image
if ! file --mime-type "$input_image" | grep -q "image"; then
    echo "The provided file is not a valid image."
    exit 1
fi

# Get the filename without the extension
filename=$(basename -- "$input_image")
filename_noext="${filename%.*}"

# Output ICO file name
output_icon="$filename_noext.ico"

# Desired icon sizes in pixels
sizes="16x16 32x32 48x48 64x64 128x128 256x256"

# Convert the image for each size and add to the ICO file
for size in $sizes; do
    magick "$input_image" -resize "$size" "$size" "temp_$size.png"
done

magick "$(ls temp_*.png | sort -V)" "$output_icon"

# Remove temporary files
rm temp_*.png

echo "Conversion completed. The ICO icon has been saved as $output_icon"
