#!/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This script removes the background from an image using the remove.bg API. It takes an input image file path as an argument, 
sends a request to the API, and saves the resulting image with the background removed. The original and processed images are 
displayed side by side for comparison. The script requires an API key for authentication with the remove.bg service.

Dependencies:
1. os - Native library (no installation required)
2. sys - Native library (no installation required)
3. requests - Third-party library (install via pip)
4. io - Native library (no installation required)
5. matplotlib - Third-party library (install via pip)

Installation of Dependencies:
To install the required third-party dependencies, run the following commands:

pip install requests matplotlib

This will install the 'requests' and 'matplotlib' packages necessary for the script to function properly. 
Additionally, ensure you have a valid API key for the remove.bg service to authenticate your requests.
"""

import os
import sys
import requests
from io import BytesIO
from matplotlib import pyplot as plt

# Define the API key as a global variable
# https://www.remove.bg/dashboard#credits-plan
API_KEY = "mzQqpgCQo54jHiwJqYoStSPt"

def remove_background(input_path):
    # Generate the output path with the suffix _background_removed.png
    base_name = os.path.splitext(os.path.basename(input_path))[0]
    output_path = f"{base_name}_background_removed.png"

    # Set up the remove.bg API URL
    api_url = "https://api.remove.bg/v1.0/removebg"

    # Set up the request headers
    headers = {
        "X-Api-Key": API_KEY,
    }

    # Read the input image
    with open(input_path, "rb") as image_file:
        image_data = image_file.read()

    # Make the request to the API
    response = requests.post(api_url, headers=headers, files={"image_file": image_data})

    # Check if the request was successful (status code 200)
    if response.status_code == 200:
        # Save the resulting image without background
        with open(output_path, "wb") as output_file:
            output_file.write(response.content)

        # Display the original image and the resulting image
        original_image = plt.imread(input_path)
        segmented_image = plt.imread(output_path)

        plt.subplot(1, 2, 1)
        plt.imshow(original_image)
        plt.title("Original Image")

        plt.subplot(1, 2, 2)
        plt.imshow(segmented_image)
        plt.title("Image Without Background")

        plt.show()
    else:
        print(f"Request error: {response.status_code}")
        print(response.text)

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Remove the background from an image using the remove.bg API.")
    parser.add_argument("input_path", help="Path to the input image")

    args = parser.parse_args()

    # Check if the input file exists
    if not os.path.isfile(args.input_path):
        print("The input file was not found.")
        sys.exit(1)

    # Remove the background from the image and save the resulting image
    remove_background(args.input_path)