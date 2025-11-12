#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Simple script to open terminal in current Nautilus directory using lsof
DOCUMENTATION

# Check if Script Instaled
nautilus_scripts="$HOME/.local/share/nautilus/scripts"
nautilus_open_terminal_script="$nautilus_scripts/Open Terminal"

[[ ! -d "$nautilus_scripts" ]] && mkdir -p "$nautilus_scripts"

if [[ ! -f "$nautilus_open_terminal_script" ]]; then

cat <<'EOF' | tee "$nautilus_open_terminal_script" > /dev/null
#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

##################################
# A nautilus script to open terminal in the current directory
# place in ~/.local/share/nautilus/scripts
##################################

# Configuration file
CONFIG_FILE="$HOME/.nautilus_terminal.conf"

fallback_terminal() {
	if command -v alacritty >/dev/null; then
		echo "alacritty" > "$CONFIG_FILE"
		echo "alacritty"
	else
		echo "xterm" > "$CONFIG_FILE"
		echo "xterm"
	fi
}

# Function to detect and set terminal
setup_terminal() {
    # Check if zenity is available
    if command -v zenity &> /dev/null; then
        # Use zenity to ask for terminal preference
        TERMINAL_CHOICE=$(zenity --list \
            --title="Select Terminal" \
            --text="Choose your preferred terminal:" \
            --radiolist \
            --column="Select" \
            --column="Terminal" \
            TRUE "alacritty" \
            FALSE "kitty" \
            FALSE "wezterm" \
            FALSE "terminator" \
            FALSE "foot" \
            FALSE "sakura" \
            FALSE "xfce4-terminal" \
            FALSE "qterminal" \
            FALSE "lxterminal" \
            FALSE "mate-terminal" \
            FALSE "gnome-terminal" \
            FALSE "konsole" \
            FALSE "xterm" \
            FALSE "rxvt-unicode" \
            --height=400 \
            --width=300)
        
        if [ -n "$TERMINAL_CHOICE" ]; then
            echo "$TERMINAL_CHOICE" > "$CONFIG_FILE"
            echo "$TERMINAL_CHOICE"
        else
            # If user cancels, default to alacritty
			fallback_terminal
        fi
    else
        # zenity not available, use notify-send
        if command -v notify-send &> /dev/null; then
            notify-send "Nautilus Terminal" "Please install zenity to configure terminal preferences"
        fi
		fallback_terminal
    fi
}

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    TERMINAL=$(setup_terminal)
else
    TERMINAL=$(cat "$CONFIG_FILE")
fi

# Verify if the chosen terminal is available, if not, setup again
if ! command -v "$TERMINAL" &> /dev/null; then
    TERMINAL=$(setup_terminal)
fi

# Get current directory
if [ -n "$NAUTILUS_SCRIPT_CURRENT_URI" ]; then
    current_dir=$(echo "$NAUTILUS_SCRIPT_CURRENT_URI" | sed 's/^file:\/\///')
    current_dir=$(python3 -c "import urllib.parse; print(urllib.parse.unquote('$current_dir'))")
else
    current_dir="$HOME"
fi

# Open terminal based on selection
if [ -d "$current_dir" ]; then
    case $TERMINAL in
        "alacritty")
            alacritty --working-directory "$current_dir" &
            ;;
        "kitty")
            kitty --directory "$current_dir" &
            ;;
        "wezterm")
            wezterm start --cwd "$current_dir" &
            ;;
        "terminator")
            terminator --working-directory "$current_dir" &
            ;;
        "foot")
            foot --working-directory "$current_dir" &
            ;;
        "sakura")
            sakura --working-directory "$current_dir" &
            ;;
        "xfce4-terminal")
            xfce4-terminal --default-working-directory="$current_dir" &
            ;;
        "qterminal")
            qterminal --workdir "$current_dir" &
            ;;
        "lxterminal")
            lxterminal --working-directory="$current_dir" &
            ;;
        "mate-terminal")
            mate-terminal --working-directory="$current_dir" &
			;;
        "gnome-terminal")
			gnome-terminal --working-directory="$current_dir" >/dev/null 2>&1 &
            ;;
        "konsole")
            konsole --workdir "$current_dir" &
            ;;
        "xterm")
            xterm -e bash -c "cd \"$current_dir\"; exec \$SHELL" &
            ;;
        "rxvt-unicode")
            urxvt -cd "$current_dir" &
            ;;
        *)
			# Fallback to alacritty if unknown terminal
			if command -v alacritty >/dev/null; then
				alacritty --working-directory "$current_dir" &
			else
				xterm -e "cd \"$current_dir\" && bash" &
			fi
            ;;
    esac
