# File Name Manipulation in Shell Scripting

This guide presents professional techniques for file name manipulation in shell scripts, with special focus on removing file extensions. Each method includes practical examples with clearly demonstrated inputs and outputs.

## 📋 Table of Contents

- [Overview](#overview)
- [Extension Removal Methods](#extension-removal-methods)
  - [Using Parameter Expansion](#1-using-parameter-expansion-recommended)
  - [Using `cut` Command](#2-using-cut-command)
  - [Using `awk` Command](#3-using-awk-command)
  - [Using `sed` Command](#4-using-sed-command)
  - [Using `basename` Command](#5-using-basename-command)
- [Advanced Manipulation with Parameter Expansion](#advanced-manipulation-with-parameter-expansion)
- [Method Comparison](#method-comparison)
- [Best Practices](#best-practices)
- [References](#references)

## Overview

In shell scripting, we frequently need to extract different parts of a file name - whether it's the base name without extension, just the extension, or manipulating full paths. This document compiles the main available techniques with practical examples.

## Extension Removal Methods

### 1. Using Parameter Expansion (Recommended)

**Advantages:** Native to shell, faster, doesn't depend on external executables

```bash
#!/usr/bin/env bash

# Example 1: Simple file
filename="document.txt"

# Remove the last extension (removes shortest pattern from the end)
name="${filename%.*}"
echo "$name"  # Output: document

# Remove all extensions (removes longest pattern from the end)  
name="${filename%%.*}"
echo "$name"  # Output: document

# Get only the extension (removes longest pattern from the beginning)
extension="${filename##*.}"
echo "$extension"  # Output: txt

# Example 2: File with multiple extensions
filename="file.backup.tar.gz"

echo "${filename%.*}"     # Output: file.backup.tar
echo "${filename%%.*}"    # Output: file  
echo "${filename##*.}"    # Output: gz
```

### 2. Using `cut` Command

```bash
#!/usr/bin/env bash

# Example 1: Simple file
filename="report.pdf"

# Remove extension using dot delimiter (first field)
name=$(echo "$filename" | cut -f1 -d'.')
echo "$name"  # Output: report

# Example 2: File with multiple dots
filename="project.v1.backup.zip"

name=$(echo "$filename" | cut -f1 -d'.')
echo "$name"  # Output: project (only the first field!)
```

**⚠️ Warning:** This method can have problems with files containing multiple dots, as it always returns only the first field.

### 3. Using `awk` Command

```bash
#!/usr/bin/env bash

# Example 1: Extract last extension
filename="data.tar.bz2"

# Get the last extension (last field)
extension=$(echo "$filename" | awk -F. '{print $NF}')
echo "$extension"  # Output: bz2

# Example 2: Extract name without extension
filename="config.backup.conf"

# Get all fields except the last one
name=$(echo "$filename" | awk -F. '{
    if (NF > 1) {
        for(i=1; i<NF; i++) {
            if (i > 1) printf "."
            printf $i
        }
        printf "\n"
    } else {
        print $0
    }
}')
echo "$name"  # Output: config.backup
```

### 4. Using `sed` Command

```bash
#!/usr/bin/env bash

# Example 1: Extract extension
filename="image.png"

# Extract only the extension (everything after the last dot)
extension=$(echo "$filename" | sed 's/.*\.//')
echo "$extension"  # Output: png

# Example 2: Remove specific extension
filename="file.txt"

# Remove 3-character extension (less precise)
name=$(echo "$filename" | sed 's/\(.*\).../\1/')
echo "$name"  # Output: file

# More robust method to remove extension
name=$(echo "$filename" | sed 's/\.[^.]*$//')
echo "$name"  # Output: file
```

### 5. Using `basename` Command

```bash
#!/usr/bin/env bash

# Example 1: Known extension
filename="site.html"

# Remove specific extension
name=$(basename "$filename" .html)
echo "$name"  # Output: site

# Example 2: Dynamic extension
filename="document.docx"

# For dynamic extensions (less common)
name=$(basename "$filename" ".${filename##*.}")
echo "$name"  # Output: document

# Example 3: Get filename from full path
path="/home/user/documents/file.txt"
name=$(basename "$path")
echo "$name"  # Output: file.txt
```

## Advanced Manipulation with Parameter Expansion

Here's a complete example demonstrating the power of native shell parameter expansion:

```bash
#!/usr/bin/env bash

# Let's analyze this complex path
path="this.path/with.dots/in.path.name/filename.tar.gz"

echo "=== COMPLETE PATH ANALYSIS ==="

# 1. Get directory (removes file part)
# Removes the shortest trailing pattern of / followed by anything
dirname="${path%/*}"
echo "Directory: $dirname"
# Output: this.path/with.dots/in.path.name

# 2. Get base name (removes all directories)
# Removes the longest leading pattern of anything followed by /
basename="${path##*/}"
echo "File name: $basename"
# Output: filename.tar.gz

# 3. Remove only the last extension
# Removes the shortest trailing pattern of dot followed by anything
oneextless="${basename%.*}"
echo "Without last extension: $oneextless"
# Output: filename.tar

# 4. Remove all extensions
# Removes the longest trailing pattern of dot followed by anything
noext="${basename%%.*}"
echo "Without any extension: $noext"
# Output: filename

# 5. Get only the main extension
extension="${basename##*.}"
echo "Main extension: $extension"
# Output: gz

echo "================================="
```

**Complete example output:**
```
=== COMPLETE PATH ANALYSIS ===
Directory: this.path/with.dots/in.path.name
File name: filename.tar.gz
Without last extension: filename.tar
Without any extension: filename
Main extension: gz
=================================
```

### 📚 Detailed Operator Explanation

| Operator | Meaning | Example | Result |
|----------|---------|---------|---------|
| `${var%pattern}` | Remove **shortest pattern** from the **end** | `"file.txt" %.*` | `"file"` |
| `${var%%pattern}` | Remove **longest pattern** from the **end** | `"file.tar.gz" %%.*` | `"file"` |
| `${var#pattern}` | Remove **shortest pattern** from the **beginning** | `"path/file" #*/` | `"file"` |
| `${var##pattern}` | Remove **longest pattern** from the **beginning** | `"/path/to/file" ##*/` | `"file"` |

## Method Comparison

| Method | Speed | Portability | Complexity | Edge Cases | Usage Example |
|--------|-------|-------------|------------|------------|---------------|
| **Parameter Expansion** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | Handles multiple dots well | `${name%.*}` |
| `cut` | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ | Problems with multiple dots | `cut -f1 -d'.'` |
| `awk` | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Flexible but complex | `awk -F. '{print $NF}'` |
| `sed` | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | Regex can be complex | `sed 's/.*\.//'` |
| `basename` | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ | Only for known extensions | `basename file.txt .txt` |

## 📝 Practical Use Cases

### Use Case 1: Batch File Processing
```bash
#!/usr/bin/env bash

# Process all .jpg files in a directory
for file in *.jpg; do
    # Remove extension to create base name
    base_name="${file%.jpg}"
    
    # Create thumbnail version
    convert "$file" -resize 50% "${base_name}_thumb.jpg"
    
    echo "Processed: $file -> ${base_name}_thumb.jpg"
    # Input: photo.jpg → Output: photo_thumb.jpg
done
```

### Use Case 2: Backup with Timestamp
```bash
#!/usr/bin/env bash

# Configuration file backup
config_file="application.conf"
timestamp=$(date +%Y%m%d_%H%M%S)

# Remove extension and add timestamp
backup_name="${config_file%.conf}_backup_${timestamp}.conf"

cp "$config_file" "$backup_name"
echo "Backup created: $backup_name"
# Input: application.conf → Output: application_backup_20231201_143022.conf
```

### Use Case 3: Download Organization
```bash
#!/usr/bin/env bash

# Classify file by extension
filename="tax_document.pdf"

# Extract extension
extension="${filename##*.}"

# Move to corresponding directory
mkdir -p "$extension"
mv "$filename" "$extension/"
echo "Moved $filename to $extension/ directory"
```

## Best Practices

1. **Prefer Parameter Expansion:** It's the most efficient and portable solution
2. **Use quotes with variables:** Always use `"$filename"` instead of `$filename`
3. **Consider edge cases:** Files without extensions, multiple dots, dots in directory names
4. **Test your scripts:** Verify with different file name patterns

```bash
#!/usr/bin/env bash

# Robust function for general use
get_filename_without_extension() {
    local filepath="$1"
    local filename="${filepath##*/}"
    echo "${filename%%.*}"
}

# Test with various cases
get_filename_without_extension "/path/to/file.tar.gz"        # Output: file
get_filename_without_extension "document.txt"                # Output: document  
get_filename_without_extension "config.backup.conf"          # Output: config
get_filename_without_extension "file_without_extension"      # Output: file_without_extension
```

## References

- [Stack Overflow: Remove File Extension](https://stackoverflow.com/questions/12152626/how-can-i-remove-the-extension-of-a-filename-in-a-shell-script)
- [DelftStack: Remove File Extension Using Shell](https://www.delftstack.com/howto/linux/remove-file-extension-using-shell/)
- [Bash Parameter Expansion Documentation](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)

---

**💡 Professional Tip:** For maximum portability and performance, **Parameter Expansion** is recommended whenever possible, as it's a shell built-in functionality and doesn't depend on external executables.