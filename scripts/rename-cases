#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Rename archives (files and folders) to UPPER, title or lower case.
DOCUMENTATION

# Define a signal handler to capture SIGINT (Ctrl+C)
trap 'kill $(jobs -p)' SIGTERM #SIGHUP #SIGINT #SIGQUIT #SIGABRT #SIGKILL #SIGALRM #SIGTERM

doc() {
    less -FX "$0" | head -n6 | tail -n1
}

help() {
    cat <<EOF

    $(doc)

    Usage: ${0##*/} [args] [file/folder]

        -t
            rename file to titlecase
            Example: ${0##*/} -l file

        -a2t
            rename all files of folder to titlecase

        -l
            rename file to lowercase
            Example: ${0##*/} -l file

        -a2l
            rename all files of folder to lowercase

        -u
            rename file to UPPERCASE
            Example: ${0##*/} -u file

        -a2u
            rename all files of folder to UPPERCASE

    
EOF
}

rename_to_titlecase() {
    local original_name="$1"
    local new_name

    # Substitui os delimitadores para facilitar o processamento (espaço, hífen e underline)
    new_name=$(echo "$original_name" | sed 's/[ _-]/\n/g' | awk '{
        $0 = toupper(substr($0, 1, 1)) tolower(substr($0, 2))
        print
    }' | paste -sd'-' -)

    # Renomeia o arquivo
    mv "$original_name" "$new_name" && echo "Arquivo renomeado para: $new_name" || echo "Erro ao renomear o arquivo!"
}

rename_all_to_titlecase() {
    echo 'All files in this directory will be renamed to title case'
    echo -e "\nContinue: yes | no" 
    declare -l option
    read -r option
    if [[ "${option}" = yes ]]; then
        for i in *;
            do
            rename_to_titlecase "${i}"
        done
    fi
    exit 0
}

rename_to_lowercase()
{
    if [ -z "${1}" ]; then
        echo -e "Usage:\n\nrename_to_lowercase <file or directory>"
    else
        mv -v "${1}" "$(echo "${1}" | tr '[A-Z]' '[a-z]')"
    fi
}

rename_all_to_lowercase()
{
    echo 'All files in this directory will be renamed to lower case'
    echo -e "\nContinue: yes | no" 
    declare -l option
    read -r option
    if [[ "${option}" = yes ]]; then
        for i in *;
            do
            mv -v "${i}" "$(echo ${i} | tr '[A-Z]' '[a-z]')"
        done
    fi
    exit 0
}

rename_to_uppercase()
{
    if [ -z "${1}" ]; then
        echo -e "Usage:\n\nrename_to_uppercase <file or directory>"
    else
        mv -v "${1}" "$(echo "${1}" | tr '[a-z]' '[A-Z]')"
    fi
}

rename_all_to_uppercase()
{
    echo 'All files in this directory will be renamed to UPPER CASE'
    echo -e "\nContinue: yes | no" 
    declare -l option
    read -r option
    if [[ "${option}" = yes ]]; then
        for i in *;
            do
            mv -v "${i}" "$(echo "${i}" | tr '[a-z]' '[A-Z]')"
        done
    fi
    exit 0
}

if [[ -z $1 ]] || [[ $1 == "-h" || $1 == "--help" ]]; then
    help
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -t)
            rename_to_titlecase "$2"
            shift 2
            continue
            ;;
        -a2t)
            rename_all_to_titlecase "$2"
            shift 2
            continue
            ;;
        -l)
            rename_to_lowercase "$2"
            shift 2
            continue
            ;;
        -a2l)
            rename_all_to_lowercase
            shift
            continue
            ;;
        -u)
            rename_to_uppercase "$2"
            shift 2
            continue
            ;;
        -a2u)
            rename_all_to_uppercase
            shift
            continue
            ;;
        *)
            help
            break
            ;;
    esac
done

# Wait for all child processes to finish
wait