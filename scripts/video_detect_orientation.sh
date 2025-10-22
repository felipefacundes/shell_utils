#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

detect_orientation() {
    local file="$1"
    
    # Get video dimensions
    dimensions=$(ffprobe -v error -select_streams v:0 \
              -show_entries stream=width,height -of csv=p=0 "$file")
    
    width=$(echo $dimensions | cut -d',' -f1)
    height=$(echo $dimensions | cut -d',' -f2)
    
    echo "Resolution: ${width}x${height}"
    
    # Determine orientation
    if [ "$width" -gt "$height" ]; then
        echo "Orientation: HORIZONTAL (landscape)"
        return 0
    elif [ "$height" -gt "$width" ]; then
        echo "Orientation: VERTICAL (portrait)"
        return 1
    else
        echo "Orientation: SQUARE"
        return 2
    fi
}

# Usage
detect_orientation "$1"