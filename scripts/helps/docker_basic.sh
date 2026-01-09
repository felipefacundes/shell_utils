docker_basic() {
	cat <<-'EOF'
	# Docker - Basic Quick Guide
	EOF
	clear
	if [[ "${LANG,,}" =~ pt_ ]]; then
		cat <<-'EOF'
		# Docker - Guia Básico Rápido
	
		Exemplos:

		# Cria e inicia um container interativamente
		docker run -it --name meu-container archlinux:latest bash
		# Ao sair de um container. Verificar se o container está ativo
		docker ps
		# Verificar containers parados
		docker ps -a
		# Iniciar o container parado
		docker start meu-container
		# E depois acessá-lo
		docker exec -it meu-container bash
		# Remover o container antigo
		docker rm meu-container
		# Ver quais imagens tem
		docker images
		# Remover a imagem
		docker rmi archlinux:latest
		# Remove todos containers parados
		docker container prune
		# Remove todas imagens não usadas
		docker image prune -a
		# Remove volumes não usados
		docker volume prune
		# Limpeza completa de tudo não usado
		docker system prune -a
		# Remover tudo de uma vez (nuclear option):
		# Para TODOS containers (cuidado!):
		docker rm -f $(docker ps -aq)
		# Para TODAS imagens (cuidado!):
		docker rmi -f $(docker images -q)
		# Ou o comando mais agressivo:
		docker system prune -a --volumes
		# Se quer testar algo temporário, use --rm para auto-remover ao sair:
		# Quando sair com exit, o container é automaticamente removido
		docker run -it --rm --name meu-container-temp archlinux:latest bash
		# Se quiser que o container continue rodando mesmo após sair do bash, inicie-o com um processo que não termine:
		docker run -d --name meu-container archlinux:latest tail -f /dev/null
		docker exec -it meu-container bash

		# Para executar o container com todas as permissões mas como usuário comum, você tem algumas opções:
		docker run -it --name meu-container --user $(id -u):$(id -g) archlinux:latest bash

		EOF

		read -s -n 1 -rp "Pressione qualquer tecla, para exibir o help completo" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/basico_de_docker.md
	else
		cat <<-'EOF'
		# Docker - Quick Basic Guide

		Examples:

		# Create and start a container interactively
		docker run -it --name my-container archlinux:latest bash
		# After exiting a container. Check if container is active
		docker ps
		# Check stopped containers
		docker ps -a
		# Start a stopped container
		docker start my-container
		# And then access it
		docker exec -it my-container bash
		# Remove old container
		docker rm my-container
		# Check which images you have
		docker images
		# Remove an image
		docker rmi archlinux:latest
		# Remove all stopped containers
		docker container prune
		# Remove all unused images
		docker image prune -a
		# Remove unused volumes
		docker volume prune
		# Complete cleanup of everything unused
		docker system prune -a
		# Remove everything at once (nuclear option):
		# For ALL containers (be careful!):
		docker rm -f $(docker ps -aq)
		# For ALL images (be careful!):
		docker rmi -f $(docker images -q)
		# Or the most aggressive command:
		docker system prune -a --volumes
		# If you want to test something temporarily, use --rm to auto-remove on exit:
		# When you exit with exit, the container is automatically removed
		docker run -it --rm --name my-container-temp archlinux:latest bash
		# If you want the container to keep running even after exiting bash, start it with a process that doesn't terminate:
		docker run -d --name my-container archlinux:latest tail -f /dev/null
		docker exec -it my-container bash

		# To run the container with all permissions but as a regular user, you have some options:
		docker run -it --name my-container --user $(id -u):$(id -g) archlinux:latest bash

		EOF

		read -s -n 1 -rp "Press any key to display the full help" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/docker_basic.md
    fi
}