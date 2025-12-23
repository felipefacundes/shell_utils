#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Hardware Info Script - Collects complete hardware information
DOCUMENTATION

script_version="1.0"

######################
# Configurações
######################

# Informações a serem exibidas
display=(
    'host'
    'distro'
    'kernel'
    'uptime'
    'pkgs'
    'shell'
    'display'
    'wm'
    'theme'
    'icons'
    'font'
    'cursor'
    'terminal'
    'terminal_font'
    'cpu'
    'gpu'
    'memory'
    'swap'
    'disk'
    'ip'
    'battery'
    'locale'
)

# Cores
textcolor="\e[0m"
labelcolor="\e[1;34m"

# Verbose Setting
verbosity=0

# Dependencies check
check_deps() {
    local deps=(
        "dbus: Bluetooth, Player & Media detection"
        "dconf: Needed for values that are only stored in DConf + Fallback for GSettings"
        "ddcutil: Brightness detection of external displays"
        "directx-headers: GPU detection in WSL"
        "glib2: Output for values that are only stored in GSettings"
        "hwdata: GPU output"
        "imagemagick: Image output using sixel or kitty graphics protocol"
        "libdrm: Displays detection"
        "libelf: st term font detection and fast path of systemd version detection"
        "libpulse: Sound detection"
        "libxrandr: Multi monitor support"
        "ocl-icd: OpenCL module"
        "python: Needed for zsh and fish completions"
        "sqlite: Needed for Sqlite integration and Soar packages count"
        "vulkan-icd-loader: Vulkan module & fallback for GPU output"
        "zlib: Faster image output when using kitty graphics protocol"
    )
    
    echo "Dependências necessárias para funcionalidades detalhadas:"
    echo "=========================================================="
    
    for dep in "${deps[@]}"; do
        local pkg="${dep%%:*}"
        local desc="${dep#*:}"
        
        if command -v "$pkg" >/dev/null 2>&1 || pkg-config --exists "$pkg" 2>/dev/null; then
            echo "✓ $pkg: $desc [INSTALADO]"
        else
            echo "✗ $pkg: $desc [NÃO INSTALADO]"
        fi
    done
}

# Se o argumento -dep for passado
if [[ "$1" == "-dep" ]]; then
    check_deps
    exit 0
fi

#############################################
#### CODE No need to edit past here CODE ####
#############################################

# Detect which awk to use
if [[ -z "${AWK}" ]]; then
    for awk in awk gawk mawk; do
        if command -v "${awk}" >/dev/null; then
            AWK="${awk}"
            break
        fi
    done
fi

if ! command -v "${AWK}" >/dev/null; then
    echo "Erro: Nenhum interpretador awk disponível."
    exit 1
fi

# Static Variables
c0=$'\033[0m' # Reset Text
bold=$'\033[1m' # Bold Text
underline=$'\033[4m' # Underline Text
display_index=0

verboseOut () {
    if [[ "$verbosity" -eq "1" ]]; then
        printf '\033[1;31m:: \033[0m%s\n' "$1"
    fi
}

errorOut () {
    printf '\033[1;37m[[ \033[1;31m! \033[1;37m]] \033[0m%s\n' "$1"
}

####################
# Detection Functions
####################

# Detecção de Distribuição
detectdistro () {
    if [[ -z "${distro}" ]]; then
        distro="Unknown"
        if type -p lsb_release >/dev/null 2>&1; then
            distro=$(lsb_release -si)
            distro_release=$(lsb_release -sr)
            distro_codename=$(lsb_release -sc)
        elif [[ -f /etc/os-release ]]; then
            source /etc/os-release
            distro="${NAME}"
            distro_release="${VERSION_ID}"
            distro_codename="${VERSION_CODENAME}"
        elif [[ -f /etc/arch-release ]]; then
            distro="Arch Linux"
        elif [[ -f /etc/debian_version ]]; then
            distro="Debian"
            distro_release=$(cat /etc/debian_version)
        fi
    fi
    
    # Arquitetura
    arch=$(uname -m)
    verboseOut "Detectando distribuição... encontrada como '${distro} ${arch}'"
}

