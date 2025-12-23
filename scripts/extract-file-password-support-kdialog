#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script is a Bash utility for compressing and extracting files using various formats, 
leveraging the 'kdialog' tool for graphical user interface prompts. It allows users to 
select files or folders for compression, choose compression types, and handle password-protected archives. 
The script also provides feedback through dialog boxes, displaying success or error messages based on the operations performed.
DOCUMENTATION

#set -euo pipefail

if [[ "$1" ]]; then
    # Get the input file directory
    file_dir=$(dirname "$1")

    # Navigate to the input file directory
    cd "$file_dir"
fi

# Function to display the output window
output_window_and_log() {
    local title="$1"
    local command="$2"
    local folder="$3"
    local output=""
    local output_file="${title%.*}.txt"

    eval "$command" 2>&1 | tee >(kdialog --textbox --title "$title" --geometry 500x300 --timeout 999999 --result "${folder}/${output_file}") > >(tee "${folder}/${output_file}" >/dev/null)

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
                local unrar_command="unrar x -ad -p\"$password\" \"$file\" \"$folder\""

                # Execute the command to test the password
                eval "$unrar_command" >/dev/null 2>&1

                if [[ $? -eq 0 ]]; then
                    command="$unrar_command"
                else
                    echo 'Invalid password!' >&2
                    kdialog --sorry "Invalid password for file: $file"
                    return 1
                fi
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
                local unzip_command="unzip -o -P \"$password\" \"$file\" -d \"$folder\""

                # Execute the command to test the password
                eval "$unzip_command" >/dev/null 2>&1

                if [[ $? -eq 0 ]]; then
                    command="$unzip_command"
                else
                    echo 'Invalid password!' >&2
                    kdialog --sorry "Invalid password for file: $file"
                    return 1
                fi
            else
                command="unzip -o \"$file\" -d \"$folder\""
            fi
            ;;
        *.[Zz])
            command="uncompress \"$file\" -c > \"${folder}/$(basename "${file%.*}")\" --force"
            ;;
        *.7[Zz])
            if [[ -n "$password" ]]; then
                local p7zip_command="7z x -p\"$password\" \"$file\" -o\"$folder\" -y"

                # Execute the command to test the password
                eval "$p7zip_command" >/dev/null 2>&1

                if [[ $? -eq 0 ]]; then
                    command="$p7zip_command"
                else
                    echo 'Invalid password!' >&2
                    kdialog --sorry "Invalid password for file: $file"
                    return 1
                fi
            else
                command="7z x \"$file\" -o\"$folder\" -y"
            fi
            ;;
        *.[Ii][Ss][Oo])
            command="7z x \"$file\" -o\"$folder\" -y"
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
            local info='File extracted successfully!' && echo "$info" && kdialog --msgbox "$info"
            return 0
        else
            local warn='An error occurred during extraction!' && echo "$warn" >&2 && kdialog --sorry "$warn"
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
            local option=$(kdialog --title "Choose an option" --radiolist "Select an option for zip compression" "No password" "No password" "With password" "With password")
            if [[ "$option" == "No password" ]]; then
                command="zip ${file}.zip $file"
            else
                local password=$(kdialog --title "Enter Password" --password "Please enter the password:")
                password=$(echo "$password" | tr -d '\n')
                command="zip --password \"$password\" ${file}.zip $file"
            fi
            ;;
        "zst")
            command="zstd --ultra -22 $file -o ${file}.zst"
            ;;
        "7z")
            local option=$(kdialog --title "Choose an option" --radiolist "Select an option for 7z compression" "No password" "No password" "With password" "With password")
            if [[ "$option" == "No password" ]]; then
                command="7z a ${file}.7z $file"
            else
                local password=$(kdialog --title "Enter Password" --password "Please enter the password:")
                password=$(echo "$password" | tr -d '\n')
                command="7z a -p\"$password\" ${file}.7z $file"
            fi
            ;;
        "rar")
            local option=$(kdialog --title "Choose an option" --radiolist "Select an option for rar compression" "No password" "No password" "With password" "With password")
            if [[ "$option" == "No password" ]]; then
                command="rar a ${file}.rar $file"
            else
                local password=$(kdialog --title "Enter Password" --password "Please enter the password:")
                password=$(echo "$password" | tr -d '\n')
                command="rar a -p\"$password\" ${file}.rar $file"
            fi
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
            local info='File compressed successfully!' && echo "$info" && kdialog --msgbox "$info"
            return 0
        else
            local warn='An error occurred during compression!' && echo "$warn" >&2 && kdialog --sorry "$warn"
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
            local option=$(kdialog --title "Choose an option" --radiolist "Select an option for zip compression" "No password" "No password" "With password" "With password")
            if [[ "$option" == "No password" ]]; then
                command="(cd \"$(dirname "$folder")\" && zip -r \"${folder}.zip\" \"$(basename "$folder")\")"
            else
                local password=$(kdialog --title "Enter Password" --password "Please enter the password:")
                password=$(echo "$password" | tr -d '\n')
                command="(cd \"$(dirname "$folder")\" && zip --password \"$password\" -r \"${folder}.zip\" \"$(basename "$folder")\")"
            fi
            ;;
        "zst")
            command="(cd \"$(dirname "$folder")\" && tar cf \"${folder}.tar\" \"$(basename "$folder")\" && zstd --ultra -22 \"${folder}.tar\" -o \"${folder}.tar.zst\" && rm \"${folder}.tar\")"
            ;;
        "7z")
            local option=$(kdialog --title "Choose an option" --radiolist "Select an option for 7z compression" "No password" "No password" "With password" "With password")
            if [[ "$option" == "No password" ]]; then
                command="(cd \"$(dirname "$folder")\" && 7z a \"${folder}.7z\" \"$(basename "$folder")\")"
            else
                local password=$(kdialog --title "Enter Password" --password "Please enter the password:")
                password=$(echo "$password" | tr -d '\n')
                command="(cd \"$(dirname "$folder")\" && 7z a -p\"$password\" \"${folder}.7z\" \"$(basename "$folder")\")"
            fi
            ;;
        "rar")
            local option=$(kdialog --title "Choose an option" --radiolist "Select an option for rar compression" "No password" "No password" "With password" "With password")
            if [[ "$option" == "No password" ]]; then
                command="(cd \"$(dirname "$folder")\" && rar a \"${folder}.rar\" \"$(basename "$folder")\")"
            else
                local password=$(kdialog --title "Enter Password" --password "Please enter the password:")
                password=$(echo "$password" | tr -d '\n')
                command="(cd \"$(dirname "$folder")\" && rar a -p\"$password\" \"${folder}.rar\" \"$(basename "$folder")\")"
            fi
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
            local info='Folder compressed successfully!' && echo "$info" && kdialog --msgbox "$info"
            return 0
        else
            local warn='An error occurred during compression!' && echo "$warn" >&2 && kdialog --sorry "$warn"
            return 1
        fi
    fi
}

