#!/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This Python script generates and plays a sound at a specified frequency, with the added feature of exporting the audio to a WAV file. 
It accepts command-line arguments for frequency in Hertz and an optional output file name. The script calculates the sound signal and 
plays it for one second, while also saving the audio to the specified file if provided. This makes it suitable for users who want to
create and store audio tones programmatically.

Dependencies:
1. sounddevice - Third-party library (install via pip)
2. numpy - Third-party library (install via pip)
3. wave - Native library (no installation required)
4. argparse - Native library (no installation required)
5. sys - Native library (no installation required)

Installation of Dependencies:
To install the required third-party dependencies, run the following commands:

pip install sounddevice numpy

This will install the 'sounddevice' and 'numpy' packages necessary for the script to function properly. 
Ensure you have Python 3.x installed on your system.
"""

import sys
import argparse
import numpy as np
import sounddevice as sd
import wave

def freq_sound(frequency, output_file=None):
    # Duration in seconds of sound
    duration = 1.0

    # Calculate the number of necessary frames
    num_frames = int(duration * frequency)

    # Generates the sound signal based on frequency
    signal = (np.sin(2 * np.pi * np.arange(num_frames) * frequency / sd.query_devices(0, 'input')['default_samplerate'])).astype(np.float32)

    try:
        # Plays the sound
        sd.play(signal, samplerate=sd.query_devices(0, 'input')['default_samplerate'])
        sd.wait()

        # If an output file is supplied, record the sound in it
        if output_file:
            with wave.open(output_file, 'w') as wf:
                wf.setnchannels(1)
                wf.setsampwidth(2)
                wf.setframerate(sd.query_devices(0, 'input')['default_samplerate'])
                wf.writeframes((signal * 32767).astype(np.int16).tobytes())
    except Exception as e:
        print(f"Erro: {e}")
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generates a sound at the specified frequency.")
    parser.add_argument("-f", "--frequency", type=float, required=True, help="Frequency in Hz (Hertz)")
    parser.add_argument("-o", "--output", help="Output file name (without extension)")

    args = parser.parse_args()

    if args.output:
        output_file = args.output + ".wav"
        freq_sound(args.frequency, output_file)
    else:
        freq_sound(args.frequency)
