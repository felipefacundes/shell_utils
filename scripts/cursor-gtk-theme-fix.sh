#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script is to fix the mouse cursor theme.
Cursor Theme fix for WMs: openbox, i3 and more...
How to use lxappearance. No stress.

Advanced cursor and GTK theme synchronization tool that automatically detects
changes in GTK configuration files and applies them system-wide, including
X resources, window manager settings, and desktop environments.

Key Features:
• Smart GTK config detection (GTK2/GTK3/GTK4)
• Dynamic base configuration selection
• Comprehensive theme synchronization
• Window Manager compatibility
DOCUMENTATION

while ! lsof 2>/dev/null | grep -m 1 -qi libgtk; do
	sleep 1
done

SCRIPT="${0##*/}"
XRESOURCES=~/.Xresources
TMPDIR="${TMPDIR:-/tmp}"
TMP_DIR="${TMPDIR}/${SCRIPT%.*}"
XSETTINGSD=~/.config/xsettingsd/xsettingsd.conf
GTK3_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0/settings.ini"
GTK4_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-4.0/settings.ini"
GTK2_RC_FILES="${HOME}/.gtkrc-2.0" #"${HOME}/.gtkrc-2.0:${XDG_CONFIG_HOME}/gtk-2.0/gtkrc:/etc/gtk-2.0/gtkrc"
GTK_RC_BASE="$GTK2_RC_FILES"

[[ -d "$TMP_DIR" ]] && rm -rf "$TMP_DIR"
[[ ! -d "$TMP_DIR" ]] && mkdir -p "$TMP_DIR"
lock_file="${TMP_DIR}/lock"
start_file="${TMP_DIR}/start"
{ date | tee "$start_file"; } >/dev/null
trap '[[ -d "$TMP_DIR" ]] && rm -rf "$TMP_DIR"; kill -TERM -- -$$' SIGINT SIGQUIT SIGHUP SIGABRT EXIT

TMP_GTK2="${TMP_DIR}/gtk2rc.ini"
TMP_GTK3="${TMP_DIR}/gtk3rc.ini"
TMP_GTK4="${TMP_DIR}/gtk4rc.ini"

cp -f "$GTK2_RC_FILES" "$TMP_GTK2"
cp -f "$GTK3_RC_FILES" "$TMP_GTK3"
cp -f "$GTK4_RC_FILES" "$TMP_GTK4"

delay=2.0

doc() {
	less -FX "$0" | head -n8 | tail -n3
	echo
}

