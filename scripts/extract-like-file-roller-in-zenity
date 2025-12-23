#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Script of compression and extraction ("Similar to file-roller").

This Bash script is designed to facilitate file compression and extraction through a user-friendly graphical interface using Zenity. 
Its primary purpose is to allow users to easily manage compressed files and folders without needing to remember command-line syntax. 

Strengths:
1. User -Friendly Interface: Utilizes Zenity to provide a graphical interface for file operations.
2. Supports Multiple Formats: Can handle various compression and extraction formats, including ZIP, TAR, RAR, and more.
3. Password Protection: Allows users to extract password-protected files.
4. Error Handling: Provides feedback on success or failure of operations, enhancing user experience.
5. Flexible Options: Offers options to compress files or folders and to extract files to specified directories.

Capabilities:
- Extracts files from various compressed formats.
- Compresses files and folders into multiple formats.
- Provides options for user interaction to select files and directories.
- Logs output and displays it in a dedicated window for user reference.
DOCUMENTATION

#set -euo pipefail

if [[ "$1" ]]; then
    # Get the input file directory
    file_dir=$(dirname "$1")

    # Navigates to the input file directory
    cd "$file_dir" || exit
fi

# Function to display the output window
output_window_and_log() {
    local title="$1"
    local command="$2"
    local folder="$3"
    local output=""
    local output_file="${title%.*}.txt"

    eval "$command" 2>&1 | tee >(zenity --text-info --title="$title" --width=500 --height=300 --timeout=99999 --editable >/dev/null) > >(tee "${folder}/${output_file}" >/dev/null)
}

extract_file() {
    local file="$1"
    local folder="$2"
    local password="$3"

    local command=""
    local title="Extraction Output"

    case "$file" in
        *.[Tt][Aa][Rr].[Bb][Zz]2)
            command="tar -xvjf \"$file\" -C \"$folder\" --overwrite"
            ;;
        *.[Tt][Aa][Rr].[Gg][Zz])
            command="tar -xvzf \"$file\" -C \"$folder\" --overwrite"
            ;;
        *.[Tt][Aa][Rr].[Xx][Zz])
            command="tar -xvJf \"$file\" -C \"$folder\" --overwrite"
            ;;
        *.[Tt][Aa][Rr].[Zz][Ss][Tt])
            command="tar -xvf \"$file\" -C \"$folder\" --overwrite"
            ;;
        *.[Tt][Aa][Rr])
            command="tar -xvf \"$file\" -C \"$folder\" --overwrite"
            ;;
        *.[Gg][Zz])
            command="gunzip -c \"$file\" > \"${folder}/$(basename "${file%.*}")\" --force"
            ;;
        *.[Xx][Zz])
            command="unxz -c \"$file\" > \"${folder}/$(basename "${file%.*}")\" --force"
            ;;
        *.[Zz][Ss][Tt])
            command="zstd -d \"$file\" -o \"${folder}/$(basename "${file%.*}")\" --force"
            ;;
        *.[Ll][Zz][Mm][Aa])
            command="unlzma \"$file\" -c > \"${folder}/$(basename "${file%.*}")\" --force"
            ;;
        *.[Bb][Zz]2)
            command="bunzip2 \"$file\" -c > \"${folder}/$(basename "${file%.*}")\" --force"
            ;;
        *.[Rr][Aa][Rr])
            if [[ -n "$password" ]]; then
                command="unrar x -ad -p\"$password\" \"$file\" \"$folder\""
            else
                command="unrar x -ad \"$file\" \"$folder\""
            fi
            ;;
        *.[Tt][Gg][Zz])
            command="tar -xvzf \"$file\" -C \"$folder\" --overwrite"
            ;;
        *.[Tt][Bb][Zz]2)
            command="tar -xvjf \"$file\" -C \"$folder\" --overwrite"
            ;;
        *.[Zz][Ii][Pp])
            if [[ -n "$password" ]]; then
                command="unzip -o -P \"$password\" \"$file\" -d \"$folder\""
            else
                command="unzip -o \"$file\" -d \"$folder\""
            fi
            ;;
        *.[Zz])
            command="uncompress \"$file\" -c > \"${folder}/$(basename "${file%.*}")\" --force"
            ;;
        *.7[Zz] | *.[Ii][Ss][Oo])
            if [[ -n "$password" ]]; then
                command="7z x -p\"$password\" \"$file\" -o\"$folder\" -y"
            else
                command="7z x \"$file\" -o\"$folder\" -y"
            fi
            ;;
        *.[Ee][Xx][Ee])
            command="cabextract \"$file\" -d \"$folder\" --overwrite"
            ;;
        *)
            echo 'Unsupported file extension!' >&2
            return 1
            ;;
    esac

    if [[ -n "$command" ]]; then
        output_window_and_log "$title" "$command" "$folder"

        if [[ $? -eq 0 ]]; then
            local info='File extracted successfully!' && echo "$info" && zenity --info --text "$info"
            return 0
        else
            echo 'An error occurred during extraction!' >&2
            return 1
        fi
    else
        echo 'Unsupported file extension!' >&2
        return 1
    fi
}

