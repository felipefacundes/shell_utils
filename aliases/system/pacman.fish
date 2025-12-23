if command -v pacman >/dev/null && test -d /var/cache/pacman/pkg/

	alias p='pacman'
	alias sp='sudo pacman'
	alias spS='sudo pacman -S'
	alias pSs='pacman -Ss'
	alias resolve_pacman='~/.shell_utils/scripts/pacman-resolve'
	alias pacman_error='resolve_pacman'
	alias pac_his='~/.shell_utils/scripts/pacman-history'
	alias pachis_ins='~/.shell_utils/scripts/pacman-history-installed-log'
	alias pachis_rem='~/.shell_utils/scripts/pacman-history-removed-log'
	alias pacman_remove_debug='help pacman_remove_debug'
	alias last_update='ls -lt --time-style=+%Y-%m-%d /var/cache/pacman/pkg/*.zst | grep $(date +%Y-%m-%d)'
	alias last_update2="ls -ltr --time-style=+%Y-%m-%d /var/cache/pacman/pkg/*.zst | grep -E '\b[0-9]{4}-[0-9]{2}-[0-9]{2}\b'"
    alias pacman_history_installed_today='last_update'
    alias pacman_history_installed_today2='last_update2'

	alias u='sudo pacman -Syyu --noconfirm --overwrite "*"'
	alias up="u"
	alias autoremove='sudo pacman -Rcs $(pacman -Qtdq)'

	alias undevel_packages='sudo pacman -Rcs autoconf texinfo pkgconf patch make m4 groff flex binutils automake autoconf gcc'
	alias devel_packages='sudo pacman -S autoconf texinfo pkgconf patch make m4 groff flex binutils automake autoconf gcc'

    if command -v yay >/dev/null
		alias ua='u; yay -Sua'
		alias sua='ua'
		alias Sua='ua'
    end
end