help() {
    doc
	cat <<-EOF | echo -e "$(cat)"
	\033[1mUSAGE:\033[0m
	${0##*/} [OPTIONS]

	\033[1mDESCRIPTION:\033[0m
	Advanced cursor and GTK theme synchronization tool that automatically detects
	changes in GTK configuration files and applies them system-wide, including
	X resources, window manager settings, and desktop environments.

	\033[1mKEY FEATURES:\033[0m
	• Automatic detection of GTK2/GTK3/GTK4 config changes
	• Smart base configuration selection (prioritizes most recent changes)
	• Lock file mechanism to prevent conflicts
	• Comprehensive theme synchronization across all GTK versions

	\033[1mOPTIONS:\033[0m
	-o              Run only the X resources database (xrdb) maintenance loop
	-t              Run full theme synchronization (monitors all config files)
	-h, --help      Show this help message

	\033[1mCONFIGURATION FILES:\033[0m
	The script monitors and synchronizes these files:
	• GTK2: ~/.gtkrc-2.0 (primary base config)
	• GTK3: ~/.config/gtk-3.0/settings.ini
	• GTK4: ~/.config/gtk-4.0/settings.ini
	• XResources: ~/.Xresources (automatically downloaded if missing)
	• xsettingsd: ~/.config/xsettingsd/xsettingsd.conf

	\033[1mLOCK MECHANISM:\033[0m
	Uses /tmp/cursor-gtk-theme-fix/lock to:
	• Prevent multiple simultaneous updates
	• Track which GTK version was modified last
	• Ensure clean termination (lock file removed on exit)

	\033[1mSYSTEM INTEGRATION:\033[0m
	Supports multiple integration methods:
	• Direct config file updates
	• DBus signals (for GNOME/GTK apps)
	• SIGHUP to GTK processes
	• Window manager specific reload commands

	\033[1mSUPPORTED ENVIRONMENTS:\033[0m
	Window Managers: awesome, bspwm, dwm, fluxbox, herbstluftwm, i3, openbox,
	qtile, sway, xmonad, spectrwm, fvwm, icewm, pekwm, wayfire, hyprland, labwc
	Desktop Environments: GNOME, Xfce, and other GTK-based environments

	\033[1mEXAMPLES:\033[0m
	${0##*/} -t          # Full theme synchronization (recommended)
	${0##*/} -o          # X resources maintenance only

	\033[1mNOTES:\033[0m
	• Runs continuously by default (use Ctrl+C to exit)
	• For best results, use with lxappearance
	• Requires xsettingsd for proper theme application in some WMs
	• Automatically creates missing directories and config files
	EOF
}

xsetroot -cursor_name left_ptr >/dev/null 2>&1
xrdb -merge "${XRESOURCES}" >/dev/null 2>&1

only_xrdb() {
	while true
	do 
		xrdb "${XRESOURCES}" > /dev/null 2>&1
		xrdb -merge "${XRESOURCES}" > /dev/null 2>&1
		xsetroot -cursor_name left_ptr > /dev/null 2>&1

		sleep "$delay"
	done
}

reload_wm() {
    local wm=$(ps -o comm= -p $(pidof -x awesome bspwm dwm fluxbox herbstluftwm i3 openbox qtile sway xmonad spectrwm fvwm icewm pekwm wayfire hyprland labwc | head -n1))
    
    case "$wm" in
        awesome)    awesome-client 'awesome.restart()' ;;
        bspwm)      bspc wm -r ;;
        dwm)        pkill -USR1 -x dwm ;;
        fluxbox)    fluxbox-remote restart ;;
        herbstluftwm) herbstclient reload ;;
        i3)         i3-msg restart ;;
        openbox)    openbox --reconfigure ;;
        qtile)      qtile cmd-obj -o cmd -f restart ;;
        sway)       swaymsg reload ;;
        xmonad)     pkill -USR1 -x xmonad ;;
        spectrwm)   spectrwm -r ;;
        fvwm)       fvwm -r ;;
        icewm)      icewm -r ;;
        pekwm)      pekwm --replace ;;
        wayfire)    wayfire -r ;;
        hyprland)   hyprctl reload ;;
        labwc)      labwc -r ;;
        *)          notify-send "WM Restart" "Manual restart required for $wm" ;;
    esac
}

exec_reload_wm() {
	reload_wm &
	rwm_pid=$!
	wait "$rwm_pid"
}

reload_gtk() {
	# Try GNOME Shell first
	if dbus-send --session --type=method_call --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:'global.reexec_self()' >/dev/null 2>&1; then
		true #echo "Gnome shell reloaded via d-bus."
	else
		# Fallback to HUP signal
		echo "Reloading GTK processes via SIGHUP..."
		pkill -HUP -f "gtk" || true
		pkill -HUP -f "gtk3" || true
		pkill -HUP -f "gtk4" || true
		pkill -HUP -f gtk3-nocsd || true
		pkill -9 -f rofi || true
		
		# Send DBus signals for various settings
		local signals=(
			"gtk-modules" "gtk-xft-rgba" "gtk-font-name" "gtk-theme-name"
			"gtk-menu-images" "gtk-xft-hinting" "gtk-xft-hintstyle"
			"gtk-toolbar-style" "gtk-button-images" "gtk-xft-antialias"
			"gtk-icon-theme-name" "gtk-cursor-theme-name" "gtk-cursor-theme-size"
			"gtk-toolbar-icon-size" "gtk-enable-event-sounds"
			"gtk-enable-input-feedback-sounds"
		)
		
		for signal in "${signals[@]}"; do
			dbus-send --session --type=signal / org.gtk.SettingsChanged "string:$signal" || true
		done
	fi
}

if_xsettingsd() {
	if command -v xsettingsd >/dev/null; then
		pkill -9 xsettingsd 2>/dev/null || true
		xsettingsd 2>/dev/null & disown
	else
		notify-send "Install xsettingsd" "For proper theme application in some WMs"
	fi
}

qt_themes() {
	export QT_STYLE_OVERRIDE=gtk2  
	export QT_QPA_PLATFORMTHEME=gtk2 
	export XCURSOR_THEME="$XCURSOR_THEME"
	export XCURSOR_SIZE="$XCURSOR_SIZE"
	command -v qt5ct >/dev/null && qt5ct --apply 2>/dev/null
	command -v qt6ct >/dev/null && qt6ct --apply 2>/dev/null
}

update_themes() {
	# GTK Theme
	[[ "$GTK_RC_BASE" != "$GTK3_RC_FILES" ]] && sed -i "/gtk-theme-name/c\gtk-theme-name=${GTK_THEME}" "${GTK3_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK2_RC_FILES" ]] && sed -i "/gtk-theme-name/c\gtk-theme-name=\"${GTK_THEME}\"" "${GTK2_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK4_RC_FILES" ]] && sed -i "/gtk-theme-name/c\gtk-theme-name=${GTK_THEME}" "${GTK4_RC_FILES}"
	sed -i "/Net\/ThemeName/c\Net\/ThemeName \"${GTK_THEME}\"" "${XSETTINGSD}"
	# Cursor Theme
	sed -i "/^Xcursor\.theme/c\Xcursor.theme: ${XCURSOR_THEME}" "${XRESOURCES}"
	sed -i "/Gtk\/CursorThemeName/c\Gtk\/CursorThemeName \"${XCURSOR_THEME}\"" "${XSETTINGSD}"
	[[ "$GTK_RC_BASE" != "$GTK3_RC_FILES" ]] && sed -i "/gtk-cursor-theme-name/c\gtk-cursor-theme-name=${XCURSOR_THEME}" "${GTK3_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK2_RC_FILES" ]] && sed -i "/gtk-cursor-theme-name/c\gtk-cursor-theme-name=\"${XCURSOR_THEME}\"" "${GTK2_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK4_RC_FILES" ]] && sed -i "/gtk-cursor-theme-name/c\gtk-cursor-theme-name=${XCURSOR_THEME}" "${GTK4_RC_FILES}"
	# Cursor size
	sed -i "/^Xcursor\.size/c\Xcursor.size: ${XCURSOR_SIZE}" "${XRESOURCES}"
	sed -i "/Gtk\/CursorThemeSize/c\Gtk\/CursorThemeSize ${XCURSOR_SIZE}" "${XSETTINGSD}"
	[[ "$GTK_RC_BASE" != "$GTK3_RC_FILES" ]] && sed -i "/gtk-cursor-theme-size/c\gtk-cursor-theme-size=${XCURSOR_SIZE}" "${GTK3_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK2_RC_FILES" ]] && sed -i "/gtk-cursor-theme-size/c\gtk-cursor-theme-size=${XCURSOR_SIZE}" "${GTK2_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK4_RC_FILES" ]] && sed -i "/gtk-cursor-theme-size/c\gtk-cursor-theme-size=${XCURSOR_SIZE}" "${GTK4_RC_FILES}"
	# Icon theme
	sed -i "/Net\/IconThemeName/c\Net\/IconThemeName \"${icon_theme}\"" "${XSETTINGSD}"
	[[ "$GTK_RC_BASE" != "$GTK3_RC_FILES" ]] && sed -i "/gtk-icon-theme-name/c\gtk-icon-theme-name=${icon_theme}" "${GTK3_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK2_RC_FILES" ]] && sed -i "/gtk-icon-theme-name/c\gtk-icon-theme-name=\"${icon_theme}\"" "${GTK2_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK4_RC_FILES" ]] && sed -i "/gtk-icon-theme-name/c\gtk-icon-theme-name=${icon_theme}" "${GTK4_RC_FILES}"
	# GTK Font 
	[[ "$GTK_RC_BASE" != "$GTK3_RC_FILES" ]] && sed -i "/gtk-font-name/c\gtk-font-name=${font_name}" "${GTK3_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK2_RC_FILES" ]] && sed -i "/gtk-font-name/c\gtk-font-name=\"${font_name}\"" "${GTK2_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK4_RC_FILES" ]] && sed -i "/gtk-font-name/c\gtk-font-name=${font_name}" "${GTK4_RC_FILES}"
	sed -i "/Gtk\/FontName/c\Gtk\/FontName \"${font_name}\"" "${XSETTINGSD}"
	sed -i "/Xft\/Hinting/c\Xft\/Hinting \"${hinting}\"" "${XSETTINGSD}"
	[[ "$GTK_RC_BASE" != "$GTK3_RC_FILES" ]] && sed -i "/gtk-xft-hinting/c\gtk-xft-hinting=${hinting}" "${GTK3_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK2_RC_FILES" ]] && sed -i "/gtk-xft-hinting/c\gtk-xft-hinting=${hinting}" "${GTK2_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK4_RC_FILES" ]] && sed -i "/gtk-xft-hinting/c\gtk-xft-hinting=${hinting}" "${GTK4_RC_FILES}"
	sed -i "/Xft\/HintStyle/c\Xft\/HintStyle \"${hintstyle}\"" "${XSETTINGSD}"
	[[ "$GTK_RC_BASE" != "$GTK3_RC_FILES" ]] && sed -i "/gtk-xft-hintstyle/c\gtk-xft-hintstyle=${hintstyle}" "${GTK3_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK2_RC_FILES" ]] && sed -i "/gtk-xft-hintstyle/c\gtk-xft-hintstyle=\"${hintstyle}\"" "${GTK2_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK4_RC_FILES" ]] && sed -i "/gtk-xft-hintstyle/c\gtk-xft-hintstyle=${hintstyle}" "${GTK4_RC_FILES}"
	sed -i "/Xft\/Antialias/c\Xft\/Antialias \"${antialias}\"" "${XSETTINGSD}"
	[[ "$GTK_RC_BASE" != "$GTK3_RC_FILES" ]] && sed -i "/gtk-xft-antialias/c\gtk-xft-antialias=${antialias}" "${GTK3_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK2_RC_FILES" ]] && sed -i "/gtk-xft-antialias/c\gtk-xft-antialias=${antialias}" "${GTK2_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK4_RC_FILES" ]] && sed -i "/gtk-xft-antialias/c\gtk-xft-antialias=${antialias}" "${GTK4_RC_FILES}"
	sed -i "/Xft\/RGBA/c\Xft\/RGBA \"${rgba}\"" "${XSETTINGSD}"
	[[ "$GTK_RC_BASE" != "$GTK3_RC_FILES" ]] && sed -i "/gtk-xft-rgba/c\gtk-xft-rgba=${rgba}" "${GTK3_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK2_RC_FILES" ]] && sed -i "/gtk-xft-rgba/c\gtk-xft-rgba=\"${rgba}\"" "${GTK2_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK4_RC_FILES" ]] && sed -i "/gtk-xft-rgba/c\gtk-xft-rgba=${rgba}" "${GTK4_RC_FILES}"
	# GTK Others
	[[ "$GTK_RC_BASE" != "$GTK3_RC_FILES" ]] && sed -i "/gtk-modules/c\gtk-modules=${GTK_MODULES}" "${GTK3_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK2_RC_FILES" ]] && sed -i "/gtk-modules/c\gtk-modules=\"${GTK_MODULES}\"" "${GTK2_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK3_RC_FILES" ]] && sed -i "/gtk-menu-images/c\gtk-menu-images=${menu_images}" "${GTK3_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK2_RC_FILES" ]] && sed -i "/gtk-menu-images/c\gtk-menu-images=${menu_images}" "${GTK2_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK3_RC_FILES" ]] && sed -i "/gtk-button-images/c\gtk-button-images=${button_images}" "${GTK3_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK2_RC_FILES" ]] && sed -i "/gtk-button-images/c\gtk-button-images=${button_images}" "${GTK2_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK3_RC_FILES" ]] && sed -i "/gtk-toolbar-style/c\gtk-toolbar-style=${toolbar_style}" "${GTK3_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK2_RC_FILES" ]] && sed -i "/gtk-toolbar-style/c\gtk-toolbar-style=${toolbar_style}" "${GTK2_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK3_RC_FILES" ]] && sed -i "/gtk-toolbar-icon-size/c\gtk-toolbar-icon-size=${toolbar_icon_size}" "${GTK3_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK2_RC_FILES" ]] && sed -i "/gtk-toolbar-icon-size/c\gtk-toolbar-icon-size=${toolbar_icon_size}" "${GTK2_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK3_RC_FILES" ]] && sed -i "/gtk-enable-event-sounds/c\gtk-enable-event-sounds=${feedback_sounds}" "${GTK3_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK2_RC_FILES" ]] && sed -i "/gtk-enable-event-sounds/c\gtk-enable-event-sounds=${feedback_sounds}" "${GTK2_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK4_RC_FILES" ]] && sed -i "/gtk-enable-event-sounds/c\gtk-enable-event-sounds=${feedback_sounds}" "${GTK4_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK3_RC_FILES" ]] && sed -i "/gtk-enable-input-feedback-sounds/c\gtk-enable-input-feedback-sounds=${event_sounds}" "${GTK3_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK2_RC_FILES" ]] && sed -i "/gtk-enable-input-feedback-sounds/c\gtk-enable-input-feedback-sounds=${event_sounds}" "${GTK2_RC_FILES}"
	[[ "$GTK_RC_BASE" != "$GTK4_RC_FILES" ]] && sed -i "/gtk-enable-input-feedback-sounds/c\gtk-enable-input-feedback-sounds=${event_sounds}" "${GTK4_RC_FILES}"

	xrdb "${XRESOURCES}" > /dev/null 2>&1
	xrdb -merge "${XRESOURCES}"> /dev/null 2>&1
	xsetroot -cursor_name left_ptr > /dev/null 2>&1
	gsettings set "${gnome_schema}" gtk-theme "${GTK_THEME}"
	gsettings set "${gnome_schema}" font-name "${font_name}"
	gsettings set "${gnome_schema}" icon-theme "${icon_theme}"
	gsettings set "${gnome_schema}" cursor-theme "${XCURSOR_THEME}"
	gsettings reset org.gnome.desktop.interface gtk-theme
	gsettings set org.gnome.desktop.interface gtk-theme "${GTK_THEME}"
	gsettings set org.gnome.desktop.interface cursor-theme "${XCURSOR_THEME}"
	export GTK_THEME="$GTK_THEME"
	if_xsettingsd
	reload_gtk
	qt_themes
	xrefresh
}

