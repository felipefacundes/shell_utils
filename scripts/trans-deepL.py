#!/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
The provided script is a command-line interface (CLI) tool for translating text using the DeepL translation service. 
Its main purpose is to facilitate the translation of text either directly from the command line or from input files, 
making it versatile for various user needs.

Key strengths:
1. User -Friendly Interface: Utilizes argparse for easy command-line argument parsing.
2. Flexible Input Options: Supports both direct text input and file-based input/output.
3. Automatic Language Detection: Automatically detects the source language, allowing for seamless translations.
4. Integration with DeepL: Leverages the DeepL translation API for high-quality translations.
5. Modular Design: Easily extendable for future enhancements or additional features.

Capabilities:
- Translate text directly from the command line.
- Read from an input file and write translations to an output file.
- Handle multiple text inputs efficiently.

$ python -m venv .venv
$ source .venv/bin/activate
$ pip install deepl-cli --break-system-packages

Requeriments:

deepl_cli==0.6.0
greenlet==3.0.1
install-playwright==0.0.0
playwright==1.40.0
pyee==11.0.1
typing_extensions==4.9.0

## Dependencies
1. argparse - Native library (no installation required)
2. deepl-cli - Third-party library (install via pip)
3. greenlet - Third-party library (install via pip)
4. install-playwright - Third-party library (install via pip)
5. playwright - Third-party library (install via pip)
6. pyee - Third-party library (install via pip)
7. typing_extensions - Third-party library (install via pip)

### Installation of Dependencies
To set up the environment and install the required dependencies, run the following commands:

python -m venv .venv
source .venv/bin/activate
pip install deepl-cli --break-system-packages

This will install the 'deepl-cli' package along with its dependencies, including 'greenlet', 'install-playwright', 
'playwright', 'pyee', and 'typing_extensions'.
"""

import argparse
from deepl import DeepLCLI

parser = argparse.ArgumentParser()
parser.add_argument("-l", "--lang", required=True, help="Target language")
parser.add_argument("text", nargs="*", help="Text to be translated")  # Positional argument for the text
parser.add_argument("-i", "--input", help="Input file")
parser.add_argument("-o", "--output", help="Output file")  
args = parser.parse_args()

deepl = DeepLCLI("auto", args.lang)

if args.text:
    # Text mode
    text = ' '.join(args.text)
    translated = deepl.translate(text)
    print(translated)

elif args.input and args.output:
    # File mode
    with open(args.input, 'r') as f_input: 
        text = f_input.read()
        
    translated = deepl.translate(text)
    
    with open(args.output, 'w') as f_output:
        f_output.write(translated)

else:
    print("No text or file provided.")

