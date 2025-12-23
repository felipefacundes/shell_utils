#!/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This script removes the background from an image using the remove.bg API. It takes an input image file path as an argument, 
sends the image to the API, and saves the processed image with the background removed. The script checks for successful API 
responses and handles errors accordingly. It requires the 'requests' library for making HTTP requests and uses standard libraries 
for file handling and command-line argument parsing.

Dependencies:
1. requests - Third-party library (install via pip)
2. argparse - Native library (no installation required)
3. os - Native library (no installation required)
4. sys - Native library (no installation required)

Installation of Dependencies:
To install the required third-party dependency, run the following command:

pip install requests

This will install the 'requests' package necessary for the script to function properly. 
Additionally, ensure you have a valid API key for the remove.bg service to authenticate your requests.
"""

import os
import sys
import requests

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

        print(f"Background removed image saved at: {output_path}")
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