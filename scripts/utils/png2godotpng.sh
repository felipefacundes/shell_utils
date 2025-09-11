#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Optimize PNGs for Godot Engine using AVIF as intermediate step
DOCUMENTATION

shopt -s globstar

readonly BACKUP_DIR="png_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

processed=0
error=false
errors=0

for file in **/*.png; do
    [[ -f "$file" ]] || continue
    
	error=false  # Reset error status for each file
    echo "Processing: $file"
    
    # Secure backup with directory structure preserved
    backup_path="$BACKUP_DIR/$(dirname "$file")"
    [[ ! -d "$backup_path" ]] && mkdir -p "$backup_path"
    cp -f "$file" "${backup_path}/"
    
    # Temporary AVIF filename
    avif_file="${file%.*}.avif"
    
	# Create a temporary file
	temp_file="${file%.*}.tmp.png"

    # Step 1: Convert PNG to AVIF (high quality lossless compression)
    if magick "$file" "$avif_file"; then
        
        echo -e "\n✅ AVIF conversion successful\n"
		[[ -f "$file" ]] && rm -f "$file"
        
	else
		echo "❌ PNG → AVIF conversion failed: $file"
        ((errors++))
		error=true
	fi
        
	# Step 2: Convert AVIF back to PNG with optimizations
    if ! "$error" && magick "$avif_file" \
		-strip \
		-colors 1000 \
		-define png:compression-level=9 \
		-define png:compression-filter=5 \
		-define png:compression-strategy=4 \
		-define png:exclude-chunk=all \
		"$temp_file"; then
            
		echo -e "✅ AVIF → PNG conversion successful\n"

	else
		echo "❌ AVIF → PNG conversion failed: $file"
		((errors++))
		error=true
	fi

	# Step 3: Final optimization with optipng
	if ! "$error" && optipng -o7 -nc -out "$file" "$temp_file"; then
		echo -e "✅ $file successfully optimized via AVIF\n"
		((processed++))
	else
		echo "❌ optipng failed: $file"
		((errors++))
		error=true
	fi
	
	# Cleanup temporary files
	[[ -f "$temp_file" ]] && rm -f "$temp_file"
            
	# Remove temporary AVIF file
	[[ -f "$avif_file" ]] && rm -f "$avif_file"

	# Restore from backup
	[[ "$error" == true ]] && cp -f "$backup_path/$file" "$file"
        
done

echo "Completed! Processed: $processed, Errors: $errors"
echo "Backups in: $BACKUP_DIR"