# Detecção de Host e Usuário
detecthost () {
    myUser=${USER}
    myHost=${HOSTNAME}
    if [[ -z "$USER" ]]; then
        myUser=$(whoami)
    fi
    
    # Informações do modelo do laptop
    if [[ -f /sys/devices/virtual/dmi/id/product_name ]]; then
        product_name=$(cat /sys/devices/virtual/dmi/id/product_name)
        product_version=$(cat /sys/devices/virtual/dmi/id/product_version 2>/dev/null || echo "")
        host_info="${product_name} (${product_version})"
    else
        host_info="Unknown"
    fi
    verboseOut "Detectando hostname e usuário... encontrado como '${myUser}@${myHost}'"
}

# Detecção de Kernel
detectkernel () {
    kernel=$(uname -r)
    verboseOut "Detectando versão do kernel... encontrada como '${kernel}'"
}

# Detecção de Uptime
detectuptime () {
    if [[ -f /proc/uptime ]]; then
        uptime_seconds=$(awk '{print int($1)}' /proc/uptime)
        days=$((uptime_seconds/86400))
        hours=$(( (uptime_seconds%86400)/3600 ))
        minutes=$(( (uptime_seconds%3600)/60 ))
        
        if [[ $days -gt 0 ]]; then
            uptime="${days}d ${hours}h ${minutes}m"
        elif [[ $hours -gt 0 ]]; then
            uptime="${hours}h ${minutes}m"
        else
            uptime="${minutes}m"
        fi
    else
        uptime="Unknown"
    fi
    verboseOut "Detectando uptime... encontrado como '${uptime}'"
}

# Detecção de Pacotes
detectpkgs () {
    if type -p pacman >/dev/null 2>&1; then
        # Arch Linux
        pkgs=$(pacman -Qq 2>/dev/null | wc -l)
        pkgs_manager="pacman"
    elif type -p dpkg >/dev/null 2>&1; then
        # Debian/Ubuntu
        pkgs=$(dpkg -l | grep -c '^ii')
        pkgs_manager="dpkg"
    elif type -p rpm >/dev/null 2>&1; then
        # Red Hat/Fedora
        pkgs=$(rpm -qa | wc -l)
        pkgs_manager="rpm"
    elif type -p xbps-query >/dev/null 2>&1; then
        # Void Linux
        pkgs=$(xbps-query -l | wc -l)
        pkgs_manager="xbps"
    elif type -p nix-env >/dev/null 2>&1; then
        # NixOS
        pkgs=$(nix-env -q | wc -l)
        pkgs_manager="nix"
    else
        pkgs="Unknown"
        pkgs_manager=""
    fi
    verboseOut "Contando pacotes... encontrado como '$pkgs ($pkgs_manager)'"
}

# Detecção de Shell
detectshell () {
    shell_type=$(basename "${SHELL}")
    shell_version=$("${SHELL}" --version 2>/dev/null | head -1 | awk '{print $NF}' || echo "")
    if [[ -n "$shell_version" ]]; then
        myShell="${shell_type} ${shell_version}"
    else
        myShell="${shell_type}"
    fi
    verboseOut "Detectando shell... encontrado como '$myShell'"
}

# Detecção de Display
detectdisplay () {
    if [[ -n ${DISPLAY} ]] && type -p xdpyinfo >/dev/null 2>&1; then
        # Resolução
        resolution=$(xdpyinfo | awk '/dimensions:/ {print $2}')
        
        # Tamanho e refresh rate
        monitor_info=$(xrandr --current 2>/dev/null | grep -w connected | head -1)
        monitor_size=$(echo "$monitor_info" | grep -o '[0-9]*\.*[0-9]*"' | head -1 || echo "")
        refresh_rate=$(echo "$monitor_info" | grep -o '[0-9]*\.*[0-9]*Hz' | head -1 || echo "60Hz")
        
        # Tipo de monitor
        if echo "$monitor_info" | grep -q "primary"; then
            monitor_type="Primary"
        else
            monitor_type="External"
        fi
        
        if [[ -n "$monitor_size" ]]; then
            xResolution="${resolution} in ${monitor_size}, ${refresh_rate} [${monitor_type}]"
        else
            xResolution="${resolution} @ ${refresh_rate} [${monitor_type}]"
        fi
    else
        xResolution="No X Server"
    fi
    verboseOut "Detectando display... encontrado como '$xResolution'"
}

