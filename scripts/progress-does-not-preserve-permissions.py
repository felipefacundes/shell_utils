#!/usr/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
Script Summary: Advanced Directory Copying Utility with Progress Tracking

Purpose:
A Python script designed to copy directories with a detailed progress bar, providing visual feedback during file transfer operations.

Strong Points:
1. Progress Tracking: Utilizes tqdm library to display real-time copy progress
2. Total File Size Calculation: Computes and tracks total transfer size
3. User-Friendly Interface: Simple command-line usage
4. Error Handling: Prevents overwriting existing destination directories
5. Large File Support: Reads and writes files in manageable 1MB chunks

Capabilities:
- Copies entire directory structures
- Shows transfer speed and estimated time remaining
- Handles large directories and files efficiently

Limitation:
- Does NOT preserve original file permissions during the copy process, which might be a critical consideration for system administrators 
or users requiring exact file attribute replication

Recommended Use:
Ideal for users needing a visually informative directory copy tool with clear progress indication.

Dependencies
1. tqdm - Third-party library (install via pip)
2. os - Native library (no installation required)
3. sys - Native library (no installation required)
4. shutil - Native library (no installation required)

### Installation of Dependencies
To install the required third-party dependency, run the following command:

pip install tqdm

This will install the 'tqdm' package necessary for the script to function properly. 
Ensure you have Python 3.x installed on your system.
"""

import os
import sys
from shutil import copytree
from tqdm import tqdm

def copy_with_progress(source, destination):
    try:
        copytree(source, destination, copy_function=copy_with_tqdm)
    except FileExistsError:
        print(f"The destination directory '{destination}' It already exists.")
        sys.exit(1)

def copy_with_tqdm(src, dst):
    if os.path.isdir(dst):
        dst = os.path.join(dst, os.path.basename(src))
    total_size = sum(os.path.getsize(os.path.join(dirpath, filename)) for dirpath, _, filenames in os.walk(src) for filename in filenames)

    with tqdm(total=total_size, unit='B', unit_scale=True, unit_divisor=1024, desc=os.path.basename(src)) as pbar:
        with open(src, 'rb') as fsrc:
            with open(dst, 'wb') as fdst:
                while True:
                    buf = fsrc.read(1024 * 1024)
                    if not buf:
                        break
                    fdst.write(buf)
                    pbar.update(len(buf))

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: copy-progress.py origin destination")
        sys.exit(1)

    source_dir = sys.argv[1]
    dest_dir = sys.argv[2]
    copy_with_progress(source_dir, dest_dir)
