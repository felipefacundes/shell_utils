#!/usr/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This Python script facilitates the copying of files and directories while providing a progress bar for better user experience. 
It checks if the destination directory already exists and exits with an error message if it does. 
The script recursively copies the contents of the source directory to the destination, updating the progress bar for each file copied. 
It utilizes the 'tqdm' library to display the progress of the file copying process. 
The script requires two command-line arguments: the source and destination directories.

Dependencies:
1. 'os' - Native library for interacting with the operating system (no installation needed).
2. 'sys' - Native library for system-specific parameters and functions (no installation needed).
3. 'shutil' - Native library for file operations (no installation needed).
4. 'tqdm' - Third-party library for displaying progress bars (install via pip).

Installation of Dependencies:
- Install the 'tqdm' library using pip:
  
  pip install tqdm
"""

import os
import sys
from shutil import copy2
from tqdm import tqdm

def copy_with_progress(source, destination):
    try:
        copytree_with_progress(source, destination)
    except FileExistsError:
        print(f"The destination directory '{destination}' It already exists.")
        sys.exit(1)

def copytree_with_progress(source, destination):
    if not os.path.exists(destination):
        os.makedirs(destination)
    
    for item in os.listdir(source):
        src_path = os.path.join(source, item)
        dest_path = os.path.join(destination, item)
        
        if os.path.isdir(src_path):
            copytree_with_progress(src_path, dest_path)
        else:
            copy_with_tqdm(src_path, dest_path)

def copy_with_tqdm(src, dst):
    total_size = os.path.getsize(src)
    with tqdm(total=total_size, unit='B', unit_scale=True, unit_divisor=1024, desc=os.path.basename(src)) as pbar:
        copy2(src, dst)
        pbar.update(total_size)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: copy-progress.py Origin destination")
        sys.exit(1)

    source_dir = sys.argv[1]
    dest_dir = sys.argv[2]
    copy_with_progress(source_dir, dest_dir)
