#!/usr/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This Python script is designed to extract various compressed file formats based on their extensions. 
It uses the 'subprocess' module to call appropriate extraction commands for formats such as 
'.tar.bz2', '.tar.gz', '.zip', '.rar', and more. The script checks the file extension and executes 
the corresponding extraction command, handling multiple formats including '.7z', '.iso', and '.exe'. 
If the user does not provide exactly one argument (the file to extract), it displays a usage message and exits. 
The script ensures that a wide range of common archive formats can be easily extracted from the command line. 
Overall, it provides a convenient tool for file extraction in a single script.
"""

import os
import subprocess
import sys

def extract_file(file_path):
    file_name, file_extension = os.path.splitext(file_path)

    if file_extension.lower() in ['.tar.bz2', '.tar.tbz2']:
        subprocess.call(['tar', 'xvjf', file_path])
    elif file_extension.lower() == '.tar.gz':
        subprocess.call(['tar', 'xvzf', file_path])
    elif file_extension.lower() == '.tar.xz':
        subprocess.call(['tar', 'xvJf', file_path])
    elif file_extension.lower() == '.tar.zst':
        subprocess.call(['tar', 'xvf', file_path])
    elif file_extension.lower() == '.lzma':
        subprocess.call(['unlzma', file_path])
    elif file_extension.lower() == '.bz2':
        subprocess.call(['bunzip2', file_path])
    elif file_extension.lower() == '.rar':
        subprocess.call(['unrar', 'x', '-ad', file_path])
    elif file_extension.lower() == '.gz':
        subprocess.call(['gunzip', file_path])
    elif file_extension.lower() == '.tar':
        subprocess.call(['tar', 'xvf', file_path])
    elif file_extension.lower() == '.tbz2':
        subprocess.call(['tar', 'xvjf', file_path])
    elif file_extension.lower() == '.tgz':
        subprocess.call(['tar', 'xvzf', file_path])
    elif file_extension.lower() == '.zip':
        subprocess.call(['unzip', file_path])
    elif file_extension.lower() == '.zst':
        subprocess.call(['unzstd', file_path])
    elif file_extension.lower() == '.z':
        subprocess.call(['uncompress', file_path])
    elif file_extension.lower() == '.7z':
        subprocess.call(['7z', 'x', file_path])
    elif file_extension.lower() == '.iso':
        subprocess.call(['7z', 'x', file_path])
    elif file_extension.lower() == '.xz':
        subprocess.call(['unxz', file_path])
    elif file_extension.lower() == '.exe':
        subprocess.call(['cabextract', file_path])

if len(sys.argv) != 2:
    print("Uso: python script.py arquivo.extensao")
    sys.exit(1)

file_to_extract = sys.argv[1]
extract_file(file_to_extract)
