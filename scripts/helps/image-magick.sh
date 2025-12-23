remove_background() {
	cat <<-'EOF'
	# remove background with image magick ( ImageMagick )
	$ ffmpeg -i GIF.gif -r 15 %03d.jpg
	$ convert 001.jpg -fuzz 10% -transparent white 001.png  # white / black / green / etc..
	$ for i in *.jpg; do convert "$i" -fuzz 5% -transparent white folder/"${i%.*}.png"; done
	EOF
}

generate_pdf() {
	cat <<- 'eof'
	# generate pdf A4 format | gere pdf no formato A4 | gerar pdf
	$ convert -size 595x842 xc:white page1.png
	$ convert -size 595x842 xc:white page2.png

	$ convert page1.png page2.png blank.pdf
	eof
}

resize_force() {
    cat <<-'EOF'
	# Forced Resizing of Images and Videos: ImageMagick vs FFmpeg (resize)
	EOF
    clear
    if [[ "${LANG,,}" =~ pt_ ]]; then
		cat <<-'EOF'
		# Redimensionamento Forçado de Imagens e Vídeos: ImageMagick vs FFmpeg (resize)

		$ magick picture.jpg -resize "300x200!" output.jpg
		$ ffmpeg -i video.mp4 -vf "scale=300:200,setsar=1" output.mp4

		EOF

        read -s -n 1 -rp "Pressione qualquer tecla, para exibir o help completo" >/dev/tty
        markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/force_resize_pt.md
    else
		cat <<-'EOF'
		# Forced Resizing of Images and Videos: ImageMagick vs FFmpeg (resize)

		$ magick picture.jpg -resize "300x200!" output.jpg
		$ ffmpeg -i video.mp4 -vf "scale=300:200,setsar=1" output.mp4

		EOF

        read -s -n 1 -rp "Press any key to display the full help" >/dev/tty
        markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/force_resize.md
    fi
}