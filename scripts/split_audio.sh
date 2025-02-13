#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script is designed to split an audio file into segments of a specified duration, defaulting to 3 minutes. 
It ensures that the input file exists and creates an output directory if it doesn't already exist. The script utilizes 
FFmpeg for the audio segmentation process.

Strengths:
1. Input Validation: Checks if the correct number of arguments is provided and verifies the existence of the input audio file.
2. Dynamic Duration: Allows for a default duration of 180 seconds, which can be easily modified.
3. Output Management: Automatically creates an output directory to store the segmented audio files.
4. FFmpeg Integration: Leverages FFmpeg's powerful capabilities for audio processing, ensuring high-quality output.
5. User -Friendly Messaging: Provides clear feedback to the user regarding the process and results. 

Capabilities:
- Splits audio files into smaller segments.
- Supports various audio file formats.
- Customizable segment duration.
DOCUMENTATION

if [ "$#" -ne 1 ]; then
    echo "Usage: duration=180 ${0##*/} <audio_file.ext>"
    exit 1
fi

input_audio="$1"
output_prefix="output"
duration="${duration:-180}"  # 3 minutes in seconds

# Check if the input audio file exists
if [ ! -f "$input_audio" ]; then
    echo "O arquivo de áudio de entrada não foi encontrado: $input_audio"
    exit 1
fi

# Obtain the input file extension
input_extension="${input_audio##*.}"

# Creates an exit directory if it does not exist
if [ ! -d "$output_prefix" ]; then
    mkdir "$output_prefix"
fi

# Uses FFmpeg to divide audio into 3 -minute files
ffmpeg -i "$input_audio" -f segment -segment_time "$duration" -c copy "$output_prefix/output_%03d.$input_extension"

echo "Áudio dividido em arquivos de $duration segundos no diretório '$output_prefix' com a extensão .$input_extension."
