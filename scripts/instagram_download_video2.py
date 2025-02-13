#!/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This script is designed to download videos from Instagram posts using the Instaloader library, 
similar to the previous scripts. Its main purpose is to provide a user-friendly way to retrieve video content from Instagram.

Key strengths include:
1. Video Verification: The script checks if the specified post is a video before attempting to download it.
2. Dynamic Directory Creation: It automatically creates a directory for the user based on the post owner's username, 
   ensuring organized storage of downloaded content.
3. Simplified Input Method: Instead of requiring a command-line argument, this script prompts the user to input the Instagram link directly, 
   enhancing accessibility for users who may not be familiar with command-line usage.
4. Direct Download Functionality: Utilizes Instaloader's built-in method to download videos, streamlining the code.

Differences from the first script:
- Input Method: This script uses 'input()' to get the Instagram link, while the first script requires the link as a command-line argument.
- Progress Tracking: Unlike the first script, this version does not include a progress bar to show the download status.
- Download Method: The first script uses 'requests' to handle the download, while this script relies on Instaloader's 'download_pic' method.

Overall, this script offers a straightforward approach to downloading Instagram videos, with a focus on user input and simplicity, 
but lacks progress indication during the download process.

Dependencies:
1. instaloader - Third-party library (install via pip)
2. os - Native library (no installation required)
3. time - Native library (no installation required)

Installation of Dependencies:
To install the required third-party dependency, run the following command:

pip install instaloader

This will install the 'instaloader' package necessary for the script to function properly. 
Ensure you have Python 3.x installed on your system.
"""

import instaloader
import time
import os

def download_video(link):
    # Instantiate Instaloader
    loader = instaloader.Instaloader()

    # Extract shortcode from URL
    shortcode = link.split("/")[-2]

    # Get Instagram post from shortcode
    post = instaloader.Post.from_shortcode(loader.context, shortcode)

    # Check if the post is a video
    if post.is_video:
        # Create the directory if it does not exist
        directory = './' + post.owner_username
        if not os.path.exists(directory):
            os.makedirs(directory)

        # Download the video
        timestamp = str(time.time())
        filename = directory + '/' + timestamp
        loader.download_pic(filename=filename, url=post.video_url, mtime=post.date_local)
        print("Vídeo baixado com sucesso!")
    else:
        print("A postagem não é um vídeo.")

if __name__ == "__main__":
    # Get the video link from Instagram
    link = input("Enter the Instagram video link: ")

    # Download the video
    download_video(link)
