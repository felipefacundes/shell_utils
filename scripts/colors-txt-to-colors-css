#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script is a versatile color-to-CSS conversion utility that transforms a 
text file of color codes into a CSS stylesheet. Its key strengths include 
multilingual support with dynamic language detection, robust input validation, 
and efficient color class generation. The script automatically creates 
CSS classes for each color, allowing easy background color styling, and provides clear, 
localized usage instructions and error messages. It demonstrates flexible file processing 
capabilities with built-in error handling and user-friendly output.
DOCUMENTATION

# Declare an associative array for messages in both languages
declare -A MESSAGES

# Check language setting (English or Portuguese)
if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        ["usage_script"]="Uso: ${0##*/} colors.txt colors.css"
        ["error"]="Erro: Número insuficiente de parâmetros."
        ["finished"]="Finalizado"
    )
else
    MESSAGES=(
        ["usage_script"]="Usage: ${0##*/} colors.txt colors.css"
        ["error"]="Error: Insufficient number of parameters."
        ["finished"]="Finished"
    )
fi

# Input file containing the colors
input_file="$1"
# Output CSS file
output_file="$2"

# Check if the required number of arguments is passed
if [ $# -lt 2 ]; then
    echo -e "${MESSAGES['error']}"
    echo -e "${MESSAGES['usage_script']}"
    exit 1
fi

# Clear the output file if it already exists
> "$output_file"

# Read each line of the input file
while IFS= read -r cor; do
    # Remove leading and trailing spaces from the line
    cor=$(echo "$cor" | tr -d '[:space:]')
    # Check if the line is not empty
    if [ -n "$cor" ]; then
        # Write the corresponding CSS class to the output file
        echo ".color-${cor:1} { background-color: $cor; }" >> "$output_file"
    fi
done < "$input_file"

# Print finished message
echo -e "\n${MESSAGES['finished']}\n"
