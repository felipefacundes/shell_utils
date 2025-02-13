#!/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This Python script automates the process of removing backgrounds from images using the rembg library. 
It takes an input image path as a command-line argument, processes the image by first checking and converting RGBA images to RGB if necessary, 
then removes the background using rembg's remove function. The script automatically generates an output filename by appending "_removebg" 
to the original filename and saves the result as a PNG file to preserve transparency. The program includes error handling for incorrect 
usage and provides feedback about the successful completion of the background removal process.

Dependencies:
1. rembg - Third-party library (install via pip)
2. Pillow - Third-party library (install via pip)
3. sys - Native library (no installation required)
4. Command-line interface to execute the script

Installation of Dependencies:
To install the required third-party dependencies, run the following commands:

pip install rembg Pillow

This will install the 'rembg' and 'Pillow' packages necessary for the script to function properly. 
Ensure you have a compatible version of Python (3.x) installed on your system.
"""

import sys
from rembg import remove
from PIL import Image

def remove_background(input_path, output_path):
    input_image = Image.open(input_path)

    # Check if the image has an alpha channel (RGBA)
    if input_image.mode == 'RGBA':
        # Convert the image to RGB mode before removing the bottom
        input_image = input_image.convert('RGB')

    output_image = remove(input_image)
    
    # Get the name of the file without extension
    file_name, _ = input_path.rsplit('.', 1)
    
    # Add the suffix to the output file name
    output_path = f"{file_name}_removebg.png"

    # Save the image as PNG to preserve the alpha channel
    output_image.save(output_path)

    print(f"Background removed successfully. Result saved at {output_path}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <input_image>")
        sys.exit(1)

    input_path = sys.argv[1]
    remove_background(input_path, input_path)
