#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes
# OCR tesseract

: <<'DOCUMENTATION'
This is a script that makes several conversions of image files into text in a massive way, just run it in a folder with images
DOCUMENTATION

# Define a signal handler to capture SIGINT (Ctrl+C)
trap 'kill $(jobs -p)' SIGTERM #SIGHUP #SIGINT #SIGQUIT #SIGABRT #SIGKILL #SIGALRM #SIGTERM

lang="${lang:-eng}"
format="${format:-txt}"
allfiletypes='*.[jJpP][nNpP][gG]'
ext="$(eval echo "$allfiletypes")"
textcleaner=~/.shell_utils/scripts/Freds_img/textcleaner

doc() {
    less -FX "$0" | head -n7 | tail -n1
}

help() {
    cat <<EOF | less -i -R

    $(doc)

    Usage: lang=eng format=txt ${0##*/} [args]

    -mode1
            The massive_ocr() function loops through images (JPG, JPEG, PNG) in the directory, extracts their names without extensions, 
            prints them to the console, and uses Tesseract to convert the images to text files in the same directory, with the original name. 
            The configured language is Portuguese.
    -mode2
            The massive_ocr_optimized_tiff_bw() function performs optimized OCR on images (JPG, JPEG, PNG). It uses ImageMagick to enhance the image,
            convert to black and white and invert colors. Then Tesseract is applied to convert the image to text, and the intermediate files are removed.
    -mode3
            The massive_ocr_optimized_tiff_bw2() function is a variation of the previous one, using ImageMagick to optimize, convert to black and white and
            invert colors in images (JPG, JPEG, PNG). The main difference is in color manipulation, where it uses cloning and compositing to obtain the final
            result before applying Tesseract for OCR. Intermediate files are removed at the end of the process.
    -mode4
            The massive_ocr_optimized_tiff_bw3() function differs from the previous one when processing images (JPG, JPEG, PNG). It uses ImageMagick to optimize,
            convert to grayscale, and invert colors, employing a specific approach to color manipulation before applying Tesseract for OCR. Intermediate files are
            removed at the end of the process.
    -mode5
            The massive_ocr_optimized_scale_150() function follows an optimization approach for OCR on images (JPG, JPEG, PNG). Use ImageMagick to enhance, resize
            by 150%, convert to black and white, and invert colors. Tesseract is applied to convert the image to text, removing intermediate files at the end.
    -mode6
            The effectiveness of the massive_ocr_optimized_scale_200() function is related to increasing the scale by 200%, resulting in enlarged images before 
            the OCR process. Compared to the previous function (massive_ocr_optimized_scale_150()), this approach can provide better readability for smaller 
            characters or fine details in images. Benefits include a potential improvement in OCR accuracy for more detailed elements, although at the cost of 
            taking up more disk space due to larger images.
    -mode7
            The massive_ocr_optimized_tiff_gray() function optimizes images (JPG, JPEG, PNG) for OCR. It uses ImageMagick to enhance, convert to grayscale, 
            adjust density and quality before applying Tesseract to convert the image to text. Intermediate files are removed at the end of the process.
    -mode8
            The massive_ocr_optimized_tiff_gray2() function differs from the previous one by simplifying the optimization process for OCR. It only uses ImageMagick 
            to convert the image directly to grayscale, without any enhancement steps or density adjustments. This can result in a faster process, although it may
            sacrifice fine details present in images optimized by the previous function (massive_ocr_optimized_tiff_gray()).
    -mode9
            The massive_ocr_optimized_alpha_bw() function optimizes images (JPG, JPEG, PNG) for OCR, using ImageMagick to create a black and white version of the 
            image based on the alpha channel. This is achieved by making pixels that are very close to black and white transparent before applying Tesseract to 
            convert the image to text. Intermediate files are removed at the end of the process.
    -mode10
            The massive_ocr_optimized_bw() function optimizes images (JPG, JPEG, PNG) for OCR, using ImageMagick to create a black and white version of the image.
            This is done by making pixels that are very close to black and white transparent before applying Tesseract to convert the image to text. Intermediate
            files are removed at the end of the process.
    -mode11
            The massive_ocr_optimized_bw2() function optimizes images (JPG, JPEG, PNG) for OCR, using ImageMagick to create a black and white version of the image.
            It manipulates the alpha channel to make near-black and white pixels transparent, before applying Tesseract to convert the image to text.
            Intermediate files are removed at the end of the process.
    -mode12
            The massive_ocr_optimized_colors() function optimizes images (JPG, JPEG, PNG) for OCR, using ImageMagick. It adjusts the colors of the image,
            replacing specified ones with more readable ones for OCR. Then Tesseract is applied to convert the image to text. Intermediate files are removed
            at the end of the process. Increasing the density to 1200 can improve accuracy in fine details.
    -mode13
            The massive_ocr_optimized_enhance() function optimizes images (JPG, JPEG, PNG) for OCR using ImageMagick. It applies a significant enhancement to
            the image, repeating the enhancement 10 times, before using Tesseract to convert the image to text. Intermediate files are removed at the end of
            the process, resulting in an image optimized for OCR.
    -mode14
            The massive_ocr_optimized_gray() function optimizes images (JPG, JPEG, PNG) for OCR by converting them to grayscale using ImageMagick. Then apply
            Tesseract to convert the image to text. Intermediate files are removed at the end of the process, resulting in a grayscale version optimized for
            optical character recognition.
    -mode15
            The massive_ocr_optimized_gray2() function differs from the previous one by only adjusting the density and quality of the image before converting
            it to PGM and applying Tesseract. This can save computational resources compared to the massive_ocr_optimized_gray() function, which explicitly sets
            the color space to grayscale, and can result in more efficient execution. Both remove intermediate files at the end of the process.
    -mode16
            The massive_ocr_optimized_gray_RGB() function optimizes images (JPG, JPEG, PNG) for OCR by separating the RGB color channels. It creates independent
            images for each channel, averages the G and B channels, and then averages the results to obtain an optimized grayscale version. Tesseract is then
            applied to convert the image to text. Intermediate files are removed at the end of the process.
    -mode17
            The massive_ocr_optimized_gray_RGB2() function optimizes images (JPG, JPEG, PNG) for OCR, using ImageMagick. It creates grayscale versions by
            averaging the RG and GB components separately before combining the results. Tesseract is applied to convert the image to text, and the intermediate
            files are removed at the end of the process. This approach provides more efficient conversion to grayscale.
    -mode18
            # Script Font: https://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=textcleaner&dirname=textcleaner
            The massive_ocr_textcleaner() function optimizes images (JPG, JPEG, PNG) for OCR using the textcleaner script. Performs specific operations such as
            gamma adjustment, normalization, and histogram equalization to improve text readability. Tesseract is then applied to convert the optimized image to
            text, and the intermediate files are removed at the end of the process.
    -mode19
            The super_massive_ocr() function optimizes images (JPG, JPEG, PNG) for OCR, using ImageMagick for enhancement and conversion to grayscale. Then apply 
            Tesseract to convert the image to text. Intermediate files are removed at the end of the process, providing an effective overall approach to converting
            images to text with Tesseract.

    Enter q to quit this help.
EOF
}

massive_ocr()
{
for i in "$ext"
    do name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    tesseract "$i" "${name}" -l "$lang" "$format"
done
}

massive_ocr_optimized_tiff_bw()
{
for i in "$ext";
    do name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    convert "${i}" -enhance -enhance -enhance \
            -enhance -enhance -enhance -enhance \
            -enhance -enhance -enhance "${name}"_enhance.tiff
    convert "${name}"_enhance.tiff -colorspace HSI -channel B \
            -level 100,0% +channel -colorspace sRGB "${name}"_wb.tiff
            convert "${name}"_wb.tiff -negate "${name}"_bw.tiff
    tesseract "${name}"_bw.tiff "${name}" -l "$lang" "$format"
    rm "${name}"_bw.tiff "${name}"_enhance.tiff "${name}"_wb.tiff
done
}

massive_ocr_optimized_tiff_bw2()
{
for i in "$ext";
    do name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    convert "${i}" -enhance -enhance -enhance \
            -enhance -enhance -enhance -enhance \
            -enhance -enhance -enhance "${name}"_enhance.tiff
    convert "${name}"_enhance.tiff -colorspace HSI -separate +channel \
    \( -clone 2 -negate \) \
    \( -clone 1 -threshold 1% -negate \) \
    \( -clone 2 -clone 3 -clone 4 -compose over -composite \) \
    -delete 3,4 +swap +delete -set colorspace HSI -combine -colorspace sRGB "${name}"_bw.tiff
    tesseract "${name}"_bw.tiff "${name}" -l "$lang" "$format"
    rm "${name}"_bw.tiff "${name}"_enhance.tiff
done
}

massive_ocr_optimized_tiff_bw3()
{
#pdftoppm *.pdf -gray out
for i in "$ext";
    do name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    convert "${i}" -enhance -enhance -enhance \
            -enhance -enhance -enhance -enhance \
            -enhance -enhance -enhance "${name}"_enhance.tiff
    convert "${name}"_enhance.tiff -grayscale Rec709Luminance \
            -channel RGB "${name}"_gray.tiff
    convert "${name}"_gray.tiff \
            -channel rgba -alpha set -fuzz 50% \
            -fill none -opaque white \
            -fill white -opaque black \
            -fill black -opaque none \
            -colors 2 -strip \
            -alpha off -negate \
            -density 300x300 -quality 100% "${name}"_bw.tiff
    tesseract "${name}"_bw.tiff "${name}" -l "$lang" "$format"
    rm "${name}"_bw.tiff "${name}"_gray.tiff "${name}"_enhance.tiff
done
}

massive_ocr_optimized_scale_150()
{
for i in "$ext";
    do name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    convert "${i}" -enhance -enhance -enhance \
            -enhance -enhance -enhance -enhance \
            -enhance -enhance -enhance -scale 150% "${name}"_enhance.tiff
    convert "${name}"_enhance.tiff -colorspace HSI -channel B \
            -level 100,0% +channel -colorspace sRGB "${name}"_wb.tiff
            convert "${name}"_wb.tiff -negate "${name}"_bw.tiff
    tesseract "${name}"_bw.tiff "${name}" -l "$lang" "$format"
    rm "${name}"_bw.tiff "${name}"_enhance.tiff "${name}"_wb.tiff
done
}

massive_ocr_optimized_scale_200()
{
for i in "$ext";
    do name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    convert "${i}" -enhance -enhance -enhance \
            -enhance -enhance -enhance -enhance \
            -enhance -enhance -enhance -scale 200% "${name}"_enhance.tiff
    convert "${name}"_enhance.tiff -colorspace HSI -channel B \
            -level 100,0% +channel -colorspace sRGB "${name}"_wb.tiff
            convert "${name}"_wb.tiff -negate "${name}"_bw.tiff
    tesseract "${name}"_bw.tiff "${name}" -l "$lang" "$format"
    rm "${name}"_bw.tiff "${name}"_enhance.tiff "${name}"_wb.tiff
done
}

massive_ocr_optimized_tiff_gray()
{
for i in "$ext";
    do name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    convert "${i}" -enhance -enhance -enhance \
            -enhance -enhance -enhance -enhance \
            -enhance -enhance -enhance "${name}"_enhance.tiff
    convert "${name}"_enhance.tiff -grayscale Rec709Luminance \
            -channel RGB "${name}"_gray.tiff
    convert "${name}"_gray.tiff -density 300x300 -quality 100% "${name}".pgm
    tesseract "${name}".pgm "${name}" -l "$lang" "$format"
    rm "${name}".pgm "${name}"_gray.tiff "${name}"_enhance.tiff
done
}

massive_ocr_optimized_tiff_gray2()
{
for i in "$ext";
    do name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    convert "${i}" -grayscale Rec709Luminance \
            -channel RGB "${name}"_gray.tiff
    tesseract "${name}"_gray.tiff "${name}" -l "$lang" "$format"
    rm "${name}"_gray.tiff
done
}

massive_ocr_optimized_alpha_bw()
{
for i in "$ext";
    do name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    convert "${i}" -fill '#000000000001' -opaque white \
            -fill white -opaque black \
            -fill black -opaque '#000000000001' "${name}"_alpha_bw.png
    tesseract "${name}"_alpha_bw.png "${name}" -l "$lang" "$format"
    rm "${name}"_alpha_bw.png
done
}

massive_ocr_optimized_bw()
{
for i in "$ext";
    do name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    convert "${i}" -fill '#0008' -opaque white \
            -fill white -opaque black \
            -fill black -opaque '#0008' "${name}"_bw.png
    tesseract "${name}"_bw.png "${name}" -l "$lang" "$format"
    rm "${name}"_bw.png
done
}

massive_ocr_optimized_bw2()
{
for i in "$ext";
    do name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    convert "${i}" -channel rgba -alpha set \
            -fill none -opaque white \
            -fill white -opaque black \
            -fill white -opaque none \
            -alpha off "${name}"_bw.png
    tesseract "${name}"_bw.png "${name}" -l "$lang" "$format"
    rm "${name}"_bw.png
done
}

massive_ocr_optimized_colors()
{
for i in "$ext";
    do name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    convert "${i}" -fuzz 0% -fill "#30ff00" \
            -opaque "#b01111" -opaque "#c0c0c0" \
            -opaque "#f4f4f4" -opaque "#c87d7d" \
            -opaque "#bebebe" -opaque "#808080" \
            -fill none -fuzz 0% +opaque "#30ff00" \
            -fuzz 0% -fill "#000000" \
            -opaque "#30ff00" +profile "icc" -density 1200 "${name}"_colors.png
    tesseract "${name}"_colors.png "${name}" -l "$lang" "$format"
    rm "${name}"_colors.png
done
}

massive_ocr_optimized_enhance()
{
for i in "$ext";
    do name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    convert "${i}" -enhance -enhance -enhance \
            -enhance -enhance -enhance -enhance \
            -enhance -enhance -enhance "${name}"_enhance.tiff
    tesseract "${name}"_enhance.tiff "${name}" -l "$lang" "$format"
    rm "${name}"_enhance.tiff
done
}

massive_ocr_optimized_gray()
{
for i in "$ext";
    do name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    convert "${i}" -colorspace Gray "${name}"_Gray.png
    tesseract "${name}"_Gray.png "${name}" -l "$lang" "$format"
    rm "${name}"_Gray.png
done
}

massive_ocr_optimized_gray2()
{
for i in "$ext";
    do name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    convert "${i}" -density 300x300 -quality 100% "${name}".pgm
    tesseract "${name}".pgm "${name}" -l "$lang" "$format"
    rm "${name}".pgm
done
}

massive_ocr_optimized_gray_RGB()
{
for i in "$ext";
    do name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    convert "${i}" -channel R -separate "${name}"_R.png
    convert "${i}" -channel G -separate "${name}"_G.png
    convert "${i}" -channel B -separate "${name}"_B.png
    convert "${name}"_R.png "${name}"_G.png -evaluate-sequence mean "${name}"_RG.png
    convert "${name}"_G.png "${name}"_B.png -evaluate-sequence mean "${name}"_GB.png
    convert "${name}"_RG.png "${name}"_GB.png -evaluate-sequence mean "${name}"_grayRGB.png
    tesseract "${name}"_grayRGB.png "${name}" -l "$lang" "$format"
    rm "${name}"_grayRGB.png "${name}"_R.png "${name}"_G.png
    rm "${name}"_B.png "${name}"_RG.png "${name}"_GB.png
done
}

massive_ocr_optimized_gray_RGB2()
{
for i in "$ext";
    do name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    convert "${i}" \
    \( -clone 0 -channel RG -separate +channel -evaluate-sequence mean \) \
    \( -clone 0 -channel GB -separate +channel -evaluate-sequence mean \) \
    -delete 0 -evaluate-sequence mean "${name}"_color2gray1.png
    tesseract "${name}"_color2gray1.png "${name}" -l "$lang" "$format"
    rm "${name}"_color2gray1.png
done
}

massive_ocr_textcleaner()
{
# Script Font: https://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=textcleaner&dirname=textcleaner
for i in "$ext"
    do name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    eval "$textcleaner" -g -f 20 -o 10 -e normalize -i 1 "${i}" "${name}"_textcleaner.png
    tesseract "${name}"_textcleaner.png "${name}" -l "$lang" "$format"
    rm "${name}"_textcleaner.png
done
}

super_massive_ocr() 
{
for i in "$ext"; do
    name=$(echo "${i}" | cut -d'.' -f1)
    echo "${name}"
    convert "${i}" -enhance -channel RGB -separate -evaluate-sequence mean "${name}"_gray.png
    tesseract "${name}"_gray.png "${name}" -l "$lang" "$format"
    rm "${name}"_gray.png
done
}

check_images() {
    found_image=false

    for file in "$ext"; do
        type=$(file -b "$file" | cut -d' ' -f1)
        if [ "$type" == "JPEG" ] || [ "$type" == "PNG" ] || [ "$type" == "JPEG2000" ]; then
            found_image=true
            break
        fi
    done

    if [ "$found_image" = true ]; then
        echo 'Image found!'
        echo
        echo "selected $lang language"
        echo "selected $format format"
        echo
    else
        echo "Error: No image found in the directory."
        exit 1
    fi
}

if [[ -z $1 ]] || [[ $1 == "-h" || $1 == "--help" ]]; then
    help
    exit 0
fi

# check if there is an image in the directory
check_images

while [[ $# -gt 0 ]]; do
    case $1 in
        -mode1)
            massive_ocr
            shift
            continue
            ;;
        -mode2)
            massive_ocr_optimized_tiff_bw
            shift
            continue
            ;;
        -mode3)
            massive_ocr_optimized_tiff_bw2
            shift
            continue
            ;;
        -mode4)
            massive_ocr_optimized_tiff_bw3
            shift
            continue
            ;;
        -mode5)
            massive_ocr_optimized_scale_150
            shift
            continue
            ;;
        -mode6)
            massive_ocr_optimized_scale_200
            shift
            continue
            ;;
        -mode7)
            massive_ocr_optimized_tiff_gray
            shift
            continue
            ;;
        -mode8)
            massive_ocr_optimized_tiff_gray2
            shift
            continue
            ;;
        -mode9)
            massive_ocr_optimized_alpha_bw
            shift
            continue
            ;;
        -mode10)
            massive_ocr_optimized_bw
            shift
            continue
            ;;
        -mode11)
            massive_ocr_optimized_bw2
            shift
            continue
            ;;
        -mode12)
            massive_ocr_optimized_colors
            shift
            continue
            ;;
        -mode13)
            massive_ocr_optimized_enhance
            shift
            continue
            ;;
        -mode14)
            massive_ocr_optimized_gray
            shift
            continue
            ;;
        -mode15)
            massive_ocr_optimized_gray2
            shift
            continue
            ;;
        -mode16)
            massive_ocr_optimized_gray_RGB
            continue
            ;;
        -mode17)
            massive_ocr_optimized_gray_RGB2
            shift
            continue
            ;;
        -mode18)
            massive_ocr_textcleaner
            shift
            continue
            ;;
        -mode19)
            super_massive_ocr
            shift
            continue
            ;;
        *)
            help
            break
            ;;
    esac
done

# Wait for all child processes to finish
wait