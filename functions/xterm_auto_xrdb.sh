if [[ -z "$XTERM_VERSION" ]] && [[ -f ~/.Xresources ]]; then
	if [[ ! -f ~/.xrdb_check.lock ]]; then
		cp -f ~/.Xresources ~/.xrdb_check.lock
		xrdb -merge ~/.Xresources
	fi

	md5sum_xresources="$(md5sum ~/.Xresources | awk '{ print $1 }')"
	md5sum_xrdb_check="$(md5sum ~/.xrdb_check.lock | awk '{ print $1 }')"

	if [[ "$md5sum_xresources" != "$md5sum_xrdb_check" ]]; then
		cp -f ~/.Xresources ~/.xrdb_check.lock
		xrdb -merge ~/.Xresources
	fi

	unset md5sum_xresources
	unset md5sum_xrdb_check
elif [[ -n "$XTERM_VERSION" ]] && [[ -f ~/.Xresources ]]; then
	xrdb -merge ~/.Xresources
fi