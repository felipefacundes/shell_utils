#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script is designed to convert audio files in a specified input directory into text using an external Python script. 
It begins by validating the input directory and checking for audio files within it. A loop processes each audio file, 
invoking the external transcription script to generate corresponding text files. After processing, it concatenates all 
generated text files into a single output file named 'final.txt'. The script provides usage instructions and handles errors related to invalid input.
DOCUMENTATION

audio2text=~/.shell_utils/scripts/audio2text_whisper.py

help() {
    echo "Usage: ${0##*/} input_directory

Example:
        ${0##*/} input_directory"
}

# Check if the number of arguments is valid
if [[ -z "$1" ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    help
    exit 0
fi

if [[ ! -d ~/.python/whisper ]]; then
    python -m venv ~/.python/whisper
    source ~/.python/whisper/bin/activate
    export VIRTUAL_ENV="${HOME}/.python/whisper"
	pip install git+https://github.com/openai/whisper.git
fi

if [[ -z "$VIRTUAL_ENV" ]]; then
    export VIRTUAL_ENV="${HOME}/.python/whisper"
    source "${VIRTUAL_ENV}/bin/activate"
fi


# Input directory passed as an argument
input_dir="$1"

# Check if the input directory is a valid directory
if [ ! -d "$input_dir" ]; then
    echo "The specified input directory is not valid."
    exit 1
fi

# Loop to process each audio file in the input directory
for audio_file in "${input_dir}"/*.*; do
    if file -b --mime-type "${audio_file}" | grep audio >/dev/null; then 
        # Generate the output filename for the text
        txt_file="${audio_file%.*}.txt"

        # Run the audio transcription script to convert the file to text
        python "$audio2text" -i "$audio_file" -o "$txt_file"

        # Display a message to indicate progress
        echo "Audio file $audio_file converted to text as $txt_file"
    fi
done

[[ -e final.txt ]] && rm -rf final.txt
[[ ! -f final.txt ]] && touch final.txt

#cat "${input_dir}"/*.txt > final.txt

for txt_file in "${input_dir}"/*.txt; do
    # Concatenate the text file to final.txt
    cat "$txt_file" >> final.txt
    # Add a newline at the end of final.txt
    echo "" >> final.txt
done