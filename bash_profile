#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

# Exit if not running in a TTY or if stdin is not a terminal
{ [[ ! -t 0 ]] || ! tty >/dev/null 2>&1; } && exit
[[ "${XDG_SESSION_TYPE,,}" != "tty" ]] && exit

dms=("sddm" "lightdm" "gdm" "slim" "xdm" "lxdm" "wdm")
running_dm=""

for dm in "${dms[@]}"; do
    # Using pgrep as it's more reliable and handles process names better
    if pgrep -x "$dm" > /dev/null 2>&1; then
        running_dm="$dm"
        echo -e "${bred}WARNING: ${running_dm^^} display manager is currently running.${color_off}"
        echo "This script performs better when display managers are temporarily disabled."
        echo -e "${bred} To override warnings and continue, use the 'select-wm' command.${color_off}"
        exit
    fi
done

temp_log=/tmp/profile-with-select-wm.log
# Save original stderr to file descriptor 3
exec 3>&2
# Redirect stderr to log file
exec 2>>"${temp_log}"

### THEMES
# Export GTK theme configuration
GTK_THEME="$GTK_THEME"; export GTK_THEME
GTK_MODULES="$GTK_MODULES"; export GTK_MODULES
XCURSOR_SIZE="$XCURSOR_SIZE"; export XCURSOR_SIZE
XCURSOR_THEME="$XCURSOR_THEME"; export XCURSOR_THEME

### KEYBOARD
# Set keyboard layout to Brazilian Portuguese
export XKB_DEFAULT_LAYOUT=br
# Configure Alt+Shift to toggle keyboard layout
export XKB_DEFAULT_OPTIONS=grp:alt_shift_toggle

# ANSI Color codes for terminal output
color_off='\033[0m'
black='\033[0;30m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
bblack='\033[1;30m'
bred='\033[1;31m'
bgreen='\033[1;32m'
byellow='\033[1;33m'
bblue='\033[1;34m'
bpurple='\033[1;35m'
bcyan='\033[1;36m'
bwhite='\033[1;37m'
iblack='\033[0;90m'
ired='\033[0;91m'
igreen='\033[0;92m'
iyellow='\033[0;93m'
iblue='\033[0;94m'
ipurple='\033[0;95m'
icyan='\033[0;96m'
iwhite='\033[0;97m'

# Array of ANSI colors for cycling through WM list
ansi_colors=("$bwhite" "$bgreen" "$byellow" "$bcyan" "$ipurple" "$iyellow" "$cyan" "$iwhite" "$bblue" "$ired" "$igreen" "$bpurple" "$icyan" "$iyellow")

# Uncomment for VSYNC control (can improve performance but may cause screen tearing)
#export vblank_mode=0
#export __GL_SYNC_TO_VBLANK=0

# Export SSH authentication socket
export SSH_AUTH_SOCK

# Reference to this file for re-sourcing
file=~/.bash_profile

# Directory to store window manager logs
export wms_logs_dir="${HOME}/.WMs_logs_dir"
# Get current size of logs directory in KB
wms_logs_dir_size=$(du "${wms_logs_dir}" 2>/dev/null | awk '{print $1}')

# Create logs directory if it doesn't exist
if [ ! -d "${wms_logs_dir}" ]; then
    mkdir -p "${wms_logs_dir}"
fi
 
# Clean up large log files if directory exceeds 2GB
if [ "${wms_logs_dir_size}" -gt 2097152 ]; then
    # Find and remove log files larger than 100MB
    find "${wms_logs_dir}" -type f \( -name "*.log" \) -size +100M -exec rm {} \; > /dev/null 2>&1 &
fi

# Generate systemd boot analysis log (runs in background)
(systemd-analyze blame > ~/.sysAnalyze) > /dev/null 2>&1

# Enable Wayland support for Mozilla applications if running Wayland
[[ "$XDG_SESSION_TYPE" = "wayland" ]] && export MOZ_ENABLE_WAYLAND=1

# Fix XDG user directories - recreate if Pictures directory is missing
[[ ! -d ~/Pictures ]] && rm ~/.config/user-dirs.dirs && LANG=en xdg-user-dirs-update > /dev/null 2>&1

# Clean up and create fresh startx log file
rm -f ~/.startx_log
touch ~/.startx_log
clear

