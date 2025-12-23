#!/usr/bin/env python
# License: GPLv3
# Credits: Felipe Facundes
# https://github.com/openai/whisper

"""
This script utilizes OpenAI's Whisper model to convert audio files in .wav format into text. It loads an audio file, 
processes it to fit within a 30-second duration, and generates a log-Mel spectrogram for decoding. The recognized text is 
then saved to a specified output file. The script can be executed from the command line, requiring input and output file arguments.

Dependencies:

- Python 3.x
- Whisper library (install via: 'pip install git+https://github.com/openai/whisper.git --break-system-packages')
- Argparse (included in Python standard library)
"""

import argparse
import whisper

# Function to convert audio to text using Whisper
def audio_to_text(input_file, output_file):
    model = whisper.load_model("base")

    # Load the audio and adjust/trim to fit within 30 seconds
    audio = whisper.load_audio(input_file)
    audio = whisper.pad_or_trim(audio)

    # Create the log-Mel spectrogram and move it to the same device as the model
    mel = whisper.log_mel_spectrogram(audio).to(model.device)

    # Decode the audio
    options = whisper.DecodingOptions()
    result = whisper.decode(model, mel, options)

    # Save the recognized text
    with open(output_file, "w") as output_file:
        output_file.write(result.text)
        print("Recognized text saved in", output_file)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Converts .wav audio of up to 3 minutes into a text file.")
    parser.add_argument("-i", "--input", help="Input audio file (e.g., my_audio.wav)")
    parser.add_argument("-o", "--output", help="Name of the output file (e.g., output_file.txt)")

    args = parser.parse_args()

    if args.input is None or args.output is None:
        parser.print_help()
    elif args.input is not None and args.input.lower() == "-h":
        parser.print_help()
    else:
        audio_to_text(args.input, args.output)