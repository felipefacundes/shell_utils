printer_share() {
	cat <<-'EOF'
	# Complete Tutorial: Printer Sharing via CUPS and Samba with UFW Firewall
	EOF
	clear
	if [[ "${LANG,,}" =~ pt_ ]]; then
		cat <<-'EOF'
		Primeiro, liste todas as impressoras instaladas no sistema:

		$ lpstat -p

		Exemplo de saída:

		printer HP-LaserJet-P1005 is idle. enabled since Thu 01 Jan 2026 10:00:00 AM -03

		Anote o nome exato da sua impressora (no exemplo: 'HP-LaserJet-P1005').

		# 1.2 Habilitar o Compartilhamento de Impressoras

		Ative o compartilhamento de impressoras no CUPS:

		$ cupsctl --share-printers

		> *Nota: Será solicitada a senha do usuário (a mesma usada para o 'sudo').

		# 1.3 Compartilhar a Impressora Específica

		Compartilhe a impressora identificada no passo anterior:

		lpadmin -p nome-da-impressora -o printer-is-shared=true

		EOF
        echo "Pressione qualquer tecla para exibir o help completo, exceto as setas."
        # Função para impedir que se use as setas
        no_arrow
		#read -s -n 1 -rp "Pressione qualquer tecla, para exibir o help completo" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/printers-pt.md
	else
		cat <<-'EOF'
		First, list all installed printers on the system:

		$ lpstat -p

		Example output:

		printer HP-LaserJet-P1005 is idle. enabled since Thu 01 Jan 2026 10:00:00 AM -03

		Note the exact name of your printer (in the example: 'HP-LaserJet-P1005').

		# 1.2 Enable Printer Sharing

		Enable printer sharing in CUPS:

		$ cupsctl --share-printers

		> *Note: You will be prompted for your user password (the same one used for 'sudo').

		# 1.3 Share the Specific Printer

		Share the printer identified in the previous step:

		$ lpadmin -p printer-name -o printer-is-shared=true


		EOF
        echo "Press any key to display the full help, except the arrows."
        # Função para impedir que se use as setas
        no_arrow
		#read -s -n 1 -rp "Press any key to display the full help" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/printers.md
    fi
}