# Function to display countdown and clear screen before exit
local_count() {
    echo -e "${bgreen}Exiting:${color_off}"
    for i in {1..2}; do
        echo -n "${i}. "
        sleep 0.4
    done
    clear
}

# Function to start Wayland window managers with appropriate environment variables
wm_wayland() {
    # Intel GPU vendor library (specific to Intel graphics)
    export __GLX_VENDOR_LIBRARY_NAME=intel
    # Input method configuration for uim (Universal Input Method)
    export GTK_IM_MODULE=uim 
    export QT_IM_MODULE=uim 
    export XMODIFIERS=@im=uim 
    # Set current desktop environment for compatibility
    export XDG_CURRENT_DESKTOP="${wm_wayland}" 
    # Specify which autostart environments to support
    export WB_AUTOSTART_ENVIRONMENT=GNOME:KDE 
    # Force Wayland backend for GTK applications
    export GDK_BACKEND=wayland 
    # Uncomment for Qt Wayland support
    #export QT_QPA_PLATFORM=wayland
    # Use Kvantum theme for Qt applications (alternative: gtk2 which requires qt5-styleplugins)
    export QT_STYLE_OVERRIDE=kvantum
    # Disable hardware cursors (fixes cursor issues on some hardware)
    export WLR_NO_HARDWARE_CURSORS=1 
    # Enable Wayland support for Mozilla applications
    export MOZ_ENABLE_WAYLAND=1 
    # Note: MOZ_USE_XINPUT2=1 causes crashes, so it's commented out
    #export MOZ_USE_XINPUT2=1
    # Set session type to Wayland for proper detection
    export XDG_SESSION_TYPE=wayland 
    # Uncomment for DBus session socket (alternative DBus setup)
    #/usr/bin/dbus-daemon --session --address=unix:path=/tmp/dbus-session-socket &
    #export DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/dbus-session-socket

    # Create log file with timestamp for current WM session
    echo -e "${wm_wayland} log - $(date +'%d/%m/%Y - %T')\n\
------------------------------------\n\n" | tee -a "${wms_logs_dir}"/"${wm_wayland}_$(date +'%d-%m-%Y - %T')".log

    # Parse command into array (handles multi-word commands properly in bash)
    local cmd=($wm_wayland)
  
    # Kill Wayland-related processes before starting new session
    pkill -u $USER -f -e "nwg|waybar|sway|hyprland|river|weston|wlroots|labwc|swww|swaybg|mako|wayfire|wayfire\.ini|wlogout|wlsunset|wbg|wpaperd|waybox|wayvnc|xdg-desktop-portal|xdg-desktop-portal-gtk|xdg-desktop-portal-kde" 2>/dev/null || true

    # Convert WM name to lowercase for case-insensitive comparison
    wm_check="${wm_wayland,,}"
    
    # Special handling for Hyprland with Vulkan renderer
    if [[ "$wm_wayland" =~ "uwsm" ]] && ! command -v uwsm >/dev/null; then
        # Use original stderr (fd 3) to show message
        echo -e "${bred}uwsm not found!${color_off}" >&3
        read -rp "Press enter to continue..." dummy <&0 >&3
        return 1
    elif [[ "$wm_check" == "hyprland" ]]; then
        # Start Hyprland with Vulkan renderer and log output
        env WLR_RENDERER=vulkan start-hyprland "$@" | tee -a "${wms_logs_dir}"/"${wm_wayland}_$(date +'%d-%m-%Y - %T')".log 
    elif [[ "$wm_wayland" == "sway" ]]; then
        # Start Sway with Vulkan renderer and unsupported GPU flag
        env WLR_RENDERER=vulkan sway --unsupported-gpu "$@" | tee -a "${wms_logs_dir}"/"${wm_wayland}_$(date +'%d-%m-%Y - %T')".log 
    else
        # Start other Wayland WMs with Vulkan renderer
        env WLR_RENDERER=vulkan "${cmd[@]}" "$@" | tee -a "${wms_logs_dir}"/"${wm_wayland}_$(date +'%d-%m-%Y - %T')".log 
    fi
}

