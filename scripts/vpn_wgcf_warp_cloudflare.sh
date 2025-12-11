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
temp_log="/tmp/${0##*/}.disable_wireguard.log"
arg="$1"

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

success() {
    # Verification
    echo -e "\n${BLUE}Verifying connection! Wait 25 seconds...${NC}"
    curl -s --connect-timeout 20 https://www.cloudflare.com/cdn-cgi/trace/ | grep warp || {
        echo -e "${YELLOW}Warning: Could not verify WARP connection${NC}"
    }

    echo -e "\n${YELLOW}To disconnect run:${NC}"
    echo -e "${SUDO_COLOR}sudo${NC} ${GREEN}wg-quick down wgcf-profile${NC}" | tee -a "$temp_log"
}

error_warp_message() { echo -e "${RED}Error: Failed to activate WireGuard interface${NC}"; }

help() {
    echo -e "\n${GREEN}Usage: ${0##*/} [OPTION]${NC}"
    echo -e "Manage WGCF/WireGuard connection\n"
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  -d,             Disconnect WGCF/WireGuard"
    echo -e "  -h, --help      Display this help message\n"
    echo -e "${YELLOW}Description:${NC}"
    echo -e "  This script manages WGCF/WireGuard connections. It will automatically"
    echo -e "  set up the profile if not already configured, enable systemd-resolved"
    echo -e "  for DNS, and establish a connection to Cloudflare WARP.\n"
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  ${0##*/}                    Connect to WGCF/WireGuard"
    echo -e "  ${0##*/} -up, --connect     Connect to WGCF/WireGuard"
    echo -e "  ${0##*/} -d, --disconnect   Disconnect from WGCF/WireGuard"
    echo -e "  ${0##*/} -h, --help         Show this help message\n"
    echo -e "${YELLOW}Notes:${NC}"
    echo -e "  • Requires wgcf to be installed"
    echo -e "  • Uses systemd-resolved for DNS resolution"
    echo -e "  • Automatically registers/generates profile if needed\n"
    exit 0
}

connection_test() {
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
}

connection_up() {
    # Activate connection
    connection_test

    echo -e "${YELLOW}Activating WGCF connection...${NC}"
    sudo wg-quick up wgcf-profile || {
        error_warp_message
        sudo wg-quick down wgcf-profile >/dev/null 2>&1 || exit 1
        echo -e "\n${YELLOW}Reconnecting...${NC}\n"
        sudo wg-quick up wgcf-profile || { error_warp_message && exit 1; }
        success && exit 1
    }
    success && exit 0
}

if [[ "$arg" == "-h" || "$arg" == "--help" ]]; then
    help
fi

if [[ "$arg" == "-d" || "$arg" == "--disconnect" ]]; then
    if sudo wg-quick down wgcf-profile 2>/dev/null; then
        echo -e "\n${YELLOW}WGCF successfully disconnected. Command executed:${NC}"
        echo -e "${SUDO_COLOR}sudo${NC} ${GREEN}wg-quick down wgcf-profile${NC}" | tee -a "$temp_log"
        exit 0
    else
        echo -e "${RED}wg-quick: 'wgcf-profile' is not a WireGuard interface${NC}"
        exit 1
    fi
fi

if [[ "$arg" == "-up" || "$arg" == "--connect" ]]; then
    connection_up
fi

if [[ "$arg" == "$arg" ]]; then
    echo -e "${RED}Error: Unrecognized argument '$arg'${NC}\n"
    help
fi

connection_up
