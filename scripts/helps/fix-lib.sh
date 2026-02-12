fix_lib() {
	cat <<-'EOF'
	# If you are reading this because your system fails to boot with errors about '/lib', 'vfat', or 'mount.efi', you can fix it immediately from a live environment:
	EOF
	clear
	if [[ "${LANG,,}" =~ pt_ ]]; then
		cat <<-'EOF'
		# Se você está lendo isto porque seu sistema não inicializa com erros sobre '/lib', 'vfat' ou 'mount.efi', você pode corrigir imediatamente a partir de um ambiente live:

		# Monte sua partição raiz em /mnt
		mount /dev/sua_particao_raiz /mnt

		# Reinstale o pacote filesystem com o link simbólico correto
		pacman --sysroot /mnt -Syu filesystem

		# Se o comando acima falhar devido a conflitos, force a criação do link:
		pacman --sysroot /mnt -Syu --overwrite '/lib/*' filesystem

		# Or run the script as root, which fixes all the errors described above
		$ fix-lib-utils
		EOF

		read -s -n 1 -rp "Pressione qualquer tecla, para exibir o help completo" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/fix-lib-pt.md
	else
		cat <<-'EOF'
		# If you are reading this because your system fails to boot with errors about '/lib', 'vfat', or 'mount.efi', you can fix it immediately from a live environment:

		# Mount your root partition to /mnt
		mount /dev/your_root_partition /mnt

		# Reinstall filesystem package with correct /lib symlink
		pacman --sysroot /mnt -Syu filesystem

		# If the above fails due to conflicts, force the symlink creation:
		pacman --sysroot /mnt -Syu --overwrite '/lib/*' filesystem

		# Or run the script as root, which fixes all the errors described above
		$ fix-lib-utils
		EOF

		read -s -n 1 -rp "Press any key to display the full help" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/fix-lib.md
    fi
}