# Function to save standard/default window manager configuration
standard_wm() {
    standard_wm_conf="${HOME}/.standard_wm.conf"
    # Create config file if it doesn't exist
    [[ ! -f "${standard_wm_conf}" ]] && touch "${standard_wm_conf}"

    # Save Wayland WM configuration (protocol=1 indicates Wayland)
    if [ -n "${wm_wayland}" ]; then
        echo 'protocol=1' | tee "${standard_wm_conf}" > /dev/null 2>&1
        echo "swm=${wm_wayland}" | tee -a "${standard_wm_conf}" > /dev/null 2>&1
    fi

    # Save X11 WM configuration (protocol=2 indicates X11)
    if [ -n "${start_wm}" ]; then
        echo 'protocol=2' | tee "${standard_wm_conf}" > /dev/null 2>&1
        echo "swm=${start_wm}" | tee -a "${standard_wm_conf}" > /dev/null 2>&1
    fi
}

# Function to dynamically list and display window managers from a directory
list_wms() {
    local dir="$1"          # Directory containing .desktop files
    local protocol_name="$2" # Display name (Wayland or X11)
    
    # Check if directory exists
    if [ ! -d "$dir" ]; then
        echo -e "${bred}Directory not found: ${dir}${color_off}"
        return 1
    fi
    
    # Get list of .desktop files (basename only)
    local wms=($(ls "$dir"/*.desktop 2>/dev/null | xargs -n1 basename 2>/dev/null))
    local count=${#wms[@]}
    
    # Check if any WMs were found
    if [ "$count" -eq 0 ]; then
        echo -e "${bred}No window managers found in ${dir}${color_off}"
        return 1
    fi
    
    # Display menu header
    echo -e "\n${byellow}Choose an Option:\n"
    
    # Display each WM with a different color from the ANSI colors array
    # BASH FIX: Use C-style for loop instead of brace expansion
    for ((i=0; i<count; i++)); do
        local wm_file="${wms[$i]}"  # Bash arrays are 0-indexed
        local wm_name="${wm_file%.desktop}"
        local color_index=$((i % ${#ansi_colors[@]}))
        local color="${ansi_colors[$color_index]}"  # Bash arrays are 0-indexed
        
        echo -e "${color}${i} - ${wm_name} - ${protocol_name}${color_off}"
    done
    
    # Add "Back to Menu" option with red color
    local back_index=$count
    local back_color_index=$((back_index % ${#ansi_colors[@]}))
    local back_color="${ansi_colors[$back_color_index]}"
    echo -e "${bred}${back_index} - Back Menu${color_off}"
    
    return 0
}

# Function to get Exec value from .desktop file
get_wm_exec() {
    local dir="$1"      # Directory containing the .desktop file
    local wm_file="$2"  # Name of the .desktop file
    
    # Extract Exec line from .desktop file using grep with Perl regex
    # The (?<=Exec=) is a positive lookbehind to match everything after "Exec="
    local exec_value=$(grep -oP '(?<=Exec=).*' "$dir/$wm_file" 2>/dev/null | head -n1)
    echo "$exec_value"
}

# Display main menu with color-coded options
echo -e "\n${byellow}Choose an Option:\n"
echo -e "${bpurple}1 - Wayland"
echo -e "${bwhite}2 - X11"
echo -e "${bcyan}3 - Terminal"
echo -e "${bgreen}h - Help"
echo -e "${bwhite}e - Exit"
echo -e "${byellow}r - Reboot"
echo -e "${bred}s - Shutdown${color_off}"
echo
read -r option
echo

clear

# Check if xorg-xinit is installed
install_xinit() {
    if ! command -v startx &> /dev/null; then
        echo -e "${byellow}xorg-xinit is not installed. Installing now...${color_off}"
        
        # Detect distribution and install appropriately
        if [ -f /etc/arch-release ]; then
            sudo pacman -Sy xorg-xinit --noconfirm
        elif [ -f /etc/debian_version ]; then
            sudo apt update && sudo apt install xorg-xinit -y
        elif [ -f /etc/fedora-release ]; then
            sudo dnf install xorg-xinit -y
        else
            echo -e "${bred}Unsupported distribution. Please install xorg-xinit manually.${color_off}"
            exit 1
        fi

        clear        
        echo "${bgreen}xorg-xinit installation completed.${color_off}"
    fi
}

check_xinitrc_config() {
    local xinitrc_original="$HOME/.shell_utils/xinitrc"
    local xinitrc_current="$HOME/.xinitrc"
    local md5_original=""
    local md5_current=""
    
    # Check if the original xinitrc exists
    if [ ! -f "$xinitrc_original" ]; then
        echo "Original xinitrc template not found: $xinitrc_original"
        exit 1
    fi
    
    # Calculate MD5 checksums
    if [ -f "$xinitrc_current" ]; then
        md5_current=$(md5sum "$xinitrc_current" | cut -d' ' -f1)
    else
        echo "No ~/.xinitrc file found. Script will use default configuration."
        if [ -f "$xinitrc_original" ]; then
            echo "Original xinitrc template found in: $xinitrc_original"
        fi
        exit 0
    fi
    
    md5_original=$(md5sum "$xinitrc_original" | cut -d' ' -f1)
    
    # Compare checksums
    if [ "$md5_current" != "$md5_original" ]; then
        echo -e "\n${bred}WARNING: ~/.xinitrc differs from the script's base template.${color_off}"
        echo "MD5 checksum mismatch detected:"
        echo "  Original template: $md5_original"
        echo "  Current ~/.xinitrc: $md5_current"
        echo ""
        echo "This script may not function correctly because:"
        echo "1. Your current ~/.xinitrc has been modified from the expected template"
        echo "2. Missing or altered configuration may cause X11 session failures"
        echo "3. Environment variables or execution commands may be incorrect"
        echo ""
        echo "Recommended actions:"
        echo "  - Backup current: cp ~/.xinitrc ~/.xinitrc.backup"
        echo "  - Restore template: cp ~/.shell_utils/xinitrc ~/.xinitrc"
        echo "  - Review differences: diff ~/.xinitrc ~/.shell_utils/xinitrc"
        echo ""
        echo -e "${bred}Continuing in 3 seconds with potentially unstable configuration...${color_off}"
        sleep 3
    fi
}

help() {
    ! command -v less >/dev/null && echo -e "${bred}Install less${color_off}\n" && sleep 5

    cat <<EOF | { echo -e "$(cat)" | less -R; }

${bcyan}NAME${color_off}
    select-wm - Window Manager selector for X11, Wayland and Terminal sessions

${bcyan}SYNOPSIS${color_off}
    ./select-wm [OPTION]

${bcyan}DESCRIPTION${color_off}
    This script provides an interactive menu to select and launch different
    window managers and display sessions. It supports:
    
    ${bgreen}•${color_off} ${green}Wayland${color_off} sessions from /usr/share/wayland-sessions/
    ${bgreen}•${color_off} ${green}X11${color_off} sessions from /usr/share/xsessions/
    ${bgreen}•${color_off} ${green}Terminal${color_off} sessions (shell only)
    ${bgreen}•${color_off} ${green}System${color_off} operations (reboot/shutdown)

    The script automatically detects and handles display manager conflicts,
    provides colorful interface feedback, and maintains session logs.

${bcyan}MAIN MENU OPTIONS${color_off}
    ${bpurple}1, way, wayland, w${color_off}
        Launch a Wayland window manager session
    
    ${bwhite}2, x11, x${color_off}
        Launch an X11 window manager session (requires xorg-xinit)
    
    ${bcyan}3, terminal, t${color_off}
        Start a terminal session without window manager
    
    ${byellow}r, reboot${color_off}
        Reboot the system (if pacman is not running)
    
    ${bred}s, shutdown, S, p, P, poweroff${color_off}
        Shutdown the system (if pacman is not running)

${bcyan}WM SELECTION MENU${color_off}
    After choosing ${green}Wayland${color_off} or ${green}X11${color_off}, a numbered list of available
    window managers is displayed with ${bwhite}color-coded${color_off} entries.
    
    ${yellow}Example:${color_off}
        0 - sway - Wayland
        1 - hyprland - Wayland
        2 - back_menu
    
    ${bred}IMPORTANT:${color_off} The last option always returns to the main menu.

${bcyan}AUTOMATIC SESSION RESUMPTION${color_off}
    If launched without options and ${green}~/.standard_wm.conf${color_off} exists,
    the script automatically resumes the last used session:
    
    ${yellow}Protocol detection:${color_off}
        ${cyan}protocol=1${color_off} → Wayland session
        ${cyan}protocol=2${color_off} → X11 session
    
    ${yellow}WM specification:${color_off}
        ${cyan}swm=<window_manager_command>${color_off}

${bcyan}ENVIRONMENT VARIABLES${color_off}
    ${green}GTK_THEME${color_off}, ${green}XCURSOR_THEME${color_off}
        GUI theme configuration
    
    ${green}XKB_DEFAULT_LAYOUT${color_off}, ${green}XKB_DEFAULT_OPTIONS${color_off}
        Keyboard layout (default: br with Alt+Shift toggle)
    
    ${green}MOZ_ENABLE_WAYLAND${color_off}
        Auto-enabled for Wayland sessions
    
    ${green}WLR_RENDERER=vulkan${color_off}
        Used for Wayland compositors (Hyprland, Sway, etc.)

${bcyan}LOG FILES${color_off}
    ${green}~/.WMs_logs_dir/${color_off}
        Window manager session logs (auto-cleaned when >2GB)
    
    ${green}/tmp/select-wm.log${color_off}
        Script execution log
    
    ${green}~/.startx_log${color_off}
        X11 startx session log

${bcyan}DEPENDENCIES${color_off}
    ${yellow}Required for X11:${color_off} xorg-xinit (auto-installed if missing)
    ${yellow}Recommended:${color_off} Display manager temporarily disabled for best performance

${bcyan}DISPLAY MANAGER WARNING${color_off}
    ${bred}WARNING:${color_off} Running display managers (SDDM, LightDM, GDM, etc.)
    may cause conflicts. The script detects and warns about active DMs.
    
    ${yellow}Temporary disable:${color_off}
        sudo systemctl stop <display_manager>
        sudo systemctl disable <display_manager>
    
    ${yellow}Re-enable later:${color_off}
        sudo systemctl enable <display_manager>
        sudo systemctl start <display_manager>

${bcyan}EXAMPLES${color_off}
    ${yellow}Interactive selection:${color_off}
        ./select-wm          # Shows main menu
    
    ${yellow}Direct Wayland selection:${color_off}
        ./select-wm wayland  # Goes directly to Wayland WM menu
    
    ${yellow}Direct X11 selection:${color_off}
        ./select-wm x11      # Goes directly to X11 WM menu
    
    ${yellow}Terminal only:${color_off}
        ./select-wm terminal # Starts shell session

${bcyan}TROUBLESHOOTING${color_off}
    ${bred}1. Script exits immediately${color_off}
        ${yellow}Cause:${color_off} Running in graphical environment
        ${yellow}Fix:${color_off} Run in text console (Ctrl+Alt+F2-F6)
    
    ${bred}2. WM doesn't start properly${color_off}
        ${yellow}Check:${color_off} ~/.WMs_logs_dir/ for error logs
        ${yellow}Check:${color_off} Display manager conflicts
    
    ${bred}3. Missing .xinitrc template${color_off}
        ${yellow}Fix:${color_off} Ensure ~/.shell_utils/xinitrc exists
    
    ${bred}4. Keyboard layout wrong${color_off}
        ${yellow}Fix:${color_off} Modify XKB_DEFAULT_LAYOUT in script

${bcyan}SEE ALSO${color_off}
    startx(1), systemctl(1), xinit(1), journalctl(1)

${bcyan}AUTHOR${color_off}
    Felipe Facundes

${bcyan}LICENSE${color_off}
    GPLv3

EOF
}

main() {
    # Main menu case statement
    case "$option" in
        "1"|"way"|"wayland"|"w")
            # Wayland window managers menu
            wayland_dir="/usr/share/wayland-sessions"
            
            # Check if Wayland sessions directory exists
            if [ ! -d "$wayland_dir" ]; then
                echo -e "${bred}Wayland sessions directory not found!${color_off}"
                local_count
                source "${file}"
                exit
            fi
            
            # Get list of Wayland WMs (basename only)
            wayland_wms=($(ls "$wayland_dir"/*.desktop 2>/dev/null | xargs -n1 basename 2>/dev/null))
            wayland_count=${#wayland_wms[@]}
            
            # Display Wayland WMs using the list_wms function
            list_wms "$wayland_dir" "Wayland"
            
            echo
            read -r WM
            echo
            
            # Check if user selected "Back Menu" option
            if [ "$WM" = "$wayland_count" ]; then
                local_count
                source "${file}"
                exit
            fi
            
            # Validate input is within valid range
            if [ "$WM" -ge 0 ] && [ "$WM" -lt "$wayland_count" ]; then
                # Get selected WM file - BASH FIX: arrays are 0-indexed
                selected_wm_file="${wayland_wms[$WM]}"
                # Get Exec command from .desktop file
                wm_wayland=$(get_wm_exec "$wayland_dir" "$selected_wm_file")
                
                # Save as standard WM and start Wayland session
                standard_wm
                if ! wm_wayland >>"${temp_log}" 2>>"${temp_log}"; then
                    pkill -9 -u $USER
                fi
                local_count
                exit
            else
                echo -e "${bred}Wrong Option!${color_off}"
                local_count
                source "${file}"
            fi
        ;;
        "2"|"x11"|"x")
            # X11 window managers menu
            x11_dir="/usr/share/xsessions"
            
            install_xinit
            check_xinitrc_config
            # Check if X11 sessions directory exists
            if [ ! -d "$x11_dir" ]; then
                echo -e "${bred}X11 sessions directory not found!${color_off}"
                local_count
                source "${file}"
                exit
            fi
            
            # Get list of X11 WMs (basename only)
            x11_wms=($(ls "$x11_dir"/*.desktop 2>/dev/null | xargs -n1 basename 2>/dev/null))
            x11_count=${#x11_wms[@]}
            
            # Display X11 WMs using the list_wms function
            list_wms "$x11_dir" "X11"
            
            echo
            read -r WM
            echo
            
            # Check if user selected "Back Menu" option
            if [ "$WM" = "$x11_count" ]; then
                local_count
                source "${file}"
                exit
            fi
            
            # Validate input is within valid range
            if [ "$WM" -ge 0 ] && [ "$WM" -lt "$x11_count" ]; then
                # Get selected WM file - BASH FIX: arrays are 0-indexed
                selected_wm_file="${x11_wms[$WM]}"
                # Get Exec command from .desktop file
                export start_wm=$(get_wm_exec "$x11_dir" "$selected_wm_file")
                
                # Save as standard WM and start X11 session with startx
                standard_wm
                [ "$XDG_VTNR" ] && startx | tee -a ~/.startx_log > /dev/null 2>&1
                local_count
                exit
            else
                echo -e "${bred}Wrong Option!${color_off}"
                local_count
                source "${file}"
            fi
        ;;
        "3"|"terminal"|"t")
            # Terminal option - stay in shell without starting a window manager
            # Restore original stderr from fd 3
            exec 2>&3
            clear
            bash
            local_count
            source "${file}"
        ;;
        "h"|"help")
            help
            clear
            local_count
            source "${file}"
        ;;
        "e"|"exit")
            exit
        ;;
        "r"|"reboot")
            # Reboot - check if pacman is not running
            if ! pidof pacman >/dev/null; then
                systemctl reboot 2>/dev/null
            else
                echo -e "${bred}Cannot reboot while pacman is running${color_off}"
                sleep 2
            fi
        ;;
        "s"|"shutdown"|"S"|"p"|"P"|"poweroff")
            # Shutdown - check if pacman is not running
            if ! pidof pacman >/dev/null; then
                systemctl poweroff 2>/dev/null
            else
                echo -e "${bred}Cannot shutdown while pacman is running${color_off}"
                sleep 2
            fi
        ;;
        *)
            # Default option - load saved standard WM from config file
            # Read protocol type from config file (1=Wayland, 2=X11)
            if [ -f ~/.standard_wm.conf ]; then
                protocol=$(cat ~/.standard_wm.conf | head -n1 | cut -f2 -d'=')
                # Read saved WM name from config file
                swm=$(cat ~/.standard_wm.conf | tail -n1 | cut -f2 -d'=')

                if [ "${protocol}" = 1 ]; then
                    # Start saved Wayland WM from config
                    wm_wayland="${swm}"
                    if ! wm_wayland >>"${temp_log}" 2>>"${temp_log}"; then
                        pkill -9 -u $USER
                        exit
                    fi
                    local_count
                elif [ "${protocol}" = 2 ]; then
                    # Start saved X11 WM from config
                    export start_wm="${swm}"
                    [ "$XDG_VTNR" ] && startx | tee -a ~/.startx_log > /dev/null 2>&1
                    local_count
                else
                    # Invalid protocol in config file or no config found
                    echo -e "${bred}Wrong Option!${color_off}"
                    local_count
                    source "${file}"
                fi
            else
                echo -e "${bred}No config file found!${color_off}"
                local_count
                source "${file}"
            fi
        ;;
    esac
}

main 2>>"${temp_log}"
