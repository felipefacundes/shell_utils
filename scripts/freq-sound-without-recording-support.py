#!/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This Python script generates and plays a sound at a specified frequency using the 'sounddevice' library. 
It accepts a frequency argument in Hertz via command-line input and calculates the necessary signal to produce the sound. 
The script handles potential errors during playback and ensures the sound plays for one second. It is designed for users who want 
to generate audio tones programmatically.

Dependencies:
1. sounddevice - Third-party library (install via pip)
2. numpy - Third-party library (install via pip)
3. argparse - Native library (no installation required)
4. sys - Native library (no installation required)

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

def freq_sound(frequency):
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
    except Exception as e:
        print(f"Erro: {e}")
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generates a sound at the specified frequency.")
    parser.add_argument("-f", "--frequency", type=float, required=True, help="Frequency in Hz (Hertz)")

    args = parser.parse_args()
    freq_sound(args.frequency)
