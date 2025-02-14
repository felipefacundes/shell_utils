#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
SHELL_UTILS CHECK UPDATE
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
    )
else
    MESSAGES=(
        ["framework_not_found"]="Shell Utils directory not found. Cloning repository..."
        ["repo_clone_error"]="Error cloning repository"
        ["update_check"]="Checking for updates..."
        ["updates_found"]="New updates found. Updating..."
        ["update_success"]="Shell Utils successfully updated!"
        ["update_error"]="Error updating Shell Utils"
    )
fi

GITHUB_REPO="felipefacundes/shell_utils"
LOCAL_PATH="${HOME}/.shell_utils"
UPDATE_LOCK_FILE="/tmp/shell_utils_update.lock"
UPDATE_CHECK_INTERVAL=3600  # Interval in seconds (1 hour)

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Checks if an update is already in progress
if [ -f "$UPDATE_LOCK_FILE" ]; then
    if [ $(($(date +%s) - $(stat -c %Y "$UPDATE_LOCK_FILE"))) -lt 300 ]; then
        exit 0  # Exit if an update was checked in the last 5 minutes
    fi
fi

# Create lock file
touch "$UPDATE_LOCK_FILE"

# Check if the local directory exists
if [ ! -d "$LOCAL_PATH" ]; then
    log_message "${MESSAGES["framework_not_found"]}"
    git clone "https://github.com/$GITHUB_REPO.git" "$LOCAL_PATH"
    if [ $? -ne 0 ]; then
        log_message "${MESSAGES["repo_clone_error"]}"
        rm "$UPDATE_LOCK_FILE"
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
        rm "$UPDATE_LOCK_FILE"
        exit 0  # Don't check if updated recently
    fi
fi

# Save the current commit hash
CURRENT_HASH=$(git rev-parse HEAD)

# Try pulling the latest changes
log_message "${MESSAGES["update_check"]}"
git remote update &> /dev/null
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u})

if [ "$LOCAL" != "$REMOTE" ]; then
    log_message "${MESSAGES["updates_found"]}"
    
    # Backup local configurations if necessary
    if [ -f "config.local" ]; then
        cp config.local config.local.backup
    fi
    
    # Update the repository
    git pull
    if [ $? -eq 0 ]; then
        log_message "${MESSAGES["update_success"]}"
        
        # Restore local configurations if necessary
        if [ -f "config.local.backup" ]; then
            mv config.local.backup config.local
        fi
        
        # Run post-update script if exists
        if [ -f "post_update.sh" ]; then
            bash post_update.sh
        fi
    else
        log_message "${MESSAGES["update_error"]}"
        git reset --hard "$CURRENT_HASH"
    fi

fi

# Update the timestamp of the last check
date +%s > "$LAST_UPDATE_FILE"

# Remove the lock file
rm "$UPDATE_LOCK_FILE"