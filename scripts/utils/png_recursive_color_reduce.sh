#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

# Enable globstar (for ** to work in Bash)
shopt -s globstar

# Process all PNGs recursively
for file in **/*.png; do
    if [[ -f "$file" ]]; then
        echo "Optimizing: $file"
        
        # Create a temporary file
        temp_file="${file%.*}.temp.png"
        
        # Apply optimization with magick
        magick "$file" \
            -strip \
            -define png:compression-level=9 \
            -define png:exclude-chunk=all \
            -colors 1000 \
            "$temp_file"
        
        # Replace original with optimized version (if magick succeeded)
        if [[ -f "$temp_file" ]]; then
            rm "$file"
            mv "$temp_file" "$file"
            optipng -o7 -nc "$file"
            echo "✅ $file successfully optimized."
        else
            echo "❌ Failed to optimize $file."
        fi
    fi
done

echo "Done!"