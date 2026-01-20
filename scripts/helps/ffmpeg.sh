# ffmpeg full flags
. ~/.shell_utils/scripts/helps/ffmpeg-full-flags.sh

ffmpeg_tips() {
    clear
	cat <<-'EOF'
	# A Complete and Pedagogical FFmpeg Guide

	EOF
    if [[ "${LANG,,}" =~ pt_ ]]; then
        markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/ffmpeg-tips-pt.md
    else
        markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/ffmpeg-tips.md
    fi
    clear
}

video_clear_metadata() {
    clear
	cat <<-'EOF'
	# Removing Video Metadata Using FFmpeg or exiftool

	EOF
    if [[ "${LANG,,}" =~ pt_ ]]; then
        markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/video-clear-metadat-pt.md
    else
        markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/video-clear-metadat.md
    fi
    clear
}

video2whatsapp() {
	cat <<-'EOF'
		# Transform videos to WhatsApp standard

		$ ffmpeg -i input.mp4 -c:v libx264 -crf 32 -vf "scale=1920:1080" -r 24 -c:a aac -b:a 96k -preset slow -movflags +faststart output_whatsapp.mp4

		# With filter

		$ ffmpeg -i input.mp4 -c:v libx264 -crf 32 -vf "scale=1920:1080:flags=lanczos" -r 24 -c:a aac -b:a 96k -preset slow -movflags +faststart output_whatsapp.mp4
	EOF
}

gif2sprite() {
	cat <<-'EOF'
		# 1 frame per second (ideal for sprites)
		$ ffmpeg -i sprite.gif -vf "fps=1" -vsync 0 %08d.png

		# Custom rate (ex: 15 FPS)
		$ ffmpeg -i sprite.gif -r 15 %08d.png

		# Frame every N seconds (ex: 1 frame every 3 seconds)
		$ ffmpeg -i sprite.gif -r 1/3 %08d.png

		# Specific number of frames
		$ ffmpeg -i animation.gif -frames:v 10 %08d.png
	EOF
}

video2sprite() {
    clear
	cat <<-'EOF'
	# Video for Sprites - A Comprehensive Guide

	EOF
    if [[ "${LANG,,}" =~ pt_ ]]; then
        markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/video2sprite-pt.md
    else
        markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/video2sprite.md
    fi
    clear
}

ffmpeg_video_enhancer() {
    cat <<'EOF'
# ffmpeg video enhancer / melhore a qualidade de videos com ffmpeg

# Usar Constant Rate Factor (CRF): Em vez de definir uma taxa de bits fixa (-b:v 1000k), você pode usar o CRF para controlar a qualidade. 
# Quanto menor o valor do CRF, melhor será a qualidade, mas o tamanho do arquivo também será maior. Um valor padrão para CRF é 23.

$ ffmpeg -i input.mkv -filter_complex "[0:v]scale=1920:1080:flags=lanczos,eq=contrast=1.1:saturation=1.1,unsharp=5:5:1.0:5:5:0.0[v]; \
[0:a]anull[a]" -map "[v]" -map "[a]" -c:v libx264 -preset slow -crf 18 output.mp4

$ ffmpeg -i input.mkv -vf "scale=1920:1080:flags=lanczos,unsharp=5:5:1.0:5:5:0.0" -c:v libx264 -preset slow -crf 18 -c:a copy output.mp4

$ ffmpeg -i input.mkv -vf "scale=1920:1080:flags=lanczos,eq=contrast=1.2:saturation=1.5,unsharp=5:5:1.0:5:5:0.0" -c:v libx264 -preset slow -crf 18 -c:a copy output.mp4
EOF
}

ffmpeg_others() {
    cat <<'EOF'
# ffmpeg others commands

$ ffmpeg -i 1702664171.4888504.mp4 -vn -c:a copy 1702660850.131925.m4a

$ ffmpeg -i 1v3E.mp4 -vf reverse -af areverse saida.mp4                                                     

$ ffmpeg -i Walk\ Cycle\ Cut\ Out\ \[2ldT83lpGSw\].webm pngs-sequence/%d-walk.png                               

$ ffmpeg -formats | grep PCM 
EOF
}

video2images()
{
    cat <<'EOF'
# ffmpeg video 2 images - decode all frames

$ ffmpeg -i input.mp4 -c:v png output_frames/frame_%08d.png

$ ffmpeg -i input.mp4 -vsync 0 -c:v png output_frames/%08d.png

$ ffmpeg -i input.mp4 -vf fps=15 -c:v png output_frames/frame_%08d.png

$ ffmpeg -i input.mp4 -vf "fps=15, chromakey=0xfb44f8:0.1:0.2" -c:v png output_frames/frame_%08d.png
EOF
}

