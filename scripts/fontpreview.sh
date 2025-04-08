#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
A bash script for interactive font previews using ImageMagick and fzf with Sixel support.
Displays customizable text samples with adjustable size, colors, and font parameters.
Supports both GUI selection via fzf and direct output to image files.
Lightweight (1.0) and works in terminals with/without Sixel graphics capability.
DOCUMENTATION

clear

SCRIPT="${0##*/}"
TMPDIR="${TMPDIR:-/tmp}"
FONTPREVIEWTEMPDIR="${TMPDIR}/${SCRIPT%.*}"
TEMP_FILE="$FONTPREVIEWTEMPDIR/temp_prev.jpg"

[[ -d "${FONTPREVIEWTEMPDIR}" ]] && rm -rf "${FONTPREVIEWTEMPDIR}"
[[ ! -d "${FONTPREVIEWTEMPDIR}" ]] && mkdir -p "${FONTPREVIEWTEMPDIR}"

cleanup() { [[ -d "${FONTPREVIEWTEMPDIR}" ]] && rm -rf "${FONTPREVIEWTEMPDIR}"; }
trap cleanup INT EXIT

VERSION=1.0
FONT_SIZE=24
SIZE=1000x700
BG_COLOR="#ffffff"
FG_COLOR="#000000"
PREVIEW_TEXT=$(
	cat <<-EOF
	{}

	ABCDEFGHIJKLMNOPQRSTUVWXYZ

	abcdefghijklmnopqrstuvwxyz

	1234567890

	'$\!/\%|&*@+=#?()[]'

	A white sheep peacefully 
	grazes on the green pasture.
	EOF
)

# Check if fzf and ImageMagick are installed
if ! command -v fzf magick &> /dev/null; then
    echo "❌ Error: This script requires 'fzf' and 'ImageMagick' to be installed."
    exit 1
fi

# IS TERMINAL SIXEL CAPABLE?
IFS=";?c" read -ra REPLY -s -t 1 -d "c" -p $'\e[c' >&2
for code in "${REPLY[@]}"; do
	if [[ $code == "4" ]]; then
		hassixel=yup
		break
	fi
done

# YAFT is vt102 compatible, cannot respond to vt220 escape sequence.
if [[ "$TERM" == yaft* ]]; then hassixel=yeah; fi

if [[ -z "$hassixel" && -z "$LSIX_FORCE_SIXEL_SUPPORT" ]]; then
	cat <<-EOF >&2
	Error: Your terminal does not report having sixel graphics support.
			Falling back to viu for image display.

	Please use a sixel capable terminal, such as alacritty-sixel-git,
	or contour, or wezterm, or xterm -ti vt340.

	You may test your terminal by viewing a single image, like so:

		magick foo.jpg -geometry 800x480  sixel:-
	EOF
	command -v feh >/dev/null && MODE='jpg:- | feh -'
	! command -v feh >/dev/null && MODE="$TEMP_FILE | xdg-open $TEMP_FILE"
else
	MODE='sixel:-'
fi

show_help() {
printf "%s" "\
usage: $SCRIPT [-h] [--size \"px\"] [--font-size \"FONT_SIZE\"] [--bg-color \"BG_COLOR\"] 
                      [--fg-color \"FG_COLOR\"] [--preview-text \"PREVIEW_TEXT\"] [-i font.otf] 
                      [-o preview.png] [--version]
 
┌─┐┌─┐┌┐┌┌┬┐┌─┐┬─┐┌─┐┬  ┬┬┌─┐┬ ┬
├┤ │ ││││ │ ├─┘├┬┘├┤ └┐┌┘│├┤ │││
└  └─┘┘└┘ ┴ ┴  ┴└─└─┘ └┘ ┴└─┘└┴┘
Very customizable and minimal font previewer written in bash
 
optional arguments:
   -h,  --help            show this help message and exit
   -i,  --input           filename of the input font (.otf, .ttf, .woff are supported)
   -o,  --output          filename of the output preview image (input.png if not set)
   -s,  --size            size of the font preview window
   -fs, --font-size       font size
   -bg, --bg-color        background color of the font preview window
   -fg, --fg-color        foreground color of the font preview window
   -t,  --text            preview text that should be displayed in the font preview window
   -v,  --version         show the version of fontpreview you are using
"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--size)
			shift
            SIZE="$1"
            ;;
        -h|--help)
            show_help
            exit
            ;;
        -v|--version)
            echo "$VERSION"
            exit
            ;;
        -i|--input)
			shift
            input_font="$1"
            ;;
        -o|--output)
			shift
            output_file="$1"
            ;;
        -fs|--font-size)
			shift
            FONT_SIZE="$1"
            ;;
        -bg|--bg-color)
			shift
            BG_COLOR="$1"
            ;;
        -fg|--fg-color)
			shift
            FG_COLOR="$1"
            ;;
        -t|--text)
			shift
            PREVIEW_TEXT="$1"
            ;;
        --)
            shift
            break
            ;;
		*)
            shift
            break
            ;;
    esac
    shift
done

# If an input file was specified, use only that
if [[ -f "$input_font" ]]; then
    font_list="$input_font"
else
    # Generate font list only if no input file was specified
    font_list=$(magick -list font | grep "Font:" | awk '{print $2}' | sort -u)
fi

read -ra cmd <<< "$MODE"

if [[ -n "$output_file" ]]; then
	[[ ! -f "$font_list" ]] && echo "Use -i to specify the font file and -o to extract the image" && exit 1
	magick -size "$SIZE" -background "$BG_COLOR" -fill "$FG_COLOR" -font "$font_list" \
		-pointsize "$FONT_SIZE" label:"$PREVIEW_TEXT" -geometry "$SIZE" "$output_file"
	exit 0
elif [[ -z "$output_file" ]]; then
	# Use fzf for interactive selection with Sixel preview
	selected_font=$(echo "$font_list" | fzf \
		--prompt="🔍 Select a font: " \
		--preview="magick -size \"$SIZE\" -background \"$BG_COLOR\" -fill \"$FG_COLOR\" -font '{}' \
		-pointsize \"$FONT_SIZE\" label:\"$PREVIEW_TEXT\" -geometry \"$SIZE\" ${cmd[*]}" \
		--preview-window="right:80%:border-left" \
		--height=80%)
	# If a font was selected, show confirmation
	if [[ -n "$selected_font" ]]; then
		echo "✅ Selected font: $selected_font"
	else
		echo "🚫 No font selected."
	fi
fi