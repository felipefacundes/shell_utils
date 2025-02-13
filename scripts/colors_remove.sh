#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script is a powerful image processing utility that automatically generates 
transparent background sprites for multiple colors. Its key strengths include multilingual 
support with dynamic language detection, flexible color-based image manipulation using ImageMagick, 
and robust error handling with clear usage instructions. The script can process multiple PNG files, 
removing specified colors with a configurable fuzz percentage, and outputs the modified images to a 
dedicated directory. It demonstrates an efficient approach to batch image transparency processing 
with user-friendly error messaging and internationalization.
DOCUMENTATION

# Declare an associative array for messages in both languages
declare -A MESSAGES

# Check language setting (English or Portuguese)
if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        ["uso_script"]="Uso: ${0##*/} \"#cor1 #cor2 #cor3 ...\""
        ["exemplo_uso"]="Exemplo de uso:"
        ["diretorio_saida"]="Diretório de saída para os sprites com fundo transparente: output"
        ["erro_cor_nao_encontrada"]="Erro: Nenhuma cor encontrada no formato '#cor'."
        ["finalizado"]="Finalizado"
    )
else
    MESSAGES=(
        ["uso_script"]="Usage: ${0##*/} \"#color1 #color2 #color3 ...\""
        ["exemplo_uso"]="Example of use:"
        ["diretorio_saida"]="Output directory for transparent background sprites: output"
        ["erro_cor_nao_encontrada"]="Error: No colors found in '#color' format."
        ["finalizado"]="Finished"
    )
fi

# Check if an argument was passed
if [ -z "$1" ]; then
    echo "${MESSAGES['uso_script']}"
    exit 1
fi

# Convert the color string passed as an argument into an array
IFS=' ' read -r -a colors <<< "$1"

# Check if any color contains '#'
if ! echo "${colors[@]}" | grep -q '#'; then
    # Display the example usage
    cat <<EOF
${MESSAGES['exemplo_uso']}

${0##*/} "#41f60c #19e709 #3fff16 #19c504 #48ff1a"
EOF
    exit 1
fi

# Output directory for transparent background sprites
output_dir="output"
echo "${MESSAGES['diretorio_saida']}"

# Ensure the output directory exists
mkdir -p "$output_dir"

# Loop through all PNG files
for i in *.png; do
    # Copy the original image to the output directory
    cp "$i" "$output_dir/${i%.*}.png"
    
    # Loop through all colors to be removed
    for color in "${colors[@]}"; do
        magick "$output_dir/${i%.*}.png" -fuzz 5% -transparent "$color" "$output_dir/${i%.*}.png"
    done
done

# Print finished message
echo -e "\n${MESSAGES['finalizado']}\n"
