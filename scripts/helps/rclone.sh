rclone_help() {
	cat <<-'EOF'
	# 'rclone' is a command-line program specifically built to sync files with cloud storage. Many call it the "rsync for cloud storage". It is the standard and most reliable tool for this task. Here is a step-by-step guide to set up and use 'rclone' to sync a local folder with Google Drive on Linux.
	EOF
	clear
	if [[ "${LANG,,}" =~ pt_ ]]; then
		cat <<-'EOF'
		# O 'rclone' é um programa de linha de comando criado especificamente para sincronizar arquivos com a nuvem. Muitos o chamam de "rsync for cloud storage". 
		# Ele é a ferramenta padrão e mais confiável para essa tarefa.

		$ rclone config
		# Usar copy é sempre a melhor opção, sync é destrutivo e bisync sempre da erro
		$ rclone copy /path/to/your/local/folder googleDrive:path/in/the/cloud # ->
		$ rclone copy googleDrive:path/in/the/cloud /path/to/your/local/folder # <-


		# FIX - Solução de Problemas na Configuração

		$ rclone listremotes
		$ rclone config show googleDrive:
		# Se estiver 'type = google cloud storage', está errado. O correto para o Google Drive é 'type = drive' (24).
		# Apague o remoto errado:
		$ rclone config delete googleDrive
		# Crie um novo remoto com o tipo correto:
		$ rclone config

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
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/rclone-pt.md
	else
		cat <<-'EOF'
		# 'rclone' is a command-line program specifically built to sync files with cloud storage. Many call it the "rsync for cloud storage". It is the standard and most reliable tool for this task. 
		# Here is a step-by-step guide to set up and use 'rclone' to sync a local folder with Google Drive on Linux.

		$ rclone config
		# Using copy is always the best option, sync is destructive, and bisync always gives errors
		$ rclone copy /path/to/your/local/folder googleDrive:path/in/the/cloud # ->
		$ rclone copy googleDrive:path/in/the/cloud /path/to/your/local/folder # <-

		# FIX - Configuration Troubleshooting

		$ rclone listremotes
		$ rclone config show googleDrive:
		# If it shows 'type = google cloud storage', it is wrong. The correct type for Google Drive is 'type = drive' (24).
		# Delete the wrong remote:
		$ rclone config delete googleDrive
		# Create a new remote with the correct type:
		$ rclone config

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
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/rclone.md
    fi
}