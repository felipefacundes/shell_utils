#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This is a script that generates spritesheet using imagemagick.
DOCUMENTATION

# Define a signal handler to capture SIGINT (Ctrl+C)
trap 'kill $(jobs -p)' SIGTERM #SIGINT #SIGHUP #SIGQUIT #SIGABRT #SIGKILL #SIGALRM

tile=${tile:-2}
format=${format:-png}

doc() {
    less -FX "$0" | head -n6 | tail -n1
}

help() {
    cat <<EOF #| less -i -R

    $(doc)

    Usage: ${0##*/} [args]

    Options:
      -s, -size    Define the size of the sprites (e.g., 512x512)
      -t, -tile    Define the number of tiles per row in the spritesheet (default: 2)
      -f, -format  Define the format of the spritesheet (default: png)

    Example:
      ${0##*/} -s 512x512 -t 4 -f png

    Note: Make sure the images are in PNG or JPG format.
EOF
    exit 0
}

fail() {
    [[ -z "$1" ]] && help
}

analyze_images() {
    for image in **/*.[PpJj][NnPp][Gg]; do
        # Check if the file is a regular file and if it is an image file
        if [ ! -f "$image" ] && ! file -b --mime-type "$image" | grep -q "^image/"; 
            then
            echo 'There are no images in the directory or subdirectories. Nothing to be done!'
            exit 1
        fi
    done
}

spritesheet_gen() {
    for dir in *; do
        if [ -d "$dir" ]; then
            montage "$dir"/*.png -background none -tile x"${tile}" -geometry "${size}"+0+0 "$dir"."$format"
        fi
    done
}

if [[ -z "$1" ]]; then
    help
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|-size)
            size="$2"
            shift 2
            fail "$size"
            if ! [[ "$size" =~ ^[0-9]+x[0-9]+$ ]]; then
                echo 'Invalid dimension. Usage example: 512x512.'
                exit 1
            fi
            continue
            ;;
        -t|-tile)
            tile="$2"
            shift 2
            fail "$tile"
            if ! [[ "$tile" =~ ^[0-9]+$ ]]; then
                echo 'Only numbers are allowed'
                exit 1
            fi
            continue
            ;;
        -f|-format)
            format="$2"
            shift 2
            fail "$format"
            if [[ "$format" != [pj][np][g] ]]; then
                echo 'Invalid format. Use png or jpg'
                exit 1
            fi
            continue
            ;;
        *)
            help
            ;;
    esac
done

if [[ -z "$size" ]]; then
    echo "Dimensions not defined, example: ${0##*/} -s 512x512"
    exit 1
fi

analyze_images
spritesheet_gen

# Wait for all child processes to finish
wait