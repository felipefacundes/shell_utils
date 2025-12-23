#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script checks for the installation of ImageMagick and retrieves the color space of a specified image file. 
It supports both English and Portuguese languages, displaying appropriate error messages based on the user's language setting. 
The script first verifies if ImageMagick is installed, then checks if an image file argument is provided and exists. 
If any checks fail, it outputs relevant error messages. Finally, it retrieves and displays the color space of the specified image.
DOCUMENTATION

# Declare an associative array for messages in both languages
declare -A MESSAGES

# Check language setting (English or Portuguese)
if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        ["imagem_magick"]="Erro: ImageMagick não está instalado. Instale-o para usar este script."
        ["usage_script"]="Uso: $0 <imagem>"
        ["file_not_found"]="Erro: Arquivo '$IMAGE' não encontrado."
        ["error_color_space"]="Erro: Não foi possível analisar o espaço de cores da imagem."
        ["color_space"]="Espaço de cores da imagem '$IMAGE': $COLOR_SPACE"
    )
else
    MESSAGES=(
        ["imagem_magick"]="Error: ImageMagick is not installed. Install it to use this script."
        ["usage_script"]="Usage: $0 <image>"
        ["file_not_found"]="Error: File '$IMAGE' not found."
        ["error_color_space"]="Error: Unable to analyze the image's color space."
        ["color_space"]="Color space of image '$IMAGE': $COLOR_SPACE"
    )
fi

# Checks if ImageMagick is installed
if ! command -v identify &> /dev/null; then
    echo "${MESSAGES['imagem_magick']}"
    exit 1
fi

# Checks if an argument was passed
if [ $# -eq 0 ]; then
    echo "${MESSAGES['usage_script']}"
    exit 1
fi

# Image file path
IMAGE="$1"

# Checks if the file exists
if [ ! -f "$IMAGE" ]; then
    echo "${MESSAGES['file_not_found']}"
    exit 1
fi

# Retrieves the image's color space
COLOR_SPACE=$(identify -format "%[colorspace]" "$IMAGE" 2>/dev/null)

# Checks if there was an error identifying the image
if [ $? -ne 0 ]; then
    echo "${MESSAGES['error_color_space']}"
    exit 1
fi

# Displays the color space
echo "${MESSAGES['color_space']}"
