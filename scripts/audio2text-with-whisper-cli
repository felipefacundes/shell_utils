#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Script: audio_to_text.sh
Description: Converts audio to text using whisper.cpp with OpenVINO
DOCUMENTATION

# Settings
CONFIG_DIR="$HOME/.config/audio_transcribe"
CONFIG_FILE="$CONFIG_DIR/transcribe.conf"
CACHE_DIR="$HOME/.cache/audio_transcribe"
MODEL_CPU="ggml-base.bin"

# Create directories if they don't exist
mkdir -p "$CONFIG_DIR" "$CACHE_DIR"

# Load configuration or create default
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        cat > "$CONFIG_FILE" << EOF
# Audio transcription script configuration
# Model paths to check (one per line)
MODEL_PATHS=(
    "/usr/share/whisper/models/ggml-base.bin"
    "/usr/share/whisper.cpp-model-base/ggml-base.bin"
    "/usr/share/whisper.cpp/models/ggml-base.bin"
)
EOF
    fi
    source "$CONFIG_FILE"
}

# Check dependencies
check_dependencies() {
    local deps=("whiptail" "whisper-cli" "ffmpeg")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        whiptail --title "Error" --msgbox "Missing dependencies: ${missing[*]}" 10 60
        exit 1
    fi
}

# List of languages supported by Whisper
declare -A LANGUAGES=(
    ["Afrikaans"]="af" ["Arabic"]="ar" ["Armenian"]="hy" ["Azerbaijani"]="az"
    ["Belarusian"]="be" ["Bosnian"]="bs" ["Bulgarian"]="bg" ["Catalan"]="ca"
    ["Chinese"]="zh" ["Croatian"]="hr" ["Czech"]="cs" ["Danish"]="da"
    ["Dutch"]="nl" ["English"]="en" ["Estonian"]="et" ["Finnish"]="fi"
    ["French"]="fr" ["Galician"]="gl" ["German"]="de" ["Greek"]="el"
    ["Hebrew"]="he" ["Hindi"]="hi" ["Hungarian"]="hu" ["Icelandic"]="is"
    ["Indonesian"]="id" ["Italian"]="it" ["Japanese"]="ja" ["Kannada"]="kn"
    ["Kazakh"]="kk" ["Korean"]="ko" ["Latvian"]="lv" ["Lithuanian"]="lt"
    ["Macedonian"]="mk" ["Malay"]="ms" ["Marathi"]="mr" ["Maori"]="mi"
    ["Nepali"]="ne" ["Norwegian"]="no" ["Persian"]="fa" ["Polish"]="pl"
    ["Portuguese"]="pt" ["Romanian"]="ro" ["Russian"]="ru" ["Serbian"]="sr"
    ["Slovak"]="sk" ["Slovenian"]="sl" ["Spanish"]="es" ["Swahili"]="sw"
    ["Swedish"]="sv" ["Tagalog"]="tl" ["Tamil"]="ta" ["Thai"]="th"
    ["Turkish"]="tr" ["Ukrainian"]="uk" ["Urdu"]="ur" ["Vietnamese"]="vi"
    ["Welsh"]="cy"
)

# Select language
select_language() {
    local options=()
    
    # Sort language names alphabetically
    mapfile -t sorted_keys < <(printf '%s\n' "${!LANGUAGES[@]}" | sort)
    
    # Build options array in correct order
    for lang in "${sorted_keys[@]}"; do
        options+=("$lang" "${LANGUAGES[$lang]}")
    done
    
    local selected=$(whiptail --title "Select Language" \
        --menu "Choose the audio language:" 25 60 16 \
        "${options[@]}" 3>&1 1>&2 2>&3)
    
    if [[ -n "$selected" ]]; then
        echo "${LANGUAGES[$selected]}"
    else
        echo "auto"
    fi
}

# Select OpenVINO device
select_device() {
    local device=$(whiptail --title "Select Device" \
        --menu "Choose the processing device:" 15 50 4 \
        "CPU" "Processor (most compatible)" \
        "GPU" "Graphics card (faster)" \
        3>&1 1>&2 2>&3)
    
    echo "${device:-CPU}"
}

# Select output format
select_output_format() {
    local format=$(whiptail --title "Output Format" \
        --menu "Choose the output format:" 16 50 5 \
        "txt" "Plain text (.txt)" \
        "srt" "SRT subtitles (.srt)" \
        "vtt" "Web VTT subtitles (.vtt)" \
        "all" "All formats simultaneously" \
        3>&1 1>&2 2>&3)
    
    echo "${format:-txt}"
}

# Find model
find_model() {
    for path in "${MODEL_PATHS[@]}"; do
        if [[ -f "$path" ]]; then
            echo "$path"
            return 0
        fi
    done
    
    whiptail --title "Error" --msgbox "No whisper model found!\n\nCheck if the ggml-base.bin model is installed in:\n${MODEL_PATHS[*]}" 12 70
    exit 1
}

# Convert audio to WAV
convert_audio() {
    local input_file="$1"
    local output_file="$2"
    
    if ! ffmpeg -i "$input_file" -ar 16000 -ac 1 -c:a pcm_s16le -y "$output_file" 2>/dev/null; then
        whiptail --title "Error" --msgbox "Failed to convert audio: $input_file" 10 50
        exit 1
    fi
}

