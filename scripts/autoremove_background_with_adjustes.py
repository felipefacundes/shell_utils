#!/usr/bin/env python3
# License: GPLv3
# Credits: Felipe Facundes

"""
This Python script removes backgrounds from images using OpenCV. It processes the input image through adaptive 
thresholding and contour detection to create a mask, then applies morphological operations to refine the mask. 
The script adds an alpha channel to create transparency where the background was detected and includes Gaussian 
blur for smoother edges. It features customizable parameters through command-line arguments and outputs the 
processed image with the background removed. The script is designed to be both a standalone tool and a reusable function, 
with sensible defaults for all processing parameters.

Dependencies:
1. OpenCV (cv2) - Third-party library (install via pip)
2. NumPy - Third-party library (install via pip)
3. argparse - Native library (no installation required)
4. sys - Native library (no installation required)
5. os - Native library (no installation required)

Installation of Dependencies:
To install the required third-party dependencies, run the following commands:

pip install opencv-python numpy

This will install the 'opencv-python' and 'numpy' packages necessary for the script to function properly. 
Ensure you have Python 3.x installed on your system.

Would you like me to explain any specific part of how the script works?
"""

import cv2
import numpy as np
import argparse
import sys
import os

def remove_background(input_image, output_filename, threshold, blur_radius, morph_size, open_iterations, close_iterations, alpha_blur_radius):
    # Load image
    img = cv2.imread(input_image)

    # Convert to grayscale
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Use adaptive thresholding to create a binary mask
    mask = cv2.adaptiveThreshold(gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, 11, threshold)

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

    # Apply blur to the alpha channel
    img[:, :, 3] = cv2.GaussianBlur(img[:, :, 3], (0, 0), alpha_blur_radius)

    # Apply morphology to the mask
    kernel = np.ones((morph_size, morph_size), np.uint8)
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel, iterations=open_iterations)
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel, iterations=close_iterations)

    # Save resulting masked image
    cv2.imwrite(output_filename, img)
    print(f"Result saved as {output_filename}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Remove background from an image.")
    parser.add_argument("input_image", help="Path to the input image.")
    parser.add_argument("-o", "--output", help="Path to the output image. Default: <input_basename>_removebg.png")
    parser.add_argument("--threshold", type=int, default=11, help="Threshold for adaptive thresholding. Default: 11")
    parser.add_argument("--blur-radius", type=int, default=2, help="Radius for Gaussian blur. Default: 2")
    parser.add_argument("--morph-size", type=int, default=3, help="Size of the structuring element for morphological operations. Default: 3")
    parser.add_argument("--open-iterations", type=int, default=1, help="Number of iterations for opening operation. Default: 1")
    parser.add_argument("--close-iterations", type=int, default=1, help="Number of iterations for closing operation. Default: 1")
    parser.add_argument("--alpha-blur-radius", type=int, default=2, help="Radius for Gaussian blur applied to alpha channel. Default: 2")

    args = parser.parse_args()

    input_image = args.input_image
    output_filename = args.output

    if output_filename is None:
        output_filename = os.path.splitext(os.path.basename(input_image))[0] + '_removebg.png'

    remove_background(
        input_image,
        output_filename,
        args.threshold,
        args.blur_radius,
        args.morph_size,
        args.open_iterations,
        args.close_iterations,
        args.alpha_blur_radius
    )
