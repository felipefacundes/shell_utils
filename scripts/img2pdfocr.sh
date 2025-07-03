#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Converts images to PDFs with selectable text using OCR.
Supports multiple languages via Tesseract.
Preserves image quality while adding text layer.
Requires Tesseract, ImageMagick, and qpdf.
Handles multiple files in one execution.
DOCUMENTATION

# Default language (English)
LANG="eng"

# Display help
show_help() {
    cat <<EOF
Usage: ${0##*/} [OPTIONS] file1 [file2 ...]

Convert images to PDF with selectable text using OCR.

Options:
  -l LANGUAGE  Set OCR language (default: eng)
             Examples: eng (English), spa (Spanish), fra (French), por (Portuguese)

Examples:
  ${0##*/} -l eng document.jpg          # Convert to English
  ${0##*/} -l por *.png                 # Convert multiple files to Portuguese
  ${0##*/} -l spa photo1.jpg photo2.jpg # Convert to Spanish

Supported languages (depends on Tesseract installation):
  eng - English
  por - Portuguese
  spa - Spanish
  fra - French
  deu - German
  ita - Italian
  ... (and others, run 'tesseract --list-langs' to see all)

Requirements:
  Tesseract OCR, ImageMagick and qpdf must be installed
EOF
    exit 0
}

# Process arguments
while getopts ":l:h" opt; do
    case $opt in
        l) LANG="$OPTARG" ;;
        h) show_help ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
        :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
    esac
done
shift $((OPTIND-1))

# Check if any files were provided
if [ $# -eq 0 ]; then
    echo "Error: No files specified." >&2
    show_help
    exit 1
fi

# Check required programs
for cmd in tesseract magick qpdf; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed." >&2
        case $cmd in
            tesseract)
                echo "Install Tesseract OCR:"
                echo "  Ubuntu/Debian: sudo apt install tesseract-ocr tesseract-ocr-por"
                echo "  Fedora: sudo dnf install tesseract tesseract-langpack-por"
                echo "  macOS: brew install tesseract tesseract-lang"
                ;;
            magick)
                echo "Install ImageMagick:"
                echo "  Ubuntu/Debian: sudo apt install imagemagick"
                echo "  Fedora: sudo dnf install ImageMagick"
                echo "  macOS: brew install imagemagick"
                ;;
            qpdf)
                echo "Install qpdf:"
                echo "  Ubuntu/Debian: sudo apt install qpdf"
                echo "  Fedora: sudo dnf install qpdf"
                echo "  macOS: brew install qpdf"
                ;;
        esac
        exit 1
    fi
done

# Check if language is installed
if ! tesseract --list-langs 2>/dev/null | grep -qw "$LANG"; then
    echo "Error: Language '$LANG' is not installed in Tesseract." >&2
    echo "Available languages:" >&2
    tesseract --list-langs 2>/dev/null | sed 's/^/  /' >&2
    echo "Install with:" >&2
    case $LANG in
        por) echo "  Ubuntu/Debian: sudo apt install tesseract-ocr-por" >&2
             echo "  Fedora: sudo dnf install tesseract-langpack-por" >&2
             echo "  macOS: brew install tesseract-lang" >&2 ;;
        eng) echo "  Ubuntu/Debian: sudo apt install tesseract-ocr-eng" >&2
             echo "  Fedora: sudo dnf install tesseract-langpack-eng" >&2 ;;
        spa) echo "  Ubuntu/Debian: sudo apt install tesseract-ocr-spa" >&2
             echo "  Fedora: sudo dnf install tesseract-langpack-spa" >&2 ;;
        fra) echo "  Ubuntu/Debian: sudo apt install tesseract-ocr-fra" >&2
             echo "  Fedora: sudo dnf install tesseract-langpack-fra" >&2 ;;
        *)   echo "  Consult Tesseract documentation for language package '$LANG'" >&2 ;;
    esac
    exit 1
fi

# Process each input file
for input_file in "$@"; do
    # Check if file exists
    if [ ! -f "$input_file" ]; then
        echo "Warning: File '$input_file' not found. Skipping..." >&2
        continue
    fi

    # Check if it's a valid image
    if ! identify "$input_file" &> /dev/null; then
        echo "Warning: '$input_file' is not a valid image or unsupported format. Skipping..." >&2
        continue
    fi

    # Extract filename without extension
    filename=$(basename -- "$input_file")
    filename="${filename%.*}"

    echo "Processing: $input_file (Language: $LANG)"

    # 1. Create PDF from image (to maintain quality)
    img_pdf="${filename}_img.pdf"
    magick "$input_file" "$img_pdf"

    # 2. Create PDF with OCR text (invisible, overlaid on image)
    txt_pdf="${filename}_txt.pdf"
    tesseract "$input_file" - -l "$LANG" --psm 6 pdf > "$txt_pdf" 2>/dev/null

    # 3. Combine both PDFs (image as background, invisible text on top)
    final_pdf="${filename}.pdf"
    qpdf "$img_pdf" --overlay "$txt_pdf" -- "$final_pdf"

    # Remove temporary files
    rm -f "$img_pdf" "$txt_pdf"

    echo "File created: $final_pdf"
done

echo "Conversion complete!"