images2video() {
	clear
    if [[ "${LANG,,}" =~ pt_ ]]; then
	    cat <<-'EOF'
		# Este guia explica diversos comandos FFmpeg para converter sequências de imagens em vídeo, com foco em diferentes cenários e necessidades.

		EOF
        markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/image2video-pt.md
    else
		cat <<-'EOF'
		# This guide explains various FFmpeg commands for converting image sequences into video, focusing on different scenarios and needs.

		EOF
        markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/image2video.md
    fi
}

ffmpeg_metadata()
{
echo "$(cat <<'EOF'
# ffmpeg metadata

command example:

ffmpeg -i input.mp3 -c copy -metadata title="Some Title" -metadata artist="Someone" output.mp3

 album            -- nome do conjunto ao qual este trabalho pertence.
 album_artist     -- criador principal do set/álbum, se for diferente do artista
                     por exemplo, "Various Artists" para álbuns de compilação.
 artist           -- criador principal da obra.
 comment          -- qualquer descrição adicional do arquivo.
 composer         -- quem compôs a obra, se diferente do artista.
 copyright        -- nome do detentor dos direitos autorais ou o tipo de licensa.
 creation_time    -- data em que o arquivo foi criado, preferencialmente em ISO 8601.
 date             -- data em que o trabalho foi criado, preferencialmente em ISO 8601.
 disc             -- número de um subconjunto, por exemplo, disco em uma coleção de vários discos.
 encoder          -- nome/configurações do software/hardware que produziu o arquivo.
 encoded_by       -- pessoa/grupo que criou o arquivo.
 filename         -- nome original do arquivo.
 genre            -- gênero musical, exemplo: Pop/Rock.
 language         -- idioma principal no qual o trabalho é realizado, de preferência
                     no formato ISO 639-2.  Vários idiomas podem ser especificados por
                     separando-os com vírgulas.
 performer        -- artista que executou a obra, se diferente do artista.
                     Por exemplo, para "Also sprach Zarathustra", o artista seria "Richard
                     Strauss" e intérprete da "London Philharmonic Orchestra".
 publisher        -- nome da gravadora/editora.
 service_name     -- nome do serviço na transmissão (nome do canal).
 service_provider -- nome do provedor de serviço na transmissão.
 title            -- nome da obra.
 track            -- número deste trabalho no conjunto, pode estar na forma atual/total.
 variant_bitrate  -- a taxa de bits total da variante de taxa de bits da qual o stream atual faz parte.

See More:
https://ffmpeg.org/doxygen/0.8/group__metadata__api.html
https://write.corbpie.com/adding-metadata-to-a-video-or-audio-file-with-ffmpeg/
EOF
)" | less
}

