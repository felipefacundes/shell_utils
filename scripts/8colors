#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script converts images in the current directory and its subfolders to a maximum of 8 colors using ImageMagick. 
It first creates an output directory for the converted images if it doesn't already exist. 
The script then iterates through all JPEG and PNG files, checking the number of colors in each image. 
If an image has more than 8 colors, it converts the image and saves it in the output directory, 
while also providing feedback on the conversion process.
DOCUMENTATION

# Directory where the converted images will be saved
OUTPUT_DIR="./converted"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Process images in the current folder and subfolders
for i in *.[jJPpGg][PpNnIi][GgFf]; do
    # Check if the file exists to avoid errors in the loop
    [ -f "$i" ] || continue

    # Get the number of colors in the image
    NUM_COLORS=$(magick "$i" -format %k info:)

    echo "Image: $i - Colors: $NUM_COLORS"

    # If the number of colors is greater than 8, convert the image
    if (( NUM_COLORS > 8 )); then
        echo "Converting $i to 8 colors..."
        magick "$i" -colors 8 "$OUTPUT_DIR/$(basename "$i")"
        echo "Converted image saved to: $OUTPUT_DIR/$(basename "$i")"
    else
        echo "The image $i already has 8 or fewer colors."
    fi
done
