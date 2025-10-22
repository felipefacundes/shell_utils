#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<DOCUMENTATION
Script to convert videos to WhatsApp and Telegram compatible format using ffmpeg.

Available modes:
- 1920: High resolution (max 1920px for landscape, 1080px for portrait)
- 1280: Original mode (max resolution 1280px for landscape, 720px for portrait)
- 720: Medium resolution (max 720px for landscape, 480px for portrait)
- 640: Low resolution (max 640px for landscape, 360px for portrait)
- 360: Very low resolution (optimized for small file size)

All modes include:
- H.264 video codec (libx264)
- AAC audio
- movflags +faststart for streaming
- Automatic orientation detection
- Smart scaling maintaining aspect ratio

ffmpeg parameters explained:
-i input.mp4          - Input video file
-c:v libx264          - H.264 video encoder (widely compatible)
-crf                  - Video quality (lower=better quality)
-preset               - Encoding speed/file size tradeoff
-c:a aac              - AAC audio encoder (WhatsApp compatible)
-b:a                  - Audio bitrate (lower=smaller file size)
-movflags +faststart  - Enables streaming (playback before full download)
-vf "scale=..."       - Smart scaling to target resolution

Usage: $0 [mode] input_video.mp4 [output_video.mp4]
DOCUMENTATION

# Default values
mode="1280"
portrait=false
input_file=""
output_file=""

# Function to detect video orientation and dimensions
detect_orientation() {
    local file="$1"
    
    # Get video dimensions
    dimensions=$(ffprobe -v error -select_streams v:0 \
              -show_entries stream=width,height -of csv=p=0 "$file" 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo "Error: Could not get video dimensions for $file"
        return 1
    fi
    
    width=$(echo $dimensions | cut -d',' -f1)
    height=$(echo $dimensions | cut -d',' -f2)
    
    echo "Original resolution: ${width}x${height}"
    
    # Determine orientation
    if [ "$width" -gt "$height" ]; then
        portrait=false
        echo "Orientation: Landscape"
    elif [ "$height" -gt "$width" ]; then
        portrait=true
        echo "Orientation: Portrait"
    else
        portrait=true
        echo "Orientation: Square (treated as portrait)"
    fi
}

# Function to set scaling parameters based on mode and orientation
get_scaling_params() {
    local mode="$1"
    local portrait="$2"
    
    case $mode in
        "1920")
            if [ "$portrait" = true ]; then
                echo "scale=1080:1920:flags=lanczos"
            else
                echo "scale=1920:1080:flags=lanczos"
            fi
            ;;
        "1280")
            if [ "$portrait" = true ]; then
                echo "scale=720:1280:flags=lanczos"
            else
                echo "scale=1280:720:flags=lanczos"
            fi
            ;;
        "720")
            if [ "$portrait" = true ]; then
                echo "scale=480:720:flags=lanczos"
            else
                echo "scale=720:480:flags=lanczos"
            fi
            ;;
        "640")
            if [ "$portrait" = true ]; then
                echo "scale=360:640:flags=lanczos"
            else
                echo "scale=640:360:flags=lanczos"
            fi
            ;;
        "360")
            if [ "$portrait" = true ]; then
                echo "scale=360:640:flags=lanczos"
            else
                echo "scale=640:360:flags=lanczos"
            fi
            ;;
        *)
            echo "scale=1280:720:flags=lanczos"
            ;;
    esac
}

# Function to set encoding parameters based on mode
get_encoding_params() {
    local mode="$1"
    
    case $mode in
        "1920")
            echo "crf=28 preset=slow r=30 b_a=128k"
            ;;
        "1280")
            echo "crf=30 preset=slow r=25 b_a=96k"
            ;;
        "720")
            echo "crf=32 preset=medium r=20 b_a=80k"
            ;;
        "640")
            echo "crf=33 preset=medium r=15 b_a=72k"
            ;;
        "360")
            echo "crf=35 preset=slow r=12 b_a=64k"
            ;;
        *)
            echo "crf=30 preset=slow r=25 b_a=96k"
            ;;
    esac
}