ffmpeg_crf()
{
    echo -e "
# ffmpeg crf

Guia CRF (fator de taxa constante em x264, x265 e libvpx)

O que é o fator de taxa constante?

O fator de taxa constante (CRF) é a configuração padrão de qualidade (e controle de taxa) para os codificadores x264 e x265
e também está disponível para libvpx . Com x264 e x265, você pode definir os valores entre 0 e 51, onde valores mais baixos
resultariam em melhor qualidade, em detrimento de tamanhos de arquivo maiores. Valores mais altos significam mais compactação,
mas em algum momento você notará a degradação da qualidade.

Para x264, os valores sensatos estão entre 18 e 28. O padrão é 23, portanto, você pode usá-lo como ponto de partida.

Com ffmpeg, ficaria assim:

${shell_color_palette[bwhite_on_black]}ffmpeg -i input.mp4 -c:v libx264 -crf 23 output.mp4

Para x265, o CRF padrão é 28:

${shell_color_palette[bwhite_on_black]}ffmpeg -i input.mp4 -c:v libx265 -crf 28 output.mp4

${shell_color_palette[bgreen]}Eu uso:

${shell_color_palette[bwhite_on_black]}ffmpeg -i input.mp4 -c:v libx265 -preset fast -crf 20 output.mp4

Converter para AV1 com ${shell_color_palette[bwhite_on_black]}libaom-av1${shell_color_palette[color_off]} é muito lento, requer um excelente processador, use ${shell_color_palette[bwhite_on_black]}libsvtav1${shell_color_palette[color_off]} para uma conversão mais rápida:
Um valor CRF de 23 produz um nível de qualidade correspondente a CRF 19 para x264, que seria considerado visualmente sem perdas.

Lento ao converter, porém é referência:
${shell_color_palette[bwhite_on_black]}ffmpeg -i input.mp4 -c:v libaom-av1 -preset fast -crf 23 output.mp4

Rápido ao converter:
${shell_color_palette[bwhite_on_black]}ffmpeg -i input.mp4 -c:v libsvtav1 -crf 23 output.mp4

${shell_color_palette[bold]}Nota${shell_color_palette[color_off]}: Ao fazer multiplexação em MP4, você pode querer adicionar ${shell_color_palette[bwhite_on_black]}-movflags +faststart${shell_color_palette[color_off]}
aos parâmetros de saída se o uso pretendido para o arquivo resultante for streaming.

Para libvpx, não há padrão e o CRF pode variar entre 0 e 63. 31 é recomendado para vídeo HD 1080p:

${shell_color_palette[bwhite_on_black]}ffmpeg -i input.mp4 -c:v libvpx-vp9 -crf 31 -b:v 0 output.mkv

Se você não tiver certeza sobre qual CRF usar, comece com o padrão e altere-o de acordo com sua impressão subjetiva da saída.
A qualidade é boa o suficiente? Não? Em seguida, defina um CRF mais baixo. O tamanho do arquivo é muito alto? Escolha um CRF mais alto.
Uma alteração de ±6 deve resultar em cerca de metade/dobro do tamanho do arquivo, embora os resultados possam variar.

Você deve usar a codificação CRF principalmente para armazenamento de arquivos off-line, a fim de obter as codificações mais ideais.
Para outras aplicações, outros modos de controle de taxa são recomendados. No streaming de vídeo, por exemplo, o CRF pode ser usado
em um modo restrito/limitado para evitar picos de taxa de bits.

    ${shell_color_palette[byellow_on_black]}0 <----- 18 <----- 23 -----> 28 -----> 51
${shell_color_palette[bold]}Lossless        Better    Worse           Worst
Sem perdas      Melhor    Piorar          Pior

${shell_color_palette[bcyan]}Exemplo de CRF

Este comando codifica um vídeo com boa qualidade, usando predefinições mais lentas para obter melhor compactação:

${shell_color_palette[bwhite_on_black]}ffmpeg -i input -c:v libx264 -preset slow -crf 22 -c:a copy output.mkv

Observe que, neste exemplo, o fluxo de áudio do arquivo de entrada é simplesmente copiado para a saída e não recodificado.

Se você estiver codificando um conjunto de vídeos semelhantes, aplique as mesmas configurações a todos os vídeos: isso garantirá
que todos tenham qualidade semelhante.
    " | less
}

