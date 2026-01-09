docker_basic() {
    local biblack_on_cyan='\033[90;1;46m'
    local bigreen_on_bblack='\033[92;1;40m'
    local nc='\033[0m'
    
	cat <<-EOF | { echo -e "$(cat)"; }
	# Docker - Basic Quick Guide
	EOF
	clear
	if [[ "${LANG,,}" =~ pt_ ]]; then
		cat <<-EOF | { echo -e "$(cat)"; }
		# Docker - Guia Básico Rápido
	
		Exemplos:

		${biblack_on_cyan}# Cria e inicia um container interativamente${nc}
		${bigreen_on_bblack}docker run -it --name meu-container archlinux:latest bash${nc}
		${biblack_on_cyan}# Ao sair de um container. Verificar se o container está ativo${nc}
		${bigreen_on_bblack}docker ps${nc}
		${biblack_on_cyan}# Verificar containers parados${nc}
		${bigreen_on_bblack}docker ps -a${nc}
		${biblack_on_cyan}# Iniciar o container parado${nc}
		${bigreen_on_bblack}docker start meu-container${nc}
		${biblack_on_cyan}# E depois acessá-lo${nc}
		${bigreen_on_bblack}docker exec -it meu-container bash${nc}
		${biblack_on_cyan}# Remover o container antigo${nc}
		${bigreen_on_bblack}docker rm meu-container${nc}
		${biblack_on_cyan}# Ver quais imagens tem${nc}
		${bigreen_on_bblack}docker images${nc}
		${biblack_on_cyan}# Remover a imagem${nc}
		${bigreen_on_bblack}docker rmi archlinux:latest${nc}
		${biblack_on_cyan}# Remove todos containers parados${nc}
		${bigreen_on_bblack}docker container prune${nc}
		${biblack_on_cyan}# Remove todas imagens não usadas${nc}
		${bigreen_on_bblack}docker image prune -a${nc}
		${biblack_on_cyan}# Remove volumes não usados${nc}
		${bigreen_on_bblack}docker volume prune${nc}
		${biblack_on_cyan}# Limpeza completa de tudo não usado${nc}
		${bigreen_on_bblack}docker system prune -a${nc}
		${biblack_on_cyan}# Remover tudo de uma vez (nuclear option):${nc}
		${biblack_on_cyan}# Para TODOS containers (cuidado!):${nc}
		${bigreen_on_bblack}docker rm -f \$(docker ps -aq)${nc}
		${biblack_on_cyan}# Para TODAS imagens (cuidado!):${nc}
		${bigreen_on_bblack}docker rmi -f \$(docker images -q)${nc}
		${biblack_on_cyan}# Ou o comando mais agressivo:${nc}
		${bigreen_on_bblack}docker system prune -a --volumes${nc}
		${biblack_on_cyan}# Se quer testar algo temporário, use --rm para auto-remover ao sair:${nc}
		${biblack_on_cyan}# Quando sair com exit, o container é automaticamente removido${nc}
		${bigreen_on_bblack}docker run -it --rm --name meu-container-temp archlinux:latest bash${nc}
		${biblack_on_cyan}# Se quiser que o container continue rodando mesmo após sair do bash, inicie-o com um processo que não termine:${nc}
		${bigreen_on_bblack}docker run -d --name meu-container archlinux:latest tail -f /dev/null${nc}
		${bigreen_on_bblack}docker exec -it meu-container bash${nc}

		${biblack_on_cyan}# Para executar o container com todas as permissões mas como usuário comum, você tem algumas opções:${nc}
		${bigreen_on_bblack}docker run -it --name meu-container --user \$(id -u):\$(id -g) archlinux:latest bash${nc}

		EOF

		read -s -n 1 -rp "Pressione qualquer tecla, para exibir o help completo" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/basico_de_docker.md
	else
		cat <<-EOF | { echo -e "$(cat)"; }
		# Docker - Quick Basic Guide

		Examples:

		${biblack_on_cyan}# Create and start a container interactively${nc}
		${bigreen_on_bblack}docker run -it --name my-container archlinux:latest bash${nc}
		${biblack_on_cyan}# After exiting a container. Check if container is active${nc}
		${bigreen_on_bblack}docker ps${nc}
		${biblack_on_cyan}# Check stopped containers${nc}
		${bigreen_on_bblack}docker ps -a${nc}
		${biblack_on_cyan}# Start a stopped container${nc}
		${bigreen_on_bblack}docker start my-container${nc}
		${biblack_on_cyan}# And then access it${nc}
		${bigreen_on_bblack}docker exec -it my-container bash${nc}
		${biblack_on_cyan}# Remove old container${nc}
		${bigreen_on_bblack}docker rm my-container${nc}
		${biblack_on_cyan}# Check which images you have${nc}
		${bigreen_on_bblack}docker images${nc}
		${biblack_on_cyan}# Remove an image${nc}
		${bigreen_on_bblack}docker rmi archlinux:latest${nc}
		${biblack_on_cyan}# Remove all stopped containers${nc}
		${bigreen_on_bblack}docker container prune${nc}
		${biblack_on_cyan}# Remove all unused images${nc}
		${bigreen_on_bblack}docker image prune -a${nc}
		${biblack_on_cyan}# Remove unused volumes${nc}
		${bigreen_on_bblack}docker volume prune${nc}
		${biblack_on_cyan}# Complete cleanup of everything unused${nc}
		${bigreen_on_bblack}docker system prune -a${nc}
		${biblack_on_cyan}# Remove everything at once (nuclear option):${nc}
		${biblack_on_cyan}# For ALL containers (be careful!):${nc}
		${bigreen_on_bblack}docker rm -f \$(docker ps -aq)${nc}
		${biblack_on_cyan}# For ALL images (be careful!):${nc}
		${bigreen_on_bblack}docker rmi -f \$(docker images -q)${nc}
		${biblack_on_cyan}# Or the most aggressive command:${nc}
		${bigreen_on_bblack}docker system prune -a --volumes${nc}
		${biblack_on_cyan}# If you want to test something temporarily, use --rm to auto-remove on exit:${nc}
		${biblack_on_cyan}# When you exit with exit, the container is automatically removed${nc}
		${bigreen_on_bblack}docker run -it --rm --name my-container-temp archlinux:latest bash${nc}
		${biblack_on_cyan}# If you want the container to keep running even after exiting bash, start it with a process that doesn't terminate:${nc}
		${bigreen_on_bblack}docker run -d --name my-container archlinux:latest tail -f /dev/null${nc}
		${bigreen_on_bblack}docker exec -it my-container bash${nc}

		${biblack_on_cyan}# To run the container with all permissions but as a regular user, you have some options:${nc}
		${bigreen_on_bblack}docker run -it --name my-container --user \$(id -u):\$(id -g) archlinux:latest bash${nc}

		EOF

		read -s -n 1 -rp "Press any key to display the full help" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/docker_basic.md
    fi
}