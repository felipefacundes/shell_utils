#!/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This Python script removes the background from an input image using the 'rembg' library. 
It reads an image file specified as a command-line argument, processes it to eliminate the background, 
and saves the resulting image with a modified filename. The script also displays both the original 
and the background-removed images side by side for comparison. It requires the OpenCV and Matplotlib 
libraries for image processing and visualization.

Dependencies:
- OpenCV ('cv2')
- Matplotlib ('pyplot')
- rembg

Dependencies:
1. OpenCV (cv2) - Third-party library (install via pip)
2. Matplotlib (pyplot) - Third-party library (install via pip)
3. rembg - Third-party library (install via pip)
4. os - Native library (no installation required)
5. sys - Native library (no installation required)

Installation of Dependencies:
To install the required third-party dependencies, run the following commands:

pip install opencv-python matplotlib rembg

This will install the 'opencv-python', 'matplotlib', and 'rembg' packages necessary for the script to function properly.
"""

import cv2
import os
import sys
from matplotlib import pyplot as plt
from rembg import remove

def remove_background(input_path):
    # Load the image
    original_image = cv2.imread(input_path)
    original_image = cv2.cvtColor(original_image, cv2.COLOR_BGR2RGB)

    # Generate the output path with the suffix _background_removed.png
    base_name = os.path.splitext(os.path.basename(input_path))[0]
    output_path = f"{base_name}_background_removed.png"

    # Save the resulting image without background
    with open(output_path, "wb") as output_file:
        input_image = cv2.imencode(".png", cv2.cvtColor(original_image, cv2.COLOR_RGB2BGR))[1].tobytes()
        output_file.write(remove(input_image))

    # Display the original image and the resulting image
    plt.subplot(1, 2, 1)
    plt.imshow(original_image)
    plt.title("Original Image")

    plt.subplot(1, 2, 2)
    segmented_image = cv2.imread(output_path)
    segmented_image = cv2.cvtColor(segmented_image, cv2.COLOR_BGR2RGB)
    plt.imshow(segmented_image)
    plt.title("Image Without Background")

    plt.show()

if __name__ == "__main__":
    # Check if an input path was provided as an argument
    if len(sys.argv) != 2:
        print("Please provide the image path as an argument.")
        sys.exit(1)

    # Get the image path from the command line argument
    input_path = sys.argv[1]

    # Check if the input file exists
    if not os.path.isfile(input_path):
        print("The input file was not found.")
        sys.exit(1)

    # Remove the background from the image and save the resulting image
    remove_background(input_path)