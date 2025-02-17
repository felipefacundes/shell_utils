#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script offers a comprehensive image cartoonization toolkit using ImageMagick, 
providing eight distinct methods to transform photographs into cartoon-like images. 
Developed by Felipe Facundes and licensed under GPLv3, the script supports both 
English and Portuguese languages and automatically adapts its interface based on the system's locale.

Key strengths include:
- Multiple cartoonization techniques with varying visual effects
- Supports both PNG and JPG image formats
- Batch processing capability for entire image directories
- Bilingual user interface with contextual help function
- Advanced image manipulation using ImageMagick's complex commands
- Selective blur, edge enhancement, and color manipulation techniques
- Flexible methods ranging from simple posterization to advanced edge fusion

The cartoonization methods (cartoonize1-8) offer diverse artistic transformations, 
such as color reduction, edge highlighting, selective blurring, and specialized effects 
like Kuwahara filtering, giving users multiple creative options for stylizing their images.
DOCUMENTATION

# Script to apply different cartoonization methods to images using ImageMagick.

# https://imagemagick.org/discourse-server/viewtopic.php?t=31416
# https://graphicdesign.stackexchange.com/questions/28561/how-can-i-achieve-this-cartoon-effect
# http://mariovalle.name/postprocessing/ImageTools.html
# https://askubuntu.com/questions/703184/how-to-transform-an-image-into-a-cartoon-from-command-line
# http://www.fmwconcepts.com/imagemagick/cartoon/
# https://stackoverflow.com/questions/47017741/image-filter-to-cartoonize-and-colorize

declare -A MESSAGES

# Define bilingual messages
if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        [USAGE]="Uso: ${0##*/} [função] [argumentos]"
        [AVAILABLE_FUNCTIONS]="Funções disponíveis:"
        [DESCRIPTION1]="- Aplica uma cartoonização simples com modulação, posterização e blur."
        [DESCRIPTION2]="- Aplica cartoonização com bordas realçadas e efeito Sobel."
        [DESCRIPTION3]="- Combina cartoonização básica com realce de bordas."
        [DESCRIPTION4]="- Método avançado com blur seletivo, posterização e fusão."
        [DESCRIPTION4_OTHER]="- Variante do método cartoonize4."
        [DESCRIPTION5]="- Aplica cartoonização com convolução personalizada."
        [DESCRIPTION6]="- Método avançado com blur seletivo e fusão de bordas."
        [DESCRIPTION6_ALIAS]="- Alias para cartoonize5."
        [DESCRIPTION7]="- Converte para tons de cinza, aplica Kuwahara e afiação."
        [DESCRIPTION8]="- Aplica efeito Kuwahara diretamente."
        [INSTRUCTIONS]="Para usar:"
        [INSTRUCTIONS_DETAIL]="Execute ${0##*/} <função> no diretório contendo as imagens PNG ou JPG a serem cartoonizadas."
    )
else
    MESSAGES=(
        [USAGE]="Usage: ${0##*/} [function] [arguments]"
        [AVAILABLE_FUNCTIONS]="Available functions:"
        [DESCRIPTION1]="- Applies basic cartoonization with modulation, posterization, and blur."
        [DESCRIPTION2]="- Applies cartoonization with enhanced edges and Sobel effect."
        [DESCRIPTION3]="- Combines basic cartoonization with edge enhancement."
        [DESCRIPTION4]="- Advanced method with selective blur, posterization, and fusion."
        [DESCRIPTION4_OTHER]="- Variant of the cartoonize4 method."
        [DESCRIPTION5]="- Applies cartoonization with custom convolution."
        [DESCRIPTION6]="- Advanced method with selective blur and edge fusion."
        [DESCRIPTION6_ALIAS]="- Alias for cartoonize5."
        [DESCRIPTION7]="- Converts to grayscale, applies Kuwahara, and sharpening."
        [DESCRIPTION8]="- Applies Kuwahara effect directly."
        [INSTRUCTIONS]="To use:"
        [INSTRUCTIONS_DETAIL]="Run ${0##*/} <function> in the directory containing PNG or JPG images to be cartoonized."
    )
fi

TMPDIR="${TMPDIR:-/tmp}"

