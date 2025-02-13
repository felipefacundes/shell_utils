set -gx SHELL_UTILS_AUTO_UPDATE 0

# SHELL_UTILS AUTO UPDATE
if test "$SHELL_UTILS_AUTO_UPDATE" -eq 1
    ~/.shell_utils/scripts/shell_utils_upgrade.sh
end