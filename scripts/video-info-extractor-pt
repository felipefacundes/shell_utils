#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

# Verifica se o arquivo foi fornecido
if [ $# -eq 0 ]; then
    echo "Uso: ${0##*/} <arquivo_de_video>"
    echo "Exemplo: ${0##*/} video.mp4"
    exit 1
fi

VIDEO_FILE="$1"

# Verifica se o arquivo existe
if [ ! -f "$VIDEO_FILE" ]; then
    echo "Erro: Arquivo '$VIDEO_FILE' não encontrado!"
    exit 1
fi

# Verifica se ffprobe está instalado
if ! command -v ffprobe &> /dev/null; then
    echo "Erro: ffprobe não está instalado. Instale o ffmpeg primeiro."
    echo "Ubuntu/Debian: sudo apt install ffmpeg"
    echo "CentOS/RHEL: sudo yum install ffmpeg"
    echo "macOS: brew install ffmpeg"
    exit 1
fi

echo "=============================================="
echo "ANÁLISE DETALHADA DO VÍDEO: $VIDEO_FILE"
echo "=============================================="
echo ""

# Função para formatar bytes para unidades legíveis
format_bytes() {
    local bytes=$1
    if [ $bytes -ge 1073741824 ]; then
        echo "$(echo "scale=2; $bytes/1073741824" | bc) GB"
    elif [ $bytes -ge 1048576 ]; then
        echo "$(echo "scale=2; $bytes/1048576" | bc) MB"
    elif [ $bytes -ge 1024 ]; then
        echo "$(echo "scale=2; $bytes/1024" | bc) KB"
    else
        echo "$bytes bytes"
    fi
}

# Obtém informações gerais do arquivo
FILE_SIZE=$(stat -c%s "$VIDEO_FILE")
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO_FILE")
FORMATTED_SIZE=$(format_bytes $FILE_SIZE)

echo "📊 INFORMAÇÕES GERAIS:"
echo "   Tamanho do arquivo: $FORMATTED_SIZE"
echo "   Duração: $(echo "scale=2; $DURATION/60" | bc) minutos ($(echo "scale=2; $DURATION" | bc) segundos)"
echo "   Formato: $(ffprobe -v error -show_entries format=format_name -of default=noprint_wrappers=1:nokey=1 "$VIDEO_FILE")"
echo ""

# Obtém informações do stream de vídeo
echo "🎥 INFORMAÇÕES DE VÍDEO:"
VIDEO_STREAM=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height,r_frame_rate,bit_rate,pix_fmt,profile,level -of default=noprint_wrappers=1 "$VIDEO_FILE")

# Extrai informações individuais
CODEC_VIDEO=$(echo "$VIDEO_STREAM" | grep "codec_name" | cut -d= -f2)
WIDTH=$(echo "$VIDEO_STREAM" | grep "width" | cut -d= -f2)
HEIGHT=$(echo "$VIDEO_STREAM" | grep "height" | cut -d= -f2)
FPS=$(echo "$VIDEO_STREAM" | grep "r_frame_rate" | cut -d= -f2)
FPS_CALC=$(echo "scale=2; $FPS" | bc -l)
BITRATE_VIDEO=$(echo "$VIDEO_STREAM" | grep "bit_rate" | cut -d= -f2)
PIX_FMT=$(echo "$VIDEO_STREAM" | grep "pix_fmt" | cut -d= -f2)
PROFILE=$(echo "$VIDEO_STREAM" | grep "profile" | cut -d= -f2)
LEVEL=$(echo "$VIDEO_STREAM" | grep "level" | cut -d= -f2)

# Formata o bitrate
if [ ! -z "$BITRATE_VIDEO" ] && [ "$BITRATE_VIDEO" != "N/A" ]; then
    BITRATE_VIDEO_KB=$(echo "scale=2; $BITRATE_VIDEO/1000" | bc)
    BITRATE_VIDEO_MB=$(echo "scale=2; $BITRATE_VIDEO/1000000" | bc)
    BITRATE_VIDEO_FORMATTED="${BITRATE_VIDEO_KB} kbps (${BITRATE_VIDEO_MB} Mbps)"
else
    BITRATE_VIDEO_FORMATTED="N/A"
fi

echo "   Codec: $CODEC_VIDEO"
echo "   Resolução: ${WIDTH}x${HEIGHT}"
echo "   FPS: $FPS_CALC"
echo "   Bitrate: $BITRATE_VIDEO_FORMATTED"
echo "   Formato de pixel: $PIX_FMT"
echo "   Profile: ${PROFILE:-N/A}"
echo "   Level: ${LEVEL:-N/A}"

# Tenta obter o CRF (se existir)
CRF_VALUE=$(ffprobe -v error -select_streams v:0 -show_entries stream_tags=crf -of default=noprint_wrappers=1:nokey=1 "$VIDEO_FILE")
if [ ! -z "$CRF_VALUE" ]; then
    echo "   CRF: $CRF_VALUE"
