#!/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This script is designed to download videos from Instagram posts using the Instaloader library, providing a straightforward command-line interface for users. 
Its primary purpose is to enable users to easily retrieve video content from Instagram.

Key strengths include:
1. Video Verification: The script checks if the specified post is a video before proceeding with the download.
2. Dynamic Directory Creation: It automatically creates a directory for the user based on the post owner's username, ensuring organized 
storage of downloaded content.
3. Simple Download Process: Utilizes the Instaloader's built-in functionality to download videos directly, simplifying the code.
4. Error Notification: Provides feedback to the user if the post is not a video, enhancing usability.
5. Command-Line Interface: Accepts an Instagram link as a command-line argument, making it easy to use in various environments.

However, it is important to note that this script does not show the progress of the download, which may limit user awareness of the download status. 
Overall, it offers a simple and effective way to download Instagram videos.

## Dependencies
1. instaloader - Third-party library (install via pip)
2. os - Native library (no installation required)
3. sys - Native library (no installation required)
4. time - Native library (no installation required)

## Installation of Dependencies
To install the required third-party dependency, run the following command:

pip install instaloader

This will install the 'instaloader' package necessary for the script to function properly.
"""

import instaloader
import time
import os
import sys

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
    # Check if the Instagram link is passed as an argument
    if len(sys.argv) != 2:
        print("Uso: script <link do Instagram>")
        sys.exit(1)

    # Get the video link from Instagram
    link = sys.argv[1]

    # Download the video
    download_video(link)
