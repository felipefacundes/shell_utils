#!/usr/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This Python script extracts the dominant colors from an input image and converts them into hexadecimal 
format using the 'PIL' and 'extcolors' libraries. It accepts command-line arguments to specify the input image, 
an optional output image filename, and an optional flag to save the extracted color codes to a text file. 
The script generates a new image displaying the extracted colors as swatches and saves it to the specified output filename. 
If the extraction option is used, it writes the hexadecimal color codes to the designated text file, providing a convenient 
way to capture color information from images.

Dependencies:
1. 'PIL' (Pillow) - Third-party library for image processing (install via pip).
2. 'extcolors' - Third-party library for extracting dominant colors from images (install via pip).
3. 'sys' - Native library for system-specific parameters and functions (no installation needed).

Installation of Dependencies:
- Install 'Pillow' and 'extcolors' using pip:

  pip install Pillow extcolors
"""

import sys
from PIL import Image
import extcolors

def rgb_to_hex(rgb):
    if len(rgb) == 2:
        r, g = rgb
        b = 0
    else:
        r, g, b = rgb
    return '#%02x%02x%02x' % (r, g, b)

def extract_hex_colors(input_name):
    img = Image.open(input_name)
    colors_x = extcolors.extract_from_path(input_name, tolerance=12, limit=12)
    hex_colors = [rgb_to_hex(color[0]) for color in colors_x[0]]
    return hex_colors

def main():
    if len(sys.argv) < 2:
        print("Usage: script.py <input_image> [output_image.png] [--extract <output_text.txt>]")
        return
    
    input_name = sys.argv[1]
    output_name = sys.argv[2] if len(sys.argv) > 2 else "output_image.png"
    
    extract_index = sys.argv.index("--extract") if "--extract" in sys.argv else -1
    extract_output = sys.argv[extract_index + 1] if extract_index != -1 and extract_index + 1 < len(sys.argv) else None

    hex_colors = extract_hex_colors(input_name)
    
    if extract_output:
        with open(extract_output, 'w') as f:
            for color in hex_colors:
                f.write(color + '\n')
        print(f"The hexadecimal codes of the colors were extracted to the file {extract_output}")

    if output_name:
        with open(output_name, 'w') as f:
            for color in hex_colors:
                f.write(color + '\n')
    else:
        for color in hex_colors:
            print(color)

    # Save the output image with a representative color of each hexadecimal code
    output_image = Image.new("RGB", (len(hex_colors) * 100, 100))
    for i, color in enumerate(hex_colors):
        x = i * 100
        output_image.paste(color, (x, 0, x + 100, 100))
    output_image.save(output_name)

if __name__ == "__main__":
    main()