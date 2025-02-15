#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
SHELL_UTILS CHECK UPDATE
Enhanced with better error handling and efficient update checking
DOCUMENTATION

GITHUB_REPO="felipefacundes/shell_utils"
LOCAL_PATH="${HOME}/.shell_utils"
UPDATE_LOCK_FILE="/tmp/shell_utils_update.lock"
UPDATE_CHECK_INTERVAL=3600 # Interval in seconds (1 hour)
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

# Check if the local directory exists
if [ ! -d "$LOCAL_PATH" ]; then
    log_message "${MESSAGES[framework_not_found]}"
    if ! git clone "https://github.com/$GITHUB_REPO.git" "$LOCAL_PATH"; then
        log_message "${MESSAGES["repo_clone_error"]}"
        exit 1
    fi
fi

# Change to the framework directory
cd "$LOCAL_PATH" || exit 1

# Check for last update
LAST_UPDATE_FILE="${HOME}/.shell_utils_last_update"
if [ -f "$LAST_UPDATE_FILE" ]; then
    LAST_UPDATE=$(cat "$LAST_UPDATE_FILE")
    NOW=$(date +%s)
    if [ $((NOW - LAST_UPDATE)) -lt "$UPDATE_CHECK_INTERVAL" ]; then
        exit 0 # Don't check if updated recently
    fi
fi

# Check for updates efficiently
git_command remote update &> /dev/null

LOCAL=$(git_command rev-parse HEAD)
REMOTE=$(git_command rev-parse @{u})

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