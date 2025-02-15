#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
SHELL_UTILS CHECK UPDATE
Enhanced with better error handling and efficient update checking
DOCUMENTATION

declare -A MESSAGES
# Check the system language and assign messages accordingly
if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        ["framework_not_found"]="Shell Utils não encontrado. Clonando repositório..."
        ["repo_clone_error"]="Erro ao clonar repositório"
        ["update_check"]="Verificando atualizações..."
        ["updates_found"]="Novas atualizações encontradas. Atualizando..."
        ["update_success"]="Shell Utils atualizado com sucesso!"
        ["update_error"]="Erro ao atualizar Shell Utils"
        ["rebase_error"]="Erro durante o rebase. Abortando..."
    )
else
    MESSAGES=(
        ["framework_not_found"]="Shell Utils directory not found. Cloning repository..."
        ["repo_clone_error"]="Error cloning repository"
        ["update_check"]="Checking for updates..."
        ["updates_found"]="New updates found. Updating..."
        ["update_success"]="Shell Utils successfully updated!"
        ["update_error"]="Error updating Shell Utils"
        ["rebase_error"]="Error during rebase. Aborting..."
    )
fi

GITHUB_REPO="felipefacundes/shell_utils"
LOCAL_PATH="${HOME}/.shell_utils"
UPDATE_LOCK_FILE="/tmp/shell_utils_update.lock"
UPDATE_CHECK_INTERVAL=3600 # Interval in seconds (1 hour)
RED='\033[0;31m'
NORMAL='\033[0m'

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to handle git operations
git_command() {
    command git --git-dir="$LOCAL_PATH/.git" --work-tree="$LOCAL_PATH" "$@"
}

# Function to perform update
perform_update() {
    local current_hash=$(git_command rev-parse HEAD)
    
    # Backup local configurations if necessary
    if [ -f "config.local" ]; then
        cp config.local config.local.backup
    fi

    # Attempt to update with rebase
    if ! git_command pull --rebase --stat origin main; then
        log_message "${MESSAGES["rebase_error"]}"
        printf '%s\n' "oh-my-bash: running 'git rebase --abort'..."
        git_command rebase --abort
        printf "${RED}%s${NORMAL}\n" 'There was an error updating.'
        git_command reset --hard "$current_hash"
        git_command pull
        return 1
    fi

    # Restore local configurations if necessary
    if [ -f "config.local.backup" ]; then
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
    log_message "${MESSAGES["framework_not_found"]}"
    if ! git clone "https://github.com/$GITHUB_REPO.git" "$LOCAL_PATH"; then
        log_message "${MESSAGES["repo_clone_error"]}"
        exit 1
    fi
fi

# Change to the framework directory
cd "$LOCAL_PATH" || exit 1

# Check for last update
LAST_UPDATE_FILE="$LOCAL_PATH/.last_update"
if [ -f "$LAST_UPDATE_FILE" ]; then
    LAST_UPDATE=$(cat "$LAST_UPDATE_FILE")
    NOW=$(date +%s)
    if [ $((NOW - LAST_UPDATE)) -lt "$UPDATE_CHECK_INTERVAL" ]; then
        exit 0 # Don't check if updated recently
    fi
fi

# Check for updates efficiently
log_message "${MESSAGES["update_check"]}"
git_command remote update &> /dev/null

LOCAL=$(git_command rev-parse HEAD)
REMOTE=$(git_command rev-parse @{u})

if [ "$LOCAL" != "$REMOTE" ]; then
    log_message "${MESSAGES["updates_found"]}"
    if perform_update; then
        log_message "${MESSAGES["update_success"]}"
    else
        log_message "${MESSAGES["update_error"]}"
    fi
fi

# Update the timestamp of the last check
date +%s > "$LAST_UPDATE_FILE"