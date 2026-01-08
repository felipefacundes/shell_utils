tunnel_and_server() {
	cat <<-'EOF'
	# Complete Guide: Exposing Local Services with Tunnels (Free Alternatives to Ngrok), pinggy etc...
	EOF
	clear
	if [[ "${LANG,,}" =~ pt_ ]]; then
		cat <<-'EOF'
		# Guia Completo: Expondo Serviços Locais com Túneis (Alternativas Gratuitas ao Ngrok), pinggy etc...
	
		Exemplos:

		# Servidor do ComfyManager:

		ssh-keygen -t rsa -b 4096 -C "seu_email@exemplo.com"
		comfy-cli launch --background
		ssh -p 443 -R0:localhost:8188 a.pinggy.io

		EOF

		read -s -n 1 -rp "Pressione qualquer tecla, para exibir o help completo" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/tuneis_e_servidor.md
	else
		cat <<-'EOF'
		# Complete Guide: Exposing Local Services with Tunnels (Free Alternatives to Ngrok), pinggy etc...
		
		Examples:

		# ComfyManager server:

		ssh-keygen -t rsa -b 4096 -C "seu_email@exemplo.com"
		comfy-cli launch --background
		ssh -p 443 -R0:localhost:8188 a.pinggy.io

		EOF

		read -s -n 1 -rp "Press any key to display the full help" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/tunnel_and_server.md
    fi
}