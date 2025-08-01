#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script generates random PDF files with customizable text content. 
Users can specify the number of PDFs, pages per PDF, and characters per page. 
It creates A4-sized pages with random background colors and text, then combines them into PDFs. 
The script includes options for output directory and help menu, requiring ImageMagick for operation.
DOCUMENTATION

# Help function
show_help() {
    cat <<EOF
This script creates PDF images with random content based on the RANDOM variable.

Usage: ${0##*/} [NUMBER_OF_PDFS] [NUMBER_OF_PAGES] [NUMBER_OF_CHARACTERS] [OPTIONS]

Arguments:
  NUMBER_OF_PDFS       Number of PDFs to generate (default: 1)
  NUMBER_OF_PAGES      Number of pages per PDF (default: 2)
  NUMBER_OF_CHARACTERS Number of characters per page (default: 170)
                       Note: 12000 characters fill an entire page,
                       but generation will be slower.

Options:
  -d, --directory DIR  Destination directory for the PDFs
  -h, --help           Show this help

Examples:
  ${0##*/} 5              # Generates 5 PDFs with 2 pages each (170 characters/page)
  ${0##*/} 7 9            # Generates 7 PDFs with 9 pages each
  ${0##*/} 3 4 500        # Generates 3 PDFs with 4 pages of 500 characters each
  ${0##*/} 2 1 12000      # Generates 2 PDFs with 1 completely filled page (slow)
  ${0##*/} 3 4 -d ~/pdfs  # Generates in specified folder
EOF
    exit 0
}

# Check for help arguments
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
fi

# Process arguments
num_pdfs=1
num_pages=2
num_characters=170
dest_dir="."

if [[ -n "$TERMUX_VERSION" ]]; then
	font="Roboto-Condensed" #Or DejaVu-Sans
else
	font="Liberation-Sans"
fi

# Process positional arguments
if [[ "$1" =~ ^[0-9]+$ ]]; then
    num_pdfs=$1
    shift
    
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        num_pages=$1
        shift
        
        if [[ "$1" =~ ^[0-9]+$ ]]; then
            num_characters=$1
            shift
        fi
    fi
fi

# Process options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--directory)
            if [[ -d "$2" ]]; then
                dest_dir="$2"
                shift 2
            else
                echo "Error: Destination directory '$2' does not exist." >&2
                exit 1
            fi
            ;;
        *)
            echo "Error: Invalid argument '$1'" >&2
            exit 1
            ;;
    esac
done

# Check if required programs are installed
for cmd in magick awk tr; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed. Please install ImageMagick and awk." >&2
        exit 1
    fi
done

# Function to generate random hex color
random_hex_color() {
    printf "%06x" $((RANDOM % 0xFFFFFF))
}

# Function to generate random character
random_char() {
    # Printable ASCII characters (32-126)
    printf "\\$(printf '%03o' $((RANDOM % 95 + 32)))"
}

# Function to generate an A4 page with random text
generate_page() {
    local page_num=$1
    local output_file=$2
    
    # Generate random colors
    local bg_color=$(random_hex_color)
    local text_color=$(random_hex_color)
    
    # Create temporary file with random text
    local temp_txt=$(mktemp)
    local char_count=0
    local line=""
    
    # Generate text with proper line breaks
    while [[ $char_count -lt "$num_characters" ]]; do
        # Add random character
        char=$(random_char)
        line+="$char"
        ((char_count++))
        
        # Break line every ~170 characters (simulating A4 width)
        if [[ ${#line} -ge 170 ]]; then
            echo "$line" >> "$temp_txt"
            line=""
            # Add extra line break occasionally
            if [[ $((RANDOM % 5)) -eq 0 ]]; then
                echo "" >> "$temp_txt"
            fi
        fi
    done
    
    # Add last line if not empty
    if [[ -n "$line" ]]; then
        echo "$line" >> "$temp_txt"
    fi
    
    # Create A4 image (210x297mm at 300dpi ≈ 2480x3508 pixels)
    magick -size 2480x3508 xc:"#$bg_color" \
            -pointsize 24 \
            -fill "#$text_color" \
            -font "$font" \
            -annotate +100+100 "@$temp_txt" \
            -density 300 \
            -units PixelsPerInch \
            -page A4 \
            "$output_file"
    
    rm "$temp_txt"
}

# Generate PDFs
for ((pdf_num=1; pdf_num<=num_pdfs; pdf_num++)); do
    echo "Generating PDF $pdf_num of $num_pdfs with $num_pages pages..."
    
    # List of pages for this PDF
    page_files=()
    
    for ((page=1; page<=num_pages; page++)); do
        page_file="${dest_dir}/page_${pdf_num}_${page}.png"
        generate_page "$page" "$page_file"
        page_files+=("$page_file")
    done
    
    # Combine pages into PDF
    output_pdf="${dest_dir}/random_pdf_${pdf_num}.pdf"
    magick "${page_files[@]}" "$output_pdf"
    
    # Remove temporary page files
    rm "${page_files[@]}"
    
    echo "PDF generated: $output_pdf"
done

echo "Completed! Generated $num_pdfs PDF(s) in $dest_dir"