else
    echo "   CRF: Não detectado (pode ser CBR/VBR sem CRF)"
fi
echo ""

# Obtém informações do stream de áudio
echo "🔊 INFORMAÇÕES DE ÁUDIO:"
AUDIO_STREAMS=$(ffprobe -v error -select_streams a -show_entries stream=codec_name,channels,sample_rate,bit_rate -of default=noprint_wrappers=1 "$VIDEO_FILE")

if [ ! -z "$AUDIO_STREAMS" ]; then
    I=0
    echo "$AUDIO_STREAMS" | while read -r line; do
        if [[ $line == codec_name=* ]]; then
            I=$((I+1))
            CODEC_AUDIO=$(echo $line | cut -d= -f2)
            echo "   Stream $I:"
            echo "     Codec: $CODEC_AUDIO"
        elif [[ $line == channels=* ]]; then
            CHANNELS=$(echo $line | cut -d= -f2)
            echo "     Canais: $CHANNELS"
        elif [[ $line == sample_rate=* ]]; then
            SAMPLE_RATE=$(echo $line | cut -d= -f2)
            echo "     Sample Rate: ${SAMPLE_RATE} Hz"
        elif [[ $line == bit_rate=* ]]; then
            BITRATE_AUDIO=$(echo $line | cut -d= -f2)
            if [ ! -z "$BITRATE_AUDIO" ] && [ "$BITRATE_AUDIO" != "N/A" ]; then
                BITRATE_AUDIO_KB=$(echo "scale=2; $BITRATE_AUDIO/1000" | bc)
                echo "     Bitrate: ${BITRATE_AUDIO_KB} kbps"
            else
                echo "     Bitrate: N/A"
            fi
            echo ""
        fi
    done
else
    echo "   Nenhum stream de áudio encontrado"
fi

# Informações adicionais úteis para otimização
echo "⚙️  INFORMAÇÕES PARA OTIMIZAÇÃO:"
echo "   Tamanho atual: $FORMATTED_SIZE"
echo "   Bitrate total estimado: $(echo "scale=2; ($FILE_SIZE*8)/$DURATION/1000" | bc) kbps"

# Calcula bitrate alvo para redução de 50%
CURRENT_BITRATE=$(echo "scale=2; ($FILE_SIZE*8)/$DURATION" | bc)
TARGET_BITRATE=$(echo "scale=2; $CURRENT_BITRATE*0.5" | bc)
echo "   Bitrate alvo para redução de 50%: $(echo "scale=2; $TARGET_BITRATE/1000" | bc) kbps"

# Sugestões de otimização
echo ""
echo "💡 SUGESTÕES PARA REDUÇÃO DE TAMANHO:"
echo "   1. Reduzir CRF (23 é padrão, aumentar para 28-30 reduz tamanho)"
echo "   2. Diminuir resolução (ex: 1920x1080 → 1280x720)"
echo "   3. Reduzir FPS (ex: 60 → 30 ou 24)"
echo "   4. Usar codec mais eficiente (h264 → h265)"
echo "   5. Reduzir bitrate de áudio (ex: 128k → 96k)"
echo ""

echo "=============================================="
echo "EXEMPLOS DE COMANDOS FFMPEG PARA OTIMIZAÇÃO:"
echo "=============================================="
echo ""
echo "1. Reduzir CRF para 28:"
echo "   ffmpeg -i \"$VIDEO_FILE\" -c:v libx264 -crf 28 -c:a copy output_crf28.mp4"
echo ""
echo "2. Reduzir resolução para 720p:"
echo "   ffmpeg -i \"$VIDEO_FILE\" -vf \"scale=1280:720\" -c:a copy output_720p.mp4"
echo ""
echo "3. Reduzir FPS para 30:"
echo "   ffmpeg -i \"$VIDEO_FILE\" -r 30 -c:a copy output_30fps.mp4"
echo ""
echo "4. Converter para HEVC (h265):"
echo "   ffmpeg -i \"$VIDEO_FILE\" -c:v libx265 -crf 28 -c:a copy output_h265.mp4"
echo ""
echo "5. Reduzir bitrate de áudio para 96k:"
echo "   ffmpeg -i \"$VIDEO_FILE\" -c:v copy -c:a aac -b:a 96k output_audio96k.mp4"
echo ""
echo "6. Combinação de otimizações:"
echo "   ffmpeg -i \"$VIDEO_FILE\" -c:v libx265 -crf 28 -vf \"scale=1280:720\" -r 30 -c:a aac -b:a 96k output_optimized.mp4"
echo ""
echo "7. Ultra compactado:"
echo "   ffmpeg -i \"$VIDEO_FILE\" -c:v libx264 -crf 35 -vf \"scale=640:360\" -r 12 -c:a aac -b:a 15k -preset slow -movflags +faststart output_optimized.mp4"