help() {
    cat << EOF
${MESSAGES[USAGE]}

${MESSAGES[AVAILABLE_FUNCTIONS]}
  cartoonize                    ${MESSAGES[DESCRIPTION1]}
  cartoonize2                   ${MESSAGES[DESCRIPTION2]}
  cartoonize3                   ${MESSAGES[DESCRIPTION3]}
  cartoonize4                   ${MESSAGES[DESCRIPTION4]}
  cartoonize4-other-method      ${MESSAGES[DESCRIPTION4_OTHER]}
  cartoonize5                   ${MESSAGES[DESCRIPTION5]}
  cartoonize6                   ${MESSAGES[DESCRIPTION6]}
  cartoonize6-remover-espinhas  ${MESSAGES[DESCRIPTION6_ALIAS]}
  cartoonize7                   ${MESSAGES[DESCRIPTION7]}
  cartoonize8                   ${MESSAGES[DESCRIPTION8]}

${MESSAGES[INSTRUCTIONS]}
  ${MESSAGES[INSTRUCTIONS_DETAIL]}
EOF
}

# Cartoonization functions
cartoonize() {
    for i in *.[jJpP][nNpP][gG]; do
        magick "$i" -colors 64 -paint 4 -compose over -compose multiply \
        -modulate 100,150,100 -posterize 24 -blur 0x2 -set filename:base "%[basename]" \
        "%[filename:base]-cartoon.png"
    done
}

cartoonize2() {
    for i in *.[jJpP][nNpP][gG]; do
        magick "$i" \( -clone 0 -blur 0x5 \) \( -clone 0 -fill black -colorize 100 \) \
        \( -clone 0 -define convolve:scale="!" -define morphology:compose=Lighten \
        -morphology Convolve "Sobel:>" -negate -evaluate pow 5 -negate -level 30x100% \) \
        -delete 0 -compose over -composite -set filename:base "%[basename]" \
        "%[filename:base]-cartoon.png"
    done
}

cartoonize3() {
    for i in *.[jJpP][nNpP][gG]; do
        magick "$i" -colors 64 -paint 4 -compose over -compose multiply \
        -modulate 100,150,100 -posterize 24 -blur 0x2 -define morphology:compose=Lighten \
        -morphology Convolve "Sobel:>" -negate -evaluate pow 5 -negate -level 30x100% \
        -set filename:base "%[basename]" "%[filename:base]-cartoon.png"
    done
}

cartoonize4() {
    for i in *.[jJpP][nNpP][gG]; do
        magick -quiet "$i" +repage -depth 8 -selective-blur 0x5+10% "${TMPDIR}/pre-cartoon1.mpc"
        magick "${TMPDIR}/pre-cartoon1.mpc" -level 0x60% -colorspace gray -posterize 6 -depth 8 \
        -gamma 2.2 "${TMPDIR}/pre-cartoon2.mpc"
        PreCartoon1=${TMPDIR}/pre-cartoon1.mpc
        PreCartoon2=${TMPDIR}/pre-cartoon2.mpc
        magick "$PreCartoon1" \( "$PreCartoon2" -blur 0x1 \) \( -clone 0 -clone 1 -compose over \
        -compose multiply -composite -modulate 100,150,100 \) \( -clone 0 -colorspace gray \) \
        \( -clone 3 -negate -blur 0x2 \) \( -clone 3 -clone 4 -compose over -compose colordodge \
        -composite -evaluate pow 4 -threshold 90% -statistic median 3x3 \) -delete 0,1,3,4 \
        -compose over -compose multiply -composite "${i/.[jJpP][nNpP][gG]/-cartoon.png}"
        rm "${TMPDIR}/pre-cartoon1.mpc" "${TMPDIR}/pre-cartoon2.mpc"
    done
}

cartoonize4_other_method() {
    for i in *.[jJpP][pPnN][gG]; do 
        magick "$i" +repage -depth 8 -selective-blur 0x5+10%% \( -clone 0 -level 0x60%% -colorspace gray \
        -posterize 6 -depth 8 -gamma 2.2 -blur 0x1 \) \( -clone 0 -clone 1 -compose multiply -composite \
        -modulate 100,150,100 \) \( -clone 0 -colorspace gray \) \( -clone 3 -negate -blur 0x2 \) \( -clone 3 \
        -clone 4 -compose colordodge -composite -evaluate pow 4 -threshold 90%% -statistic median 3x3 \) -delete 0,1,3,4 \
        -compose multiply -composite "${i/.[jJpP][pPnN][gG]/-cartoon.png}"
    done
}

