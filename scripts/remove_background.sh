#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Background Removal Bash Utility

A Bash script that uses ImageMagick to automatically remove backgrounds from PNG images in a specified directory. 
The tool allows users to transparentize images based on a specific color hex code.

Key Features:
1. Batch PNG image processing
2. Simple command-line interface
3. Precise background removal
4. Automatic output directory management

The script provides an efficient solution for bulk image background removal, ideal for designers and developers 
seeking quick image preprocessing.
DOCUMENTATION

# Check if the number of arguments is appropriate
if [ "$#" -ne 3 ]; then
    echo "Usage: ${0##*/}  <input_directory> <output_directory> <color_hexadecimal>"
    exit 1
fi

# Attribute arguments to variables
input_directory="$1"
output_directory="$2"
background_color="$3"

# Creates exit directory if it does not exist
mkdir -p "$output_directory"

# Itra about all images in the entrance directory
for input_image in "$input_directory"/*.png; do
    # Get the file name without the way and the extension
    filename=$(basename -- "$input_image")
    filename_noext="${filename%.*}"

    # Removes the background of the image using imagemagick
    convert "$input_image" -transparent "$background_color" "$output_directory/$filename_noext.png"

    echo "Removed the bottom $filename"
done

echo "Completed!"
