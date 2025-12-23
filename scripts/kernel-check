#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script is designed to manage and check kernel versions on a system, 
providing users with options to view the currently initiated kernel, 
the latest available kernel in repositories, and to check if the kernel has been updated. 

Strengths:
1. Multilingual Support: The script supports both Portuguese and English, making it accessible to a wider audience.
2. User -Friendly Help Menu: It includes a help menu that clearly outlines the available options and their functionalities.
3. Kernel Version Checking: Users can easily check the current and available kernel versions with simple commands.
4. Update Notification: The script notifies users if the kernel has been updated and requires a system restart.
5. Error Handling: It provides feedback for unknown options, enhancing user experience.

Capabilities:
- Display the current kernel version.
- Show the latest kernel version available in repositories.
- Check if the kernel has been updated and display differences if applicable.
DOCUMENTATION

# Associative array to store messages in both languages
declare -A MESSAGES

if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        ["usage"]="Uso: ${0##*/} [OPÇÕES]"
        ["options"]="Opções:"
        ["initiated"]="  -i, --initiated       Mostrar a versão atual do kernel iniciado"
        ["available"]="  -a, --available       Mostrar a versão mais recente do kernel disponível nos repositórios"
        ["check"]="  -c, --check           Verificar se o kernel do sistema foi atualizado"
        ["help"]="  -h, --help            Exibir este menu de ajuda"
        ["kernel_initiated"]="Kernel iniciado: "
        ["kernel_installed"]="Kernel instalado: "
        ["updated_message"]="O kernel foi atualizado e o sistema precisa ser reiniciado!"
        ["diff_message"]="\nDiff:\n"
        ["same"]="Eles são absolutamente os mesmos!"
        ["unknown_option"]="Opção desconhecida: "
    )
else
    MESSAGES=(
        ["usage"]="Usage: ${0##*/} [OPTIONS]"
        ["options"]="Options:"
        ["initiated"]="  -i, --initiated       Show the currently initiated kernel version"
        ["available"]="  -a, --available       Show the latest available kernel version in repositories"
        ["check"]="  -c, --check           Check if the system kernel has been updated"
        ["help"]="  -h, --help            Display this help menu"
        ["kernel_initiated"]="Kernel initiated: "
        ["kernel_installed"]="Kernel installed: "
        ["updated_message"]="The kernel has been updated and the system needs to be restarted!"
        ["diff_message"]="\nDiff:\n"
        ["same"]="They are absolutely the same!"
        ["unknown_option"]="Unknown option: "
    )
fi

# Function to show the help menu
show_help() {
    echo "${MESSAGES["usage"]}"
    echo -e "\n${MESSAGES["options"]}"
    echo "${MESSAGES["initiated"]}"
    echo "${MESSAGES["available"]}"
    echo "${MESSAGES["check"]}"
    echo "${MESSAGES["help"]}"
}

# Function to check the initiated kernel version
kernel_initiated_version() {
    uname -r | sed 's|-|.|g'
}

# Function to check the latest available kernel version in the repositories
kernel_installed_version() {
    LC_ALL=en pacman -Si linux | grep -i "^Version" | awk '{print $3}' | sed 's|-|.|g'
}

# Main function to check if the kernel has been updated
kernel_been_updated() {
    kernel_initiated=$(kernel_initiated_version)
    installed_kernel=$(kernel_installed_version)

    echo "${MESSAGES["kernel_initiated"]}$kernel_initiated"
    echo "${MESSAGES["kernel_installed"]}$installed_kernel"

    if [[ "$kernel_initiated" != "$installed_kernel" ]]; then
        echo -e "\n${MESSAGES["updated_message"]}"
        echo -e "${MESSAGES["diff_message"]}"
        kernel_initiated_version | diff -u - <(kernel_installed_version)
        return 1
    else
        echo -e "\n${MESSAGES["same"]}"
    fi
}

# Argument handling
if [[ $# -eq 0 ]]; then
    show_help
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--initiated)
            echo "${MESSAGES["initiated"]}"
            kernel_initiated_version
            shift
            ;;
        -a|--available)
            echo "${MESSAGES["available"]}"
            kernel_installed_version
            shift
            ;;
        -c|--check)
            kernel_been_updated
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "${MESSAGES["unknown_option"]}$1"
            show_help
            exit 1
            ;;
    esac
    shift
done
