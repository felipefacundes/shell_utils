screen_help() {
	local biblack_on_cyan='\033[90;1;46m'
	local bigreen_on_bblack='\033[92;1;40m'
	local nc='\033[0m'
    
    cat <<-EOF | { echo -e "$(cat)"; }
	# Screen - Basic Quick Guide
	EOF
	clear
	if [[ "${LANG,,}" =~ pt_ ]]; then
		cat <<-EOF | { echo -e "$(cat)"; }
		# Screen - Guia Básico Rápido

		Exemplos:

		${biblack_on_cyan}# Criar nova sessão com nome${nc}
		${bigreen_on_bblack}screen -S minha-sessao${nc}
		${biblack_on_cyan}# Listar todas as sessões ativas${nc}
		${bigreen_on_bblack}screen -ls${nc}
		${biblack_on_cyan}# Reconectar a uma sessão existente${nc}
		${bigreen_on_bblack}screen -r minha-sessao${nc}
		${biblack_on_cyan}# Reconectar forçadamente (detach de outros lugares)${nc}
		${bigreen_on_bblack}screen -rD minha-sessao${nc}
		${biblack_on_cyan}# Compartilhar sessão com outro usuário${nc}
		${bigreen_on_bblack}screen -S minha-sessao -x${nc}
		${biblack_on_cyan}# Criar sessão sem attach (rodar em background)${nc}
		${bigreen_on_bblack}screen -dmS minha-sessao${nc}
		${biblack_on_cyan}# Rodar comando específico em nova sessão${nc}
		${bigreen_on_bblack}screen -dmS backup bash -c "./backup.sh"${nc}
		${biblack_on_cyan}# Encerrar sessão completamente${nc}
		${bigreen_on_bblack}screen -XS minha-sessao quit${nc}
		${biblack_on_cyan}# Remover sessões terminadas (zumbis)${nc}
		${bigreen_on_bblack}screen -wipe${nc}
		${biblack_on_cyan}# Criar nova janela dentro do screen${nc}
		${bigreen_on_bblack}Ctrl + A c${nc}
		${biblack_on_cyan}# Alternar para próxima janela${nc}
		${bigreen_on_bblack}Ctrl + A n${nc}
		${biblack_on_cyan}# Alternar para janela anterior${nc}
		${bigreen_on_bblack}Ctrl + A p${nc}
		${biblack_on_cyan}# Listar todas as janelas${nc}
		${bigreen_on_bblack}Ctrl + A "${nc}
		${biblack_on_cyan}# Ir para janela específica (0-9)${nc}
		${bigreen_on_bblack}Ctrl + A 3${nc}
		${biblack_on_cyan}# Detach (sair mantendo sessão ativa)${nc}
		${bigreen_on_bblack}Ctrl + A d${nc}
		${biblack_on_cyan}# Matar janela atual${nc}
		${bigreen_on_bblack}Ctrl + A k${nc}
		${biblack_on_cyan}# Dividir tela horizontalmente${nc}
		${bigreen_on_bblack}Ctrl + A S${nc}
		${biblack_on_cyan}# Alternar entre regiões${nc}
		${bigreen_on_bblack}Ctrl + A Tab${nc}
		${biblack_on_cyan}# Fechar região atual${nc}
		${bigreen_on_bblack}Ctrl + A X${nc}
		${biblack_on_cyan}# Renomear janela atual${nc}
		${bigreen_on_bblack}Ctrl + A A${nc}
		${biblack_on_cyan}# Modo scroll/copy (sair com Enter)${nc}
		${bigreen_on_bblack}Ctrl + A [${nc}
		${biblack_on_cyan}# Monitorar janela por atividade${nc}
		${bigreen_on_bblack}Ctrl + A M${nc}
		${biblack_on_cyan}# Monitorar janela por silêncio${nc}
		${bigreen_on_bblack}Ctrl + A _${nc}
		${biblack_on_cyan}# Mostrar hora atual${nc}
		${bigreen_on_bblack}Ctrl + A t${nc}
		${biblack_on_cyan}# Bloqueio de terminal${nc}
		${bigreen_on_bblack}Ctrl + A x${nc}
		${biblack_on_cyan}# Ajuda com todos os comandos${nc}
		${bigreen_on_bblack}Ctrl + A ?${nc}
		${biblack_on_cyan}# Sair completamente (mata todas as janelas)${nc}
		${bigreen_on_bblack}Ctrl + A \\${nc}
		${biblack_on_cyan}# Configuração avançada: Salvar layout das janelas${nc}
		${bigreen_on_bblack}Ctrl + A :layout save meu-layout${nc}
		${biblack_on_cyan}# Restaurar layout salvo${nc}
		${bigreen_on_bblack}Ctrl + A :layout load meu-layout${nc}
		${biblack_on_cyan}# Listar layouts salvos${nc}
		${bigreen_on_bblack}Ctrl + A :layout list${nc}
		${biblack_on_cyan}# Log de saída para arquivo${nc}
		${bigreen_on_bblack}Ctrl + A H${nc}
		${biblack_on_cyan}# Exportar variável de ambiente para todas as janelas${nc}
		${bigreen_on_bblack}Ctrl + A :setenv VAR valor${nc}
		${biblack_on_cyan}# Comandos úteis: rodar comando em todas as janelas${nc}
		${bigreen_on_bblack}Ctrl + A :at "#" stuff "comando\\n"${nc}
		${biblack_on_cyan}# Para trabalhar com múltiplos processos simultaneamente, use diferentes janelas:${nc}
		${bigreen_on_bblack}screen -S projeto${nc}
		${bigreen_on_bblack}Ctrl + A c  # janela 1: editor${nc}
		${bigreen_on_bblack}Ctrl + A c  # janela 2: logs${nc}
		${bigreen_on_bblack}Ctrl + A c  # janela 3: banco de dados${nc}
		${bigreen_on_cyan}# Para manter processo rodando após logout SSH:${nc}
		${bigreen_on_bblack}screen -dmS servidor bash -c "./iniciar_servidor.sh && tail -f /dev/null"${nc}
		${bigreen_on_cyan}# Para reattach posteriormente:${nc}
		${bigreen_on_bblack}screen -r servidor${nc}
		${bigreen_on_cyan}# Script para limpar sessões antigas (cuidado!):${nc}
		${bigreen_on_bblack}screen -ls | grep Detached | cut -d. -f1 | awk '{print \$1}' | xargs -I {} screen -XS {} quit${nc}
		${bigreen_on_cyan}# Criar sessão com configuração personalizada:${nc}
		${bigreen_on_bblack}screen -c ~/.screen_config_especial${nc}
		${bigreen_on_cyan}# Com múltiplos usuários no mesmo sistema, use -x para colaboração:${nc}
		${bigreen_on_bblack}screen -S sessao-compartilhada${nc}
		${bigreen_on_bblack}# Em outro terminal/usuário:${nc}
		${bigreen_on_bblack}screen -x sessao-compartilhada${nc}

		EOF

		read -s -n 1 -rp "Pressione qualquer tecla, para exibir o help completo" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/basico_de_screen.md
    else
		cat <<-EOF | { echo -e "$(cat)"; }
		# Screen - Quick Basic Guide

		Examples:

		${biblack_on_cyan}# Create new named session${nc}
		${bigreen_on_bblack}screen -S my-session${nc}
		${biblack_on_cyan}# List all active sessions${nc}
		${bigreen_on_bblack}screen -ls${nc}
		${biblack_on_cyan}# Reconnect to existing session${nc}
		${bigreen_on_bblack}screen -r my-session${nc}
		${biblack_on_cyan}# Forcefully reconnect (detach from other places)${nc}
		${bigreen_on_bblack}screen -rD my-session${nc}
		${biblack_on_cyan}# Share session with another user${nc}
		${bigreen_on_bblack}screen -S my-session -x${nc}
		${biblack_on_cyan}# Create session without attach (run in background)${nc}
		${bigreen_on_bblack}screen -dmS my-session${nc}
		${biblack_on_cyan}# Run specific command in new session${nc}
		${bigreen_on_bblack}screen -dmS backup bash -c "./backup.sh"${nc}
		${biblack_on_cyan}# Terminate session completely${nc}
		${bigreen_on_bblack}screen -XS my-session quit${nc}
		${biblack_on_cyan}# Remove terminated sessions (zombies)${nc}
		${bigreen_on_bblack}screen -wipe${nc}
		${biblack_on_cyan}# Create new window inside screen${nc}
		${bigreen_on_bblack}Ctrl + A c${nc}
		${biblack_on_cyan}# Switch to next window${nc}
		${bigreen_on_bblack}Ctrl + A n${nc}
		${biblack_on_cyan}# Switch to previous window${nc}
		${bigreen_on_bblack}Ctrl + A p${nc}
		${biblack_on_cyan}# List all windows${nc}
		${bigreen_on_bblack}Ctrl + A "${nc}
		${biblack_on_cyan}# Go to specific window (0-9)${nc}
		${bigreen_on_bblack}Ctrl + A 3${nc}
		${biblack_on_cyan}# Detach (exit keeping session active)${nc}
		${bigreen_on_bblack}Ctrl + A d${nc}
		${biblack_on_cyan}# Kill current window${nc}
		${bigreen_on_bblack}Ctrl + A k${nc}
		${biblack_on_cyan}# Split screen horizontally${nc}
		${bigreen_on_bblack}Ctrl + A S${nc}
		${biblack_on_cyan}# Switch between regions${nc}
		${bigreen_on_bblack}Ctrl + A Tab${nc}
		${biblack_on_cyan}# Close current region${nc}
		${bigreen_on_bblack}Ctrl + A X${nc}
		${biblack_on_cyan}# Rename current window${nc}
		${bigreen_on_bblack}Ctrl + A A${nc}
		${biblack_on_cyan}# Scroll/copy mode (exit with Enter)${nc}
		${bigreen_on_bblack}Ctrl + A [${nc}
		${biblack_on_cyan}# Monitor window for activity${nc}
		${bigreen_on_bblack}Ctrl + A M${nc}
		${biblack_on_cyan}# Monitor window for silence${nc}
		${bigreen_on_bblack}Ctrl + A _${nc}
		${biblack_on_cyan}# Show current time${nc}
		${bigreen_on_bblack}Ctrl + A t${nc}
		${biblack_on_cyan}# Terminal lock${nc}
		${bigreen_on_bblack}Ctrl + A x${nc}
		${biblack_on_cyan}# Help with all commands${nc}
		${bigreen_on_bblack}Ctrl + A ?${nc}
		${biblack_on_cyan}# Exit completely (kills all windows)${nc}
		${bigreen_on_bblack}Ctrl + A \\${nc}
		${biblack_on_cyan}# Advanced configuration: Save window layout${nc}
		${bigreen_on_bblack}Ctrl + A :layout save my-layout${nc}
		${biblack_on_cyan}# Restore saved layout${nc}
		${bigreen_on_bblack}Ctrl + A :layout load my-layout${nc}
		${biblack_on_cyan}# List saved layouts${nc}
		${bigreen_on_bblack}Ctrl + A :layout list${nc}
		${biblack_on_cyan}# Output log to file${nc}
		${bigreen_on_bblack}Ctrl + A H${nc}
		${biblack_on_cyan}# Export environment variable to all windows${nc}
		${bigreen_on_bblack}Ctrl + A :setenv VAR value${nc}
		${biblack_on_cyan}# Useful commands: run command in all windows${nc}
		${bigreen_on_bblack}Ctrl + A :at "#" stuff "command\\n"${nc}
		${biblack_on_cyan}# To work with multiple processes simultaneously, use different windows:${nc}
		${bigreen_on_bblack}screen -S project${nc}
		${bigreen_on_bblack}Ctrl + A c  # window 1: editor${nc}
		${bigreen_on_bblack}Ctrl + A c  # window 2: logs${nc}
		${bigreen_on_bblack}Ctrl + A c  # window 3: database${nc}
		${biblack_on_cyan}# To keep process running after SSH logout:${nc}
		${bigreen_on_bblack}screen -dmS server bash -c "./start_server.sh && tail -f /dev/null"${nc}
		${biblack_on_cyan}# To reattach later:${nc}
		${bigreen_on_bblack}screen -r server${nc}
		${biblack_on_cyan}# Script to clean old sessions (be careful!):${nc}
		${bigreen_on_bblack}screen -ls | grep Detached | cut -d. -f1 | awk '{print \$1}' | xargs -I {} screen -XS {} quit${nc}
		${biblack_on_cyan}# Create session with custom configuration:${nc}
		${bigreen_on_bblack}screen -c ~/.screen_custom_config${nc}
		${biblack_on_cyan}# With multiple users on same system, use -x for collaboration:${nc}
		${bigreen_on_bblack}screen -S shared-session${nc}
		${bigreen_on_bblack}# In another terminal/user:${nc}
		${bigreen_on_bblack}screen -x shared-session${nc}

		EOF

		read -s -n 1 -rp "Press any key to display the full help" >/dev/tty
		markdown_reader -nc -nf ~/.shell_utils/scripts/helps/markdowns/screen_basic.md
    fi
}