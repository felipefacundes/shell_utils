gif()
{
(
cat <<'EOF'
# 1. Criar gif de alttíssima qualidade com paleta a parte:

Já com a resolução desejada método ULTRAPASSADO:
$ ffmpeg -i OnePiece.mkv -filter_complex '[0:v] palettegen' palette.png
$ ffmpeg -ss 00:00:26.00 -t 8 -r 23 -i Video.mkv -i palette.png \
    -filter_complex '[0:v][1:v] paletteuse' -pix_fmt rgb24 -s 616x182 OnePiece.gif

2. MELHOR MÉTODO. Criar gif de alttíssima qualidade com paleta diretamente e já definindo o número de quadros e escala:

$ ffmpeg -i OnePiece.mkv \
	-vf "fps=15,scale=800:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 OnePiece.gif

Obs.: Se não definir a resolusção de saída '-s 616x182' será a resolução original do vídeo.

3. Método 2. Criar gif de alttíssima qualidade com paleta diretamente e já definindo o número de quadros e escala:

$ ffmpeg -filter_complex "[0:v] fps=6,scale=w=1080:h=-1,split [a][b];[a] palettegen [p];[b][p] paletteuse" \
    -i OnePiece.mkv -ss 00:00:05 -r 6 OnePiece.gif

===========================================================================================
3. Criando Wallpapers Animados com gifs:

3.1 Baixando do Youtube só o trecho do Vídeo desejado para criação do gif:
fmpeg $(yt-dlp -g 'https://youtu.be/uPk0RYQ7taI' | sed "s/.*/-ss 00:00:07 -i &/") -t 00:00:06 -c copy OnePiece.mkv

3.2 Mesmo processo do item 2:
$ ffmpeg -filter_complex "[0:v] fps=6,scale=w=1080:h=-1,split [a][b];[a] palettegen [p];[b][p] paletteuse" \
    -i OnePiece.mkv -ss 00:00:05 -r 6 OnePiece.gif 

3.2 Otimize ainda mais reduzindo o número de quadros com: gifski
$ gifski --fps 5 -o OnePiece-gifski.gif OnePiece.gif

3.3 Otimize ainda mais piorando a qualidade com gifscicle:
$ gifsicle --colors 256 --batch --optimize=3 OnePiece-gifski.gif -o OnePiece.gif
Ou:
$ gifsicle -O3 --lossy=80 --colors 256 OnePiece-gifski.gif -o OnePiece.gif

===========================================================================================
Dica:
     -r rate define a taxa de quadros (valor, fração ou abreviação de Hz)

Descubra qual a melhor parte do vídeo para o gif '-ss' e USE: '-r 6' para gerar um gif com menos quadros,
Bom em combinação com 'fps=6', como descrito no item 2 e 3.2:
$ ffmpeg -i OnePiece.mkv -ss 00:00:05 -r 6 OnePiece.gif

Veja mais em:
    https://www.digitalocean.com/community/tutorials/how-to-make-and-optimize-gifs-on-the-command-line
EOF
) | less
}