#!/usr/bin/env zsh
# License: GPLv3
# Credits: Felipe Facundes

# Exit if not running in a TTY or if stdin is not a terminal
{ [[ ! -t 0 ]] || ! tty >/dev/null 2>&1; } && exit
[[ "${XDG_SESSION_TYPE}" != [Tt][Tt][Yy] ]] && exit

exec 2>>/tmp/profile-with-select-wm.log

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
if [[ -n $ZSH_VERSION ]]; then
    file=~/.zprofile
elif [[ -n $ZSH_VERSION ]]; then
    file=~/.bash_profile
fi

# Directory to store window manager logs
export wms_logs_dir="${HOME}/.WMs_logs_dir"
# Get current size of logs directory in KB
wms_logs_dir_size=$(du "${wms_logs_dir}" | awk '{print $1}')

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
rm ~/.startx_log
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

    # Parse command into array (handles multi-word commands properly in zsh vs bash)
    if [[ -n "$ZSH_VERSION" ]]; then
        local cmd=("${(@s: :)wm_wayland}")
    else
        local cmd=(${wm_wayland})
    fi
  
    # kills everything before starting, if there is any active process
    pkill -u $USER -f -e "nwg|waybar|sway|hyprland|river|weston|wlroots|labwc|swww|swaybg|mako|wayfire|wayfire\.ini|wlogout|wlsunset|wbg|wpaperd|waybox|wayvnc|xdg-desktop-portal|xdg-desktop-portal-gtk|xdg-desktop-portal-kde"

    # Convert WM name to lowercase for case-insensitive comparison
    typeset -l wm_check="$wm_wayland"
    
    # Special handling for Hyprland with Vulkan renderer
    if [[ "$wm_check" == "hyprland" ]]; then
        # Start Hyprland with Vulkan renderer and log output
        env WLR_RENDERER=vulkan start-hyprland "$@" | tee -a "${wms_logs_dir}"/"${wm_wayland}_$(date +'%d-%m-%Y - %T')".log &
        disown
    elif [[ "$wm_wayland" == "sway" ]]; then
        # Start Sway with Vulkan renderer and unsupported GPU flag
        env WLR_RENDERER=vulkan sway --unsupported-gpu "$@" | tee -a "${wms_logs_dir}"/"${wm_wayland}_$(date +'%d-%m-%Y - %T')".log &
        disown
    else
        # Start other Wayland WMs with Vulkan renderer
        env WLR_RENDERER=vulkan "${cmd[@]}" "$@" | tee -a "${wms_logs_dir}"/"${wm_wayland}_$(date +'%d-%m-%Y - %T')".log & 
        disown
    fi
}

# Function to save standard/default window manager configuration
standard_wm() {
    standard_wm_conf="${HOME}/.standard_wm.conf"
    # Create config file if it doesn't exist
    [[ ! -f "${standard_wm_conf}" ]] && touch "${standard_wm_conf}"

    # Save Wayland WM configuration (protocol=1 indicates Wayland)
    if [ "${wm_wayland}" ]; then
        echo 'protocol=1' | tee "${standard_wm_conf}" > /dev/null 2>&1
        echo -e "swm=${wm_wayland}" | tee -a "${standard_wm_conf}" > /dev/null 2>&1
    fi

    # Save X11 WM configuration (protocol=2 indicates X11)
    if [ "${start_wm}" ]; then
        echo 'protocol=2' | tee "${standard_wm_conf}" > /dev/null 2>&1
        echo -e "swm=${start_wm}" | tee -a "${standard_wm_conf}" > /dev/null 2>&1
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
    for i in {0..$((count-1))}; do
        local wm_file="${wms[$i+1]}"
        local wm_name="${wm_file%.desktop}"
        local color_index=$((i % ${#ansi_colors[@]}))
        local color="${ansi_colors[$color_index+1]}"
        
        echo -e "${color}${i} - ${wm_name} - ${protocol_name}${color_off}"
    done
    
    # Add "Back to Menu" option with red color
    local back_index=$count
    local back_color_index=$((back_index % ${#ansi_colors[@]}))
    local back_color="${ansi_colors[$back_color_index+1]}"
    echo -e "${bred}${back_index} - Back Menu${color_off}"
    
    return 0
}

# Function to get Exec value from .desktop file
get_wm_exec() {
    local dir="$1"      # Directory containing the .desktop file
    local wm_file="$2"  # Name of the .desktop file
    
    # Extract Exec line from .desktop file using grep with Perl regex
    # The (?<=Exec=) is a positive lookbehind to match everything after "Exec="
    local exec_value=$(grep -oP '(?<=Exec=).*' "$dir/$wm_file" | head -n1)
    echo "$exec_value"
}

# Display main menu with color-coded options
echo -e "\n${byellow}Choose an Option:\n"
echo -e "${bpurple}1 - Wayland"
echo -e "${bwhite}2 - X11"
echo -e "${bcyan}3 - Terminal${color_off}"
echo
read -r option
echo

clear

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
            # Get selected WM file (array is 1-indexed, so add 1)
            selected_wm_file="${wayland_wms[$WM+1]}"
            # Get Exec command from .desktop file
            wm_wayland=$(get_wm_exec "$wayland_dir" "$selected_wm_file")
            
            # Save as standard WM and start Wayland session
            standard_wm
            if ! wm_wayland >/dev/null 2>&1; then
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
            # Get selected WM file (array is 1-indexed, so add 1)
            selected_wm_file="${x11_wms[$WM+1]}"
            # Get Exec command from .desktop file
            export start_wm=$(get_wm_exec "$x11_dir" "$selected_wm_file")
            
            # Save as standard WM and start X11 session with startx
            standard_wm
            [ $XDG_VTNR ] && startx | tee -a ~/.startx_log > /dev/null 2>&1
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
        $SHELL
        local_count
        source "${file}"
    ;;
    *)
        # Default option - load saved standard WM from config file
        # Read protocol type from config file (1=Wayland, 2=X11)
        protocol=$(cat ~/.standard_wm.conf | head -n1 | cut -f2 -d'=')
        # Read saved WM name from config file
        swm=$(cat ~/.standard_wm.conf | tail -n1 | cut -f2 -d'=')

        if [ "${protocol}" = 1 ]; then
            # Start saved Wayland WM from config
            wm_wayland="${swm}"
            if ! wm_wayland >/dev/null 2>&1; then
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
    ;;
esac
