#!/usr/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This Python script converts audio files in WAV format into text using Google Cloud's Speech-to-Text API. 
It accepts command-line arguments for the input audio file, output text file, and the language for speech recognition, 
defaulting to English (en-US). The script reads the audio file, processes it through the Google Cloud client, 
and saves the recognized text to the specified output file. It also includes error handling for missing input or output arguments. 
To run this script, ensure that the necessary dependencies are installed.

Dependencies:
1. google-cloud-speech (third-party, install via pip)
   - Installation: pip install google-cloud-speech
2. argparse (native, included with Python standard library)

Make sure you have a Google Cloud account and the appropriate credentials set up to use the Speech-to-Text API.
"""

import argparse
from google.cloud import speech_v1p1beta1 as speech

def audio_to_text(input_file, output_file, language):
    client = speech.SpeechClient()

    with open(input_file, "rb") as audio_file:
        audio = speech.RecognitionAudio(content=audio_file.read())

    config = speech.RecognitionConfig(
        encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
        sample_rate_hertz=16000,
        language_code=language,
        enable_automatic_punctuation=True,
    )

    response = client.recognize(config=config, audio=audio)

    for result in response.results:
        print("Transcript: {}".format(result.alternatives[0].transcript))

    with open(output_file, "w") as output_file:
        output_file.write(result.alternatives[0].transcript)
        print("Recognized text saved in", output_file)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Converts audio in .wav format, up to 3 minutes, into a text file.")
    parser.add_argument("-i", "--input", help="Input audio file (e.g., my_audio.wav)")
    parser.add_argument("-o", "--output", help="Name of the output file (e.g., output_file.txt)")
    parser.add_argument("-l", "--language", help="Language for speech recognition (default: en-US)", default="en-US")

    args = parser.parse_args()

    if args.input is None or args.output is None:
        parser.print_help()
    elif args.input is not None and args.input.lower() == "-h":
        parser.print_help()
    else:
        audio_to_text(args.input, args.output, args.language)
