#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script is designed to convert audio files in a specified directory into text using an external Python script. 
It accepts an input directory and an optional language parameter, defaulting to English (en-US). 
The script checks for valid input and iterates through each WAV audio file in the directory. 
For each audio file, it generates a corresponding text file by invoking the external audio-to-text script. 
Finally, it concatenates all generated text files into a single output file named 'final.txt'.
DOCUMENTATION

audio2text=~/.shell_utils/scripts/audio2text.py

help() {
    echo "Usage: ${0##*/} input_directory language [default: en-US]

Example:
        ${0##*/} input_directory pt-BR"
}

# Check if the number of arguments is valid
if [[ -z "$1" ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    help
    exit 0
fi

# Input directory passed as an argument
input_dir="$1"

# Language for translation
language="${2:-en-US}"

# Check if the input directory is a valid directory
if [ ! -d "$input_dir" ]; then
    echo "The specified input directory is not valid."
    exit 1
fi

# Loop to process each audio file in the input directory
for audio_file in "${input_dir}"/*.[wW][aA][vV]; do
    # Generate the output file name for the text
    txt_file="${audio_file%.wav}.txt"

    # Run the audio transcription script to convert the file to text
    python "$audio2text" -i "$audio_file" -o "$txt_file" -l "$language"

    # Display a message to indicate progress
    echo "Audio file $audio_file converted to text as $txt_file"
done

cat "${input_dir}"/*.txt > final.txt