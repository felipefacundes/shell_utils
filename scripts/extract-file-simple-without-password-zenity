#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script provides a user-friendly interface for extracting various compressed file formats. 
It allows users to either select a file through a dialog or pass a file as an argument. 
Depending on the user's choice, the script can extract files either in the current directory or in a specified folder, 
with options to create a new folder if desired. It utilizes the 'zenity' tool for graphical dialogs and supports multiple
 compression formats, ensuring a versatile extraction process.
DOCUMENTATION

# Function for extracting files according to the extension
extract () {
    case "${1}" in
        *.[Tt][Aa][Rr].[Bb][Zz]2)   tar xvjf "${1}" -C "${2}"   ;;
        *.[Tt][Aa][Rr].[Gg][Zz])    tar xvzf "${1}" -C "${2}"   ;;
        *.[Tt][Aa][Rr].[Xx][Zz])    tar xvJf "${1}" -C "${2}"   ;;
        *.[Ll][Zz][Mm][Aa])         unlzma "${1}" -c > "${2}"   ;;
        *.[Bb][Zz]2)                bunzip2 "${1}" -c > "${2}"  ;;
        *.[Rr][Aa][Rr])             unrar x -ad "${1}" "${2}"   ;;
        *.[Gg][Zz])                 gunzip "${1}" -c > "${2}"   ;;
        *.[Tt][Aa][Rr])             tar xvf "${1}" -C "${2}"    ;;
        *.[Tt][Bb][Zz]2)            tar xvjf "${1}" -C "${2}"   ;;
        *.[Tt][Gg][Zz])             tar xvzf "${1}" -C "${2}"   ;;
        *.[Zz][Ii][Pp])             unzip "${1}" -d "${2}"      ;;
        *.[Zz])                     uncompress "${1}" -c > "${2}";;
        *.[7Zz])                    7z x "${1}" -o"${2}"        ;;
        *.[Ii][Ss][Oo])             7z x "${1}" -o"${2}"        ;;
        *.[Xx][Zz])                 unxz "${1}" -c > "${2}"     ;;
        *.[Ee][Xx][Ee])             cabextract "${1}" -d "${2}" ;;
    esac
}

# Check if the script received an argument
if [ $# -eq 0 ]; then
    # If you did not receive, open a dialogue to choose a compacted file
    file=$(zenity --file-selection --title="Choose a compacted file")
else
    # If received, attributes the argument to the File variable
    file=$1
fi

# Check if the file exists and is valid
if [ -f "$file" ]; then
    # If the script received an argument, open a menu with two options: extract here or extract in a folder
    if [ $# -eq 1 ]; then
        option=$(zenity --list --title="Choose an option" --column="Option" "Extract here" "Extract to folder")
    else
        # If the script did not receive an argument, attributes the option to extract in a folder to the OPTION variable
        option="Extract to folder"
    fi

    # Check which option was chosen
    case $option in
        "Extract here")
            # If it was extracting here, it extracts the file in the same folder where it is
            extract "$file" "$(dirname "$file")"
            zenity --info --text="File extracted successfully!"
            ;;
        "Extract to folder")
            # If it went to extract in a folder, open a dialogue to ask if you want to create a new folder or use an existing
            answer=$(zenity --question --text="Do you want to create a new folder to extract the file?" --ok-label="Yes" --cancel-label="No")
            # Check the user response
            if [ $? -eq 0 ]; then
                # If you answered yes, open a dialogue to choose the name and place of the new folder
                folder=$(zenity --file-selection --save --confirm-overwrite --title="Choose the name and place of the new folder")
                # Creates the new folder if it does not exist
                mkdir -p "$folder"
            else
                # If you answered no, open a dialogue to choose an existing folder
                folder=$(zenity --file-selection --directory --title="Choose an existing folder")
            fi
            # Extract the file in the chosen folder
            extract "$file" "$folder"
            zenity --info --text="File extracted successfully!"
            ;;
    esac
else
    # If the file does not exist or is invalid, it shows an error message
    zenity --error --text="Invalid or nonexistent file!"
fi
