#!/usr/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This script converts audio files in WAV format into text using the DeepSpeech speech-to-text engine. 
It loads a pre-trained DeepSpeech model to process the audio data and generate the corresponding text output. 
The script accepts command-line arguments for specifying the input audio file and the desired output text file. 
It includes error handling to provide usage instructions if the required arguments are not provided. 
The recognized text is saved to the specified output file, and a confirmation message is displayed.

Dependencies:
1. deepspeech - Third-party library (install via pip, for speech-to-text conversion)
2. numpy - Third-party library (install via pip, for numerical operations on audio data)
3. wave - Native library (no installation required, for reading WAV audio files)
4. argparse - Native library (no installation required, for command-line argument parsing)

Installation of Dependencies:
To install the required third-party dependencies, run the following commands:

pip install deepspeech numpy

This will install the 'deepspeech' and 'numpy' packages necessary for the script to function properly. 
Additionally, ensure you have the pre-trained DeepSpeech model file ('deepspeech-0.9.3-models.pbmm') available in the script's directory.
"""

import argparse
import deepspeech
import numpy as np
import wave

def audio_to_text(input_file, output_file):
    model_file_path = 'deepspeech-0.9.3-models.pbmm'  # Way to the pre-trained model
    model = deepspeech.Model(model_file_path)

    with wave.open(input_file, 'rb') as fin:
        audio = np.frombuffer(fin.readframes(fin.getnframes()), np.int16)

    text = model.stt(audio)
    
    with open(output_file, "w") as output_file:
        output_file.write(text)
        print("Recognized text saved in", output_file)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Converts audio in .wav format, up to 3 minutes, into a text file.")
    parser.add_argument("-i", "--input", help="Input audio file (e.g., my_audio.wav)")
    parser.add_argument("-o", "--output", help="Name of the output file (e.g., output_file.txt)")

    args = parser.parse_args()

    if args.input is None or args.output is None:
        parser.print_help()
    elif args.input is not None and args.input.lower() == "-h":
        parser.print_help()
    else:
        audio_to_text(args.input, args.output)