# Function to handle the compression dialog
compress_dialog() {
    local compression_type=$(kdialog --title "Choose a compression type" --radiolist "Compression Type" "zip" "zip" "zst" "zst" "7z" "7z" "rar" "rar" "tar.gz" "tar.gz" "tar.xz" "tar.xz" "tar.zst" "tar.zst" "tar" "tar" --width 350 --height 350)

    local option=$(kdialog --title "Choose an option" --radiolist "Option" "Compress file" "Compress file" "Compress folder" "Compress folder")

    if [[ "$option" == "Compress file" ]]; then
        local file=$(kdialog --getopenfilename "Choose a file to compress")
        if [[ -z "$file" ]]; then
            exit 0
        fi

        compress_file "$file" "$compression_type"
    elif [[ "$option" == "Compress folder" ]]; then
        local folder=$(kdialog --getexistingdirectory "Choose a folder to compress")
        if [[ -z "$folder" ]]; then
            exit 0
        fi

        compress_folder "$folder" "$compression_type"
    fi
}

# Function to handle the extract dialog
extract_dialog() {
    while true; do
        local option=$(kdialog --title "Choose an option" --radiolist "Option" "Extract here" "Extract here" "Extract to a folder" "Extract to a folder" "Create a compressed file" "Create a compressed file")

        if [[ "$option" == "Extract here" ]]; then
            local file=$(kdialog --getopenfilename "Choose a compressed file")
            if [[ -z "$file" ]]; then
                exit 0
            fi

            local folder=$(dirname "$file")
            
            if [[ "$file" == *.[Rr][Aa][Rr] ]] || [[ "$file" == *.[Zz][Ii][Pp] ]] || [[ "$file" == *.7[Zz] ]]; then
                local password=$(kdialog --title "Enter Password" --password "Please enter the password:")
                password=$(echo "$password" | tr -d '\n')
                extract_file "$file" "$folder" "$password"
            else
                extract_file "$file" "$folder"
            fi
        elif [[ "$option" == "Extract to a folder" ]]; then
            local file=$(kdialog --getopenfilename "Choose a compressed file")
            if [[ -z "$file" ]]; then
                exit 0
            fi

            local answer=$(kdialog --title "Create new folder?" --yesno "Do you want to create a new folder to extract the file?")
            if [[ $? -eq 0 ]]; then
                local folder=$(kdialog --getexistingdirectory "Choose a folder to save the file")
                mkdir -p "$folder"
            else
                local folder=$(kdialog --getexistingdirectory "Choose an existing folder")
            fi

            extract_file "$file" "$folder" ""
        elif [[ "$option" == "Create a compressed file" ]]; then
            compress_dialog
        fi

        answer=$(kdialog --title "Continue" --yesno "Do you want to continue?")
        if [[ $? -ne 0 ]]; then
            exit 0
        fi
    done
}

# main function
main() {
    extract_dialog
}

# Call the main function
main