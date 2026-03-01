remove_extension() {
	cat <<-'EOF'
	# Remove extension tips - This guide presents professional techniques for file name manipulation in shell scripts, with special focus on removing file extensions. Each method includes practical examples with clearly demonstrated inputs and outputs.
	EOF
	clear
	if [[ "${LANG,,}" =~ pt_ ]]; then
		cat <<-'EOF'
		# Remoção de extensões - Este guia apresenta técnicas profissionais para manipulação de nomes de arquivos em scripts shell, 
		# com foco especial na remoção de extensões de arquivo. Cada método inclui exemplos práticos com entradas e saídas claramente demonstradas.

		# Remover extensão

		Exemplos:

		SCRIPT_NAME="${0##*/}"

		filename="arquivo.backup.tar.gz"
		echo "${filename%.*}"     # Saída: arquivo.backup.tar
		echo "${filename%%.*}"    # Saída: arquivo
		echo "${filename##*.}"    # Saída: gz

		EOF
        echo "Pressione qualquer tecla para exibir o help completo, exceto as setas."
        while true; do
            # Ler um caractere
            read -rs -n 1 key
            
            # Se for ESC (código 27)
            if [[ $key == $'\x1b' ]]; then
                # Ler próximo caractere com timeout pequeno
                read -rs -n 1 -t 0.1 key2
                
                if [[ $key2 == "[" ]]; then
                    read -rs -n 1 -t 0.1 key3
                    
                    case $key3 in
                        "A") : #printf '\033[1S'  # Sroll up
                            ;;
                        "B") : #printf '\033[1T'  # Scroll down
                            ;;
                    esac
                fi
            else
                break
            fi
        done
		#read -s -n 1 -rp "Pressione qualquer tecla, para exibir o help completo" >/dev/tty
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
        echo "Press any key to display the full help, except the arrows."
        while true; do
            # Read a character
            read -rs -n 1 key
            
            # If ESC (code 27)
            if [[ $key == $'\x1b' ]]; then
                # Read next character with small timeout
                read -rs -n 1 -t 0.1 key2
                
                if [[ $key2 == "[" ]]; then
                    read -rs -n 1 -t 0.1 key3
                    
                    case $key3 in
                        "A") : #printf '\033[1S'  # Sroll up
                            ;;
                        "B") : #printf '\033[1T'  # Scroll down
                            ;;
                    esac
                fi
            else
                break
            fi
        done
		#read -s -n 1 -rp "Press any key to display the full help" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/remove-extension.md
    fi
}