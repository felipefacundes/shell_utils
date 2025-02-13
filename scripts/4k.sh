#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This bash script is a robust image conversion utility that specializes in converting images 
to 4K resolution with optimized quality. It supports multiple image formats (JPG, PNG, and WebP) 
and offers various conversion modes. The script's key strengths include bilingual support (English/Portuguese) 
through a message system, intelligent handling of batch operations, and comprehensive image optimization parameters 
using ImageMagick. It provides options for both preserving original files with new "-4k" suffixed versions or replacing 
them entirely. The image processing includes advanced parameters like adaptive resizing, contrast stretching, color space 
optimization, and adaptive sharpening, all configured to produce high-quality 4K output. Notable features include JPEG 
optimization using jpegoptim, consistent 16-bit color depth processing, and careful handling of image quality through 
multiple optimization steps.
DOCUMENTATION

declare -A MESSAGES

if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        ["usage"]="Uso: ${0##*/} [opções]"
        ["options"]="Opções:"
        ["help"]="Exibe este menu de ajuda."
        ["convert_single"]="Converte uma única imagem para resolução 4k com qualidade otimizada."
        ["convert_jpg_all"]="Converte todas as imagens JPG para resolução 4k e as otimiza."
        ["convert_png_all"]="Converte todas as imagens PNG para resolução 4k."
        ["convert_webp_all"]="Converte todas as imagens WEBP para resolução 4k."
        ["convert_jpg_replace"]="Converte todas as imagens JPG para resolução 4k, substituindo os originais."
        ["convert_png_replace"]="Converte todas as imagens PNG para resolução 4k, substituindo os originais."
        ["convert_webp_replace"]="Converte todas as imagens WEBP para resolução 4k, substituindo os originais."
        ["examples"]="Exemplos:"
        ["invalid_command"]="Comando inválido. Use '${0##*/} help' para ajuda."
        ["convert_message"]="A imagem será convertida na resolução 4k"
        ["command_to_execute"]="Comando a ser executado:"
    )
else
    MESSAGES=(
        ["usage"]="Usage: ${0##*/} [options]"
        ["options"]="Options:"
        ["help"]="Displays this help menu."
        ["convert_single"]="Converts a single image to 4k resolution with optimized quality."
        ["convert_jpg_all"]="Converts all JPG images to 4k resolution and optimizes them."
        ["convert_png_all"]="Converts all PNG images to 4k resolution."
        ["convert_webp_all"]="Converts all WEBP images to 4k resolution."
        ["convert_jpg_replace"]="Converts all JPG images to 4k resolution, replacing the originals."
        ["convert_png_replace"]="Converts all PNG images to 4k resolution, replacing the originals."
        ["convert_webp_replace"]="Converts all WEBP images to 4k resolution, replacing the originals."
        ["examples"]="Examples:"
        ["invalid_command"]="Invalid command. Use '${0##*/} help' for help."
        ["convert_message"]="The image will be converted to 4k resolution"
        ["command_to_execute"]="Command to be executed:"
    )
fi

# Function to display the help menu
function help_menu() {
    echo "${MESSAGES["usage"]}"
    echo
    echo "${MESSAGES["options"]}"
    echo "  help      ${MESSAGES["help"]}"
    echo "  4k        ${MESSAGES["convert_single"]}"
    echo "  4kj-m     ${MESSAGES["convert_jpg_all"]}"
    echo "  4kp-m     ${MESSAGES["convert_png_all"]}"
    echo "  4kw-m     ${MESSAGES["convert_webp_all"]}"
    echo "  4kj       ${MESSAGES["convert_jpg_replace"]}"
    echo "  4kp       ${MESSAGES["convert_png_replace"]}"
    echo "  4kw       ${MESSAGES["convert_webp_replace"]}"
    echo
    echo "${MESSAGES["examples"]}"
    echo "  ${0##*/} 4k"
    echo "  ${0##*/} 4kj-m"
    echo "  ${0##*/} help"
}