seq_fix() {
	for ((i=1; i<="$1"; i++))
	do
		"$2" & disown
		{ sleep "$delay" && "$2"; } & disown
	done
}

gtk_positive() {
	[[ ! -f "$lock_file" ]] &&
	pgrep -f gvfs >/dev/null &&
	{ [[ -n "$GTK2_RC_FILES" ]] || [[ -n "$GTK_RC_FILES" ]]; } &&
	return 0
	return 1
}

gtk_rc_base() {
	md5sum_gtk2=$(md5sum "$GTK2_RC_FILES")
	md5sum_gtk3=$(md5sum "$GTK3_RC_FILES")
	md5sum_gtk4=$(md5sum "$GTK4_RC_FILES")

	[[ -f "$lock_file" ]] && return

	if [[ "$MD5SUM_GTK2" != "$md5sum_gtk2" ]] && gtk_positive && ! cmp -s "$GTK2_RC_FILES" "$TMP_GTK2"; then
		GTK_RC_BASE="$GTK2_RC_FILES"
		MD5SUM_GTK2="$md5sum_gtk2"
		echo gtk2 > "$lock_file"
		cp -f "$GTK2_RC_FILES" "$TMP_GTK2"
	elif [[ "$MD5SUM_GTK3" != "$md5sum_gtk3" ]] && gtk_positive && ! cmp -s "$GTK3_RC_FILES" "$TMP_GTK3"; then
		GTK_RC_BASE="$GTK3_RC_FILES"
		MD5SUM_GTK3="$md5sum_gtk3"
		echo gtk3 > "$lock_file"
		cp -f "$GTK3_RC_FILES" "$TMP_GTK3"
	elif [[ "$MD5SUM_GTK4" != "$md5sum_gtk4" ]] && gtk_positive && ! cmp -s "$GTK4_RC_FILES" "$TMP_GTK4"; then
		GTK_RC_BASE="$GTK4_RC_FILES"
		MD5SUM_GTK4="$md5sum_gtk4"
		echo gtk4 > "$lock_file"
		cp -f "$GTK4_RC_FILES" "$TMP_GTK4"
	fi
}

