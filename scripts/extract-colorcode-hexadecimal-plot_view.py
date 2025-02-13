#!/usr/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This Python script extracts the dominant colors from an input image and converts them into hexadecimal format, 
utilizing various libraries for image processing and data visualization. It resizes the input image for analysis, 
displays the resized image, and extracts color information using the 'extcolors' library. The extracted hexadecimal 
color codes can either be printed to the console or saved to a specified output file. The script also includes error 
handling for command-line arguments to ensure the input image file exists before processing.

Dependencies:
1. 'numpy' - Third-party library for numerical operations (install via pip).
2. 'pandas' - Third-party library for data manipulation and analysis (install via pip).
3. 'matplotlib' - Third-party library for plotting and visualization (install via pip).
4. 'Pillow' (PIL) - Third-party library for image processing (install via pip).
5. 'OpenCV' (cv2) - Third-party library for computer vision tasks (install via pip).
6. 'extcolors' - Third-party library for extracting dominant colors from images (install via pip).
7. 'colormap' - Third-party library for color conversion (install via pip).
8. 'os' - Native library for interacting with the operating system (no installation needed).
9. 'sys' - Native library for system-specific parameters and functions (no installation needed).

Installation of Dependencies:
- Install the required libraries using pip:
  
  pip install numpy pandas matplotlib Pillow opencv-python extcolors colormap
"""

import os
import sys
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import matplotlib.image as mpimg
from PIL import Image, ImageFilter
from matplotlib.offsetbox import OffsetImage, AnnotationBbox
import cv2
import extcolors
from colormap import rgb2hex

def color_to_df(input):
    colors_pre_list = str(input).replace('([(','').split(', (')[0:-1]
    df_rgb = [i.split('), ')[0] + ')' for i in colors_pre_list]
    df_percent = [i.split('), ')[1].replace(')','') for i in colors_pre_list]

    #convert RGB to HEX code
    df_color_up = [rgb2hex(int(i.split(", ")[0].replace("(","")),
                          int(i.split(", ")[1]),
                          int(i.split(", ")[2].replace(")",""))) for i in df_rgb]

    df = pd.DataFrame(zip(df_color_up, df_percent), columns=['c_code', 'occurence'])
    return df

def extract_hex_colors(input_name, output_name=None):
    output_width = 900
    img = Image.open(input_name)
    wpercent = (output_width / float(img.size[0]))
    hsize = int((float(img.size[1]) * float(wpercent)))
    img = img.resize((output_width, hsize), Image.LANCZOS)
    
    # Save resized image
    resize_name = 'resize_' + input_name
    img.save(resize_name)
    
    # Read resized image
    plt.figure(figsize=(9, 9))
    img_url = resize_name
    img = plt.imread(img_url)
    plt.imshow(img)
    plt.axis('off')
    plt.show()
    
    colors_x = extcolors.extract_from_path(img_url, tolerance=12, limit=12)
    df_color = color_to_df(colors_x)
    
    if output_name:
        # Save hex codes to a text file
        df_color['c_code'].to_csv(output_name, index=False, header=False)
    else:
        # Print hex codes
        print(df_color)
    
    # Remove resized image file
    os.remove(resize_name)
    
    return df_color

# Check if an image file path is provided
if len(sys.argv) < 2:
    print("Usage: python script.py <image_path> [output_file]")
    print("Please provide the path to the image file.")
    sys.exit(1)

# Get the image file path from command line arguments
input_name = sys.argv[1]

# Check if the image file exists
if not os.path.isfile(input_name):
    print("The specified image file does not exist.")
    sys.exit(1)

# Get the output file name from command line arguments, if provided
output_name = None
if len(sys.argv) > 2:
    output_name = sys.argv[2]

# Extract hex colors from the image
df_color = extract_hex_colors(input_name, output_name)