# Check if file is audio
is_audio_file() {
    local file="$1"
    local mimetype=$(file --mime-type -b "$file" 2>/dev/null)
    
    case "$mimetype" in
        audio/*|video/*)
            return 0
            ;;
        *)
            # Check extension as fallback
            local extension="${file##*.}"
            case "${extension,,}" in
                mp3|wav|ogg|flac|m4a|aac|wma|opus)
                    return 0
                    ;;
                *)
                    return 1
                    ;;
            esac
            ;;
    esac
}

# Process transcription for a specific format
process_transcription() {
    local temp_wav="$1"
    local model_path="$2"
    local language="$3"
    local device="$4"
    local format="$5"
    local output_file="$6"
    
    local whisper_cmd="whisper-cli -m \"$model_path\" -f \"$temp_wav\" -l \"$language\" -oved \"$device\""
    
    case "$format" in
        "txt")
            whisper_cmd+=" -otxt"
            ;;
        "srt")
            whisper_cmd+=" -osrt"
            ;;
        "vtt")
            whisper_cmd+=" -ovtt"
            ;;
    esac
    
    if eval "$whisper_cmd"; then
        if [[ -f "${temp_wav}.${format}" ]]; then
            cp "${temp_wav}.${format}" "$output_file"
            echo "✓ $format: $output_file"
        else
            echo "✗ $format: Error generating file"
        fi
    else
        echo "✗ $format: Transcription error"
    fi
}

# Main function
main() {
    # Check arguments
    if [[ $# -eq 0 ]]; then
        echo "Usage: ${0##*/} <audio_file>"
        echo "Example: ${0##*/} my_audio.mp3"
        exit 1
    fi
    
    local input_file="$1"
    
    # Check if file exists
    if [[ ! -f "$input_file" ]]; then
        whiptail --title "Error" --msgbox "File not found: $input_file" 10 50
        exit 1
    fi
    
    # Check if it's an audio file
    if ! is_audio_file "$input_file"; then
        whiptail --title "Error" --msgbox "File is not audio: $input_file" 10 50
        exit 1
    fi
    
    # Load settings and check dependencies
    load_config
    check_dependencies
    
    # Get base filename
    local base_name=$(basename "$input_file" | sed 's/\.[^.]*$//')
    local temp_wav="$CACHE_DIR/${base_name}.wav"
    local output_base="${input_file%.*}"
    
    # Select options
    local language=$(select_language)
    local device=$(select_device)
    local output_format=$(select_output_format)
    local model_path=$(find_model)
    
    # Prepare summary message
    local summary_msg="Configuration:\n\nFile: $(basename "$input_file")\nLanguage: $language\nDevice: $device\nModel: $(basename "$model_path")\n\n"
    
    if [[ "$output_format" == "all" ]]; then
        summary_msg+="Formats: TXT, SRT and VTT (all simultaneously)"
    else
        summary_msg+="Format: $output_format"
    fi
    
    summary_msg+="\n\nContinue?"
    
    # Show summary
    whiptail --title "Summary" --yesno "$summary_msg" 16 60
    if [[ $? -ne 0 ]]; then
        exit 0
    fi
    
    # Convert audio
    whiptail --title "Converting" --infobox "Converting audio to WAV..." 8 50
    convert_audio "$input_file" "$temp_wav"
    
    # Transcribe
    if [[ "$output_format" == "all" ]]; then
        whiptail --title "Transcribing" --infobox "Transcribing audio to ALL formats... This may take a few minutes." 8 70
        
        # Process all formats
        local output_files=()
        
        echo "Starting transcription for all formats..."
        
        # TXT
        process_transcription "$temp_wav" "$model_path" "$language" "$device" "txt" "${output_base}.txt"
        output_files+=("${output_base}.txt")
        
        # SRT
        process_transcription "$temp_wav" "$model_path" "$language" "$device" "srt" "${output_base}.srt"
        output_files+=("${output_base}.srt")
        
        # VTT
        process_transcription "$temp_wav" "$model_path" "$language" "$device" "vtt" "${output_base}.vtt"
        output_files+=("${output_base}.vtt")
        
        # Success message
        local success_msg="Transcription completed for all formats!\n\nGenerated files:\n"
        for file in "${output_files[@]}"; do
            if [[ -f "$file" ]]; then
                success_msg+="• $(basename "$file")\n"
            fi
        done
        
        whiptail --title "Success" --msgbox "$success_msg" 12 70
        
    else
        # Process single format (original behavior)
        whiptail --title "Transcribing" --infobox "Transcribing audio... This may take a few minutes." 8 60
        
        local whisper_cmd="whisper-cli -m \"$model_path\" -f \"$temp_wav\" -l \"$language\" -oved \"$device\""
        local output_file=""
        
        case "$output_format" in
            "txt")
                whisper_cmd+=" -otxt"
                output_file="${output_base}.txt"
                ;;
            "srt")
                whisper_cmd+=" -osrt"
                output_file="${output_base}.srt"
                ;;
            "vtt")
                whisper_cmd+=" -ovtt"
                output_file="${output_base}.vtt"
                ;;
        esac
        
        if eval "$whisper_cmd"; then
            # Move/copy output file
            if [[ -f "${temp_wav}.${output_format}" ]]; then
                cp "${temp_wav}.${output_format}" "$output_file"
            fi
            
            whiptail --title "Success" --msgbox "Transcription completed!\n\nGenerated file: $output_file" 10 60
        else
            whiptail --title "Error" --msgbox "Error during transcription." 10 50
        fi
    fi
    
    # Clean temporary file
    rm -f "$temp_wav" "${temp_wav}.txt" "${temp_wav}.srt" "${temp_wav}.vtt"
}

# Execute script
main "$@"