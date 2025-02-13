export SHELL_UTILS_AUTO_UPDATE=0

# SHELL_UTILS AUTO UPDATE
if [[ "$SHELL_UTILS_AUTO_UPDATE" -eq 1 ]]; then
    ~/.shell_utils/scripts/shell_utils_upgrade.sh
fi