# Detecção de Window Manager
detectwm () {
    WM="Not Found"
    if [[ -n ${DISPLAY} ]]; then
        if type -p xprop >/dev/null 2>&1; then
            WM=$(xprop -root _NET_SUPPORTING_WM_CHECK 2>/dev/null | awk '{print $5}')
            if [[ "$WM" =~ 'not found' ]] || [[ "$WM" =~ 'Invalid' ]] || [[ -z "$WM" ]]; then
                # Tentativa alternativa
                WM=$(ps -e | grep -E 'awesome|i3|sway|qtile|dwm|xfwm4|kwin|openbox' | grep -v grep | head -1 | awk '{print $4}')
                if [[ -z "$WM" ]]; then
                    WM="Unknown"
                fi
            else
                WM=$(xprop -id "${WM}" 8s _NET_WM_NAME 2>/dev/null | awk -F'"' '{print $2}')
            fi
        fi
    fi
    
    # Servidor de exibição
    if [[ -n "$WAYLAND_DISPLAY" ]]; then
        display_server="Wayland"
    elif [[ -n "$DISPLAY" ]]; then
        display_server="X11"
    else
        display_server="TTY"
    fi
    
    verboseOut "Detectando WM... encontrado como '$WM ($display_server)'"
}

# Detecção de Tema
detecttheme () {
    theme="Not Found"
    
    # GTK
    if [[ -f "${HOME}/.config/gtk-3.0/settings.ini" ]]; then
        gtk3_theme=$(grep 'gtk-theme-name' "${HOME}/.config/gtk-3.0/settings.ini" | awk -F'=' '{print $2}')
        theme="$gtk3_theme"
    elif [[ -f "${HOME}/.gtkrc-2.0" ]]; then
        gtk2_theme=$(grep 'gtk-theme-name' "${HOME}/.gtkrc-2.0" | awk -F'"' '{print $2}')
        theme="$gtk2_theme"
    fi
    
    # Awesome WM
    if [[ "$WM" == "awesome" ]] && [[ -f "${HOME}/.config/awesome/theme.lua" ]]; then
        awesome_theme=$(grep 'theme_name' "${HOME}/.config/awesome/theme.lua" | head -1 | awk -F'"' '{print $2}')
        if [[ -n "$awesome_theme" ]]; then
            theme="$awesome_theme"
        fi
    fi
    
    verboseOut "Detectando tema... encontrado como '$theme'"
}

