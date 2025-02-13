wav_format_help() {
    cat <<'EOF'
# wav formats help

wav 8 bits
    ffmpeg -i input.wav -ar 8000 -ac 1 -acodec pcm_u8 output.wav

wav 16 bits
    ffmpeg -i input.wav -ar 44100 -c:a pcm_s16le output.wav

all PCM codecs
    ffmpeg -formats | grep -i pcm

EOF
}