cartoonize5() {
    convolution=0.70
    dx="-$convolution,0,$convolution,-$convolution,0,$convolution,-$convolution,0,$convolution"
    dy="$convolution,$convolution,$convolution,0,0,0,-$convolution,-$convolution,-$convolution"
    for i in *.[jJpP][nNpP][gG]; do
        magick "$i" -quiet -regard-warnings -colorspace RGB +repage "${TMPDIR}/pre-cartoon1.jpg"
        magick \( "${TMPDIR}/pre-cartoon1.jpg" -median 2 \) \( -size 1x256 gradient: -rotate 90 \
        -fx "floor(u*10+0.5)/10" \) -clut "${TMPDIR}/pre-cartoon2.jpg"
        magick \( "${TMPDIR}/pre-cartoon1.jpg" -colorspace gray -median 2 \) \( -clone 0 -bias 50% \
        -convolve "$dx" -solarize 50% \) \( -clone 0 -bias 50% -convolve "$dy" -solarize 50% \) \
        \( -clone 1 -clone 1 -compose multiply -composite -gamma 2 \) \( -clone 2 -clone 2 \
        -compose multiply -composite -gamma 2 \) -delete 0-2 -compose plus -composite \
        -threshold 75% "${TMPDIR}/pre-cartoon3.jpg"
        magick "${TMPDIR}/pre-cartoon2.jpg" "${TMPDIR}/pre-cartoon3.jpg" -compose multiply -composite \
        "${i/.[jJpP][nNpP][gG]/-cartoon.png}"
        rm "${TMPDIR}/pre-cartoon1.jpg" "${TMPDIR}/pre-cartoon2.jpg" "${TMPDIR}/pre-cartoon3.jpg"
    done
}

cartoonize6() {
    for i in *.[jJpP][nNpP][gG]; do 
        magick -quiet "$i" +repage -depth 8 -selective-blur 0x5+10% "${TMPDIR}/pre-cartoon1.jpg"
        magick "${TMPDIR}/pre-cartoon1.jpg" -level 0x60 -set colorspace RGB -colorspace gray \
        -posterize 6 -depth 8 -colorspace sRGB "${TMPDIR}/pre-cartoon2.jpg"
        export PreCartoon1=${TMPDIR}/pre-cartoon1.jpg; export PreCartoon2=${TMPDIR}/pre-cartoon2.jpg
        magick "$PreCartoon1" \( "$PreCartoon2" -blur 0x1 \) \( -clone 0 -clone 1 -compose over \
        -compose multiply -composite -modulate 100,150,100 \) \( -clone 0 -set colorspace RGB \
        -colorspace gray \) \( -clone 3 -negate -blur 0x4 \) \( -clone 3 -clone 4 -compose over \
        -compose colordodge -composite -evaluate pow 4 -threshold 4 -statistic median 3x3 \) \
        -delete 0,1,3,4 -compose over -compose multiply -composite "${i/.[jJpP][nNpP][gG]/-cartoon.png}"
        rm "${TMPDIR}/pre-cartoon1.jpg" "${TMPDIR}/pre-cartoon2.jpg"
    done
}

cartoonize7() {
    for i in *.[jJpP][nNpP][gG]; do
        magick "$i" -colorspace gray -kuwahara 3 -unsharp 0x2+4+0 \
        \( xc:blue xc:red xc:yellow +append \) -clut "${i/.[jJpP][nNpP][gG]/-cartoon.png}"
    done
}

cartoonize8() {
    for i in *.[jJpP][nNpP][gG]; do
        magick "$i" -kuwahara 3 -unsharp 0x2+4+0 "${i/.[jJpP][nNpP][gG]/-cartoon.png}"
    done
}

alias cartoonize6-remover-espinhas='cartoonize5'

# Function call
if [ $# -eq 0 ]; then
    help
    exit 0
fi

"$@"
