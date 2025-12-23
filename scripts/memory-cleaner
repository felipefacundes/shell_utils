#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script is a bilingual memory management utility designed to clean 
RAM and Swap memory with advanced flexibility. Its key strengths include:

Multilingual Support: Automatically detects system language (Portuguese or English) and provides localized messages,
error handling, and help instructions, enhancing user experience across different language environments.
Comprehensive Memory Management: Offers multiple options for memory cleaning, including:

- Forcibly clearing Swap memory
- Clearing RAM cache
- Cleaning both RAM and Swap simultaneously

Robust Command-Line Interface: Implements advanced error handling and user guidance, featuring:

- Detailed help menu with usage instructions
- Comprehensive option parsing
- Informative error messages for invalid inputs

The script demonstrates sophisticated bash scripting techniques like associative arrays, dynamic message localization, 
and system memory management commands, making it a powerful and user-friendly tool for system resource optimization.
DOCUMENTATION

# Associative array for bilingual messages
declare -A MESSAGES

# Detect language
if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        ["clean_swap"]="Limpando Swap forçadamente..."
        ["clean_swap_done"]="Memória Swap liberada"
        ["clean_ram"]="Limpando RAM..."
        ["clean_ram_done"]="Memória RAM liberada"
        ["clean_both"]="Limpando RAM e Swap..."
        ["clean_both_done"]="Memória RAM e Swap liberadas"
        ["usage"]="Uso: ${0##*/} [OPÇÃO]"
        ["options"]="\nOpções disponíveis:"
        ["cleanswap_desc"]="Limpa a memória Swap forçadamente."
        ["cleanram_desc"]="Limpa a memória RAM."
        ["clean_desc"]="Limpa a memória RAM e Swap."
        ["help_desc"]="Exibe este menu de ajuda."
        ["example"]="\nExemplo de uso:"
        ["no_option_error"]="Erro: Nenhuma opção fornecida. Use --help para ver o menu de ajuda."
        ["invalid_option_error"]="Erro: Opção inválida '%s'. Use --help para ver o menu de ajuda."
    )
else
    MESSAGES=(
        ["clean_swap"]="Forcibly cleaning Swap..."
        ["clean_swap_done"]="Swap memory cleared"
        ["clean_ram"]="Cleaning RAM..."
        ["clean_ram_done"]="RAM memory cleared"
        ["clean_both"]="Cleaning RAM and Swap..."
        ["clean_both_done"]="RAM and Swap memory cleared"
        ["usage"]="Usage: ${0##*/} [OPTION]"
        ["options"]="\nAvailable options:"
        ["cleanswap_desc"]="Forcefully cleans Swap memory."
        ["cleanram_desc"]="Cleans RAM memory."
        ["clean_desc"]="Cleans both RAM and Swap memory."
        ["help_desc"]="Displays this help menu."
        ["example"]="\nExample usage:"
        ["no_option_error"]="Error: No option provided. Use --help to view the help menu."
        ["invalid_option_error"]="Error: Invalid option '%s'. Use --help to view the help menu."
    )
fi

# Function to clean swap forcefully
cleanswap_force() {
    local zram="/dev/zram0"
    echo "${MESSAGES["clean_swap"]}"

    if [ -b "$zram" ]; then
        sudo swapoff "$zram"
        sudo swapon "$zram" -p 10
    fi

    sudo swapoff -a
    sudo swapon -a
    cat /proc/swaps
    echo "${MESSAGES["clean_swap_done"]}"
}

# Function to clean RAM
cleanram() {
    clear
    free -h
    echo -e "\n${MESSAGES["clean_ram"]}\n"
    # sync && echo 1 | sudo tee /proc/sys/vm/drop_caches
    # sync && sudo sysctl -w vm.drop_caches=1
    # sync && echo 2 | sudo tee /proc/sys/vm/drop_caches
    # sync && sudo sysctl -w vm.drop_caches=2
    # sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
    sync && sudo sysctl -w vm.drop_caches=3 # All caches (pages + inodes + dentries)
    free -h
    echo -e "\n${MESSAGES["clean_ram_done"]}"
}

# Function to clean RAM and Swap
clean() {
    echo "${MESSAGES["clean_both"]}"
    cleanram
    cleanswap_force
    echo "${MESSAGES["clean_both_done"]}"
}

# Display help menu
help_menu() {
    cat <<EOF | { echo -e "$(cat)"; }
${MESSAGES["usage"]}
${MESSAGES["options"]}
  --cleanswap       ${MESSAGES["cleanswap_desc"]}
  --cleanram        ${MESSAGES["cleanram_desc"]}
  --clean           ${MESSAGES["clean_desc"]}
  --help            ${MESSAGES["help_desc"]}
${MESSAGES["example"]}
  ${0##*/} --cleanram
EOF
    exit 0
}

# Main logic to handle arguments
if [[ $# -eq 0 ]]; then
    echo "${MESSAGES["no_option_error"]}"
    exit 1
fi

case "$1" in
    --cleanswap)
        cleanswap_force
        ;;
    --cleanram)
        cleanram
        ;;
    --clean)
        clean
        ;;
    --help)
        help_menu
        ;;
    *)
        printf "${MESSAGES["invalid_option_error"]}" "$1"
        exit 1
        ;;
esac
