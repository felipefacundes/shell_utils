#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script detects the number of unique colors in a specified image and classifies it,
supporting both English and Portuguese languages. It begins by checking 
if ImageMagick is installed and verifies that an image path is provided as an argument. 
If any checks fail, it displays appropriate error messages. The script uses the ImageMagick 
command to count the unique colors in the image and outputs the result. Additionally, 
it includes a help function to guide users on how to use the script correctly.
DOCUMENTATION

# Associative array to store messages in both languages
declare -A MESSAGES

if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        ["usage"]="Uso: $0 <caminho_da_imagem>"
        ["description"]="Detecta a quantidade de cores em uma imagem e classifica."
        ["imagemagick_error"]="Erro: ImageMagick não está instalado. Instale-o para usar este script."
        ["missing_image_path"]="Erro: Caminho da imagem não fornecido."
        ["file_not_found"]="Erro: Arquivo não encontrado: "
        ["color_count"]="A imagem '$IMAGE_PATH' contém $COLOR_COUNT cores únicas."
    )
else
    MESSAGES=(
        ["usage"]="Usage: $0 <image_path>"
        ["description"]="Detects the number of colors in an image and classifies it."
        ["imagemagick_error"]="Error: ImageMagick is not installed. Install it to use this script."
        ["missing_image_path"]="Error: Image path not provided."
        ["file_not_found"]="Error: File not found: "
        ["color_count"]="The image '$IMAGE_PATH' contains $COLOR_COUNT unique colors."
    )
fi

# Function to show help
show_help() {
    echo "${MESSAGES["usage"]}"
    echo "${MESSAGES["description"]}"
    exit 1
}

# Check if ImageMagick is installed
if ! command -v magick &>/dev/null && ! command -v convert &>/dev/null; then
    echo "${MESSAGES["imagemagick_error"]}"
    exit 1
fi

# Check if the image path was provided
if [ $# -ne 1 ]; then
    show_help
fi

# Define the ImageMagick command (magick or convert)
IM_CMD=$(command -v magick || command -v convert)

# Image path
IMAGE_PATH="$1"

# Check if the file exists
if [ ! -f "$IMAGE_PATH" ]; then
    echo "${MESSAGES["file_not_found"]}$IMAGE_PATH"
    exit 1
fi

# Count the number of unique colors in the image
COLOR_COUNT=$($IM_CMD "$IMAGE_PATH" -format %k info:)

# Display the result
echo "${MESSAGES["color_count"]}"
