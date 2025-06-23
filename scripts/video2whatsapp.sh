#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<DOCUMENTATION
Script to convert videos to WhatsApp-compatible format using ffmpeg.

ffmpeg parameters explained:
-i input.mp4          - Input video file
-c:v libx264          - H.264 video encoder (widely compatible)
-crf 23               - Video quality (0=lossless, 51=worst; 23 is a good balance)
-preset fast          - Faster encoding with slightly larger file size
-c:a aac              - AAC audio encoder (WhatsApp compatible)
-b:a 128k             - 128kbps audio bitrate (good quality)
-movflags +faststart  - Enables streaming (playback before full download)
-vf "scale=..."       - Smart scaling that:
   - if(gt(iw,ih),min(1280,iw),-1) - For landscape: max width 1280px
   - if(gt(iw,ih),-1,min(1280,ih)) - For portrait: max height 1280px

Usage: video2whatsapp.sh input_video.mp4 output_video.mp4
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

# Validate argument count
if [ "$#" -ne 2 ]; then
    echo -e "\033[1;31mError: Invalid number of arguments.\033[0m"
    echo -e "\033[1;32mUsage: ${0##*/} input_video.mp4 output_video.mp4\033[0m\n"
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

# Execute conversion
ffmpeg -i "$input_file" \
    -c:v libx264 \
    -crf 23 \
    -preset fast \
    -c:a aac \
    -b:a 128k \
    -movflags +faststart \
    -vf "scale='if(gt(iw,ih),min(1280,iw),-1)':'if(gt(iw,ih),-1,min(1280,ih))'" \
    "$output_file"

echo "Conversion complete: $output_file"