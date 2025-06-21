#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

# ANSI color codes
RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color
SUDO_COLOR='\033[1;31m'

# Check if wgcf is installed
if ! command -v wgcf >/dev/null; then
    echo -e "${RED}Error: wgcf is not installed.${NC}"
    echo -e "${YELLOW}Please install wgcf using your package manager:${NC}"
    echo -e "  Debian/Ubuntu: ${SUDO_COLOR}sudo${NC} ${GREEN}apt install wgcf${NC}"
    echo -e "  Arch Linux:    ${SUDO_COLOR}sudo${NC} ${GREEN}pacman -S wgcf${NC}"
    echo -e "  Fedora:        ${SUDO_COLOR}sudo${NC} ${GREEN}dnf install wgcf${NC}"
    echo -e "${YELLOW}Or alternatively via script:${NC}"
    echo -e "  curl -fsSL git.io/wgcf.sh | ${SUDO_COLOR}sudo${NC} ${GREEN}bash${NC}"
    exit 1
fi

# Check and enable systemd-resolved if needed
if ! systemctl is-active --quiet systemd-resolved; then
    echo -e "${YELLOW}Enabling systemd-resolved...${NC}"
    sudo systemctl enable --now systemd-resolved || {
        echo -e "${RED}Error: Failed to enable systemd-resolved. Continuing without DNS configuration...${NC}"
    }
fi

# WireGuard configuration
if ! sudo test -f /etc/wireguard/wgcf-profile.conf; then
	cd /tmp || true
    echo -e "${YELLOW}Setting up WGCF profile...${NC}"
    wgcf register || {
        echo -e "${RED}Error: Failed to register WGCF account${NC}"; exit 1
    }
    wgcf generate || {
        echo -e "${RED}Error: Failed to generate WireGuard config${NC}"; exit 1
    }
    
    sudo mv wgcf-profile.conf /etc/wireguard/ || {
        echo -e "${RED}Error: Failed to move config file${NC}"; exit 1
    }
    rm -f wgcf-account.toml
	cd - || true
fi

success() {
	# Verification
	echo -e "\n${BLUE}Verifying connection! Wait 25 seconds...${NC}"
	curl -s --connect-timeout 20 https://www.cloudflare.com/cdn-cgi/trace/ | grep warp || {
		echo -e "${YELLOW}Warning: Could not verify WARP connection${NC}"
	}

	echo -e "\n${YELLOW}To disconnect run:${NC}"
	echo -e "${SUDO_COLOR}sudo${NC} ${GREEN}wg-quick down wgcf-profile${NC}"
}

error_warp_message() { echo -e "${RED}Error: Failed to activate WireGuard interface${NC}"; }

# Activate connection
echo -e "${YELLOW}Activating WGCF connection...${NC}"
sudo wg-quick up wgcf-profile || {
    error_warp_message
	sudo wg-quick down wgcf-profile >/dev/null 2>&1 || exit 1
	echo -e "\n${YELLOW}Reconnecting...${NC}\n"
	sudo wg-quick up wgcf-profile || { error_warp_message && exit 1; }
	success
	exit 1
}

success