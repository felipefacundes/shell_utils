remove_background() {
    cat <<'EOF'
# remove background with image magick ( ImageMagick )
    $ ffmpeg -i GIF.gif -r 15 %03d.jpg
    $ convert 001.jpg -fuzz 10% -transparent white 001.png  # white / black / green / etc..
    $ for i in *.jpg; do convert "$i" -fuzz 5% -transparent white folder/"${i%.*}.png"; done
EOF
}

generate_pdf() {
    cat << 'eof'
# generate pdf A4 format | gere pdf no formato A4 | gerar pdf
    $ convert -size 595x842 xc:white page1.png
    $ convert -size 595x842 xc:white page2.png

    $ convert page1.png page2.png blank.pdf
eof
}