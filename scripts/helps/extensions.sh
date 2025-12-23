remove_extension() {
	clear
    if [[ "${LANG,,}" =~ pt_ ]]; then
		cat <<-'EOF'
		# Remoção de extensões - Este guia apresenta técnicas profissionais para manipulação de nomes de arquivos em scripts shell, com foco especial na remoção de extensões de arquivo. Cada método inclui exemplos práticos com entradas e saídas claramente demonstradas.

		# Remover extensão

		Exemplos:

		SCRIPT_NAME="${0##*/}"

		filename="arquivo.backup.tar.gz"
		echo "${filename%.*}"     # Saída: arquivo.backup.tar
		echo "${filename%%.*}"    # Saída: arquivo
		echo "${filename##*.}"    # Saída: gz

		EOF

        read -s -n 1 -p "Pressione qualquer tecla, para exibir o help completo" >/dev/tty
        markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/remove-extension-pt.md
    else
		cat <<-'EOF'
		# Remove extension tips - This guide presents professional techniques for file name manipulation in shell scripts, with special focus on removing file extensions. Each method includes practical examples with clearly demonstrated inputs and outputs.

		# Remove extension

		Examples:

		SCRIPT_NAME="${0##*/}"

		filename="file.backup.tar.gz"
		echo "${filename%.*}"     # Output: file.backup.tar
		echo "${filename%%.*}"    # Output: file
		echo "${filename##*.}"    # Output: gz

		EOF
        read -s -n 1 -p "Press any key to display the full help" >/dev/tty
        markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/remove-extension.md
    fi
}