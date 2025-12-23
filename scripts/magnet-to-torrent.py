#!/usr/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This script is designed to convert a magnet link into a .torrent file using the libtorrent library. 
It requires the 'libtorrent' package to function properly. The script takes two command-line arguments: 
a magnet link and an output path for the generated .torrent file. 

Key strengths of the script include:
1. Ease of Use: Simple command-line interface for converting magnet links.
2. Automatic Metadata Handling: Waits for metadata to be downloaded before creating the torrent file.
3. File Generation: Outputs a .torrent file to a specified location.
4. Warning Management: Suppresses warning messages for a cleaner output.
5. Modular Design: The main functionality is encapsulated in a dedicated function, making it easy to modify or extend.

Overall, this script provides a straightforward solution for users needing to convert magnet links into torrent files efficiently.

## Dependencies
1. libtorrent - Third-party library (install via pip)
2. sys - Native library (no installation required)
3. warnings - Native library (no installation required)
4. os - Native library (no installation required)

## Installation of Dependencies
To install the required third-party dependency, run the following command:

pip install python-libtorrent

This will install the 'libtorrent' package necessary for the script to function properly.
"""

import libtorrent as lt
import sys
import warnings
import os

script_name = os.path.basename(sys.argv[0])

def magnet_to_torrent(magnet_link, output_path):
    # Creating a torrent session
    ses = lt.session()
    
    # Adding the magnet link to the session
    params = {
        'save_path': '.', 
        'storage_mode': lt.storage_mode_t(2)
    }
    handle = lt.add_magnet_uri(ses, magnet_link, params)
    
    # Waiting until metadata is downloaded
    while not handle.has_metadata():
        continue
    
    # Getting the torrent information
    torrent_info = handle.get_torrent_info()
    
    # Creating a create_torrent object
    create_torrent = lt.create_torrent(torrent_info)
    
    # Generating the .torrent file
    with open(output_path, 'wb') as f:
        f.write(lt.bencode(create_torrent.generate()))
    
    print(f".torrent file saved at: {output_path}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: python {script_name} [MAGNET_LINK] [OUTPUT_PATH]")
        sys.exit(1)
    
    magnet_link = sys.argv[1]
    output_path = sys.argv[2]

    # Redirecting warning messages to be ignored
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")
        magnet_to_torrent(magnet_link, output_path)