# Detecção de Ícones
detecticons () {
    icons="Not Found"
    
    # GTK 3/4 - Prioridade 1
    if [[ -f "${HOME}/.config/gtk-3.0/settings.ini" ]]; then
        icons=$(grep 'gtk-icon-theme-name' "${HOME}/.config/gtk-3.0/settings.ini" | awk -F'=' '{print $2}' | tr -d ' ')
    fi
    
    # GTK 4 específico
    if [[ "$icons" == "Not Found" ]] && [[ -f "${HOME}/.config/gtk-4.0/settings.ini" ]]; then
        icons=$(grep 'gtk-icon-theme-name' "${HOME}/.config/gtk-4.0/settings.ini" | awk -F'=' '{print $2}' | tr -d ' ')
    fi
    
    # GTK 2 - Prioridade 2
    if [[ "$icons" == "Not Found" ]] && [[ -f "${HOME}/.gtkrc-2.0" ]]; then
        icons=$(grep 'gtk-icon-theme-name' "${HOME}/.gtkrc-2.0" | awk -F'"' '{print $2}')
    fi
    
    # GSettings (GNOME/GTK) - Prioridade 3
    if [[ "$icons" == "Not Found" ]] && type -p gsettings >/dev/null 2>&1; then
        icons=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | tr -d "'")
    fi
    
    # DConf (alternativa ao GSettings)
    if [[ "$icons" == "Not Found" ]] && type -p dconf >/dev/null 2>&1; then
        icons=$(dconf read /org/gnome/desktop/interface/icon-theme 2>/dev/null | tr -d "'")
    fi
    
    # XFCE
    if [[ "$icons" == "Not Found" ]] && type -p xfconf-query >/dev/null 2>&1; then
        icons=$(xfconf-query -c xsettings -p /Net/IconThemeName 2>/dev/null)
    fi
    
    # KDE Plasma
    if [[ "$icons" == "Not Found" ]] && [[ -f "${HOME}/.config/kdeglobals" ]]; then
        icons=$(grep 'Theme=' "${HOME}/.config/kdeglobals" | grep -v 'ColorScheme' | head -1 | awk -F'=' '{print $2}')
    fi
    
    # Awesome WM
    if [[ "$icons" == "Not Found" ]] && [[ "$WM" == "awesome" ]]; then
        if [[ -f "${HOME}/.config/awesome/theme.lua" ]]; then
            icons=$(grep 'theme.icon_theme' "${HOME}/.config/awesome/theme.lua" | head -1 | awk -F'"' '{print $2}')
        fi
    fi
    
    # i3wm (via ~/.Xresources ou ~/.config/gtk-3.0)
    if [[ "$icons" == "Not Found" ]] && [[ -f "${HOME}/.Xresources" ]]; then
        icons=$(grep -i 'icontheme' "${HOME}/.Xresources" | awk '{print $2}')
    fi
    
    # LXQt
    if [[ "$icons" == "Not Found" ]] && [[ -f "${HOME}/.config/lxqt/lxqt.conf" ]]; then
        icons=$(grep 'icon_theme' "${HOME}/.config/lxqt/lxqt.conf" | awk -F'=' '{print $2}' | tr -d ' ')
    fi
    
    # MATE Desktop
    if [[ "$icons" == "Not Found" ]] && type -p gsettings >/dev/null 2>&1; then
        icons=$(gsettings get org.mate.interface icon-theme 2>/dev/null | tr -d "'")
    fi
    
    # Cinnamon
    if [[ "$icons" == "Not Found" ]] && type -p gsettings >/dev/null 2>&1; then
        icons=$(gsettings get org.cinnamon.desktop.interface icon-theme 2>/dev/null | tr -d "'")
    fi
    
    # Fallback: Procurar em diretórios de ícones por temas instalados
    if [[ "$icons" == "Not Found" ]]; then
        # Verificar se existe um symlink para o tema atual
        if [[ -L "${HOME}/.icons/default" ]]; then
            icons=$(readlink -f "${HOME}/.icons/default" | xargs basename)
        elif [[ -d "${HOME}/.local/share/icons" ]]; then
            # Pegar o tema mais recentemente modificado (provavelmente o ativo)
            icons=$(ls -t "${HOME}/.local/share/icons" | head -1)
        elif [[ -d "${HOME}/.icons" ]]; then
            icons=$(ls -t "${HOME}/.icons" | grep -v default | head -1)
        fi
    fi
    
    # Limpar resultado (remover espaços, aspas, etc)
    icons=$(echo "$icons" | tr -d ' "' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    # Se ainda não encontrou, marcar como Not Found
    if [[ -z "$icons" ]]; then
        icons="Not Found"
    fi
    
    verboseOut "Detectando ícones... encontrado como '$icons'"
}

