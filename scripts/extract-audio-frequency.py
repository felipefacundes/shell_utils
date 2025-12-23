#!/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This Python script extracts significant frequencies from a WAV audio file using the 'librosa' library. 
It computes the Short-Time Fourier Transform (STFT) of the audio data to analyze its frequency content, 
identifies frequencies with average magnitudes above a specified threshold, and saves these frequencies 
to a specified output text file. The script utilizes command-line arguments for input and output file paths, 
making it user-friendly for audio analysis tasks. It is designed to facilitate the extraction of relevant 
frequency information for further analysis or processing.

Dependencies:

1. librosa - Third-party library (install via pip)
2. numpy - Third-party library (install via pip)
3. argparse - Native library (no installation required)
4. soundfile - Third-party library (implicitly required by librosa for audio file handling; install via pip)

### Installation of Dependencies
To install the required third-party dependencies, run the following commands:

pip install librosa numpy soundfile

This will install the 'librosa', 'numpy', and 'soundfile' packages necessary for the script to function properly. 
Ensure you have Python 3.x installed on your system.
"""

import librosa
import argparse
import numpy as np

def extract_frequencies(input_file, output_file):
    # Load the audio file using librosa
    audio_data, sampling_rate = librosa.load(input_file)

    # Calculate the Short-Time Fourier Transform (STFT)
    stft = librosa.stft(audio_data)
    magnitudes = np.abs(stft)

    # Find the average magnitude along the time axis
    average_magnitudes = np.mean(magnitudes, axis=1)

    # Calculate the frequencies corresponding to the STFT
    frequencies = librosa.fft_frequencies(sr=sampling_rate, n_fft=stft.shape[0])

    # Find the relevant frequencies with significant average magnitude
    relevant_indices = np.where(average_magnitudes > np.max(average_magnitudes) * 0.1)  # Adjust the threshold as needed
    relevant_frequencies = frequencies[relevant_indices]

    # Save the frequencies to the output file in numeric format
    with open(output_file, 'w') as file:
        for freq in relevant_frequencies:
            file.write(str(freq) + '\n')

def main():
    # Set up the command-line argument parser
    parser = argparse.ArgumentParser(description='Extract frequencies from a WAV audio file.')
    parser.add_argument('-f', '--input_file', required=True, help='Path to the WAV audio file.')
    parser.add_argument('-o', '--output_file', required=True, help='Path to the output TXT file.')

    # Parse the command-line arguments
    args = parser.parse_args()

    # Extract frequencies and save to the output file
    extract_frequencies(args.input_file, args.output_file)

if __name__ == "__main__":
    main()