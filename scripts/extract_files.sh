#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script is designed to manage the extraction of various compressed file formats through a command-line interface. 
Its primary purpose is to provide users with options to extract specific files, perform recursive searches for compressed files, 
and manage file removal, all while ensuring ease of use and flexibility.

Strengths:
1. Multiple Extraction Options: Supports various commands for extracting files, including specific file extraction, recursive extraction, and extraction to designated folders.
2. File Format Support: Handles a wide range of compressed file formats such as TAR, ZIP, RAR, and more.
3. User  Guidance: Provides a help function that outlines usage and options, making it user-friendly.
4. Signal Handling: Implements a signal handler to manage background jobs effectively, enhancing script reliability.
5. File Management: Includes options to check for existing compressed files and remove them if needed.

Capabilities:
- Extracts files from specified compressed formats.
- Performs recursive searches to extract all compressed files in a directory.
- Creates folders for extracted files when necessary.
- Removes specified compressed files from the current directory.
DOCUMENTATION

# Define a signal handler to capture SIGINT (Ctrl+C)
trap 'kill $(jobs -p)' SIGTERM #SIGHUP #SIGINT #SIGQUIT #SIGABRT #SIGKILL #SIGALRM #SIGTERM

: <<'DOCUMENTATION'
Extract files
DOCUMENTATION

shopt -s globstar

doc() {
    less -FX "$0" | head -n9 | tail -n1
}

help() {
    cat <<EOF

$(doc)

Usage: ${0##*/} [options]

Options:
    -f <compressed file>    
                            Extract a specific compressed file.
    -r                      
                            Perform a recursive search for compressed files and extract them.
    -rwf                    
                            Perform a recursive search for compressed files using 'find' and extract them. 
                            Unlike the previous command (-r), the files are extracted to the main directory 
                            where the command is being executed and not to the subdirectory where each file is located.
                            This feature utilizes the 'find' command.
    -e2f                    
                            Check existence of compressed files, create folders, and extract files to folders.
    -rm                     
                            Remove compressed files in the current directory.

Examples:
    ${0##*/} -f example.tar.gz
    ${0##*/} -r
    ${0##*/} -rwf
    ${0##*/} -e2f
    ${0##*/} -rm
EOF
}


extract_file() {
    local file="${1}"
    if [ -z "${file}" ] || [ ! -f "${file}" ]; then
        echo -e "Usage:\n\n${0##*/} -f <compressed file>"
    
    elif [ -f "${file}" ]; then
        case "${file}" in
            *.[Tt][Aa][Rr].[Bb][Zz]2)       tar xvjf "${file}"    ;;
            *.[Tt][Aa][Rr].[Gg][Zz])        tar xvzf "${file}"    ;;
            *.[Tt][Aa][Rr].[Xx][Zz])        tar xvJf "${file}"    ;;
            *.[Tt][Aa][Rr].[Zz][Ss][Tt])    tar xvf "${file}"     ;;
            *.[Ll][Zz][Mm][Aa])             unlzma "${file}"      ;;
            *.[Bb][Zz]2)                    bunzip2 "${file}"     ;;
            #*.[Rr][Aa][Rr])                 unrar x -ad "${file}" ;;
            *.[Rr][Aa][Rr])                 7z x "${file}"        ;;
            *.[Gg][Zz])                     gunzip "${file}"      ;;
            *.[Tt][Aa][Rr])                 tar xvf "${file}"     ;;
            *.[Tt][Bb][Zz]2)                tar xvjf "${file}"    ;;
            *.[Tt][Gg][Zz])                 tar xvzf "${file}"    ;;
            *.[Zz][Ii][Pp])                 unzip "${file}"       ;;
            *.[Zz][Ss][Tt])                 unzstd "${file}"      ;;
            #*.[Zz])                         uncompress "${file}"  ;;
            *.[Zz])                         7z x "${file}"        ;;
            *.7[Zz])                        7z x "${file}"        ;;
            *.[Ii][Ss][Oo])                 7z x "${file}"        ;;
            *.[Xx][Zz])                     unxz "${file}"        ;;
            #*.[Ee][Xx][Ee])                 cabextract "${file}"  ;;
            *.[Ee][Xx][Ee])                 7z x "${file}"        ;;
        esac
    fi
}