else
    # If directory doesn't exist, open in home directory
    case $TERMINAL in
        "alacritty")
            alacritty --working-directory "$HOME" &
            ;;
        "kitty")
            kitty --directory "$HOME" &
            ;;
        "wezterm")
            wezterm start --cwd "$HOME" &
            ;;
        "terminator")
            terminator --working-directory "$HOME" &
            ;;
        "foot")
            foot --working-directory "$HOME" &
            ;;
        "sakura")
            sakura --working-directory "$HOME" &
            ;;
        "xfce4-terminal")
            xfce4-terminal --default-working-directory="$HOME" &
            ;;
        "qterminal")
            qterminal --workdir "$HOME" &
            ;;
        "lxterminal")
            lxterminal --working-directory="$HOME" &
            ;;
        "mate-terminal")
            mate-terminal --working-directory="$HOME" &
            ;;
        "gnome-terminal")
			gnome-terminal --working-directory="$HOME" >/dev/null 2>&1 &
            ;;
        "konsole")
            konsole --workdir "$HOME" &
            ;;
        "xterm")
            xterm -e bash -c "cd \"$HOME\"; exec \$SHELL" &
            ;;
        "rxvt-unicode")
            urxvt -cd "$HOME" &
            ;;
        *)
            alacritty --working-directory "$HOME" &
            ;;
    esac
fi
EOF

	chmod +x "$nautilus_open_terminal_script" &&
	"$nautilus_open_terminal_script"
fi

# Check if Nautilus is open
nautilus_pid=$(pgrep nautilus | head -1)

if [ -z "$nautilus_pid" ]; then
    echo "Nautilus is not open. Opening terminal in $HOME"
    notify-send "Nautilus is not open." "Opening terminal in $HOME" -t 4000
    current_dir="$HOME"
else
    # Get Nautilus current directory using lsof
    # Filters DIR lines and takes the last one (which is usually the current directory)
	# current_dir=$(lsof -p "$nautilus_pid" 2>/dev/null | grep DIR | tail -1 | tr -s ' ' | cut -d' ' -f9-)
	# current_dir=$(lsof -p "$nautilus_pid" 2>/dev/null | grep DIR | tail -1 | sed 's/  */ /g' | cut -d' ' -f9-)
	current_dir=$(lsof -p "$nautilus_pid" 2>/dev/null | grep DIR | tail -1 | awk '{for(i=9;i<=NF;i++) printf "%s%s", $i, (i==NF?"\n":" ")}')
    
    # Check if a valid directory was obtained
    if [ -z "$current_dir" ] || [ ! -d "$current_dir" ]; then
        echo "Could not get Nautilus directory. Using $HOME"
        notify-send "Could not get Nautilus directory." "Using $HOME" -t 4000
        current_dir="$HOME"
    else
        echo "Nautilus directory: $current_dir"
    fi
fi

# Get configured terminal
if [ -f "$HOME/.nautilus_terminal.conf" ]; then
    TERMINAL=$(cat "$HOME/.nautilus_terminal.conf")
else
	if command -v alacritty >/dev/null; then
    	TERMINAL="alacritty"
	else
    	TERMINAL="xterm"
	fi
fi

# Open terminal in directory
case $TERMINAL in
    "alacritty")
        alacritty --working-directory "$current_dir" &
        ;;
    "kitty")
        kitty --directory "$current_dir" &
        ;;
    "wezterm")
        wezterm start --cwd "$current_dir" &
        ;;
    "terminator")
        terminator --working-directory "$current_dir" &
        ;;
    "foot")
        foot --working-directory "$current_dir" &
        ;;
    "sakura")
        sakura --working-directory "$current_dir" &
        ;;
    "xfce4-terminal")
        xfce4-terminal --default-working-directory="$current_dir" &
        ;;
    "qterminal")
        qterminal --workdir "$current_dir" &
        ;;
    "lxterminal")
        lxterminal --working-directory "$current_dir" &
        ;;
    "mate-terminal")
        mate-terminal --working-directory "$current_dir" &
        ;;
	"gnome-terminal")
		gnome-terminal --working-directory="$current_dir" >/dev/null 2>&1 &
		;;
    "konsole")
        konsole --workdir "$current_dir" &
        ;;
    "xterm")
        xterm -e bash -c "cd \"$current_dir\"; exec \$SHELL" &
        ;;
    "rxvt-unicode")
        urxvt -cd "$current_dir" &
        ;;
    *)
        # Fallback to alacritty if unknown terminal
		if command -v alacritty >/dev/null; then
        	alacritty --working-directory "$current_dir" &
		else
        	xterm -e bash -c "cd \"$current_dir\"; exec \$SHELL" &
		fi
        ;;
esac

notify-send "Terminal $TERMINAL opened in:" "$current_dir" -t 4000