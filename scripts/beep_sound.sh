#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script provides functionality to play .ogg sound files using paplay, with built-in bilingual support (English/Portuguese) 
based on the system's LANG setting. The script accepts three main options: --help to show usage instructions, --play to reproduce a 
specified .ogg file with custom volume control, and --default to play a predefined sound located at ~/.shell_utils/sounds/bewitched.ogg. 
It includes error handling for missing files, invalid arguments, and upload failures, while using pactl for sound sample management. 
The script is designed with a modular structure using functions for help display, sound playback, and argument processing, 
making it both user-friendly and maintainable.
DOCUMENTATION

# Associative array for bilingual support
declare -A MESSAGES

if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        [help_header]="Script para reproduzir sons .ogg com paplay"
        [usage]="Uso: ${0##*/} [opcao]"
        [options]="\nOpcoes:\n  -h, --help          Mostra este menu de ajuda.\n  -p, --play <path>   Reproduz o som .ogg especificado.\n  -d, --default       Reproduz o som padrão localizado em ~/.shell_utils/sounds/bewitched.ogg."
        [error_no_beep]="Erro: Caminho para o arquivo .ogg não especificado."
        [error_upload]="Erro: Não foi possível carregar o arquivo"
        [error_default]="Erro: Arquivo de som padrão não encontrado em"
        [error_unknown_option]="Erro: Opção desconhecida:"
        [missing_arg]="Erro: O argumento para --play está faltando."
    )
else
    MESSAGES=(
        [help_header]="Script to play .ogg sounds with paplay"
        [usage]="Usage: ${0##*/} [option]"
        [options]="\nOptions:\n  -h, --help          Shows this help menu.\n  -p, --play <path>   Plays the specified .ogg sound.\n  -d, --default       Plays the default sound located at ~/.shell_utils/sounds/bewitched.ogg."
        [error_no_beep]="Error: Path to the .ogg file not specified."
        [error_upload]="Error: Failed to load the file"
        [error_default]="Error: Default sound file not found at"
        [error_unknown_option]="Error: Unknown option:"
        [missing_arg]="Error: Argument for --play is missing."
    )
fi

# Function: Displays the help menu
show_help() {
    echo "${MESSAGES[help_header]}"
    echo "${MESSAGES[usage]}"
    echo -e "${MESSAGES[options]}"
}

# Function: Plays a .ogg sound using paplay
play_ogg_sound_with_paplay() {
    if [[ -z "$beep" ]]; then
        echo "${MESSAGES[error_no_beep]}"
        echo "${MESSAGES[usage]}"
        return 1
    fi

    if ! pactl upload-sample "$beep" &>/dev/null; then
        echo "${MESSAGES[error_upload]} $beep."
        return 1
    fi

    paplay "$beep" --volume=76767
}

# Function: Plays the default sound
beep_sound() {
    beep="${beep:-${HOME}/.shell_utils/sounds/bewitched.ogg}"
    if [[ ! -f "$beep" ]]; then
        echo "${MESSAGES[error_default]} $beep."
        return 1
    fi

    play_ogg_sound_with_paplay
}

# Check script arguments
if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -p|--play)
            if [[ -n "$2" ]]; then
                beep="$2"
                play_ogg_sound_with_paplay
                shift 2
            else
                echo "${MESSAGES[missing_arg]}"
                exit 1
            fi
            ;;
        -d|--default)
            beep_sound
            shift
            ;;
        *)
            echo "${MESSAGES[error_unknown_option]} $1"
            show_help
            exit 1
            ;;
    esac
done

