#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
The provided script is a Bash script designed to facilitate the translation of text files using a Python script ('trans_deepL.py'). Its primary purpose is to read an input file, translate its contents line by line into a specified language, and save the results to an output file while ensuring that the output file does not already exist. 

Strengths:
1. Argument Validation: The script checks for the correct number of arguments and validates input options.
2. File Existence Check: It ensures that the output file does not overwrite existing files, preventing data loss.
3. Line-by-Line Processing: The script processes the input file line by line, allowing for efficient handling of large files.
4. Checksum Verification: It calculates and compares MD5 checksums of the input and output files to verify data integrity.
5. User -Friendly Messages: The script provides clear usage instructions and error messages to guide the user.

Capabilities:
- Accepts input and output file names along with a language option.
- Translates text using an external Python script.
- Outputs translated text to a specified file while displaying the original text in the terminal.
DOCUMENTATION

# Checking if the number of arguments is valid
if [ "$#" -ne 6 ]; then
    echo "Usage: ${0##*/} -i input_file -o output_file"
    exit 1
fi

# Initializing variables
SCRIPT=~/.shell_utils/scripts/trans_deepL.py
input_file=""
output_file=""
language=""

# Reading arguments
while getopts ":i:o:l:" opt; do
    case $opt in
        i)
            input_file="$OPTARG"
            ;;
        o)
            output_file="$OPTARG"
            ;;
        l)
            language="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

# Checking if both input and output files are specified
if [ -z "$input_file" ] || [ -z "$output_file" ]; then
    echo "Both input and output files must be specified."
    exit 1
fi

# Checking if the output file already exists
if [ -e "$output_file" ]; then
    echo "The output file '$output_file' already exists. Please choose a different file name."
    exit 1
fi

# Copying line by line and displaying the output in the terminal
while IFS= read -r line; do
    echo "$line"
    "$SCRIPT" -l "$language" "$line" >> "$output_file"
done < "$input_file"

# Calculating the md5sum for the files
MD5_INPUT=$(md5sum "$input_file" | awk '{print $1}')
MD5_OUTPUT=$(md5sum "$output_file" | awk '{print $1}')

# Checking if the md5sums are equal
if [ "$MD5_INPUT" = "$MD5_OUTPUT" ]; then
    echo "The md5sums of the files are equal."
else
    echo "The md5sums of the files are different."
fi