only_extract() {
    if [ -f "$file" ]; then
        case "$file" in
            *.[Tt][Aa][Rr].[Bb][Zz]2)       tar xvjf "$file"  ;;
            *.[Tt][Aa][Rr].[Gg][Zz])        tar xvzf "$file"  ;;
            *.[Tt][Aa][Rr].[Xx][Zz])        tar xvJf "$file"  ;;
            *.[Tt][Aa][Rr].[Zz][Ss][Tt])    tar --zstd -xvf "$file" ;;
            *.[Ll][Zz][Mm][Aa])             tar --lzma -xvf "$file" ;;
            *.[Bb][Zz]2)                    tar xvjf "$file" ;;
            #*.[Rr][Aa][Rr])                 unrar x "$file" "$folder_name" ;;
            *.[Rr][Aa][Rr])                 7z x "$file" ;;
            *.[Gg][Zz])                     gunzip "$file" ;;
            *.[Tt][Aa][Rr])                 tar xvf "$file" ;;
            *.[Tt][Bb][Zz]2)                tar xvjf "$file" ;;
            *.[Tt][Gg][Zz])                 tar xvzf "$file" ;;
            *.[Zz][Ii][Pp])                 unzip "$file" ;;
            *.[Zz][Ss][Tt])                 tar --zstd -xvf "$file" ;;
            *.[Zz])                         7z x "$file" ;;
            *.7[Zz])                        7z x "$file" ;;
            *.[Ii][Ss][Oo])                 7z x "$file" ;;
            *.[Xx][Zz])                     tar xvJf "$file" ;;
            *.[Ee][Xx][Ee])                 7z x "$file" ;;
            *)                              echo "Unsupported format: $file" ;;
        esac
    fi
}

extract_to_folder() {
    if [ -f "$file" ]; then
        folder_name="${file%.*}"  # Remove file extension
        mkdir -p "$folder_name"   # Create the destination folder
        case "$file" in
            *.[Tt][Aa][Rr].[Bb][Zz]2)       tar xvjf "$file" -C "$folder_name" ;;
            *.[Tt][Aa][Rr].[Gg][Zz])        tar xvzf "$file" -C "$folder_name" ;;
            *.[Tt][Aa][Rr].[Xx][Zz])        tar xvJf "$file" -C "$folder_name" ;;
            *.[Tt][Aa][Rr].[Zz][Ss][Tt])    tar --zstd -xvf "$file" -C "$folder_name" ;;
            *.[Ll][Zz][Mm][Aa])             tar --lzma -xvf "$file" -C "$folder_name" ;;
            *.[Bb][Zz]2)                    tar xvjf "$file" -C "$folder_name" ;;
            #*.[Rr][Aa][Rr])                 unrar x "$file" "$folder_name" ;;
            *.[Rr][Aa][Rr])                 7z x "$file" -o"$folder_name" ;;
            *.[Gg][Zz])                     gunzip -c "$file" > "$folder_name" ;;
            *.[Tt][Aa][Rr])                 tar xvf "$file" -C "$folder_name" ;;
            *.[Tt][Bb][Zz]2)                tar xvjf "$file" -C "$folder_name" ;;
            *.[Tt][Gg][Zz])                 tar xvzf "$file" -C "$folder_name" ;;
            *.[Zz][Ii][Pp])                 unzip "$file" -d "$folder_name" ;;
            *.[Zz][Ss][Tt])                 tar --zstd -xvf "$file" -C "$folder_name" ;;
            *.[Zz])                         7z x "$file" -o"$folder_name" ;;
            *.7[Zz])                        7z x "$file" -o"$folder_name" ;;
            *.[Ii][Ss][Oo])                 7z x "$file" -o"$folder_name" ;;
            *.[Xx][Zz])                     tar xvJf "$file" -C "$folder_name" ;;
            *.[Ee][Xx][Ee])                 7z x "$file" -o"$folder_name" ;;
            *)                              echo "Unsupported format: $file" ;;
        esac
    fi
}