ffmpeg_preset()
{
    echo -e "
# ffmpeg preset

predefinido (-preset)

Uma predefinição é uma coleção de opções que fornecerá uma determinada velocidade de codificação para a taxa de compactação.
Uma predefinição mais lenta fornecerá melhor compactação (a compactação é de qualidade por tamanho de arquivo).
Isso significa que, por exemplo, se você segmentar um determinado tamanho de arquivo ou taxa de bits constante,
obterá melhor qualidade com uma predefinição mais lenta. Da mesma forma, para uma codificação de qualidade constante,
você simplesmente economizará a taxa de bits escolhendo uma predefinição mais lenta.

Use a predefinição mais lenta para a qual você tem paciência. As predefinições disponíveis em ordem decrescente de velocidade são:

    ultrafast
    superfast
    veryfast
    faster
    fast
    medium - predefinição padrão
    slow
    slower
    veryslow
    placebo – ignore isso, pois não é útil (consulte as perguntas frequentes:  https://trac.ffmpeg.org/wiki/Encode/H.264#FAQ )

Você pode ver uma lista de predefinições atuais com -preset help(ver exemplo abaixo). Se você tem o x264binário
instalado, você também pode ver as configurações exatas que essas predefinições aplicam executando x264 --fullhelp.

    " | less
}

ffmpeg_tune()
{
    echo -e "
# ffmpeg tune

Afinação (-tune)

Você pode opcionalmente usar -tunepara alterar as configurações com base nas especificidades de sua entrada.
As afinações atuais incluem:

    film – use para conteúdo de filme de alta qualidade; reduz o desbloqueio
    animation – bom para desenhos animados; usa maior desbloqueio e mais quadros de referência
    grain – preserva a estrutura do grão em material de filme velho e granulado
    stillimage – bom para conteúdo do tipo apresentação de slides
    fastdecode – permite decodificação mais rápida ao desabilitar certos filtros
    zerolatency – bom para codificação rápida e streaming de baixa latência
    psnr – ignore isso, pois é usado apenas para desenvolvimento de codec
    ssim – ignore isso, pois é usado apenas para desenvolvimento de codec

Por exemplo, se sua entrada for animação, use o animationajuste, ou se você quiser preservar a granulação em um filme,
use o grainafinação. Se você não tiver certeza do que usar ou se sua entrada não corresponder a nenhuma das afinações,
omita o -tuneopção. Você pode ver uma lista de afinações atuais com -tune helpe com quais configurações eles se
aplicam x264 --fullhelp.

    " | less
}

ffmpeg_wav()
{
    echo "
# ffmpeg wav

ffmpeg -i audio.mp3 -ar 48000 -ac 2 -c:a pcm_s32le audio.wav    # 32 bits stereo
ffmpeg -i audio.mp3 -ar 48000 -ac 2 -c:a pcm_s24le audio.wav    # 24 bits stereo
ffmpeg -i audio.mp3 -ar 16000 -ac 2 -c:a pcm_s16le audio.wav    # 16 bits stereo
ffmpeg -i audio.mp3 -ar 8000 -ac 2 -c:a pcm_u8 audio.wav        # 8 bits stereo
ffmpeg -i audio.mp3 -ar 8000 -ac 1 -c:a pcm_u8 audio.wav        # 8 bits mono
    " # | less
}

ffmpeg_av1()
{
    echo -e "
# ffmpeg av1

Converter para AV1 com ${shell_color_palette[bwhite_on_black]}libaom-av1${shell_color_palette[color_off]} é muito lento, requer um excelente processador, use ${shell_color_palette[bwhite_on_black]}libsvtav1${shell_color_palette[color_off]} para uma conversão mais rápida:

AV1 é um codec de vídeo de código aberto e livre de royalties desenvolvido pela Alliance for Open Media (AOMedia),
um consórcio industrial sem fins lucrativos. Dependendo do caso de uso, o AV1 pode alcançar uma eficiência de compactação
cerca de 30% maior do que o VP9 e cerca de 50% maior do que o H.264.

Existem atualmente três codificadores AV1 suportados pelo FFmpeg: libaom (invocado com libaom-av1em FFmpeg), SVT-AV1 (libsvtav1)
e rav1e ( librav1e). Este guia atualmente se concentra em libaom e SVT-AV1.

libaom_
libaom (libaom-av1) é o codificador de referência para o formato AV1. Também foi usado para pesquisa durante o desenvolvimento do AV1.
libaomé baseado em libvpxe, portanto, compartilha muitas de suas características em termos de recursos, desempenho e uso.

Um valor CRF de 23 produz um nível de qualidade correspondente a CRF 19 para x264, que seria considerado visualmente sem perdas.

Lento ao converter, porém é referência:
${shell_color_palette[bwhite_on_black]}ffmpeg -i input.mp4 -c:v libaom-av1 -preset fast -crf 23 output.mp4
${shell_color_palette[bwhite_on_black]}ffmpeg -i input.mp4 -c:v libaom-av1 -crf 30 av1_test.mkv

Rápido ao converter:
${shell_color_palette[bwhite_on_black]}ffmpeg -i input.mp4 -c:v libsvtav1 -crf 23 output.mp4

Simular AV1 com x264, referência:
https://video.stackexchange.com/questions/35463/ffmpeg-to-output-something-video-mp4-codecs-avc1-42401f-can-read

${shell_color_palette[bwhite_on_black]}ffmpeg -i input.mp4 -c:v libx264 -profile:v high -level:v 3.1 -tag:v avc3 -brand avc3 -an output.mp4


${shell_color_palette[bold]}Nota${shell_color_palette[color_off]}: Ao fazer multiplexação em MP4, você pode querer adicionar ${shell_color_palette[bwhite_on_black]}-movflags +faststart${shell_color_palette[color_off]}
aos parâmetros de saída se o uso pretendido para o arquivo resultante for streaming.

Veja mais em:
https://trac.ffmpeg.org/wiki/Encode/AV1
" | less
}

ffmpeg_merged()
{
    cat <<'EOF'
# ffmpeg merged

ffmpeg -i video.mp4 -i audio.wav -c copy output.mkv
ffmpeg -i audio.wav -i video.mp4 -acodec copy -vcodec copy -f mkv output.mkv
ffmpeg -i audio.wav -i video.mp4 -c:a copy -c:v copy -f mkv output.mkv
EOF
}

ffmpeg_screen_black() {
    cat <<'EOF'
# Only audio and screen black
# Somente audio e tela preta

$ ffmpeg -i audio.m4a -f lavfi -i color=c=black:s=1920x1080:r=30 -preset ultrafast -c:v libx264 -c:a copy -shortest result.mp4
EOF
}

ffmpeg_extract_caption() {
    cat <<'EOF'
# Extract legend / caption
# Extraia legendas

$ ffmpeg -i video.mp4 -c:s srt legends.srt
EOF
}