# Function to compress the file
compress_file() {
    local file="$1"
    local compression_type="$2"

    local command=""
    local title="Compression Output"

    case "$compression_type" in
        "zip")
            command="zip ${file}.zip $file"
            ;;
        "zst")
            command="zstd --ultra -22 $file -o ${file}.zst"
            ;;
        "7z")
            command="7z a ${file}.7z $file"
            ;;
        "rar")
            command="rar a -p ${file}.rar $file"
            ;;
        "tar.gz")
            command="tar cvzf ${file}.tar.gz -C $(dirname "$file") $(basename "$file")"
            ;;
        "tar.xz")
            command="tar cvJf ${file}.tar.xz -C $(dirname "$file") $(basename "$file")"
            ;;
        "tar.zst")
            command="tar cvf ${file}.tar -C $(dirname "$file") $(basename "$file") && zstd --ultra -22 ${file}.tar -o ${file}.tar.zst && rm ${file}.tar"
            ;;
        "tar")
            command="tar cvf ${file}.tar -C $(dirname "$file") $(basename "$file")"
            ;;
        *)
            echo 'Invalid compression type!' >&2
            return 1
            ;;
    esac

    if [[ -n "$command" ]]; then
        output_window_and_log "$title" "$command" "$(dirname "$file")"

        if [[ $? -eq 0 ]]; then
            local info='File compressed successfully!' && echo "$info" && zenity --info --text "$info"
            return 0
        else
            echo 'An error occurred during compression!' >&2
            return 1
        fi
    fi
}

compress_folder() {
    local folder="$1"
    local compression_type="$2"

    local command=""
    local title="Compression Output"

    case "$compression_type" in
        "zip")
            command="(cd \"$(dirname "$folder")\" && zip -r \"${folder}.zip\" \"$(basename "$folder")\")"
            ;;
        "zst")
            command="(cd \"$(dirname "$folder")\" && tar cf \"${folder}.tar\" \"$(basename "$folder")\" && zstd --ultra -22 \"${folder}.tar\" -o \"${folder}.tar.zst\" && rm \"${folder}.tar\")"
            ;;
        "7z")
            command="(cd \"$(dirname "$folder")\" && 7z a \"${folder}.7z\" \"$(basename "$folder")\")"
            ;;
        "rar")
            command="(cd \"$(dirname "$folder")\" && rar a -p \"${folder}.rar\" \"$(basename "$folder")\")"
            ;;
        "tar.gz")
            command="(cd \"$(dirname "$folder")\" && tar cvzf \"${folder}.tar.gz\" \"$(basename "$folder")\")"
            ;;
        "tar.xz")
            command="(cd \"$(dirname "$folder")\" && tar cvJf \"${folder}.tar.xz\" \"$(basename "$folder")\")"
            ;;
        "tar.zst")
            command="(cd \"$(dirname "$folder")\" && tar cf \"${folder}.tar\" \"$(basename "$folder")\" && zstd --ultra -22 \"${folder}.tar\" -o \"${folder}.tar.zst\" && rm \"${folder}.tar\")"
            ;;
        "tar")
            command="(cd \"$(dirname "$folder")\" && tar cvf \"${folder}.tar\" \"$(basename "$folder")\")"
            ;;
        *)
            echo 'Invalid compression type!' >&2
            return 1
            ;;
    esac

    if [[ -n "$command" ]]; then
        output_window_and_log "$title" "$command" "$(dirname "$folder")"

        if [[ $? -eq 0 ]]; then
            local info='Folder compressed successfully!' && echo "$info" && zenity --info --text "$info"
            return 0
        else
            echo 'An error occurred during compression!' >&2
            return 1
        fi
    fi
}

# Function for dealing with compression dialog
compress_dialog() {
    local compression_type=$(zenity --list --title="Choose a compression type" --text="Compression Type" --radiolist --column="" --column="Compression Type" FALSE "zip" FALSE "zst" FALSE "7z" FALSE "rar" FALSE "tar.gz" FALSE "tar.xz" FALSE "tar.zst" FALSE "tar" --width=350 --height=350)

    local option=$(zenity --list --title="Choose an option" --text="Option" --radiolist --column="" --column="Option" FALSE "Compress file" FALSE "Compress folder")

    if [[ "$option" == "Compress file" ]]; then
        local file=$(zenity --file-selection --title="Choose a file to compress")
        if [[ -z "$file" ]]; then
            exit 0
        fi

        compress_file "$file" "$compression_type"
    elif [[ "$option" == "Compress folder" ]]; then
        local folder=$(zenity --file-selection --directory --title="Choose a folder to compress")
        if [[ -z "$folder" ]]; then
            exit 0
        fi

        compress_folder "$folder" "$compression_type"
    fi
}

# Function to deal with the extraction dialogue
extract_dialog() {
    while true; do
        local option=$(zenity --list --title="Choose an option" --text="Option" --radiolist --column="" --column="Option" FALSE "Extract here" FALSE "Extract to a folder" FALSE "Create a compressed file")

        if [[ "$option" == "Extract here" ]]; then
            local file=$(zenity --file-selection --title="Choose a compressed file")
            if [[ -z "$file" ]]; then
                exit 0
            fi

            local folder=$(dirname "$file")
            local password=$(zenity --password --title="Enter Password" --text="Please enter the password:")
            password=$(echo "$password" | tr -d '\n')
            extract_file "$file" "$folder" "$password"
        elif [[ "$option" == "Extract to a folder" ]]; then
            local file=$(zenity --file-selection --title="Choose a compressed file")
            if [[ -z "$file" ]]; then
                exit 0
            fi

            local answer=$(zenity --question --title="Create new folder?" --text="Do you want to create a new folder to extract the file?")
            if [[ $? -eq 0 ]]; then
                local folder=$(zenity --file-selection --directory --save --confirm-overwrite)
                mkdir -p "$folder"
            else
                local folder=$(zenity --file-selection --directory --title="Choose an existing folder")
            fi

            extract_file "$file" "$folder" ""
        elif [[ "$option" == "Create a compressed file" ]]; then
            compress_dialog
        fi

        answer=$(zenity --question --title="Continue" --text="Do you want to continue?")
        if [[ $? -ne 0 ]]; then
            exit 0
        fi
    done
}

# Main function
main() {
    extract_dialog
}

# Call the main function
main