# Function to check the existence of compressed files in the folder
loop_check_files() {
    for file in **/*.[Tt][Aa][Rr].[Bb][Zz]2 \
        **/*.[Tt][Aa][Rr].[Gg][Zz] \
        **/*.[Tt][Aa][Rr].[Xx][Zz] \
        **/*.[Tt][Aa][Rr].[Zz][Ss][Tt] \
        **/*.[Ll][Zz][Mm][Aa] \
        **/*.[Bb][Zz]2 \
        **/*.[Rr][Aa][Rr] \
        **/*.[Gg][Zz] \
        **/*.[Tt][Aa][Rr] \
        **/*.[Tt][Bb][Zz]2 \
        **/*.[Tt][Gg][Zz] \
        **/*.[Zz][Ii][Pp] \
        **/*.[Zz][Ss][Tt] \
        **/*.[Zz] \
        **/*.7[Zz] \
        **/*.[Ii][Ss][Oo] \
        **/*.[Xx][Zz] \
        **/*.[Ee][Xx][Ee]; do
        "$1"        
    done
    return 0
}

check_if_exists() {
    # Check if there are compressed files in the folder
    if [[ -f "$file" ]]; then
        export file_exists=true
    fi
}

if_continue() {
    echo -e "\nContinue: yes | no"
    declare -l option
    read -r option

    if [[ "${option}" = yes ]]; then
        return 0
    else
        exit 1
    fi
}

recursive_extract_with_find() {
    echo 'A recursive search will be made for the existence of compressed files, and extract them.'
    if_continue
    find . -type f \( \
        -name "*.[Tt][Aa][Rr].[Bb][Zz]2" -exec tar xvjf {} \; \
        -o -name "*.[Tt][Aa][Rr].[Gg][Zz]" -exec tar xvzf {} \; \
        -o -name "*.[Tt][Aa][Rr].[Xx][Zz]" -exec tar xvJf {} \; \
        -o -name "*.[Tt][Aa][Rr].[Zz][Ss][Tt]" -exec tar xvf {} \; \
        -o -name "*.[Ll][Zz][Mm][Aa]" -exec unlzma {} \; \
        -o -name "*.[Bb][Zz]2" -exec bunzip2 {} \; \
        -o -name "*.[Rr][Aa][Rr]" -exec unrar x -ad {} \; \
        -o -name "*.[Gg][Zz]" -exec gunzip {} \; \
        -o -name "*.[Tt][Aa][Rr]" -exec tar xvf {} \; \
        -o -name "*.[Tt][Bb][Zz]2" -exec tar xvjf {} \; \
        -o -name "*.[Tt][Gg][Zz]" -exec tar xvzf {} \; \
        -o -name "*.[Zz][Ii][Pp]" -exec unzip {} \; \
        -o -name "*.[Zz][Ss][Tt]" -exec unzstd {} \; \
        -o -name "*.[Zz]" -exec uncompress {} \; \
        -o -name "*.7[Zz]" -exec 7z x {} \; \
        -o -name "*.[Ii][Ss][Oo]" -exec 7z x {} \; \
        -o -name "*.[Xx][Zz]" -exec unxz {} \; \
        -o -name "*.[Ee][Xx][Ee]" -exec cabextract {} \; \
    \)
}

check_existence() {
    loop_check_files check_if_exists
    if [[ "$file_exists" ]]; then
        return 0
    else
        echo "No compressed files found in the folder"
        exit 1
    fi
}

remove_files() {
    rm -f "$file"
}

remove_compressed_files() {
    loop_check_files remove_files
}

recursive_extract() {
    echo 'A recursive search will be made for the existence of compressed files, and extract them.'
    if_continue
    # Loop to extract the compressed files
    loop_check_files only_extract
}

recursive_extract_files_to_folder() {
    if_continue
    # Loop to extract the compressed files
    loop_check_files extract_to_folder
}

if [[ -z $1 ]] || [[ $1 == "-h" || $1 == "--help" ]]; then
    help
    exit 0
fi

case $1 in
    -f)
        extract_file "$2"
        shift 2
        ;;
    -r)
        check_existence
        recursive_extract
        shift
        ;;
    -rwf)
        recursive_extract_with_find
        shift
        ;;
    -e2f)
        check_existence
        recursive_extract_files_to_folder
        shift
        ;;
    -rm)
        remove_compressed_files
        shift
        ;;
    *)
        help
        ;;
esac

# Wait for all child processes to finish
wait