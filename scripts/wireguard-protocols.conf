#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

# ANSI color variables
YELLOW='\e[1;33m'
GREEN='\e[1;32m'
RED='\e[1;31m'
NC='\e[0m' # No Color
temp_log="/tmp/${0##*/}.disable_wireguard.log"

# Check if the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${YELLOW}This script must be run as root. Use sudo.${NC}"
    exit 1
fi

# Directory where WireGuard .conf files are located
WG_DIR="/etc/wireguard"
if [ ! -d "$WG_DIR" ]; then
    echo -e "${YELLOW}Directory $WG_DIR not found.${NC}"
    exit 1
fi

# List all .conf files in the WireGuard directory
CONF_FILES=($(ls "$WG_DIR"/*.conf 2>/dev/null))

if [ ${#CONF_FILES[@]} -eq 0 ]; then
    echo -e "${YELLOW}No .conf files found in $WG_DIR.${NC}"
    exit 1
fi

# Prepare options for whiptail
OPTIONS=()
for file in "${CONF_FILES[@]}"; do
    OPTIONS+=("$(basename "$file")" "")
done

# Show interactive menu
SELECTED_CONF=$(whiptail --title "WireGuard Configurations" --menu "Choose a configuration to activate:" 15 60 6 "${OPTIONS[@]}" 3>&1 1>&2 2>&3)

if [ -z "$SELECTED_CONF" ]; then
    echo -e "${YELLOW}No configuration selected. Script will exit.${NC}"
    exit 0
fi

# Remove .conf extension from filename
CONF_NAME="${SELECTED_CONF%.*}"

deactivate_interface() {
	echo -e "${YELLOW}To deactivate the connection, run:${NC}"
	echo -e "${GREEN}  sudo wg-quick down $1${NC}" | tee -a "$temp_log"
}

# Activate WireGuard connection
echo -e "${GREEN}Executing: sudo wg-quick up $CONF_NAME${NC}"
sudo wg-quick up "$CONF_NAME" || {
    echo -e "${RED}Error: Failed to activate WireGuard interface${NC}"
	deactivate_interface "\"interface name\""; exit 1
}

# Show final message
echo -e "${YELLOW}\nWireGuard connection successfully activated using $SELECTED_CONF${NC}"
deactivate_interface "$CONF_NAME"