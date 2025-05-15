#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script is to fix the mouse cursor theme.
# Cursor Theme fix for WMs: openbox, i3 and more...
# How to use lxappearance. No stress.
DOCUMENTATION

# Define a signal handler to capture SIGINT (Ctrl+C)
trap '(kill -- -$$) &>/dev/null' INT TERM #SIGHUP #SIGINT #SIGQUIT #SIGABRT #SIGKILL #SIGALRM #SIGTERM

XRESOURCES=~/.Xresources
XSETTINGSD=~/.config/xsettingsd/xsettingsd.conf
GTK_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0/settings.ini"
GTK4_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-4.0/settings.ini"
GTK2_RC_FILES="${HOME}/.gtkrc-2.0" #"${HOME}/.gtkrc-2.0:${XDG_CONFIG_HOME}/gtk-2.0/gtkrc:/etc/gtk-2.0/gtkrc"

GTK_RC_BASE="$GTK2_RC_FILES"
MD5SUM_BASE=$(md5sum "$GTK_RC_BASE")

delay=2.0

doc() {
	less -FX "$0" | head -n8 | tail -n3
	echo
}

help() {
	doc
	echo "Usage: ${0##*/} [args]

	-o,
		Only xrdb fix loop

	-t,
		Cursor theme and GTK theme fix loop"
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

nodiff_gtk3_gtk4() {
	if ! cmp -s "$GTK_RC_FILES" "$GTK4_RC_FILES"; then
		[[ -d ~/.config/gtk-4.0/ ]] && cp -f "$GTK_RC_FILES" "$GTK4_RC_FILES"
	fi
}

reload_wm() {
	if pgrep -x "awesome" >/dev/null; then
		awesome-client 'awesome.restart()'
	elif pgrep -x "openbox" >/dev/null; then
		openbox --reconfigure
	elif pgrep -x "sway" >/dev/null; then
		swaymsg reload
	fi
}

kill_wm() {
	if pgrep -x "awesome" >/dev/null; then
		awesome-client 'awesome.restart()'
	elif pgrep -x "openbox" >/dev/null; then
		openbox --reconfigure
	elif pgrep -x "sway" >/dev/null; then
		swaymsg reload
	fi
}

exec_reload_wm() {
	reload_wm &
	rwm_pid=$!
	wait "$rwm_pid"
}

reload_gtk() {
	# Try to recharge the gnome shell via d-bus (useful in gnome environments)
	if dbus-send --session --type=method_call --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:'global.reexec_self()' >/dev/null 2>&1; then
		echo "Gnome shell recharged via d-bus."
	else
		# Fallback: Sends Sighup to GTK processes (useful in WMS like Awesome/OpenBox/Sway)
		echo "Recharging GTK processes via SIGHUP ..."
		pkill -HUP -f "gtk"
		pkill -HUP -f "gtk3" 
		pkill -HUP -f "gtk4" 
		pkill -HUP -f gtk3-nocsd
		pkill -9 -f rofi
		dbus-send --session --type=signal / org.gtk.SettingsChanged string:gtk-modules
		dbus-send --session --type=signal / org.gtk.SettingsChanged string:gtk-xft-rgba
		dbus-send --session --type=signal / org.gtk.SettingsChanged string:gtk-font-name
		dbus-send --session --type=signal / org.gtk.SettingsChanged string:gtk-theme-name
		dbus-send --session --type=signal / org.gtk.SettingsChanged string:gtk-menu-images
		dbus-send --session --type=signal / org.gtk.SettingsChanged string:gtk-xft-hinting
		dbus-send --session --type=signal / org.gtk.SettingsChanged string:gtk-xft-hintstyle
		dbus-send --session --type=signal / org.gtk.SettingsChanged string:gtk-toolbar-style
		dbus-send --session --type=signal / org.gtk.SettingsChanged string:gtk-button-images
		dbus-send --session --type=signal / org.gtk.SettingsChanged string:gtk-xft-antialias
		dbus-send --session --type=signal / org.gtk.SettingsChanged string:gtk-icon-theme-name
		dbus-send --session --type=signal / org.gtk.SettingsChanged string:gtk-cursor-theme-name
		dbus-send --session --type=signal / org.gtk.SettingsChanged string:gtk-cursor-theme-size
		dbus-send --session --type=signal / org.gtk.SettingsChanged string:gtk-toolbar-icon-size
		dbus-send --session --type=signal / org.gtk.SettingsChanged string:gtk-enable-event-sounds
		dbus-send --session --type=signal / org.gtk.SettingsChanged string:gtk-enable-input-feedback-sounds
	fi
}

if_xsettingsd() {
	if command -v xsettingsd >/dev/null; then
		pkill -9 xsettingsd 2>/dev/null
		xsettingsd & disown
	else
		notify-send "Install xsettingsd"
	fi
}

qt_themes() {
	export QT_STYLE_OVERRIDE=gtk2  
	export QT_QPA_PLATFORMTHEME=gtk2 
	export XCURSOR_THEME="$XCURSOR_THEME"
	export XCURSOR_SIZE="$XCURSOR_SIZE"
	qt5ct --apply 2>/dev/null
	qt6ct --apply 2>/dev/null
}

update_themes() {
	nodiff_gtk3_gtk4
	# GTK Theme
	sed -i "/gtk-theme-name/c\gtk-theme-name=${GTK_THEME}" "${GTK_RC_FILES}"
	sed -i "/Net\/ThemeName/c\Net\/ThemeName \"${GTK_THEME}\"" "${XSETTINGSD}"
	# Cursor Theme
	sed -i "/^Xcursor\.theme/c\Xcursor.theme: ${XCURSOR_THEME}" "${XRESOURCES}"
	sed -i "/gtk-cursor-theme-name/c\gtk-cursor-theme-name=${XCURSOR_THEME}" "${GTK_RC_FILES}"
	sed -i "/Gtk\/CursorThemeName/c\Gtk\/CursorThemeName \"${XCURSOR_THEME}\"" "${XSETTINGSD}"
	# Cursor size
	sed -i "/^Xcursor\.size/c\Xcursor.size: ${XCURSOR_SIZE}" "${XRESOURCES}"
	sed -i "/Gtk\/CursorThemeSize/c\Gtk\/CursorThemeSize ${XCURSOR_SIZE}" "${XSETTINGSD}"
	sed -i "/gtk-cursor-theme-size/c\gtk-cursor-theme-size=${XCURSOR_SIZE}" "${GTK_RC_FILES}"
	# Icon theme
	sed -i "/gtk-icon-theme-name/c\gtk-icon-theme-name=${icon_theme}" "${GTK_RC_FILES}"
	sed -i "/Net\/IconThemeName/c\Net\/IconThemeName \"${icon_theme}\"" "${XSETTINGSD}"
	# GTK Font 
	sed -i "/gtk-font-name/c\gtk-font-name=${font_name}" "${GTK_RC_FILES}"
	sed -i "/Gtk\/FontName/c\Gtk\/FontName \"${font_name}\"" "${XSETTINGSD}"
	sed -i "/Xft\/Hinting/c\Xft\/Hinting \"${hinting}\"" "${XSETTINGSD}"
	sed -i "/gtk-xft-hinting/c\gtk-xft-hinting=${hinting}" "${GTK_RC_FILES}"
	sed -i "/Xft\/HintStyle/c\Xft\/HintStyle \"${hintstyle}\"" "${XSETTINGSD}"
	sed -i "/gtk-xft-hintstyle/c\gtk-xft-hintstyle=${hintstyle}" "${GTK_RC_FILES}"
	sed -i "/Xft\/Antialias/c\Xft\/Antialias \"${antialias}\"" "${XSETTINGSD}"
	sed -i "/gtk-xft-antialias/c\gtk-xft-antialias=${antialias}" "${GTK_RC_FILES}"
	sed -i "/Xft\/RGBA/c\Xft\/RGBA \"${rgba}\"" "${XSETTINGSD}"
	sed -i "/gtk-xft-rgba/c\gtk-xft-rgba=${rgba}" "${GTK_RC_FILES}"
	# GTK Others
	sed -i "/gtk-menu-images/c\gtk-menu-images=${menu_images}" "${GTK_RC_FILES}"
	sed -i "/gtk-button-images/c\gtk-button-images=${button_images}" "${GTK_RC_FILES}"
	sed -i "/gtk-toolbar-style/c\gtk-toolbar-style=${toolbar_style}" "${GTK_RC_FILES}"
	sed -i "/gtk-toolbar-icon-size/c\gtk-toolbar-icon-size=${toolbar_icon_size}" "${GTK_RC_FILES}"
	sed -i "/gtk-enable-event-sounds/c\gtk-enable-event-sounds=${feedback_sounds}" "${GTK_RC_FILES}"
	sed -i "/gtk-enable-input-feedback-sounds/c\gtk-enable-input-feedback-sounds=${event_sounds}" "${GTK_RC_FILES}"

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
	nodiff_gtk3_gtk4
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

cursor_theme_fix() {
	[[ ! -s "${XRESOURCES}" ]] && rm "${XRESOURCES}"
	[[ ! -f "${XRESOURCES}" ]] && wget -nc https://raw.githubusercontent.com/felipefacundes/dotfiles/master/config/.Xresources -O "${XRESOURCES}"
	[[ ! -d ~/.config/gtk-4.0/ ]] && mkdir -p ~/.config/gtk-4.0/

	[[ "${XDG_SESSION_TYPE,,}" == x11 ]] && ! pgrep -f xsettingsd >/dev/null && xsettingsd & disown

	while true
	do 
		GTK_THEME="$(awk -F'=' '/gtk-theme-name/ {print $2}' "${GTK_RC_BASE}" | xargs)"
		# ICON ...
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
