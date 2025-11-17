#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'

VIDEO UPSCALE SCRIPT DOCUMENTATION
==================================

Script: video_upscale.sh
Description: Advanced video upscaling tool using Anime4K shaders with FFmpeg and Vulkan hardware acceleration
Version: 2.0
Author: AI Assistant

OVERVIEW
--------
This script provides high-quality video upscaling and enhancement using multiple Anime4K shaders
through FFmpeg with Vulkan hardware acceleration. It supports various processing modes for
different quality and enhancement requirements.

DEPENDENCIES
------------
- FFmpeg with Vulkan support
- Anime4K shaders installed at: /usr/share/anime4k/
- Compatible GPU with Vulkan support

INSTALLATION
------------
1. Ensure FFmpeg is compiled with Vulkan and libplacebo support
2. Install Anime4K shaders to /usr/share/anime4k/
3. Make script executable: chmod +x video_upscale.sh

USAGE SYNTAX
------------
./video_upscale.sh [OPTIONS] <input_file> <output_file>

OPTIONS
-------
-m, --mode MODE          Processing mode (standard|restore|experimental|premium|vivid)
                         Default: standard
-up, --upscale FACTOR    Upscale factor (1-10, default: 2)
-c, --codec CODEC        Output video codec (default: libx264)
-h, --help               Show this help message

PROCESSING MODES
----------------

1. STANDARD MODE (-m standard)
   ---------------------------
   Uses 7 Anime4K shaders for balanced upscaling:
   - Anime4K_Clamp_Highlights.glsl
   - Anime4K_Restore_CNN_VL.glsl  
   - Anime4K_Upscale_CNN_x2_VL.glsl
   - Anime4K_Restore_CNN_M.glsl
   - Anime4K_AutoDownscalePre_x2.glsl
   - Anime4K_AutoDownscalePre_x4.glsl
   - Anime4K_Upscale_CNN_x2_M.glsl (with resize applied)
   
   Codec: libx264 (default)

2. RESTORE MODE (-m restore)
   --------------------------
   Focuses on restoration and detail enhancement:
   - Anime4K_Clamp_Highlights.glsl
   - Anime4K_Restore_CNN_VL.glsl
   - Anime4K_Darken_HQ.glsl
   - Anime4K_Thin_HQ.glsl (with resize applied)
   
   Codec: libx264 (default)

3. EXPERIMENTAL MODE (-m experimental)
   -----------------------------------
   Uses experimental effects for specialized enhancement:
   - Anime4K_Clamp_Highlights.glsl
   - Anime4K_Restore_CNN_VL.glsl
   - Anime4K_Darken_HQ.glsl
   - Anime4K_Thin_HQ.glsl (with resize applied)
   
   Codec: libx264 (default)

4. PREMIUM MODE (-m premium)
   --------------------------
   High-quality mode with 10-bit color processing and advanced encoding:
   - Uses all 7 standard shaders with 10-bit color depth
   - ewa_lanczos upscaler for superior quality
   - Default codec: hevc_nvenc with quality settings:
     * -cq 24 (Constant Quality)
     * -bf 5 (B-frames)
     * -refs 5 (Reference frames)
     * -preset slow (Encoding preset)
   
   Codec: hevc_nvenc (default, can be overridden with -c)

5. VIVID MODE (-m vivid)
   ---------------------
   Enhanced colors and sharpness with 7 shaders:
   - Uses all 7 standard shaders
   - Color enhancement: brightness=0.02, contrast=1.1, saturation=1.15
   - Sharpness: unsharp=5:5:0.5
   - Optimized for vibrant, sharp output
   
   Codec: libx264 (default, can be overridden with -c)

UPSCALE FACTORS
---------------
- Range: 1 to 10
- Default: 2
- Higher values increase resolution but require more processing time and VRAM

SUPPORTED CODECS
----------------
- libx264 (H.264)
- libx265 (H.265/HEVC)
- hevc_nvenc (NVIDIA H.265)
- hevc_amf (AMD H.265)
- And other FFmpeg-supported codecs

EXAMPLES
--------
# Basic upscale with standard mode
./video_upscale.sh input.mp4 output.mp4

# 4x upscale with restore mode
./video_upscale.sh -m restore -up 4 input.mkv output.mkv

# Premium mode with custom codec
./video_upscale.sh -m premium -c libx265 input.avi output.mp4

# Vivid mode with enhanced colors
./video_upscale.sh -m vivid -up 3 input.mp4 output.mp4

# Experimental mode with specific codec
./video_upscale.sh -m experimental -c hevc_nvenc input.mov output.mkv

PERFORMANCE NOTES
-----------------
- Higher upscale factors significantly increase processing time
- Premium mode requires more VRAM due to 10-bit processing
- Vivid mode adds minimal overhead for color enhancement
- GPU memory usage scales with input resolution and upscale factor

TROUBLESHOOTING
---------------
Error: "invalid preset 'p7'"
- Solution: Use libx264-compatible presets (ultrafast to placebo)