cursor_theme_fix() {
	[[ ! -s "${XRESOURCES}" ]] && rm "${XRESOURCES}"
	[[ ! -f "${XRESOURCES}" ]] && wget -nc https://raw.githubusercontent.com/felipefacundes/dotfiles/master/config/.Xresources -O "${XRESOURCES}"
	[[ ! -d ~/.config/gtk-4.0/ ]] && mkdir -p ~/.config/gtk-4.0/

	MD5SUM_BASE=$(md5sum "$GTK_RC_BASE")
	MD5SUM_GTK2=$(md5sum "$GTK2_RC_FILES")
	MD5SUM_GTK3=$(md5sum "$GTK3_RC_FILES")
	MD5SUM_GTK4=$(md5sum "$GTK4_RC_FILES")

	while true
	do 
		! pgrep -f xsettingsd 2>/dev/null && xsettingsd & disown 2>/dev/null
		gtk_rc_base
		GTK_THEME="$(awk -F'=' '/gtk-theme-name/ {print $2}' "${GTK_RC_BASE}" | xargs)"; export GTK_THEME
		GTK_MODULES="$(awk -F'=' '/gtk-modules/ {print $2}' "${GTK_RC_BASE}" | xargs)"; export GTK_MODULES
		XCURSOR_SIZE="$(awk -F'=' '/gtk-cursor-theme-size/ {print $2}' "${GTK_RC_BASE}" | xargs)"; export XCURSOR_SIZE
		XCURSOR_THEME="$(awk -F'=' '/gtk-cursor-theme-name/ {print $2}' "${GTK_RC_BASE}" | xargs)"; export XCURSOR_THEME

		xresources_xcursor_theme="$(grep -i 'Xcursor.theme:' "${XRESOURCES}" | sed -n 's/.*:\s*\(.*\)/\1/p')"
		xresources_xcursor_size="$(awk -F':' '/Xcursor.size:/ {print $2}' "${XRESOURCES}" | xargs)"

		feedback_sounds="$(awk -F'=' '/gtk-enable-input-feedback-sounds/ {print $2}' "${GTK_RC_BASE}" | xargs)"
		toolbar_icon_size="$(awk -F'=' '/gtk-toolbar-icon-size/ {print $2}' "${GTK_RC_BASE}" | xargs)"
		event_sounds="$(awk -F'=' '/gtk-enable-event-sounds/ {print $2}' "${GTK_RC_BASE}" | xargs)"
		button_images="$(awk -F'=' '/gtk-button-images/ {print $2}' "${GTK_RC_BASE}" | xargs)"
		toolbar_style="$(awk -F'=' '/gtk-toolbar-style/ {print $2}' "${GTK_RC_BASE}" | xargs)"
		icon_theme="$(awk -F'=' '/gtk-icon-theme-name/ {print $2}' "${GTK_RC_BASE}" | xargs)"
		hintstyle="$(awk -F'=' '/gtk-xft-hintstyle/ {print $2}' "${GTK_RC_BASE}" | xargs)"
		antialias="$(awk -F'=' '/gtk-xft-antialias/ {print $2}' "${GTK_RC_BASE}" | xargs)"
		menu_images="$(awk -F'=' '/gtk-menu-images/ {print $2}' "${GTK_RC_BASE}" | xargs)"
		hinting="$(awk -F'=' '/gtk-xft-hinting/ {print $2}' "${GTK_RC_BASE}" | xargs)"
		font_name="$(awk -F'=' '/gtk-font-name/ {print $2}' "${GTK_RC_BASE}" | xargs)"
		rgba="$(awk -F'=' '/gtk-xft-rgba/ {print $2}' "${GTK_RC_BASE}" | xargs)"
		gnome_schema="org.gnome.desktop.interface"

		md5sum_base=$(md5sum "$GTK_RC_BASE")

		if [ "${MD5SUM_BASE}" != "${md5sum_base}" ] || { [ "${xresources_xcursor_theme}" != "${XCURSOR_THEME}" ] || [ "${xresources_xcursor_size}" != "${XCURSOR_SIZE}" ]; }; then
			seq_fix 1 update_themes
			seq_fix 1 exec_reload_wm
			MD5SUM_BASE="$md5sum_base"
		fi

		sleep "$delay"
	done
}

if [[ -z "${1}" ]]; then
	help
	exit 0
fi

while [[ $# -gt 0 ]]; do
	case $1 in
		-o)
			only_xrdb
			shift
			continue
			;;
		-t)
			cursor_theme_fix
			shift
			continue
			;;
		*)
			help
			break
			;;
	esac
done

# Wait for all child processes to finish
wait
