#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script is designed to reverse a video using the FFmpeg tool. It checks if the correct number of arguments is 
provided and verifies the existence of the input file, ensuring a smooth process. At the end, the script generates a new 
video file with the suffix "-reverse."

Strengths:
1. Input validation: Ensures the user provides exactly one input file.
2. Existence check: Confirms that the input file actually exists before proceeding.
3. File manipulation: Extracts the file extension and creates a new name for the output file.
4. Use of FFmpeg: Utilizes a powerful tool for video manipulation, allowing for the reversal of both video and audio.
5. Completion message: Informs the user where the reversed video has been saved, enhancing user experience.
DOCUMENTATION

# Check if the number of arguments is appropriate
if [ "$#" -ne 1 ]; then
    echo "Usage: ${0##*/} <input file>"
    exit 1
fi

# Attributes the argument to a variable
input_file="$1"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "O arquivo de entrada não existe."
    exit 1
fi

# Extracts the extension of the input file
file_extension="${input_file##*.}"

# Creates the name of the output file with the suffix -reversse
output_file="${input_file%.*}-reverse.${file_extension}"

# Uses FFmpeg to reverse the video
ffmpeg -i "${input_file}" -vf reverse -af areverse "${output_file}"

echo "Inverted video saved as $output_file"
