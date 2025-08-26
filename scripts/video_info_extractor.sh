#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

# Check if file was provided
if [ $# -eq 0 ]; then
    echo "Usage: ${0##*/} <video_file>"
    echo "Example: ${0##*/} video.mp4"
    exit 1
fi

VIDEO_FILE="$1"

# Check if file exists
if [ ! -f "$VIDEO_FILE" ]; then
    echo "Error: File '$VIDEO_FILE' not found!"
    exit 1
fi

# Check if ffprobe is installed
if ! command -v ffprobe &> /dev/null; then
    echo "Error: ffprobe is not installed. Install ffmpeg first."
    echo "Ubuntu/Debian: sudo apt install ffmpeg"
    echo "CentOS/RHEL: sudo yum install ffmpeg"
    echo "macOS: brew install ffmpeg"
    exit 1
fi

echo "=============================================="
echo "DETAILED VIDEO ANALYSIS: $VIDEO_FILE"
echo "=============================================="
echo ""

# Function to format bytes to human-readable units
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

# Get general file information
FILE_SIZE=$(stat -c%s "$VIDEO_FILE")
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO_FILE")
FORMATTED_SIZE=$(format_bytes $FILE_SIZE)

echo "📊 GENERAL INFORMATION:"
echo "   File size: $FORMATTED_SIZE"
echo "   Duration: $(echo "scale=2; $DURATION/60" | bc) minutes ($(echo "scale=2; $DURATION" | bc) seconds)"
echo "   Format: $(ffprobe -v error -show_entries format=format_name -of default=noprint_wrappers=1:nokey=1 "$VIDEO_FILE")"
echo ""

# Get video stream information
echo "🎥 VIDEO INFORMATION:"
VIDEO_STREAM=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height,r_frame_rate,bit_rate,pix_fmt,profile,level -of default=noprint_wrappers=1 "$VIDEO_FILE")

# Extract individual information
CODEC_VIDEO=$(echo "$VIDEO_STREAM" | grep "codec_name" | cut -d= -f2)
WIDTH=$(echo "$VIDEO_STREAM" | grep "width" | cut -d= -f2)
HEIGHT=$(echo "$VIDEO_STREAM" | grep "height" | cut -d= -f2)
FPS=$(echo "$VIDEO_STREAM" | grep "r_frame_rate" | cut -d= -f2)
FPS_CALC=$(echo "scale=2; $FPS" | bc -l)
BITRATE_VIDEO=$(echo "$VIDEO_STREAM" | grep "bit_rate" | cut -d= -f2)
PIX_FMT=$(echo "$VIDEO_STREAM" | grep "pix_fmt" | cut -d= -f2)
PROFILE=$(echo "$VIDEO_STREAM" | grep "profile" | cut -d= -f2)
LEVEL=$(echo "$VIDEO_STREAM" | grep "level" | cut -d= -f2)

# Format bitrate
if [ ! -z "$BITRATE_VIDEO" ] && [ "$BITRATE_VIDEO" != "N/A" ]; then
    BITRATE_VIDEO_KB=$(echo "scale=2; $BITRATE_VIDEO/1000" | bc)
    BITRATE_VIDEO_MB=$(echo "scale=2; $BITRATE_VIDEO/1000000" | bc)
    BITRATE_VIDEO_FORMATTED="${BITRATE_VIDEO_KB} kbps (${BITRATE_VIDEO_MB} Mbps)"
else
    BITRATE_VIDEO_FORMATTED="N/A"
fi

echo "   Codec: $CODEC_VIDEO"
echo "   Resolution: ${WIDTH}x${HEIGHT}"
echo "   FPS: $FPS_CALC"
echo "   Bitrate: $BITRATE_VIDEO_FORMATTED"
echo "   Pixel format: $PIX_FMT"
echo "   Profile: ${PROFILE:-N/A}"
echo "   Level: ${LEVEL:-N/A}"

# Try to get CRF (if exists)
CRF_VALUE=$(ffprobe -v error -select_streams v:0 -show_entries stream_tags=crf -of default=noprint_wrappers=1:nokey=1 "$VIDEO_FILE")
if [ ! -z "$CRF_VALUE" ]; then
    echo "   CRF: $CRF_VALUE"
else
    echo "   CRF: Not detected (may be CBR/VBR without CRF)"
fi
echo ""

# Get audio stream information
echo "🔊 AUDIO INFORMATION:"
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
            echo "     Channels: $CHANNELS"
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
    echo "   No audio streams found"
fi

# Additional useful information for optimization
echo "⚙️  OPTIMIZATION INFORMATION:"
echo "   Current size: $FORMATTED_SIZE"
echo "   Estimated total bitrate: $(echo "scale=2; ($FILE_SIZE*8)/$DURATION/1000" | bc) kbps"

# Calculate target bitrate for 50% reduction
CURRENT_BITRATE=$(echo "scale=2; ($FILE_SIZE*8)/$DURATION" | bc)
TARGET_BITRATE=$(echo "scale=2; $CURRENT_BITRATE*0.5" | bc)
echo "   Target bitrate for 50% reduction: $(echo "scale=2; $TARGET_BITRATE/1000" | bc) kbps"

# Optimization suggestions
echo ""
echo "💡 SUGGESTIONS FOR SIZE REDUCTION:"
echo "   1. Reduce CRF (23 is default, increase to 28-30 reduces size)"
echo "   2. Decrease resolution (ex: 1920x1080 → 1280x720)"
echo "   3. Reduce FPS (ex: 60 → 30 or 24)"
echo "   4. Use more efficient codec (h264 → h265)"
echo "   5. Reduce audio bitrate (ex: 128k → 96k)"
echo ""

echo "=============================================="
echo "EXAMPLE FFMPEG COMMANDS FOR OPTIMIZATION:"
echo "=============================================="
echo ""
echo "1. Reduce CRF to 28:"
echo "   ffmpeg -i \"$VIDEO_FILE\" -c:v libx264 -crf 28 -c:a copy output_crf28.mp4"
echo ""
echo "2. Reduce resolution to 720p:"
echo "   ffmpeg -i \"$VIDEO_FILE\" -vf \"scale=1280:720\" -c:a copy output_720p.mp4"
echo ""
echo "3. Reduce FPS to 30:"
echo "   ffmpeg -i \"$VIDEO_FILE\" -r 30 -c:a copy output_30fps.mp4"
echo ""
echo "4. Convert to HEVC (h265):"
echo "   ffmpeg -i \"$VIDEO_FILE\" -c:v libx265 -crf 28 -c:a copy output_h265.mp4"
echo ""
echo "5. Reduce audio bitrate to 96k:"
echo "   ffmpeg -i \"$VIDEO_FILE\" -c:v copy -c:a aac -b:a 96k output_audio96k.mp4"
echo ""
echo "6. Combination of optimizations:"
echo "   ffmpeg -i \"$VIDEO_FILE\" -c:v libx265 -crf 28 -vf \"scale=1280:720\" -r 30 -c:a aac -b:a 96k output_optimized.mp4"
echo ""
echo "7. Ultra compacto:"
echo "   ffmpeg -i \"$VIDEO_FILE\" -c:v libx264 -crf 35 -vf \"scale=640:360\" -r 12 -c:a aac -b:a 15k -preset slow -movflags +faststart output_optimized.mp4"