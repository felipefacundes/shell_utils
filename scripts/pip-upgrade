#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script is a Bash utility designed to upgrade Python packages, both globally and locally, with support for bilingual messages. 

Strengths:
1. Bilingual support for user messages (English and Portuguese).
2. Multiple functions for upgrading packages using different methods (standard and pip freeze).
3. Clear usage instructions and help function for user guidance.

Capabilities:
- Upgrades global packages with and without pip freeze.
- Upgrades local packages with and without pip freeze.
- Provides a user-friendly interface for package management.
DOCUMENTATION

# Associative array for bilingual messages
declare -A MESSAGES

# Detect language
if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        ["usage"]="Uso: ${0##*/} <função>"
        ["functions_available"]="Funções disponíveis:"
        ["pip_upgrade_all"]="Atualiza pacotes globais (sudo)"
        ["pip_upgrade_all_local"]="Atualiza pacotes locais"
        ["pip_upgrade_all_2"]="Atualiza pacotes globais com pip freeze (sudo)"
        ["pip_upgrade_all_2_local"]="Atualiza pacotes locais com pip freeze"
        ["upgrading_global"]="Atualizando todos os pacotes globais com sudo..."
        ["upgrading_local"]="Atualizando todos os pacotes locais..."
        ["upgrading_global_freeze"]="Atualizando pacotes globais usando pip freeze com sudo..."
        ["upgrading_local_freeze"]="Atualizando pacotes locais usando pip freeze..."
    )
else
    MESSAGES=(
        ["usage"]="Usage: ${0##*/} <function>"
        ["functions_available"]="Available functions:"
        ["pip_upgrade_all"]="Upgrades global packages (sudo)"
        ["pip_upgrade_all_local"]="Upgrades local packages"
        ["pip_upgrade_all_2"]="Upgrades global packages with pip freeze (sudo)"
        ["pip_upgrade_all_2_local"]="Upgrades local packages with pip freeze"
        ["upgrading_global"]="Upgrading all global packages with sudo..."
        ["upgrading_local"]="Upgrading all local packages..."
        ["upgrading_global_freeze"]="Upgrading global packages using pip freeze with sudo..."
        ["upgrading_local_freeze"]="Upgrading local packages using pip freeze..."
    )
fi

# Help function
help() {
    cat <<EOF
    ${MESSAGES["usage"]}
    ${MESSAGES["functions_available"]}
    pip_upgrade_all             - ${MESSAGES["pip_upgrade_all"]}
    pip_upgrade_all_local       - ${MESSAGES["pip_upgrade_all_local"]}
    pip_upgrade_all_2           - ${MESSAGES["pip_upgrade_all_2"]}
    pip_upgrade_all_2_local     - ${MESSAGES["pip_upgrade_all_2_local"]}
EOF
}

pip_upgrade_all() {
    echo "${MESSAGES["upgrading_global"]}"
    sudo pip list --outdated --format=freeze | grep -v '^\-e' | cut -d '=' -f 1 | xargs -n1 sudo pip install -U
}

pip_upgrade_all_local() {
    echo "${MESSAGES["upgrading_local"]}"
    pip list --outdated --format=freeze | grep -v '^\-e' | cut -d '=' -f 1 | xargs -n1 pip install -U
}

pip_upgrade_all_2() {
    echo "${MESSAGES["upgrading_global_freeze"]}"
    sudo pip freeze --local | grep -v '^\-e' | cut -d '=' -f 1 | xargs -n1 sudo pip install -U
}

pip_upgrade_all_2_local() {
    echo "${MESSAGES["upgrading_local_freeze"]}"
    pip freeze --local | grep -v '^\-e' | cut -d '=' -f 1 | xargs -n1 pip install -U
}

# Utilização com argumentos
if [[ $# -eq 0 ]]; then
    help
    exit 1
fi

case $1 in
    pip_upgrade_all)
        pip_upgrade_all
        ;;
    pip_upgrade_all_local)
        pip_upgrade_all_local
        ;;
    pip_upgrade_all_2)
        pip_upgrade_all_2
        ;;
    pip_upgrade_all_2_local)
        pip_upgrade_all_2_local
        ;;
    *)
        help
        exit 1
        ;;
esac
