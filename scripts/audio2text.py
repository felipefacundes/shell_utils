#!/usr/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This script converts audio files in WAV format into text using the Google Speech Recognition API. 
It utilizes the 'speech_recognition' library to process the audio and save the recognized text to a specified output file. 
The script accepts command-line arguments for the input audio file, output text file, and language for recognition. 
It includes error handling for unrecognized audio and issues with the speech recognition service. 
The script provides usage instructions if the required arguments are not supplied.

Dependencies:
1. 'speech_recognition' - Third-party library for audio processing and speech recognition (install via pip).
2. 'argparse' - Native library for command-line argument parsing (no installation needed).

Installation of Dependencies:
- Install the 'speech_recognition' library using pip:
  
  pip install SpeechRecognition
"""

import speech_recognition as sr
import argparse

# Function to convert audio to text
def audio_to_text(input_file, output_file, language):
    recognizer = sr.Recognizer()

    with sr.AudioFile(input_file) as source:
        audio_data = recognizer.record(source)

    try:
        text = recognizer.recognize_google(audio_data, language=language)
        with open(output_file, "w") as output_file:
            output_file.write(text)
            print("Recognized text saved in", output_file)

    except sr.UnknownValueError:
        print("Could not recognize the audio.")

    except sr.RequestError as e:
        print("Error in the speech recognition service request; {0}".format(e))

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
