swap_help() {
	cat <<-'EOF'
	# Linux Swap File Setup Guide
	EOF
	clear
	if [[ "${LANG,,}" =~ pt_ ]]; then
		cat <<-'EOF'
		# Guia de Configuração de Arquivo de Swap no Linux

		Para criar e ativar um arquivo swap:

		sudo dd if=/dev/zero of=/swapfile bs=4M count=1024 oflag=direct,dsync status=progress && sync
		sudo chmod 600 /swapfile
		sudo mkswap /swapfile
		sudo swapon /swapfile

		sudo vim /etc/fstab
		# Adicione a seguinte linha no final do arquivo:
		/swapfile none swap defaults 0 0

		# Para Reduzir o swappiness (recomendado: 10-20)
		# Um valor baixo (ex.: '10') faz o kernel usar o swap somente quando realmente necessário:

		# Alterar temporariamente (válido até a reinicialização)
		sudo sysctl vm.swappiness=10

		# Alterar permanentemente
		echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.d/99-swappiness.conf

		EOF

		read -s -n 1 -rp "Pressione qualquer tecla, para exibir o help completo" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/swap-pt.md
	else
		cat <<-'EOF'
		# Linux Swap File Setup Guide

		# To create and activate a swap file:

		sudo dd if=/dev/zero of=/swapfile bs=4M count=1024 oflag=direct,dsync status=progress && sync
		sudo chmod 600 /swapfile
		sudo mkswap /swapfile
		sudo swapon /swapfile

		sudo vim /etc/fstab
		# Add the following line at the end of the file:
		/swapfile none swap defaults 0 0

		# To Reduce swappiness (recommended: 10-20)
		# A low value (e.g. '10') makes the kernel use swap only when really necessary:

		# Change temporarily (valid until reboot)
		sudo sysctl vm.swappiness=10

		# Change permanently
		echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.d/99-swappiness.conf

		EOF
		read -s -n 1 -rp "Press any key to display the full help" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/swap.md
    fi
}