# Function to convert a single image to 4k
function 4k() {
    tput setaf 6
    echo -e "\n${MESSAGES["convert_message"]}\n"
    tput setaf 9
    echo -e "${MESSAGES["command_to_execute"]}\n"
    tput setaf 3
    echo -e "magick -adaptive-resize 5464 -contrast-stretch 0,3% -strip -modulate 99,99 -colorspace sRGB -depth 16 -channel rgba -adaptive-blur 0.05 -density 400 -strip +repage -fuzz 50% -quality 100% -adaptive-sharpen 2x2.5+2.7+01"
    tput sgr0
    magick -adaptive-resize 5464 -contrast-stretch 0,3% -strip -modulate 99,99 -colorspace sRGB -depth 16 -channel rgba -adaptive-blur 0.05 -density 400 -strip +repage -fuzz 50% -quality 100% -adaptive-sharpen 2x2.5+2.7+01
}

# Function to convert and optimize all JPG images to 4k
function 4kj-m() {
    magick -adaptive-resize 5464 -contrast-stretch 0,3% -strip -modulate 99,99 -colorspace sRGB -depth 16 -channel rgba -adaptive-blur 0.05 -density 400 -strip +repage -fuzz 50% -quality 100% -adaptive-sharpen 2x2.5+2.7+01 *.[jJpP][nNpP][gG] -set filename:base "%[basename]" "%[filename:base]-4k.jpg"
    jpegoptim *.jpg
}

# Function to convert all PNG images to 4k
function 4kp-m() {
    magick -adaptive-resize 5464 -contrast-stretch 0,3% -strip -modulate 99,99 -colorspace sRGB -depth 16 -channel rgba -adaptive-blur 0.05 -density 400 -strip +repage -fuzz 50% -quality 100% -adaptive-sharpen 2x2.5+2.7+01 *.[jJpP][nNpP][gG] -set filename:base "%[basename]" "%[filename:base]-4k.png"
}

# Function to convert all WEBP images to 4k
function 4kw-m() {
    magick -adaptive-resize 5464 -contrast-stretch 0,3% -strip -modulate 99,99 -colorspace sRGB -depth 16 -channel rgba -adaptive-blur 0.05 -density 400 -strip +repage -fuzz 50% -quality 100% -adaptive-sharpen 2x2.5+2.7+01 *.[jJpP][nNpP][gG] -set filename:base "%[basename]" "%[filename:base]-4k.webp"
}

# Function to convert and replace JPG images to 4k
function 4kj() {
    tput setaf 6
    echo -e "\n${MESSAGES["convert_message"]}\n"
    tput setaf 9
    echo -e "${MESSAGES["command_to_execute"]}\n"
    tput setaf 3
    echo -e "for i in *.[jJpP][nNpP][gG]; do convert ...; done"
    tput sgr0
    for i in *.[jJpP][nNpP][gG]; do
        magick -adaptive-resize 3840 -contrast-stretch 0,3% -strip -modulate 99,99 -colorspace sRGB -depth 16 -channel rgba -adaptive-blur 0.05 -density 400 -strip +repage -fuzz 50% -quality 100% -adaptive-sharpen 2x2.5+2.7+01 "$i" "${i%.*}-4k.jpg"
        rm "$i"
    done
    jpegoptim *.jpg
}

# Function to convert and replace PNG images to 4k
function 4kp() {
    for i in *.[jJpP][nNpP][gG]; do
        magick -adaptive-resize 3840 -contrast-stretch 0,3% -strip -modulate 99,99 -colorspace sRGB -depth 16 -channel rgba -adaptive-blur 0.05 -density 400 -strip +repage -fuzz 50% -quality 100% -adaptive-sharpen 2x2.5+2.7+01 "$i" "${i%.*}-4k.png"
        rm "$i"
    done
}

# Function to convert and replace WEBP images to 4k
function 4kw() {
    for i in *.[jJpP][nNpP][gG]; do
        magick -adaptive-resize 3840 -contrast-stretch 0,3% -strip -modulate 99,99 -colorspace sRGB -depth 16 -channel rgba -adaptive-blur 0.05 -density 400 -strip +repage -fuzz 50% -quality 100% -adaptive-sharpen 2x2.5+2.7+01 "$i" "${i%.*}-4k.webp"
        rm "$i"
    done
}

# Check which command was called
case "$1" in
    help) help_menu ;;
    4k) 4k ;;
    4kj-m) 4kj-m ;;
    4kp-m) 4kp-m ;;
    4kw-m) 4kw-m ;;
    4kj) 4kj ;;
    4kp) 4kp ;;
    4kw) 4kw ;;
    *) echo "${MESSAGES["invalid_command"]}"  ;;
esac
