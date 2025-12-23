#!/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This script is designed to download videos from Instagram posts using the Instaloader library. Its main purpose is to facilitate 
the retrieval of video content from Instagram by providing a simple command-line interface. 

Key strengths include:
1. Video Verification: The script checks if the specified post is a video before attempting to download it.
2. Dynamic Directory Creation: It automatically creates a directory for the user if it does not already exist, organizing downloaded content effectively.
3. Progress Tracking: Utilizes the 'tqdm' library to display a progress bar during the download process, enhancing user experience.
4. Error Handling: Includes basic error handling to notify users if the download fails or if the post is not a video.
5. Command-Line Interface: Accepts an Instagram link as a command-line argument, making it easy to use in various environments.

Overall, the script provides a straightforward and efficient way to download Instagram videos while ensuring a user-friendly experience.

Dependencies:
1. instaloader - Third-party library (install via pip)
2. tqdm - Third-party library (install via pip)
3. requests - Third-party library (install via pip)
4. os - Native library (no installation required)
5. sys - Native library (no installation required)
6. time - Native library (no installation required)

Installation of Dependencies:
To install the required third-party dependencies, run the following commands:

pip install instaloader tqdm requests

This will install the 'instaloader', 'tqdm', and 'requests' packages necessary for the script to function properly. 
Ensure you have Python 3.x installed on your system.
"""

import instaloader
import time
import os
import sys
import requests
from tqdm import tqdm

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
        filename = directory + '/' + timestamp + '.mp4'
        
        response = requests.get(post.video_url, stream=True)
        total_size_in_bytes= int(response.headers.get('content-length', 0))
        progress_bar = tqdm(total=total_size_in_bytes, unit='iB', unit_scale=True)
        
        with open(filename, 'wb') as file:
            for data in response.iter_content(chunk_size=1024):
                progress_bar.update(len(data))
                file.write(data)
        progress_bar.close()
        
        if total_size_in_bytes != 0 and progress_bar.n != total_size_in_bytes:
            print("ERRO, algo deu errado durante o download!")
        else:
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
