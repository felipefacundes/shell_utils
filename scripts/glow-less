#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

# glow markdown reader with pagination like less

if [ $# -ne 1 ]; then
    echo "Usage: $0 <file.md>"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: file '$1' not found"
    exit 1
fi

if ! command -v glow &> /dev/null; then
    echo "Error: 'glow' is not installed. Please install it first."
    exit 1
fi

glow -p --style dark "$1"