# Function to show usage
show_usage() {
    echo "Usage: ${0##*/} [mode] input_video.mp4 [output_video.mp4]"
    echo "Modes: 1920, 1280 (default), 720, 640, 360"
    echo ""
    echo "Examples:"
    echo "  ${0##*/} input.mp4 output.mp4"
    echo "  ${0##*/} 720 input.mp4 output.mp4"
    echo "  ${0##*/} 1920 input.mp4"
    echo ""
    echo "If output file is not specified, will use: input_whatsapp.mp4"
}

# Function to show documentation
show_documentation() {
    sed -n '/^: <<DOCUMENTATION$/,/^DOCUMENTATION$/p' "${0}" | sed '1d;$d'
}

# Parse arguments
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

# Check for help option
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_documentation
    exit 0
fi

# Parse mode and files
if [ $# -eq 1 ]; then
    # Only input file provided
    input_file="$1"
    output_file="${1%.*}_whatsapp.mp4"
elif [ $# -eq 2 ]; then
    # Could be mode+input or input+output
    if [[ "$1" =~ ^(1920|1280|720|640|360)$ ]]; then
        mode="$1"
        input_file="$2"
        output_file="${2%.*}_whatsapp.mp4"
    else
        input_file="$1"
        output_file="$2"
    fi
elif [ $# -eq 3 ]; then
    # mode + input + output
    mode="$1"
    input_file="$2"
    output_file="$3"
else
    echo "Error: Too many arguments"
    show_usage
    exit 1
fi

# Validate input file
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' not found"
    exit 1
fi

# Validate mode
if [[ ! "$mode" =~ ^(1920|1280|720|640|360)$ ]]; then
    echo "Error: Invalid mode '$mode'. Available modes: 1920, 1280, 720, 640, 360"
    exit 1
fi

echo "=== Video to WhatsApp Converter ==="
echo "Mode: $mode"
echo "Input: $input_file"
echo "Output: $output_file"

# Detect orientation
if ! detect_orientation "$input_file"; then
    exit 1
fi

# Get scaling and encoding parameters
scale_filter=$(get_scaling_params "$mode" "$portrait")
encoding_params=$(get_encoding_params "$mode")

# Parse encoding parameters
crf=$(echo "$encoding_params" | cut -d' ' -f1 | cut -d'=' -f2)
preset=$(echo "$encoding_params" | cut -d' ' -f2 | cut -d'=' -f2)
r=$(echo "$encoding_params" | cut -d' ' -f3 | cut -d'=' -f2)
b_a=$(echo "$encoding_params" | cut -d' ' -f4 | cut -d'=' -f2)

echo "Scaling: $scale_filter"
echo "Quality: CRF $crf, Preset $preset"
echo "Frame rate: $r fps"
echo "Audio bitrate: $b_a"

# Check if output file exists
if [ -f "$output_file" ]; then
    read -p "Output file '$output_file' exists. Overwrite? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Conversion cancelled."
        exit 0
    fi
fi

# Conversion command
echo "Starting conversion..."
ffmpeg -i "$input_file" \
       -c:v libx264 \
       -crf "$crf" \
       -vf "$scale_filter" \
       -r "$r" \
       -c:a aac \
       -b:a "$b_a" \
       -preset "$preset" \
       -movflags +faststart \
       -y \
       "$output_file"

# Check if conversion was successful
if [ $? -eq 0 ]; then
    echo "Conversion completed successfully: $output_file"
    
    # Show output file size
    if command -v du &> /dev/null; then
        file_size=$(du -h "$output_file" | cut -f1)
        echo "Output file size: $file_size"
    fi
else
    echo "Error: Conversion failed"
    exit 1
fi