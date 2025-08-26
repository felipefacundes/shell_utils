#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

# =============================================================================
# PDF to Vector Converter Script
# =============================================================================
# Script: pdf_to_vector.sh
# Description: Converts PDFs with selectable fonts to vector PDFs using Ghostscript
# Author: Felipe Facundes
# Version: 1.0
# Date: 2025-08-25
# =============================================================================

# Settings
VERSION="1.0"
SCRIPT_NAME=$(basename "$0")
SUFFIX="-vector.pdf"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Function to display error messages
error_exit() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Function to display information messages
log_info() {
    echo "[INFO] $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# =============================================================================
# HELP FUNCTION
# =============================================================================

show_help() {
    cat << EOF
${SCRIPT_NAME} - PDF to Vector Converter

DESCRIPTION:
    Converts PDF files with selectable fonts to vector PDFs where
    all fonts are converted to paths using Ghostscript.

USAGE:
    ${SCRIPT_NAME} [OPTIONS] <file.pdf>

OPTIONS:
    -h, --help      Display this help message
    -v, --version   Display script version
    -o, --output    Specify output filename

EXAMPLES:
    ${SCRIPT_NAME} document.pdf
        Creates 'document-vector.pdf'

    ${SCRIPT_NAME} -o result.pdf document.pdf
        Creates 'result.pdf'

    ${SCRIPT_NAME} --help
        Display this help

REQUIREMENTS:
    Ghostscript must be installed on the system.

NOTES:
    - The script automatically checks if the input file is a valid PDF
    - Output files receive the '-vector.pdf' suffix by default
    - Conversion preserves vector quality but removes text selection

EOF
}

# =============================================================================
# VERSION FUNCTION
# =============================================================================

show_version() {
    echo "${SCRIPT_NAME} version ${VERSION}"
}

# =============================================================================
# INITIAL CHECKS
# =============================================================================

# Check if Ghostscript is installed
if ! command_exists gs; then
    error_exit "Ghostscript is not installed. Install with: sudo pacman -S ghostscript"
fi

# =============================================================================
# ARGUMENT PROCESSING
# =============================================================================

# Variables for arguments
INPUT_FILE=""
OUTPUT_FILE=""
CUSTOM_OUTPUT=false

# Process arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            show_version
            exit 0
            ;;
        -o|--output)
            CUSTOM_OUTPUT=true
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -*)
            error_exit "Unknown option: $1"
            ;;
        *)
            if [[ -z "$INPUT_FILE" ]]; then
                INPUT_FILE="$1"
                shift
            else
                error_exit "Multiple input files specified"
            fi
            ;;
    esac
done

# =============================================================================
# VALIDATIONS
# =============================================================================

# Check if input file was specified
if [[ -z "$INPUT_FILE" ]]; then
    error_exit "No input file specified. Use --help for help."
fi

# Check if input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    error_exit "File not found: $INPUT_FILE"
fi

# Check if file is a PDF
if ! file "$INPUT_FILE" | grep -q "PDF document"; then
    error_exit "The file '$INPUT_FILE' does not appear to be a valid PDF"
fi

# Generate output filename if not specified
if [[ "$CUSTOM_OUTPUT" == false ]]; then
    BASE_NAME="${INPUT_FILE%.pdf}"
    OUTPUT_FILE="${BASE_NAME}${SUFFIX}"
fi

# Check if output file already exists
if [[ -f "$OUTPUT_FILE" ]]; then
    read -p "Output file '$OUTPUT_FILE' already exists. Overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Operation cancelled by user"
        exit 0
    fi
fi

# =============================================================================
# PDF CONVERSION
# =============================================================================

log_info "Starting conversion of '$INPUT_FILE' to '$OUTPUT_FILE'"

# Ghostscript command to convert fonts to paths
gs -dNOPAUSE -dBATCH -dSAFER \
   -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/prepress \
   -dEmbedAllFonts=false \
   -dSubsetFonts=false \
   -dNoOutputFonts \
   -dAutoRotatePages=/None \
   -dColorImageDownsampleType=/Bicubic \
   -dColorImageResolution=300 \
   -dGrayImageDownsampleType=/Bicubic \
   -dGrayImageResolution=300 \
   -dMonoImageDownsampleType=/Bicubic \
   -dMonoImageResolution=1200 \
   -sOutputFile="$OUTPUT_FILE" \
   -c "<</NeverEmbed [ ]>> setdistillerparams" \
   -c "<</ColorConversionStrategy /LeaveColorUnchanged>> setdistillerparams" \
   -c "<</CannotEmbedFontPolicy /Warning>> setdistillerparams" \
   -f "$INPUT_FILE"

# Check if conversion was successful
if [[ $? -eq 0 ]] && [[ -f "$OUTPUT_FILE" ]]; then
    log_info "Conversion completed successfully!"
    log_info "File created: $OUTPUT_FILE"
    
    # Display information about the generated file
    FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    log_info "File size: $FILE_SIZE"
else
    error_exit "PDF conversion failed. Check permissions and input file."
fi

exit 0