# Detecção de Fonte
detectfont () {
    font="Not Found"
    
    if [[ -f "${HOME}/.config/gtk-3.0/settings.ini" ]]; then
        font_full=$(grep 'gtk-font-name' "${HOME}/.config/gtk-3.0/settings.ini" | awk -F'=' '{print $2}')
        font_name=$(echo "$font_full" | sed 's/,.*//')
        font_size=$(echo "$font_full" | grep -o '[0-9]*$')
        if [[ -n "$font_size" ]]; then
            font="${font_name} (${font_size}pt)"
        else
            font="$font_name"
        fi
    elif [[ -f "${HOME}/.gtkrc-2.0" ]]; then
        font_full=$(grep 'gtk-font-name' "${HOME}/.gtkrc-2.0" | awk -F'"' '{print $2}')
        font_name=$(echo "$font_full" | sed 's/,.*//')
        font_size=$(echo "$font_full" | grep -o '[0-9]*$')
        if [[ -n "$font_size" ]]; then
            font="${font_name} (${font_size}pt)"
        else
            font="$font_name"
        fi
    fi
    
    verboseOut "Detectando fonte... encontrado como '$font'"
}

# Detecção de Cursor
detectcursor () {
    cursor="Not Found"
    
    if [[ -f "${HOME}/.icons/default/index.theme" ]]; then
        cursor=$(grep 'Inherits' "${HOME}/.icons/default/index.theme" | awk -F'=' '{print $2}')
        cursor_size=$(grep 'Size' "${HOME}/.icons/default/index.theme" | head -1 | awk -F'=' '{print $2}')
        if [[ -n "$cursor_size" ]]; then
            cursor="${cursor} (${cursor_size}px)"
        fi
    elif [[ -d "${HOME}/.local/share/icons" ]]; then
        # Tentar encontrar o tema de cursor
        cursor_dir=$(find "${HOME}/.local/share/icons" -name "cursors" -type d | head -1)
        if [[ -n "$cursor_dir" ]]; then
            cursor=$(basename "$(dirname "$cursor_dir")")
        fi
    fi
    
    verboseOut "Detectando cursor... encontrado como '$cursor'"
}

# Detecção de Terminal
detectterminal () {
    terminal="Not Found"
    terminal_font="Not Found"
    
    # Detect terminal emulator
    if [[ -n "$TERM_PROGRAM" ]]; then
        terminal="$TERM_PROGRAM"
    elif [[ -n "$TERM" ]]; then
        terminal="$TERM"
    fi
    
    # Detect Alacritty specifically
    if [[ "$terminal" == "alacritty" ]] || pgrep -x "alacritty" >/dev/null; then
        terminal="alacritty"
        if [[ -f "${HOME}/.config/alacritty/alacritty.toml" ]] || [[ -f "${HOME}/.config/alacritty/alacritty.yml" ]]; then
            # Try to get font from alacritty config
            if [[ -f "${HOME}/.config/alacritty/alacritty.toml" ]]; then
                font_line=$(grep -A5 '\[font\.normal\]' "${HOME}/.config/alacritty/alacritty.toml" | grep 'family\|size' | head -2)
                font_family=$(echo "$font_line" | grep family | awk -F'=' '{print $2}' | tr -d ' "')
                font_size=$(echo "$font_line" | grep size | awk -F'=' '{print $2}' | tr -d ' ')
                if [[ -n "$font_family" ]]; then
                    terminal_font="${font_family} (${font_size}pt)"
                fi
            fi
        fi
    fi
    
    # Get terminal version
    term_version=$( ($terminal --version 2>/dev/null || echo "Unknown") | head -1 | awk '{print $NF}')
    if [[ "$term_version" != "Unknown" ]]; then
        terminal="${terminal} ${term_version}"
    fi
    
    verboseOut "Detectando terminal... encontrado como '$terminal'"
    verboseOut "Detectando fonte do terminal... encontrado como '$terminal_font'"
}