Error: "Function not implemented" with unsharp filter
- Solution: Ensure proper filter chain order and format compatibility

Error: Vulkan initialization failed
- Solution: Verify Vulkan support and GPU drivers

Error: Shader files not found
- Solution: Check Anime4K installation at /usr/share/anime4k/

OUTPUT QUALITY
--------------
Standard: Good balance of quality and speed
Restore: Best for artifact reduction and detail recovery
Experimental: Specialized effects for specific use cases
Premium: Highest quality with advanced encoding
Vivid: Enhanced colors and sharpness for vibrant content

LICENSE
-------
This script is provided as-is for educational and personal use.

DOCUMENTATION

SCRIPT_NAME="${0##*/}"
DEFAULT_UPSCALE=2
MAX_UPSCALE=10
DEFAULT_CODEC="libx264"

# Default mode
MODE="standard"

# Default values
UPSCALE_FACTOR=$DEFAULT_UPSCALE
CODEC=$DEFAULT_CODEC
INPUT_FILE=""
OUTPUT_FILE=""

# Function to display help
show_help() {
    cat << EOF | { echo -e "$(cat)"; }

${SCRIPT_NAME} - Video Upscale Tool with Anime4K Shaders

USAGE:
    ${SCRIPT_NAME} [OPTIONS] <input_file> <output_file>

DESCRIPTION:
    This script performs video upscaling using multiple Anime4K shaders through FFmpeg.
    It supports different processing modes and Vulkan hardware acceleration.

OPTIONS:
    -m, --mode MODE          Set processing mode (standard, restore, experimental, premium)
                             Default: standard
    -up, --upscale FACTOR    Set upscale factor (1-${MAX_UPSCALE}, default: ${DEFAULT_UPSCALE})
    -c, --codec CODEC        Set output codec (default: ${DEFAULT_CODEC})
    -h, --help               Show this help message

MODES:
    standard      - Standard upscaling with CNN-based shaders
    restore       - Focus on restoration and detail enhancement  
    experimental  - Experimental effects (darken and thin lines)
    premium       - Premium mode with 7 shaders and high-quality encoding
    vivid         - Vivid mode with enhanced colors, sharpness and saturation

EXAMPLES:
    ${SCRIPT_NAME} -m standard -up 2 input.mp4 output.mp4
    ${SCRIPT_NAME} --mode restore --codec libx265 input.mkv output.mkv
    ${SCRIPT_NAME} -m experimental -up 4 input.avi output.mp4
    ${SCRIPT_NAME} -m premium -up 2 -c hevc_nvenc input.mp4 output.mkv

DEPENDENCIES:
    Requires FFmpeg with Vulkan support and Anime4K shaders installed at:
    /usr/share/anime4k/

EOF
}

# Function to display error and exit
error_exit() {
    echo "ERROR: $1" >&2
    echo "Use -h for help" >&2
    exit 1
}

# Function to validate upscale factor
validate_upscale() {
    if ! [[ "$1" =~ ^[1-9][0-9]*$ ]] || [ "$1" -gt $MAX_UPSCALE ] || [ "$1" -lt 1 ]; then
        error_exit "Upscale factor must be an integer between 1 and ${MAX_UPSCALE}"
    fi
}

