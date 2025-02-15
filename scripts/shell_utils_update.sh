#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
SHELL_UTILS CHECK UPDATE
Enhanced with better error handling and efficient update checking
DOCUMENTATION

SHELL_UTILS_AUTO_UPDATE=${SHELL_UTILS_AUTO_UPDATE:=0}
UPDATE_CHECK_INTERVAL=${UPDATE_CHECK_INTERVAL:=3600} # Interval in seconds (1 hour)
CONFIG_DIR="${HOME}/.shell_utils_configs"
CONFIG_FILE="${CONFIG_DIR}/shell_utils_update.conf"
GITHUB_REPO="felipefacundes/shell_utils"
LOCAL_PATH="${HOME}/.shell_utils"
UPDATE_LOCK_FILE="/tmp/shell_utils_update.lock"
ARGUMENT="$1"
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

declare -A MESSAGES
# Check the system language and assign messages accordingly
if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        ["framework_not_found"]="Shell Utils não encontrado. Clonando repositório..."
        ["repo_clone_error"]="${RED}Erro ao clonar repositório${NC}"
        ["updates_found"]="${YELLOW}Novas atualizações encontradas. Atualizando...${NC}"
        ["update_success"]="${GREEN}Shell Utils atualizado com sucesso!${NC}"
        ["update_error"]="${RED}Erro ao atualizar Shell Utils${NC}"
        ["rebase_error"]="${RED}Erro durante o rebase. Abortando...${NC}"
        ["rebase_abort"]="SHELL_UTILS: executando 'git rebase --abort'..."
        ["was_an_error"]="${RED}Houve um erro de atualização.${NC}"
        ["updated"]="${YELLOW}O SHELL_UTILS foi atualizado, não há nada a fazer!${NC}"
        ["help"]=$(
    cat <<EOF
SHELL_UTILS CHECK UPDATE
===========================================
Este script verifica e atualiza automaticamente a framework SHELL_UTILS, garantindo que você tenha sempre a versão mais recente.

USO:
    ${0##*/} [OPÇÃO]

OPÇÕES DISPONÍVEIS:
    -c, --check    Força uma verificação e atualização manual da framework.
    -h, --help     Exibe esta mensagem de ajuda.

CONFIGURAÇÃO AUTOMÁTICA:
    Para permitir atualizações automáticas da framework SHELL_UTILS, é necessário definir a seguinte configuração:
    
    Arquivo de configuração:
        ~/.shell_utils_configs/shell_utils_update.conf

    Parâmetro necessário:
        SHELL_UTILS_AUTO_UPDATE=1

    Se esta configuração não estiver definida ou estiver como 0, a atualização automática será desativada.

MECANISMO DE ATUALIZAÇÃO:
    - O script verifica se há novas versões no repositório oficial.
    - Se uma nova versão for encontrada, a atualização será aplicada automaticamente.
    - Caso ocorram conflitos durante o processo, o script tentará resolvê-los ou reverterá para o último estado estável.

BLOQUEIO DE ATUALIZAÇÃO:
    Para evitar execuções simultâneas, um arquivo de bloqueio temporário é criado em:
        /tmp/shell_utils_update.lock
    Se uma atualização foi verificada nos últimos 5 minutos, a verificação será ignorada.

REGISTRO DE ÚLTIMA VERIFICAÇÃO:
    O timestamp da última verificação bem-sucedida é armazenado em:
        /tmp/shell_utils_last_update
    O script respeita um intervalo mínimo de 1 hora entre verificações, a menos que a atualização seja forçada com -c ou --check.

EXEMPLOS:
    - Para executar uma atualização manual:
        ${0##*/} -c

    - Para ativar atualizações automáticas, edite o arquivo de configuração:
        echo "SHELL_UTILS_AUTO_UPDATE=1" > ~/.shell_utils_configs/shell_utils_update.conf

    - Para desativar atualizações automáticas:
        echo "SHELL_UTILS_AUTO_UPDATE=0" > ~/.shell_utils_configs/shell_utils_update.conf

LICENÇA:
    Este script está licenciado sob a GPLv3.

CREDITOS:
    Desenvolvido por Felipe Facundes.
===========================================
EOF
        )
    )
elif [[ "${LANG,,}" =~ es_ ]]; then
    MESSAGES=(
        ["framework_not_found"]="Shell Utils no encontrado. Clonando repositorio..."
        ["repo_clone_error"]="${RED}Error al clonar el repositorio${NC}"
        ["updates_found"]="${YELLOW}Nuevas actualizaciones encontradas. Actualizando...${NC}"
        ["update_success"]="${GREEN}¡Shell Utils actualizado con éxito!${NC}"
        ["update_error"]="${RED}Error al actualizar Shell Utils${NC}"
        ["rebase_error"]="${RED}Error durante el rebase. Abortando...${NC}"
        ["rebase_abort"]="SHELL_UTILS: ejecutando 'git rebase --abort'..."
        ["was_an_error"]="${RED}Hubo un error de actualización.${NC}"
        ["updated"]="${YELLOW}El SHELL_UTILS ha sido actualizado, no hay nada que hacer!${NC}"
        ["help"]=$(
    cat <<EOF
VERIFICACIÓN DE ACTUALIZACIÓN DE SHELL_UTILS
===========================================
Este script verifica y actualiza automáticamente la framework SHELL_UTILS, asegurando que siempre tenga la versión más reciente.

USO:
    ${0##*/} [OPCIÓN]

OPCIONES DISPONIBLES:
    -c, --check    Fuerza una verificación y actualización manual de la framework.
    -h, --help     Muestra este mensaje de ayuda.

CONFIGURACIÓN AUTOMÁTICA:
    Para permitir actualizaciones automáticas de la framework SHELL_UTILS, es necesario definir la siguiente configuración:
    
    Archivo de configuración:
        ~/.shell_utils_configs/shell_utils_update.conf

    Parámetro necesario:
        SHELL_UTILS_AUTO_UPDATE=1

    Si esta configuración no está definida o está como 0, la actualización automática será desactivada.

MECANISMO DE ACTUALIZACIÓN:
    - El script verifica si hay nuevas versiones en el repositorio oficial.
    - Si se encuentra una nueva versión, la actualización se aplicará automáticamente.
    - Si ocurren conflictos durante el proceso, el script intentará resolverlos o revertirá al último estado estable.

BLOQUEO DE ACTUALIZACIÓN:
    Para evitar ejecuciones simultáneas, se crea un archivo de bloqueo temporal en:
        /tmp/shell_utils_update.lock
    Si se ha verificado una actualización en los últimos 5 minutos, se ignorará la verificación.

REGISTRO DE ÚLTIMA VERIFICACIÓN:
    La marca de tiempo de la última verificación exitosa se almacena en:
        /tmp/shell_utils_last_update
    El script respeta un intervalo mínimo de 1 hora entre verificaciones, a menos que la actualización sea forzada con -c o --check.

EJEMPLOS:
    - Para realizar una actualización manual:
        ${0##*/} -c

    - Para habilitar actualizaciones automáticas, edite el archivo de configuración:
        echo "SHELL_UTILS_AUTO_UPDATE=1" > ~/.shell_utils_configs/shell_utils_update.conf

    - Para desactivar actualizaciones automáticas:
        echo "SHELL_UTILS_AUTO_UPDATE=0" > ~/.shell_utils_configs/shell_utils_update.conf

LICENCIA:
    Este script está licenciado bajo la GPLv3.

CRÉDITOS:
    Desarrollado por Felipe Facundes.
===========================================
EOF
        )
    )
else
    MESSAGES=(
        ["framework_not_found"]="Shell Utils directory not found. Cloning repository..."
        ["repo_clone_error"]="${RED}Error cloning repository${NC}"
        ["updates_found"]="${YELLOW}New updates found. Updating...${NC}"
        ["update_success"]="${GREEN}Shell Utils successfully updated!${NC}"
        ["update_error"]="${RED}Error updating Shell Utils${NC}"
        ["rebase_error"]="${RED}Error during rebase. Aborting...${NC}"
        ["rebase_abort"]="SHELL_UTILS: running 'git rebase --abort'..."
        ["was_an_error"]="${RED}There was an error updating.${NC}"
        ["updated"]="${YELLOW}The SHELL_UTILS has been updated, there is nothing to do!${NC}"
        ["help"]=$(
    cat <<EOF
SHELL_UTILS CHECK UPDATE
===========================================
This script checks and automatically updates the SHELL_UTILS framework, ensuring that you always have the latest version.

USAGE:
    ${0##*/} [OPTION]

AVAILABLE OPTIONS:
    -c, --check    Forces a manual check and update of the framework.
    -h, --help     Displays this help message.

AUTOMATIC CONFIGURATION:
    To allow automatic updates of the SHELL_UTILS framework, the following configuration must be set:
    
    Configuration file:
        ~/.shell_utils_configs/shell_utils_update.conf

    Required parameter:
        SHELL_UTILS_AUTO_UPDATE=1

    If this configuration is not set or is set to 0, automatic updates will be disabled.

UPDATE MECHANISM:
    - The script checks for new versions in the official repository.
    - If a new version is found, the update will be applied automatically.
    - If conflicts occur during the process, the script will attempt to resolve them or revert to the last stable state.

UPDATE LOCK:
    To prevent simultaneous executions, a temporary lock file is created at:
        /tmp/shell_utils_update.lock
    If an update has been checked in the last 5 minutes, the check will be skipped.

LAST CHECK LOG:
    The timestamp of the last successful check is stored in:
        /tmp/shell_utils_last_update
    The script respects a minimum interval of 1 hour between checks, unless the update is forced with -c or --check.

EXAMPLES:
    - To perform a manual update:
        ${0##*/} -c

    - To enable automatic updates, edit the configuration file:
        echo "SHELL_UTILS_AUTO_UPDATE=1" > ~/.shell_utils_configs/shell_utils_update.conf

    - To disable automatic updates:
        echo "SHELL_UTILS_AUTO_UPDATE=0" > ~/.shell_utils_configs/shell_utils_update.conf

LICENSE:
    This script is licensed under the GPLv3.

CREDITS:
    Developed by Felipe Facundes.
===========================================
EOF
        )
    )
fi

# Function to log messages
log_message() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to handle git operations
git_command() {
    command git --git-dir="$LOCAL_PATH/.git" --work-tree="$LOCAL_PATH" "$@"
}

# Function to perform update
perform_update() {
    current_hash=$(git_command rev-parse HEAD)
    
    # Backup local configurations if necessary
    if [ -f "config.local" ]; then
        cp config.local config.local.backup
    fi

    # Attempt to update with rebase
    if ! git_command pull --rebase --stat origin main; then
        log_message "${MESSAGES[rebase_error]}"
        printf '%s\n' "${MESSAGES[rebase_abort]}"
        git_command rebase --abort
        git_command reset --hard "$current_hash"
        if ! git_command pull; then
            git_command reset --hard "$current_hash"
            echo -e "${MESSAGES[was_an_error]}"
            return 1
        fi
    fi

    # Restore local configurations if necessary
    if [ -f "config.local.backup" ]; then
        [[ -f "config.local" ]] && rm config.local
        mv config.local.backup config.local
    fi

    # Run post-update script if exists
    if [ -f "post_update.sh" ]; then
        bash post_update.sh
    fi

    return 0
}

check_update() {
    # Check for updates efficiently
    git_command remote update &> /dev/null

    LOCAL=$(git_command rev-parse HEAD); export LOCAL
    REMOTE=$(git_command rev-parse @{u}); export REMOTE
}

# Check if the local directory exists
if [ ! -d "$LOCAL_PATH" ]; then
    log_message "${MESSAGES[framework_not_found]}"
    if ! git clone "https://github.com/$GITHUB_REPO.git" "$LOCAL_PATH"; then
        log_message "${MESSAGES["repo_clone_error"]}"
        exit 1
    fi
fi

if [[ ! -d "$CONFIG_DIR" ]]; then
    mkdir -p "$CONFIG_DIR"
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    touch "$CONFIG_FILE"
    echo 'SHELL_UTILS_AUTO_UPDATE=0' | tee "$CONFIG_FILE" 1>/dev/null
    echo 'UPDATE_CHECK_INTERVAL=3600' | tee -a "$CONFIG_FILE" 1>/dev/null
fi

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

case "$ARGUMENT" in
    "-c"|"--check")
        check_update
        if [[ "$LOCAL" == "$REMOTE" ]]; then
            log_message "${MESSAGES[updated]}"
            exit 0
        fi
        [[ -f "$UPDATE_LOCK_FILE" ]] && rm -f "$UPDATE_LOCK_FILE"
        [[ -f "$LAST_UPDATE_FILE" ]] && rm -f "$LAST_UPDATE_FILE"
        export SHELL_UTILS_AUTO_UPDATE=1
    ;;
    "-h"|"--help")
        printf '%s\n' "${MESSAGES[help]}" | less -i
    ;;
esac

if [[ "$SHELL_UTILS_AUTO_UPDATE" == 0 ]]; then
    exit 0
fi

# Check for running update
if [ -f "$UPDATE_LOCK_FILE" ]; then
    if [ $(($(date +%s) - $(stat -c %Y "$UPDATE_LOCK_FILE"))) -lt 300 ]; then
        exit 0 # Exit if an update was checked in the last 5 minutes
    fi
fi

# Create lock file
touch "$UPDATE_LOCK_FILE"

# Ensure cleanup on script exit
trap 'rm -f "$UPDATE_LOCK_FILE"' EXIT

# Change to the framework directory
cd "$LOCAL_PATH" || exit 1

# Check for last update
LAST_UPDATE_FILE="/tmp/shell_utils_last_update"
if [ -f "$LAST_UPDATE_FILE" ]; then
    LAST_UPDATE=$(cat "$LAST_UPDATE_FILE")
    NOW=$(date +%s)
    if [ $((NOW - LAST_UPDATE)) -lt "$UPDATE_CHECK_INTERVAL" ]; then
        exit 0 # Don't check if updated recently
    fi
fi

check_update

if [ "$LOCAL" != "$REMOTE" ]; then
    log_message "${MESSAGES[updates_found]}"
    echo
    if perform_update; then
        echo
        log_message "${MESSAGES[update_success]}"
    else
        echo
        log_message "${MESSAGES[update_error]}"
    fi
fi

# Update the timestamp of the last check
date +%s > "$LAST_UPDATE_FILE"