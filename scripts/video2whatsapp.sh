#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<DOCUMENTATION
Script to convert videos to WhatsApp-compatible format using ffmpeg.

Available modes:
- 1280: Original mode (max resolution 1280px, best quality)
- 720: Medium resolution (max 720px, balanced quality/size)
- 480: Low resolution (max 480px, smallest file size)

All modes include:
- H.264 video codec (libx264)
- AAC audio
- movflags +faststart for streaming

ffmpeg parameters explained:
-i input.mp4          - Input video file
-c:v libx264          - H.264 video encoder (widely compatible)
-crf                  - Video quality (lower=better quality)
-preset               - Encoding speed/file size tradeoff
-c:a aac              - AAC audio encoder (WhatsApp compatible)
-b:a                  - Audio bitrate (lower=smaller file size)
-movflags +faststart  - Enables streaming (playback before full download)
-vf "scale=..."       - Smart scaling to target resolution

Usage: video2whatsapp.sh [mode] input_video.mp4 output_video.mp4
Modes: 1280 (default), 720, 480
DOCUMENTATION

# Help function
help() {
    sed -n '/^: <<DOCUMENTATION$/,/^DOCUMENTATION$/p' "$0" | sed '1d;$d'
    exit 0
}

# Check for help request
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    help
fi

# Default mode is 1280
mode="1280"

# Check if first argument is a mode specification
if [[ "$1" =~ ^(1280|720|480)$ ]]; then
    mode="$1"
    shift
fi

# Validate argument count
if [ "$#" -ne 2 ]; then
    echo -e "\033[1;31mError: Invalid number of arguments.\033[0m"
    echo -e "\033[1;32mUsage: ${0##*/} [mode] input_video.mp4 output_video.mp4\033[0m"
    echo -e "\033[1;33mAvailable modes: 1280 (default), 720, 480\033[0m\n"
    help
fi

input_file="$1"
output_file="$2"

# Validate input file
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' not found."
    exit 1
fi

if ! ffprobe -i "$input_file" &> /dev/null; then
    echo "Error: '$input_file' doesn't appear to be a valid video file."
    exit 1
fi

# Validate output file extension
if [[ "$output_file" != *.mp4 ]]; then
    echo "Error: Output file must have .mp4 extension."
    echo "Reason: WhatsApp only accepts MP4 videos with H.264 codec."
    echo "Please specify an output filename ending with .mp4"
    exit 1
fi

# Set parameters based on mode
case "$mode" in
    1280)
        scale="scale='if(gt(iw,ih),min(1280,iw),-1)':'if(gt(iw,ih),-1,min(1280,ih))'"
        crf=23
        preset="fast"
        audio_bitrate="128k"
        ;;
    720)
        scale="scale='if(gt(iw,ih),min(720,iw),-1)':'if(gt(iw,ih),-1,min(720,ih))'"
        crf=26
        preset="medium"
        audio_bitrate="96k"
        ;;
    480)
        scale="scale='if(gt(iw,ih),min(480,iw),-1)':'if(gt(iw,ih),-1,min(480,ih))'"
        crf=28
        preset="medium"
        audio_bitrate="64k"
        ;;
    *)
        echo "Error: Invalid mode selected."
        exit 1
        ;;
esac

echo "Converting using mode $mode (resolution: ${mode}p, audio: $audio_bitrate)"

# Execute conversion
ffmpeg -i "$input_file" \
    -c:v libx264 \
    -crf "$crf" \
    -preset "$preset" \
    -c:a aac \
    -b:a "$audio_bitrate" \
    -movflags +faststart \
    -vf "$scale" \
    "$output_file"

echo "Conversion complete: $output_file"