# Function to build filter complex based on mode and upscale factor
build_filter_complex() {
    local mode=$1
    local upscale=$2
    
    # Calculate output dimensions
    local width="iw*${upscale}"
    local height="ih*${upscale}"
    
    case $mode in
        "standard")
            echo "format=yuv420p,hwupload,\
libplacebo=custom_shader_path=/usr/share/anime4k/Restore/Anime4K_Clamp_Highlights.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Restore/Anime4K_Restore_CNN_VL.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Upscale/Anime4K_Upscale_CNN_x2_VL.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Restore/Anime4K_Restore_CNN_M.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Upscale/Anime4K_AutoDownscalePre_x2.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Upscale/Anime4K_AutoDownscalePre_x4.glsl,\
libplacebo=w=${width}:h=${height}:custom_shader_path=/usr/share/anime4k/Upscale/Anime4K_Upscale_CNN_x2_M.glsl,\
hwdownload,format=yuv420p"
            ;;
        "restore")
            echo "format=yuv420p,hwupload,\
libplacebo=custom_shader_path=/usr/share/anime4k/Restore/Anime4K_Clamp_Highlights.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Restore/Anime4K_Restore_CNN_VL.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Experimental-Effects/Anime4K_Darken_HQ.glsl,\
libplacebo=w=${width}:h=${height}:custom_shader_path=/usr/share/anime4k/Experimental-Effects/Anime4K_Thin_HQ.glsl,\
hwdownload,format=yuv420p"
            ;;
        "experimental")
            echo "format=yuv420p,hwupload,\
libplacebo=custom_shader_path=/usr/share/anime4k/Restore/Anime4K_Clamp_Highlights.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Restore/Anime4K_Restore_CNN_VL.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Experimental-Effects/Anime4K_Darken_HQ.glsl,\
libplacebo=w=${width}:h=${height}:custom_shader_path=/usr/share/anime4k/Experimental-Effects/Anime4K_Thin_HQ.glsl,\
hwdownload,format=yuv420p"
            ;;
        "premium")
            echo "format=yuv420p10,hwupload,\
libplacebo=custom_shader_path=/usr/share/anime4k/Restore/Anime4K_Clamp_Highlights.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Restore/Anime4K_Restore_CNN_VL.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Upscale/Anime4K_Upscale_CNN_x2_VL.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Restore/Anime4K_Restore_CNN_M.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Upscale/Anime4K_AutoDownscalePre_x2.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Upscale/Anime4K_AutoDownscalePre_x4.glsl,\
libplacebo=w=${width}:h=${height}:upscaler=ewa_lanczos:custom_shader_path=/usr/share/anime4k/Upscale/Anime4K_Upscale_CNN_x2_M.glsl,\
hwdownload,format=yuv420p10"
            ;;
        "vivid")
            echo "format=yuv420p,hwupload,\
libplacebo=custom_shader_path=/usr/share/anime4k/Restore/Anime4K_Clamp_Highlights.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Restore/Anime4K_Restore_CNN_VL.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Upscale/Anime4K_Upscale_CNN_x2_VL.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Restore/Anime4K_Restore_CNN_M.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Upscale/Anime4K_AutoDownscalePre_x2.glsl,\
libplacebo=custom_shader_path=/usr/share/anime4k/Upscale/Anime4K_AutoDownscalePre_x4.glsl,\
libplacebo=w=${width}:h=${height}:upscaler=ewa_lanczos:custom_shader_path=/usr/share/anime4k/Upscale/Anime4K_Upscale_CNN_x2_M.glsl,\
hwdownload,format=yuv420p,\
eq=brightness=0.02:contrast=1.1:saturation=1.15,\
unsharp=5:5:0.5"
            ;;
        *)
            error_exit "Unknown mode: $mode"
            ;;
    esac
}

# Function to build ffmpeg command based on mode
build_ffmpeg_command() {
    local mode=$1
    local input=$2
    local output=$3
    local filter_complex=$4
    local codec=$5
    
    case $mode in
        "premium")
            # For premium mode, use hevc_nvenc as default but allow override
            local premium_codec=${codec:-"hevc_nvenc"}
            echo "ffmpeg -init_hw_device vulkan -i \"$input\" -vf \"$filter_complex\" -c:v $premium_codec -cq 24 -bf 5 -refs 5 -preset slow \"$output\""
            ;;
        "vivid")
            # For vivid mode, use libx264 as default but allow override
            echo "ffmpeg -init_hw_device vulkan -i \"$input\" -vf \"$filter_complex\" -c:v $codec -bf 5 -refs 5 -preset slow \"$output\""
            ;;
        *)
            # For other modes, use the specified codec
            echo "ffmpeg -init_hw_device vulkan -i \"$input\" -vf \"$filter_complex\" -c:v \"$codec\" \"$output\""
            ;;
    esac
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--mode)
            MODE="$2"
            shift 2
            ;;
        -up|--upscale)
            validate_upscale "$2"
            UPSCALE_FACTOR="$2"
            shift 2
            ;;
        -c|--codec)
            CODEC="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            error_exit "Unknown option: $1"
            ;;
        *)
            if [ -z "$INPUT_FILE" ]; then
                INPUT_FILE="$1"
            elif [ -z "$OUTPUT_FILE" ]; then
                OUTPUT_FILE="$1"
            else
                error_exit "Too many arguments"
            fi
            shift
            ;;
    esac
done

# Validate input and output files
if [ -z "$INPUT_FILE" ] || [ -z "$OUTPUT_FILE" ]; then
    error_exit "Input and output files are required"
fi

if [ ! -f "$INPUT_FILE" ]; then
    error_exit "Input file not found: $INPUT_FILE"
fi

# Build filter complex
FILTER_COMPLEX=$(build_filter_complex "$MODE" "$UPSCALE_FACTOR")

echo "Starting video upscale processing..."
echo "Input: $INPUT_FILE"
echo "Output: $OUTPUT_FILE"
echo "Mode: $MODE"
echo "Upscale factor: $UPSCALE_FACTOR"
echo "Codec: $CODEC"
echo "Filter complex: $FILTER_COMPLEX"

# Build and execute FFmpeg command
FFMPEG_CMD=$(build_ffmpeg_command "$MODE" "$INPUT_FILE" "$OUTPUT_FILE" "$FILTER_COMPLEX" "$CODEC")

echo "Executing: $FFMPEG_CMD"
eval "$FFMPEG_CMD"

if [ $? -eq 0 ]; then
    echo "SUCCESS: Video processing completed: $OUTPUT_FILE"
else
    error_exit "FFmpeg processing failed"
fi