# Detecção de CPU
detectcpu () {
    if [[ -f /proc/cpuinfo ]]; then
        cpu_model=$(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^[ \t]*//')
        cpu_cores=$(grep -c '^processor' /proc/cpuinfo)
        
        # Frequência máxima
        max_freq=$(grep 'cpu MHz' /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^[ \t]*//' | awk '{printf "%.0f", $1}')
        if [[ -n "$max_freq" ]] && command -v bc >/dev/null 2>&1; then
            max_freq_ghz=$(echo "scale=2; $max_freq/1000" | bc)
            cpu="${cpu_model} (${cpu_cores}) @ ${max_freq_ghz} GHz"
        else
            cpu="${cpu_model} (${cpu_cores})"
        fi
    else
        cpu="Unknown"
    fi
    verboseOut "Detectando CPU... encontrada como '$cpu'"
}

# Detecção de GPU
detectgpu () {
    gpus=()
    
	if lspci | grep -E "VGA|3D" | grep "NVIDIA" >/dev/null; then
		# Detect NVIDIA GPUs
		if lsmod | grep -qi nvidia && type -p nvidia-smi >/dev/null 2>&1; then
			nvidia_gpus=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null)
		else
			nvidia_gpus=$(lspci 2>/dev/null | grep -i 'vga.*nvidia' | head -1 | cut -d':' -f3- | sed 's/^[ \t]*//')
		fi
		if [[ -n "$nvidia_gpus" ]]; then
			while IFS= read -r gpu; do
				if [[ -n "$gpu" ]]; then
					#gpus+=("NVIDIA $gpu [Discrete]")
					gpus+=("$gpu [Discrete]")
				fi
			done <<< "$nvidia_gpus"
		fi
	fi
    
	if lspci | grep -E "VGA|3D" | grep "Intel" >/dev/null; then
		# Detect Intel GPUs
		intel_gpus=$(lspci 2>/dev/null | grep -i 'vga.*intel' | head -1 | cut -d':' -f3- | sed 's/^[ \t]*//')
		if [[ -n "$intel_gpus" ]]; then
			# gpus+=("Intel $intel_gpus [Integrated]")
			gpus+=("$intel_gpus [Integrated]")
		fi
	fi
    
	if lspci | grep -E "VGA|3D" | grep -E "AMD|ATI" >/dev/null; then
		# Detect AMD GPUs
		amd_gpus=$(lspci 2>/dev/null | grep -i 'vga.*amd\|vga.*ati' | head -1 | cut -d':' -f3- | sed 's/^[ \t]*//')
		if [[ -n "$amd_gpus" ]]; then
			# gpus+=("AMD $amd_gpus [Discrete]")
			gpus+=("$amd_gpus [Discrete|Integrated]")
		fi
	fi
    
    # Fallback to lspci
    if [[ ${#gpus[@]} -eq 0 ]]; then
        fallback_gpus=$(lspci 2>/dev/null | grep -i 'vga\|3d\|2d' | cut -d':' -f3- | sed 's/^[ \t]*//')
        while IFS= read -r gpu; do
            if [[ -n "$gpu" ]]; then
                gpus+=("$gpu")
            fi
        done <<< "$fallback_gpus"
    fi
    
    verboseOut "Detectando GPUs... encontradas ${#gpus[@]} GPUs"
}

# Detecção de Memória
detectmemory () {
    if [[ -f /proc/meminfo ]]; then
        mem_total_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        mem_available_kb=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        
        if [[ -n "$mem_total_kb" && -n "$mem_available_kb" ]] && command -v bc >/dev/null 2>&1; then
            mem_used_kb=$((mem_total_kb - mem_available_kb))
            
            # Converter para GiB usando bc
            mem_used_gib=$(echo "scale=2; $mem_used_kb/1024/1024" | bc)
            mem_total_gib=$(echo "scale=2; $mem_total_kb/1024/1024" | bc)
            mem_percent=$(( (mem_used_kb * 100) / mem_total_kb ))
            
            memory="${mem_used_gib} GiB / ${mem_total_gib} GiB (${mem_percent}%)"
        else
            memory="Unknown"
        fi
    else
        memory="Unknown"
    fi
    verboseOut "Detectando memória... encontrada como '$memory'"
}

# Detecção de Swap
detectswap () {
    if [[ -f /proc/meminfo ]]; then
        swap_total_kb=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
        swap_free_kb=$(grep SwapFree /proc/meminfo | awk '{print $2}')
        
        if [[ -n "$swap_total_kb" && -n "$swap_free_kb" ]]; then
            swap_used_kb=$((swap_total_kb - swap_free_kb))
            
            if [[ $swap_total_kb -gt 0 ]] && command -v bc >/dev/null 2>&1; then
                # Converter para GiB usando bc
                swap_used_gib=$(echo "scale=2; $swap_used_kb/1024/1024" | bc)
                swap_total_gib=$(echo "scale=2; $swap_total_kb/1024/1024" | bc)
                swap_percent=$(( (swap_used_kb * 100) / swap_total_kb ))
                
                swap="${swap_used_gib} GiB / ${swap_total_gib} GiB (${swap_percent}%)"
            else
                swap="0 B / 0 B (0%)"
            fi
        else
            swap="Unknown"
        fi
    else
        swap="Unknown"
    fi
    verboseOut "Detectando swap... encontrado como '$swap'"
}

# Detecção de Disco
detectdisk () {
    disks=()
    
    # Get disk information for all mounted filesystems
    while IFS= read -r line; do
        if [[ "$line" =~ /dev/ ]]; then
            device=$(echo "$line" | awk '{print $1}')
            size=$(echo "$line" | awk '{print $2}')
            used=$(echo "$line" | awk '{print $3}')
            avail=$(echo "$line" | awk '{print $4}')
            percent=$(echo "$line" | awk '{print $5}')
            mountpoint=$(echo "$line" | awk '{print $6}')
            
            # Get filesystem type
            fstype=$(df -T "$mountpoint" 2>/dev/null | tail -1 | awk '{print $2}')
            
            # Only show significant mount points
            if [[ "$mountpoint" == "/" ]] || [[ "$mountpoint" =~ /home.*HD ]] || [[ "$mountpoint" =~ /media ]] || [[ "$size" =~ T ]]; then
                disks+=("${mountpoint}: ${used} / ${size} (${percent}) - ${fstype}")
            fi
        fi
    done < <(df -h | tail -n +2)
    
    verboseOut "Detectando discos... encontrados ${#disks[@]} partições relevantes"
}

# Detecção de IP
detectip () {
    ips=()
    
    # Get all network interfaces
    for interface in $(ip -o link show | awk -F': ' '{print $2}'); do
        if [[ "$interface" != "lo" ]]; then
            ip_info=$(ip -o -4 addr show dev "$interface" 2>/dev/null | awk '{print $4}')
            if [[ -n "$ip_info" ]]; then
                ips+=("${interface}: ${ip_info}")
            fi
        fi
    done
    
    verboseOut "Detectando IPs... encontrados ${#ips[@]} interfaces"
}

# Detecção de Bateria
detectbattery () {
    battery="Not Found"
    
    if [[ -d /sys/class/power_supply ]]; then
        for battery_dir in /sys/class/power_supply/*; do
            if [[ -d "$battery_dir" ]]; then
                battery_name=$(basename "$battery_dir")
                capacity=$(cat "$battery_dir/capacity" 2>/dev/null || echo "")
                status=$(cat "$battery_dir/status" 2>/dev/null || echo "")
                
                if [[ -n "$capacity" && -n "$status" ]]; then
                    if [[ "$status" == "Discharging" ]]; then
                        status_text="Discharging"
                    else
                        status_text="AC Connected"
                    fi
                    battery="${battery_name}: ${capacity}% [${status_text}]"
                    break
                fi
            fi
        done
    fi
    
    verboseOut "Detectando bateria... encontrado como '$battery'"
}

# Detecção de Locale
detectlocale () {
    if type -p locale >/dev/null 2>&1; then
        locale=$(locale | grep -E 'LANG=|LC_CTYPE=' | head -1 | cut -d'=' -f2)
    else
        locale="Unknown"
    fi
    verboseOut "Detectando locale... encontrado como '$locale'"
}

# Display information
infoDisplay () {
    echo -e "${labelcolor}${myUser}@${myHost}${textcolor}"
    echo "-------------------"
    
    for info in "${display[@]}"; do
        case $info in
            distro)
                echo -e "${labelcolor}OS:${textcolor} ${distro} ${arch}"
                ;;
            host)
                echo -e "${labelcolor}Host:${textcolor} ${host_info}"
                ;;
            kernel)
                echo -e "${labelcolor}Kernel:${textcolor} ${kernel}"
                ;;
            uptime)
                echo -e "${labelcolor}Uptime:${textcolor} ${uptime}"
                ;;
            pkgs)
                if [[ "$pkgs" != "Unknown" ]]; then
                    echo -e "${labelcolor}Packages:${textcolor} ${pkgs} (${pkgs_manager})"
                fi
                ;;
            shell)
                echo -e "${labelcolor}Shell:${textcolor} ${myShell}"
                ;;
            display)
                if [[ "$xResolution" != "No X Server" ]]; then
                    echo -e "${labelcolor}Display:${textcolor} ${xResolution}"
                fi
                ;;
            wm)
                if [[ "$WM" != "Not Found" ]]; then
                    echo -e "${labelcolor}WM:${textcolor} ${WM} (${display_server})"
                fi
                ;;
            theme)
                if [[ "$theme" != "Not Found" ]]; then
                    echo -e "${labelcolor}Theme:${textcolor} ${theme}"
                fi
                ;;
            icons)
                if [[ "$icons" != "Not Found" ]]; then
                    echo -e "${labelcolor}Icons:${textcolor} ${icons}"
                fi
                ;;
            font)
                if [[ "$font" != "Not Found" ]]; then
                    echo -e "${labelcolor}Font:${textcolor} ${font}"
                fi
                ;;
            cursor)
                if [[ "$cursor" != "Not Found" ]]; then
                    echo -e "${labelcolor}Cursor:${textcolor} ${cursor}"
                fi
                ;;
            terminal)
                if [[ "$terminal" != "Not Found" ]]; then
                    echo -e "${labelcolor}Terminal:${textcolor} ${terminal}"
                fi
                ;;
            terminal_font)
                if [[ "$terminal_font" != "Not Found" ]]; then
                    echo -e "${labelcolor}Terminal Font:${textcolor} ${terminal_font}"
                fi
                ;;
            cpu)
                echo -e "${labelcolor}CPU:${textcolor} ${cpu}"
                ;;
            gpu)
                for ((i=0; i<${#gpus[@]}; i++)); do
                    echo -e "${labelcolor}GPU $((i+1)):${textcolor} ${gpus[i]}"
                done
                ;;
            memory)
                echo -e "${labelcolor}Memory:${textcolor} ${memory}"
                ;;
            swap)
                echo -e "${labelcolor}Swap:${textcolor} ${swap}"
                ;;
            disk)
                for disk_info in "${disks[@]}"; do
                    mount_point=$(echo "$disk_info" | cut -d':' -f1)
                    disk_data=$(echo "$disk_info" | cut -d':' -f2-)
                    echo -e "${labelcolor}Disk (${mount_point}):${textcolor} ${disk_data}"
                done
                ;;
            ip)
                for ip_info in "${ips[@]}"; do
                    interface=$(echo "$ip_info" | cut -d':' -f1)
                    ip_addr=$(echo "$ip_info" | cut -d':' -f2-)
                    echo -e "${labelcolor}Local IP (${interface}):${textcolor} ${ip_addr}"
                done
                ;;
            battery)
                if [[ "$battery" != "Not Found" ]]; then
                    echo -e "${labelcolor}Battery:${textcolor} ${battery}"
                fi
                ;;
            locale)
                echo -e "${labelcolor}Locale:${textcolor} ${locale}"
                ;;
        esac
    done
}

##################
# Main Execution
##################

# Detect all information
for detection in host distro kernel uptime pkgs shell display wm theme icons font cursor terminal cpu gpu memory swap disk ip battery locale; do
    if [[ "${display[@]}" =~ "$detection" ]]; then
        "detect${detection}"
    fi
done

# Display information
infoDisplay