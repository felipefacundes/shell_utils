#!/usr/bin/env python3
# License: GPLv3
# Credits: Felipe Facundes

"""
This Python script removes the background from an input image using OpenCV. It reads the specified image file, 
converts it to grayscale, and applies adaptive thresholding to create a binary mask. The script then finds contours in the mask, 
creates an alpha channel, and sets the alpha values for the background to zero. Finally, it saves the resulting image with a 
transparent background as a new PNG file.

Dependencies:
1. OpenCV (cv2) - Third-party library (install via pip)
2. NumPy (numpy) - Third-party library (install via pip)
3. sys - Native library (no installation required)
4. os - Native library (no installation required)

Installation of Dependencies:
To install the required third-party dependencies, run the following commands:

pip install opencv-python numpy

This will install the 'opencv-python' and 'numpy' packages necessary for the script to function properly. 
Ensure you have Python 3.x installed on your system.
"""

import cv2
import numpy as np
import sys
import os

def remove_background(input_image):
    # Load image
    img = cv2.imread(input_image)

    # Convert to grayscale
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Use adaptive thresholding to create a binary mask
    mask = cv2.adaptiveThreshold(gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, 11, 2)

    # Find contours in the mask
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    # Create an empty mask
    mask = np.zeros_like(gray)

    # Draw the contours on the mask
    cv2.drawContours(mask, contours, -1, (255), thickness=cv2.FILLED)

    # Create an alpha channel with the same shape as the original image
    alpha_channel = np.ones((img.shape[0], img.shape[1]), dtype=np.uint8) * 255

    # Add the alpha channel to the original image
    img = cv2.merge((img, alpha_channel))

    # Set the alpha values to 0 for the background
    img[:, :, 3] = mask

    # Save resulting masked image
    output_filename = os.path.splitext(os.path.basename(input_image))[0] + '_removebg.png'
    cv2.imwrite(output_filename, img)
    print(f"Result saved as {output_filename}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <input_image>")
        sys.exit(1)

    input_image = sys.argv[1]
    remove_background(input_image)
